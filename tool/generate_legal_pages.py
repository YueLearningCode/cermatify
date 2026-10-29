"""Generate public, login-free HTML from the same legal content bundled in Flutter."""
import html
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / "web" / "legal"
TARGET.mkdir(parents=True, exist_ok=True)
for source in sorted((ROOT / "assets" / "legal").glob("*.json")):
    document = json.loads(source.read_text(encoding="utf-8"))
    sections = "".join(
        f"<section><h2>{html.escape(item['title'])}</h2><p>{html.escape(item['body'])}</p></section>"
        for item in document["sections"]
    )
    action = ""
    if source.stem == "delete-account":
        action = '<p><a class="button" href="mailto:cermatifycompany@gmail.com?subject=Permintaan%20penghapusan%20akun%20Cermatify">Kirim permintaan melalui email</a></p><p>Atau kirim manual ke <strong>cermatifycompany@gmail.com</strong>. Gunakan email yang terdaftar. Jangan kirim password atau OTP.</p>'
    page = f'''<!doctype html>
<html lang="id"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>{html.escape(document['title'])}</title>
<style>body{{font:16px/1.7 system-ui,sans-serif;background:#f8fafc;color:#172033;margin:0}}main{{max-width:800px;margin:auto;padding:28px 20px}}h1{{line-height:1.25}}h2{{font-size:20px;margin-top:28px}}a{{color:#0868cb;overflow-wrap:anywhere}}nav{{display:flex;flex-wrap:wrap;gap:20px}}.button{{display:inline-block;background:#0868cb;color:white;padding:12px 18px;border-radius:10px}}a:focus-visible{{outline:3px solid #172033;outline-offset:4px}}</style>
</head><body><main><a href="/">Cermatify</a><h1>{html.escape(document['title'])}</h1><p>Diperbarui {html.escape(document['updated'])}</p>
{sections}{action}<hr><nav><a href="privacy.html">Kebijakan privasi</a><a href="terms.html">Syarat dan ketentuan</a><a href="delete-account.html">Hapus akun dan data</a></nav></main></body></html>
'''
    (TARGET / f"{source.stem}.html").write_text(page, encoding="utf-8")
print("Generated 3 public legal pages in web/legal")
