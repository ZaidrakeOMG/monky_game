#!/usr/bin/env python3
"""Deterministic inventory, duplicate detection and PNG validation (stdlib only).
Literal references are NOT a reachability graph: runtime catalogs/directories exist.
"""
from __future__ import annotations
import argparse
import collections
import hashlib
import json
from pathlib import Path
import re
import struct
import zlib

ROOT = Path(__file__).resolve().parents[1]
SKIP = {".git", ".godot", "reports", "__pycache__"}
TEXT = {".gd", ".tscn", ".tres", ".gdshader", ".godot"}
IMAGES = {".png", ".jpg", ".jpeg", ".webp", ".svg"}

def png_error(data: bytes) -> str:
    if not data.startswith(b"\x89PNG\r\n\x1a\n"):
        return "invalid PNG signature"
    offset = 8
    while offset + 12 <= len(data):
        length = struct.unpack(">I", data[offset:offset + 4])[0]
        end = offset + 12 + length
        if end > len(data):
            return "truncated PNG chunk"
        chunk = data[offset + 4:offset + 8 + length]
        crc = struct.unpack(">I", data[offset + 8 + length:end])[0]
        if zlib.crc32(chunk) & 0xffffffff != crc:
            return "CRC mismatch: " + chunk[:4].decode("ascii", "replace")
        if chunk[:4] == b"IEND":
            return "" if end == len(data) else "unexpected bytes after IEND"
        offset = end
    return "missing IEND"

def audit() -> dict:
    files = sorted(p for p in ROOT.rglob("*") if p.is_file() and not (set(p.relative_to(ROOT).parts) & SKIP))
    ignored = {p.parent for p in files if p.name == ".gdignore"}
    def inactive(p: Path) -> bool:
        return any(parent == p.parent or parent in p.parents for parent in ignored)
    inventory, image_hashes, source = [], collections.defaultdict(list), {}
    for p in files:
        relative = p.relative_to(ROOT).as_posix()
        entry = {"path": relative, "bytes": p.stat().st_size, "ignored_by_godot": inactive(p)}
        if p.suffix.lower() in IMAGES:
            raw = p.read_bytes()
            entry["sha256"] = hashlib.sha256(raw).hexdigest()
            image_hashes[entry["sha256"]].append(relative)
            if p.suffix.lower() == ".png":
                entry["png_error"] = png_error(raw)
        if p.suffix in TEXT and not inactive(p) and not relative.startswith("tests/"):
            source[relative] = p.read_text(encoding="utf-8")
        inventory.append(entry)
    refs = collections.defaultdict(list)
    emoji = []
    for path, text in source.items():
        for line_number, line in enumerate(text.splitlines(), 1):
            for match in re.finditer(r'res://([^"\'\n]+)', line):
                value = match.group(1)
                refs[value].append(f"{path}:{line_number}")
            symbols = sorted(set(c for c in line if 0x1F000 <= ord(c) <= 0x1FAFF or 0x2600 <= ord(c) <= 0x27BF))
            if symbols:
                emoji.append({"location": f"{path}:{line_number}", "symbols": "".join(symbols)})
    images = [e for e in inventory if Path(e["path"]).suffix.lower() in IMAGES]
    damaged = [e for e in images if e.get("png_error")]
    candidates = [e["path"] for e in images if not e["ignored_by_godot"] and e["path"] not in refs]
    return {"scope": "All repository files excluding engine/git caches and generated reports; missing literal references are advisory for dynamic paths.",
        "file_count": len(files), "source_script_count": sum(p.endswith(".gd") for p in source),
        "scene_count": sum(p.suffix == ".tscn" for p in files), "image_count": len(images),
        "damaged_images": damaged, "active_png_errors": [e for e in damaged if not e["ignored_by_godot"]],
        "duplicate_image_groups": [v for v in image_hashes.values() if len(v) > 1],
        "unreferenced_literal_image_candidates": candidates,
        "unicode_emoji_locations": emoji,
        "literal_missing_references": {k:v for k,v in refs.items() if not (ROOT/k).exists() and not any(t in k for t in ["%", "{", "\\", "*"])},
        "inventory": inventory}

def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT/"reports"/"asset-audit.json")
    args = parser.parse_args()
    data = audit()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(data, ensure_ascii=False, indent=2)+"\n", encoding="utf-8")
    print(f"ASSET_AUDIT: {data['source_script_count']} runtime scripts, {data['scene_count']} scenes, {data['image_count']} images, {len(data['active_png_errors'])} active PNG errors, {len(data['damaged_images'])} quarantined/damaged images")
    return 1 if data["active_png_errors"] else 0

if __name__ == "__main__":
    raise SystemExit(main())
