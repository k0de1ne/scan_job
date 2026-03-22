import asyncio
import uuid
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from playwright.async_api import async_playwright
import os
import json
from urllib.parse import urlsplit, parse_qs, urlencode
import httpx

app = FastAPI()

# HH Android App Keys from hh-applicant-tool
ANDROID_CLIENT_ID = "HIOMIAS39CA9DICTA7JIO64LQKQJF5AGIK74G9ITJKLNEDAOH5FHS5G1JI7FOEGD"
ANDROID_CLIENT_SECRET = "V9M870DE342BGHFRUJ5FTCGCUA1482AN0DI8C5TFI9ULMA89H10N60NOP8I4JMVS"
HH_ANDROID_SCHEME = "hhandroid"

# Store active sessions
sessions = {}

class LoginPhoneRequest(BaseModel):
    phone: str

class LoginCodeRequest(BaseModel):
    session_id: str
    code: str

@app.get("/status/{session_id}")
async def get_status(session_id: str):
    if session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    return {"status": sessions[session_id].get("status")}

@app.post("/login/phone")
async def login_phone(req: LoginPhoneRequest):
    session_id = str(uuid.uuid4())
    
    playwright = await async_playwright().start()
    browser = await playwright.chromium.launch(headless=True)
    
    # Use Galaxy A55 profile as in hh-applicant-tool
    device = playwright.devices["Galaxy A55"]
    context = await browser.new_context(**device)
    page = await context.new_page()
    
    code_future = asyncio.get_event_loop().create_future()

    async def handle_request(request):
        url = request.url
        if url.startswith(f"{HH_ANDROID_SCHEME}://"):
            print(f"[{session_id}] Intercepted OAuth redirect: {url}")
            if not code_future.done():
                sp = urlsplit(url)
                code = parse_qs(sp.query).get("code", [None])[0]
                code_future.set_result(code)

    page.on("request", handle_request)

    sessions[session_id] = {
        "playwright": playwright,
        "browser": browser,
        "context": context,
        "page": page,
        "code_future": code_future,
        "status": "initializing"
    }

    try:
        # Construct OAuth URL
        auth_url = f"https://hh.ru/oauth/authorize?client_id={ANDROID_CLIENT_ID}&response_type=code"
        print(f"[{session_id}] Navigating to: {auth_url}")
        await page.goto(auth_url, wait_until="load")
        
        # New selectors from hh-applicant-tool
        SEL_LOGIN_INPUT = 'input[data-qa="login-input-username"]'
        SEL_PIN_CODE_INPUT = 'input[data-qa="magritte-pincode-input-field"]'
        
        await page.wait_for_selector(SEL_LOGIN_INPUT, timeout=15000)
        await page.fill(SEL_LOGIN_INPUT, req.phone)
        await page.keyboard.press("Enter")
        
        # Wait for OTP input
        try:
            await page.wait_for_selector(SEL_PIN_CODE_INPUT, timeout=15000)
            sessions[session_id]["status"] = "waiting_otp"
        except:
            # Check for captcha or password
            if await page.query_selector('input[data-qa="login-input-password"]'):
                sessions[session_id]["status"] = "waiting_password"
            else:
                sessions[session_id]["status"] = "error_otp_not_found"
                # await page.screenshot(path=f"error_{session_id}.png")
                raise Exception("OTP input not found. Possible captcha or block.")
        
        return {"session_id": session_id, "status": sessions[session_id]["status"]}
        
    except Exception as e:
        print(f"[{session_id}] Error: {str(e)}")
        await browser.close()
        await playwright.stop()
        del sessions[session_id]
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/login/code")
async def login_code(req: LoginCodeRequest):
    if req.session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    session = sessions[req.session_id]
    page = session["page"]
    code_future = session["code_future"]
    
    try:
        SEL_PIN_CODE_INPUT = 'input[data-qa="magritte-pincode-input-field"]'
        await page.fill(SEL_PIN_CODE_INPUT, req.code)
        await page.keyboard.press("Enter")
        
        print(f"[{req.session_id}] Waiting for OAuth code...")
        # The redirect should happen and handle_request will set the code_future
        try:
            auth_code = await asyncio.wait_for(code_future, timeout=30.0)
        except asyncio.TimeoutError:
            raise Exception("Timeout waiting for OAuth code redirect")

        print(f"[{req.session_id}] Code received: {auth_code}. Exchanging for tokens...")
        
        # Exchange code for tokens
        async with httpx.AsyncClient() as client:
            resp = await client.post("https://hh.ru/oauth/token", data={
                "client_id": ANDROID_CLIENT_ID,
                "client_secret": ANDROID_CLIENT_SECRET,
                "code": auth_code,
                "grant_type": "authorization_code"
            })
            tokens = resp.json()

        cookies = await session["context"].cookies()
        
        # Cleanup
        await session["browser"].close()
        await session["playwright"].stop()
        del sessions[req.session_id]
        
        return {
            "tokens": tokens,
            "cookies": cookies,
            "success": True
        }
    except Exception as e:
        print(f"[{req.session_id}] Error in login_code: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
