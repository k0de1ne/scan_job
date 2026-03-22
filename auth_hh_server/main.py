import asyncio
import uuid
import base64
import httpx
import os
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from playwright.async_api import async_playwright
from urllib.parse import urlsplit, parse_qs

app = FastAPI()

# HH Android App Keys (from hh-applicant-tool)
ANDROID_CLIENT_ID = "HIOMIAS39CA9DICTA7JIO64LQKQJF5AGIK74G9ITJKLNEDAOH5FHS5G1JI7FOEGD"
ANDROID_CLIENT_SECRET = "V9M870DE342BGHFRUJ5FTCGCUA1482AN0DI8C5TFI9ULMA89H10N60NOP8I4JMVS"
HH_ANDROID_SCHEME = "hhandroid"

# Selectors from hh-applicant-tool
SEL_LOGIN_INPUT = 'input[data-qa="login-input-username"]'
SEL_PIN_CODE_INPUT = 'input[data-qa="magritte-pincode-input-field"]'
SEL_CAPTCHA_IMAGE = 'img[data-qa="account-captcha-picture"]'
SEL_CAPTCHA_INPUT = 'input[data-qa="account-captcha-input"]'
SEL_PASSWORD_INPUT = 'input[data-qa="login-input-password"]'

# Store active sessions: session_id -> {browser, context, page, status, captcha_image, code_future}
sessions = {}

class LoginPhoneRequest(BaseModel):
    phone: str

class LoginCodeRequest(BaseModel):
    session_id: str
    code: str

class LoginCaptchaRequest(BaseModel):
    session_id: str
    captcha_text: str

async def check_for_captcha(session_id: str):
    """Checks if captcha is visible on the page and updates session state."""
    session = sessions[session_id]
    page = session["page"]
    
    try:
        captcha_element = await page.wait_for_selector(SEL_CAPTCHA_IMAGE, timeout=2000, state="visible")
        if captcha_element:
            print(f"[{session_id}] Captcha detected!")
            img_bytes = await captcha_element.screenshot()
            session["captcha_image"] = base64.b64encode(img_bytes).decode('utf-8')
            session["status"] = "waiting_captcha"
            return True
    except:
        pass
    return False

@app.get("/status/{session_id}")
async def get_status(session_id: str):
    if session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    session = sessions[session_id]
    return {
        "status": session["status"],
        "captcha_image": session.get("captcha_image")
    }

@app.post("/login/phone")
async def login_phone(req: LoginPhoneRequest):
    session_id = str(uuid.uuid4())
    
    playwright = await async_playwright().start()
    browser = await playwright.chromium.launch(headless=True)
    
    # Use mobile profile (Galaxy A55) to reduce bot detection
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
        "status": "initializing",
        "captcha_image": None
    }

    try:
        auth_url = f"https://hh.ru/oauth/authorize?client_id={ANDROID_CLIENT_ID}&response_type=code"
        print(f"[{session_id}] Navigating to: {auth_url}")
        await page.goto(auth_url, wait_until="load")
        
        await page.wait_for_selector(SEL_LOGIN_INPUT, timeout=15000)
        await page.fill(SEL_LOGIN_INPUT, req.phone)
        await page.keyboard.press("Enter")
        
        # Check if captcha appeared immediately
        if await check_for_captcha(session_id):
            return {"session_id": session_id, "status": "waiting_captcha", "captcha_image": sessions[session_id]["captcha_image"]}

        # Wait for either OTP input, Password input, or Captcha
        try:
            # We wait for any of these to appear
            await asyncio.wait([
                page.wait_for_selector(SEL_PIN_CODE_INPUT, state="visible"),
                page.wait_for_selector(SEL_PASSWORD_INPUT, state="visible"),
                page.wait_for_selector(SEL_CAPTCHA_IMAGE, state="visible")
            ], return_when=asyncio.FIRST_COMPLETED, timeout=10000)
        except:
            pass

        if await check_for_captcha(session_id):
            return {"session_id": session_id, "status": "waiting_captcha", "captcha_image": sessions[session_id]["captcha_image"]}

        if await page.query_selector(SEL_PIN_CODE_INPUT):
            sessions[session_id]["status"] = "waiting_otp"
        elif await page.query_selector(SEL_PASSWORD_INPUT):
            sessions[session_id]["status"] = "waiting_password"
        else:
            sessions[session_id]["status"] = "unknown_state"
            # Optional: save screenshot for debug
            # await page.screenshot(path=f"debug_{session_id}.png")

        return {"session_id": session_id, "status": sessions[session_id]["status"]}
        
    except Exception as e:
        print(f"[{session_id}] Error: {str(e)}")
        await browser.close()
        await playwright.stop()
        if session_id in sessions: del sessions[session_id]
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/login/captcha")
async def login_captcha(req: LoginCaptchaRequest):
    if req.session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    session = sessions[req.session_id]
    page = session["page"]
    
    try:
        await page.fill(SEL_CAPTCHA_INPUT, req.captcha_text)
        await page.keyboard.press("Enter")
        session["captcha_image"] = None
        
        # Wait a bit to see what happens after captcha
        await asyncio.sleep(3)
        
        if await check_for_captcha(req.session_id):
            return {"status": "waiting_captcha", "captcha_image": session["captcha_image"]}
        
        if await page.query_selector(SEL_PIN_CODE_INPUT):
            session["status"] = "waiting_otp"
        elif await page.query_selector(SEL_PASSWORD_INPUT):
            session["status"] = "waiting_password"
        else:
            session["status"] = "check_status"
            
        return {"status": session["status"]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/login/code")
async def login_code(req: LoginCodeRequest):
    if req.session_id not in sessions:
        raise HTTPException(status_code=404, detail="Session not found")
    
    session = sessions[req.session_id]
    page = session["page"]
    code_future = session["code_future"]
    
    try:
        # Check if we are at OTP or Password stage
        if await page.query_selector(SEL_PIN_CODE_INPUT):
            await page.fill(SEL_PIN_CODE_INPUT, req.code)
            await page.keyboard.press("Enter")
        elif await page.query_selector(SEL_PASSWORD_INPUT):
            await page.fill(SEL_PASSWORD_INPUT, req.code) # Here 'code' is used as password
            await page.keyboard.press("Enter")
        
        print(f"[{req.session_id}] Waiting for OAuth code redirect...")
        try:
            auth_code = await asyncio.wait_for(code_future, timeout=30.0)
        except asyncio.TimeoutError:
            # Check if captcha appeared again
            if await check_for_captcha(req.session_id):
                 return {"status": "waiting_captcha", "captcha_image": session["captcha_image"]}
            raise Exception("Timeout waiting for OAuth redirect. Check if code/password is correct.")

        print(f"[{req.session_id}] Exchanging code for tokens...")
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
        
        return {"tokens": tokens, "cookies": cookies, "success": True}
    except Exception as e:
        print(f"[{req.session_id}] Error: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
