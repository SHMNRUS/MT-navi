#!/usr/bin/env python3
"""Добавляет (или обновляет) регион в maps/regions.json: считает размер и sha256 готового файла .pmtiles.

Пример:
  python3 maps/add_region.py moscow.pmtiles --name "Москва и область" \
      --url https://github.com/SHMNRUS/MT-navi/releases/download/maps-1/moscow.pmtiles
id берётся из имени файла (moscow.pmtiles -> moscow), можно задать --id.
"""
import argparse, hashlib, json, os, re, sys

p = argparse.ArgumentParser()
p.add_argument("file")
p.add_argument("--name", required=True)
p.add_argument("--url", required=True)
p.add_argument("--id")
p.add_argument("--json", default=os.path.join(os.path.dirname(os.path.abspath(__file__)), "regions.json"))
a = p.parse_args()

if not a.url.startswith("https://"):
    sys.exit("ссылка должна начинаться с https://")
with open(a.file, "rb") as f:
    head = f.read(8)
if head[:7] != b"PMTiles" or head[7] != 3:
    sys.exit("это не PMTiles версии 3")

h = hashlib.sha256()
with open(a.file, "rb") as f:
    for chunk in iter(lambda: f.read(1 << 20), b""):
        h.update(chunk)
rid = a.id or re.sub(r"[^a-z0-9_-]+", "_", os.path.basename(a.file).rsplit(".", 1)[0].lower()).strip("_")
entry = {"id": rid, "name": a.name, "url": a.url,
         "size_mb": max(1, round(os.path.getsize(a.file) / 1048576)), "sha256": h.hexdigest()}

try:
    data = json.load(open(a.json, encoding="utf-8"))
except FileNotFoundError:
    data = {"regions": []}
data["regions"] = [r for r in data["regions"] if r.get("id") != rid] + [entry]
with open(a.json, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
    f.write("\n")
print("добавлено:", entry)
