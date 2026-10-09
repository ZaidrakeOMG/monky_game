#!/usr/bin/env python3
"""Import + executable regression/navigation tests in disposable save directories.
Usage: python tools/run_checks.py --godot /path/to/godot
Runs headless (not an Android/GPU performance benchmark). Python stdlib only.
"""
from __future__ import annotations
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile

ROOT = Path(__file__).resolve().parents[1]

def inspect_log(text: str, marker: str = "") -> list[str]:
    issues = []
    expected_corruption = False
    for line in text.splitlines():
        if line == "EXPECTED_CORRUPTION_BEGIN":
            expected_corruption = True
        elif line == "EXPECTED_CORRUPTION_END":
            expected_corruption = False
        elif "SCRIPT ERROR:" in line or "ASSERTION FAILED" in line or "Parse Error:" in line:
            issues.append(line)
        elif "ERROR:" in line and not (expected_corruption and "ConfigFile parse error" in line):
            issues.append(line)
    if expected_corruption:
        issues.append("Unclosed expected-corruption diagnostic block")
    if marker and not re.search(marker, text):
        issues.append("Missing successful completion marker")
    return issues

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    parser.add_argument("--skip-import", action="store_true")
    args = parser.parse_args()
    reports = ROOT/"reports"
    reports.mkdir(exist_ok=True)
    results = []
    with tempfile.TemporaryDirectory(prefix="monky-ci-") as temporary:
        base_env = dict(os.environ, GODOT_SILENCE_ROOT_WARNING="1", MONKY_TEST_MODE="1")
        commands = []
        if not args.skip_import:
            commands.append(("import", ["--editor", "--import"], 240, ""))
        commands.extend([
            ("regression", ["--script", "tests/regression.gd"], 120, r"MONKY_REGRESSION: (?:11[4-9]|1[2-9]\d|[2-9]\d{2,}) checks, 0 failures"),
            ("navigation", ["--script", "tests/navigation.gd"], 120, r"MONKY_NAVIGATION: 9 transitions, 0 failures")])
        for name, options, timeout, marker in commands:
            isolated = str(Path(temporary)/name)
            env = dict(base_env, XDG_DATA_HOME=isolated, APPDATA=isolated)
            try:
                completed = subprocess.run([args.godot, "--headless", "--path", str(ROOT), *options], env=env,
                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, timeout=timeout, check=False)
                text, code = completed.stdout, completed.returncode
            except (OSError, subprocess.TimeoutExpired) as error:
                text, code = str(error), 1
            (reports/f"{name}.log").write_text(text, encoding="utf-8")
            errors = inspect_log(text, marker)
            warnings = [line for line in text.splitlines() if "WARNING:" in line]
            ok = code == 0 and not errors
            results.append({"test": name, "passed": ok, "exit_code": code, "errors": errors, "warnings": warnings})
            print(f"{name}: {'PASS' if ok else 'FAIL'} ({len(warnings)} warnings retained in report)")
            if not ok:
                print(text[-8000:])
                break
    (reports/"checks.json").write_text(json.dumps(results, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
    return 0 if all(result["passed"] for result in results) and len(results) >= (2 if args.skip_import else 3) else 1

if __name__ == "__main__":
    raise SystemExit(main())
