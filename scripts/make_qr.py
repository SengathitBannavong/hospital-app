#!/usr/bin/env python3
"""Generate QR codes for hospital map poi_codes (indoor "You are here" anchors).

Each QR encodes a plain poi_code string (e.g. "ENT-01"). The Flutter scanner
matches the scanned text against MapPoi.poiCode case-insensitively, so the
payload must be the bare code — no URL, JSON, or quotes.

Usage:
    pip install --user "qrcode[pil]"          # one-time

    # 1) explicit codes
    python3 scripts/make_qr.py ENT-01 WARD-A1 PHARM-01

    # 2) codes from a file (one per line, '#' comments allowed)
    python3 scripts/make_qr.py --file codes.txt

    # 3) pull codes from the backend get_nodes endpoint (uses BASE_URL in .env)
    python3 scripts/make_qr.py --fetch --map-id 1

Output (default ./scripts/qr_out):
    qr_<CODE>.png       one labeled QR per code
    qr_sheet.png        printable contact sheet of all codes

Options:
    --out DIR           output directory (default scripts/qr_out)
    --map-id N          map id for --fetch (default 1)
    --no-sheet          skip the combined contact sheet
"""
from __future__ import annotations

import argparse
import json
import os
import re
import sys
import urllib.request
from pathlib import Path

try:
    import qrcode
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit('Missing deps. Run:  pip install --user "qrcode[pil]"')

DEFAULT_CODES = ["ENT-01"]  # fallback so a first run still produces something
PROJECT_ROOT = Path(__file__).resolve().parent.parent


def read_base_url() -> str | None:
    """Return BASE_URL from .env, ignoring commented lines."""
    env = PROJECT_ROOT / ".env"
    if not env.exists():
        return None
    for line in env.read_text().splitlines():
        line = line.strip()
        if line.startswith("#") or "=" not in line:
            continue
        key, _, value = line.partition("=")
        if key.strip() == "BASE_URL":
            return value.strip().strip('"').strip("'")
    return None


def fetch_codes(map_id: int) -> list[str]:
    base = read_base_url()
    if not base:
        sys.exit("--fetch needs BASE_URL in .env")
    url = f"{base.rstrip('/')}/api/map/get_nodes?map_id={map_id}"
    print(f"fetching {url}")
    with urllib.request.urlopen(url, timeout=15) as resp:
        payload = json.load(resp)
    data = payload.get("data", payload)
    codes = [
        poi["poi_code"]
        for poi in data
        if isinstance(poi, dict) and poi.get("poi_code")
    ]
    if not codes:
        sys.exit("no poi_code values found in get_nodes response")
    return codes


def load_codes(args: argparse.Namespace) -> list[str]:
    if args.fetch:
        codes = fetch_codes(args.map_id)
    elif args.file:
        lines = Path(args.file).read_text().splitlines()
        codes = [ln.strip() for ln in lines if ln.strip() and not ln.startswith("#")]
    elif args.codes:
        codes = args.codes
    else:
        print("no codes given; using default", DEFAULT_CODES)
        codes = DEFAULT_CODES
    # de-dup, preserve order
    seen: set[str] = set()
    return [c for c in codes if not (c in seen or seen.add(c))]


def safe_name(code: str) -> str:
    return re.sub(r"[^A-Za-z0-9_-]+", "_", code)


def labeled_qr(code: str, box: int = 10, pad: int = 16) -> Image.Image:
    """QR image with the code printed underneath."""
    qr = qrcode.QRCode(box_size=box, border=2)
    qr.add_data(code)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white").convert("RGB")
    w, h = img.size
    font = ImageFont.load_default()
    label_h = 28
    canvas = Image.new("RGB", (w, h + label_h + pad), "white")
    canvas.paste(img, (0, 0))
    draw = ImageDraw.Draw(canvas)
    tw = draw.textlength(code, font=font)
    draw.text(((w - tw) / 2, h + pad / 2), code, fill="black", font=font)
    return canvas


def build_sheet(images: list[Image.Image], cols: int = 3, gap: int = 24) -> Image.Image:
    if not images:
        return Image.new("RGB", (1, 1), "white")
    cell_w = max(im.width for im in images)
    cell_h = max(im.height for im in images)
    rows = (len(images) + cols - 1) // cols
    sheet = Image.new(
        "RGB",
        (cols * cell_w + (cols + 1) * gap, rows * cell_h + (rows + 1) * gap),
        "white",
    )
    for i, im in enumerate(images):
        r, c = divmod(i, cols)
        x = gap + c * (cell_w + gap) + (cell_w - im.width) // 2
        y = gap + r * (cell_h + gap)
        sheet.paste(im, (x, y))
    return sheet


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate poi_code QR codes.")
    parser.add_argument("codes", nargs="*", help="poi_code values")
    parser.add_argument("--file", help="file with one poi_code per line")
    parser.add_argument("--fetch", action="store_true", help="pull codes from get_nodes")
    parser.add_argument("--map-id", type=int, default=1, help="map id for --fetch")
    parser.add_argument("--out", default=str(Path(__file__).parent / "qr_out"))
    parser.add_argument("--no-sheet", action="store_true", help="skip contact sheet")
    args = parser.parse_args()

    codes = load_codes(args)
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    images: list[Image.Image] = []
    for code in codes:
        img = labeled_qr(code)
        path = out / f"qr_{safe_name(code)}.png"
        img.save(path)
        images.append(img)
        print("wrote", path)

    if not args.no_sheet:
        sheet_path = out / "qr_sheet.png"
        build_sheet(images).save(sheet_path)
        print("wrote", sheet_path, f"({len(images)} codes)")


if __name__ == "__main__":
    main()
