#!/usr/bin/env python3
"""
Coverage Analyzer for Flutter/Dart projects
Run: python run_analysis.py

Shows line coverage, branch coverage, and uncovered code details.
"""

import subprocess
import re
import os
import sys
from pathlib import Path

PROJECT_ROOT = Path(__file__).parent.parent.parent
COVERAGE_DIR = PROJECT_ROOT / "coverage"
COVERAGE_FILE = COVERAGE_DIR / "lcov.info"
LIB_DIR = PROJECT_ROOT / "lib"


def run_tests_with_coverage():
    """Run flutter/dart tests with coverage."""
    print("Running tests with coverage...")
    print("-" * 50)
    
    result = subprocess.run(
        "flutter test --coverage",
        cwd=PROJECT_ROOT,
        shell=True,
        capture_output=True,
        text=True
    )
    
    if "Some tests failed" in result.stdout or result.returncode != 0:
        print("Warning: Some tests failed")
        print(result.stdout[-500:] if len(result.stdout) > 500 else result.stdout)
    else:
        print("All tests passed!")
    
    return COVERAGE_FILE.exists()


def parse_lcov_file(filepath):
    """Parse lcov.info and extract coverage data."""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    blocks = content.split('SF:')[1:]
    
    results = []
    
    for block in blocks:
        lines = block.split('\n')
        sf = lines[0]
        
        covered_lines = 0
        total_lines = 0
        
        branches = {}
        uncovered_branches_detail = []
        
        uncovered_lines_detail = []
        
        for line in lines[1:]:
            if line.startswith('DA:'):
                parts = line[3:].split(',')
                line_num = int(parts[0])
                hit = int(parts[1])
                total_lines += 1
                if hit > 0:
                    covered_lines += 1
                else:
                    uncovered_lines_detail.append(line_num)
                    
            elif line.startswith('BRDA:'):
                parts = line[5:].split(',')
                if len(parts) >= 4:
                    line_num = int(parts[0])
                    block_id = parts[1]
                    branch_id = parts[2]
                    hit = int(parts[3])
                    key = (line_num, block_id, branch_id)
                    
                    if key not in branches:
                        branches[key] = hit
                    elif hit > branches[key]:
                        branches[key] = hit
        
        line_pct = (covered_lines / total_lines * 100) if total_lines > 0 else 0
        
        total_branches = len(branches)
        hit_branches = len([h for h in branches.values() if h > 0])
        branch_pct = (hit_branches / total_branches * 100) if total_branches > 0 else 0
        
        results.append({
            'file': sf,
            'covered_lines': covered_lines,
            'total_lines': total_lines,
            'line_pct': line_pct,
            'hit_branches': hit_branches,
            'total_branches': total_branches,
            'branch_pct': branch_pct,
            'uncovered_lines': uncovered_lines_detail,
        })
    
    return results


def read_source_file(filepath, uncovered_lines):
    """Read source file and return uncovered code snippets."""
    try:
        full_path = Path(filepath)
        if not full_path.exists():
            return {}
        
        with open(full_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        result = {}
        for line_num in uncovered_lines:
            if 1 <= line_num <= len(lines):
                result[line_num] = lines[line_num - 1].rstrip()
        
        return result
    except Exception:
        return {}


def print_report(results):
    """Print formatted coverage report."""
    total_lines = sum(r['total_lines'] for r in results)
    total_covered = sum(r['covered_lines'] for r in results)
    total_branches = sum(r['total_branches'] for r in results)
    total_hit_branches = sum(r['hit_branches'] for r in results)
    
    overall_line_pct = (total_covered / total_lines * 100) if total_lines > 0 else 0
    overall_branch_pct = (total_hit_branches / total_branches * 100) if total_branches > 0 else 0
    
    print()
    print("=" * 80)
    print("COVERAGE REPORT".center(80))
    print("=" * 80)
    print()
    print(f"{'OVERALL COVERAGE':^80}")
    print("-" * 80)
    print(f"  Line Coverage:    {overall_line_pct:>6.1f}%  ({total_covered}/{total_lines} lines)")
    print(f"  Branch Coverage:  {overall_branch_pct:>6.1f}%  ({total_hit_branches}/{total_branches} branches)")
    print()
    
    sorted_by_line = sorted(results, key=lambda x: x['line_pct'])
    sorted_by_branch = sorted(results, key=lambda x: x['branch_pct'])
    
    print()
    print(f"{'LINE COVERAGE (sorted by coverage %)':^80}")
    print("-" * 80)
    print(f"{'File':<50} {'Lines':>10} {'Covered':>8} {'%':>6}")
    print("-" * 80)
    
    for r in sorted_by_line:
        filename = r['file'].split('\\')[-1] if '\\' in r['file'] else r['file'].split('/')[-1]
        status = 'OK' if r['line_pct'] >= 80 else ('WARN' if r['line_pct'] >= 50 else 'LOW')
        print(f"{filename:<50} {r['total_lines']:>10} {r['covered_lines']:>8} {r['line_pct']:>5.1f}% [{status}]")
    
    print()
    print(f"{'BRANCH COVERAGE (sorted by coverage %)':^80}")
    print("-" * 80)
    print(f"{'File':<50} {'Branches':>10} {'Hit':>8} {'%':>6}")
    print("-" * 80)
    
    for r in sorted_by_branch:
        filename = r['file'].split('\\')[-1] if '\\' in r['file'] else r['file'].split('/')[-1]
        status = 'OK' if r['branch_pct'] >= 80 else ('WARN' if r['branch_pct'] >= 50 else 'LOW')
        print(f"{filename:<50} {r['total_branches']:>10} {r['hit_branches']:>8} {r['branch_pct']:>5.1f}% [{status}]")
    
    print()
    print("=" * 80)
    print("UNCOVERED CODE DETAILS".center(80))
    print("=" * 80)
    
    low_coverage = [r for r in results if r['line_pct'] < 80]
    
    for r in low_coverage[:10]:
        filename = r['file'].split('\\')[-1] if '\\' in r['file'] else r['file'].split('/')[-1]
        print()
        print(f"FILE: {filename}")
        print(f"  Line coverage: {r['line_pct']:.1f}% ({r['covered_lines']}/{r['total_lines']})")
        print(f"  Branch coverage: {r['branch_pct']:.1f}% ({r['hit_branches']}/{r['total_branches']})")
        
        if r['uncovered_lines']:
            print(f"  Uncovered lines: {len(r['uncovered_lines'])}")
            source_lines = read_source_file(r['file'], r['uncovered_lines'][:10])
            for line_num in sorted(r['uncovered_lines'][:10]):
                if line_num in source_lines:
                    code = source_lines[line_num][:70] + ('...' if len(source_lines[line_num]) > 70 else '')
                    print(f"    {line_num:>4}: {code}")
            if len(r['uncovered_lines']) > 10:
                print(f"    ... and {len(r['uncovered_lines']) - 10} more lines")
    
    if len(low_coverage) > 10:
        print()
        print(f"... and {len(low_coverage) - 10} more files with coverage < 80%")
    
    print()
    print("=" * 80)
    print("RECOMMENDATIONS".center(80))
    print("=" * 80)
    
    critical = [r for r in results if r['line_pct'] < 50]
    if critical:
        print()
        print("Priority files to add tests (coverage < 50%):")
        for r in critical[:5]:
            filename = r['file'].split('\\')[-1] if '\\' in r['file'] else r['file'].split('/')[-1]
            print(f"  - {filename}: {r['line_pct']:.1f}%")
    
    print()
    print("To view full coverage details, open: coverage/lcov.info")
    print("For HTML report, install lcov: choco install lcov")
    print()


def main(skip_tests=False):
    print("Flutter/Dart Coverage Analyzer")
    print("=" * 50)
    
    if not skip_tests and not COVERAGE_FILE.exists():
        if not run_tests_with_coverage():
            print("Warning: Tests had failures, but using existing coverage data if available")
    
    if not COVERAGE_FILE.exists():
        print("Error: No coverage data found. Run 'flutter test --coverage' first.")
        sys.exit(1)
    
    results = parse_lcov_file(COVERAGE_FILE)
    
    if not results:
        print("Error: Failed to parse coverage data")
        sys.exit(1)
    
    print_report(results)


if __name__ == "__main__":
    skip = "--skip-tests" in sys.argv
    main(skip_tests=skip)


if __name__ == "__main__":
    main()
