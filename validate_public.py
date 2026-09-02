#!/usr/bin/env python3
"""Validate public documentation and static site routes."""

from html.parser import HTMLParser
from pathlib import Path
import re

ROOT=Path(__file__).parent
SITE=ROOT/"docs"


class PageParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.ids=set()
        self.references=[]

    def handle_starttag(self,tag,attrs):
        values=dict(attrs)
        if values.get("id"):
            self.ids.add(values["id"])
        attribute="href" if tag in {"a","link"} else "src" if tag in {"script","img"} else None
        if attribute and values.get(attribute):
            self.references.append(values[attribute])


pages={"/":SITE/"index.html","/mcp":SITE/"mcp.html"}
page_text={}
for route,page in pages.items():
    content=page.read_text(encoding="utf-8")
    page_text[route]=content
    parser=PageParser()
    parser.feed(content)
    for reference in parser.references:
        if reference.startswith(("http://","https://","mailto:")):
            continue
        if reference.startswith("#"):
            assert reference[1:] in parser.ids,f"Broken anchor on {route}: {reference}"
            continue
        path=reference.split("#",1)[0]
        if path in pages:
            continue
        target=SITE/path.lstrip("/")
        assert target.is_file(),f"Missing site asset on {route}: {reference}"

index=page_text["/"]

public_text="\n".join([
    (ROOT/"README.md").read_text(encoding="utf-8"),
    *page_text.values(),
])
for stale in ("94KB","94 KB","drop-in para","qualquer executor"):
    assert stale.lower() not in public_text.lower(),f"Stale public claim: {stale}"

icons_source=(ROOT/"Services"/"Icons.lua").read_text(encoding="utf-8")
registry_source=icons_source.split("local aliases =",1)[0]
official=[]
for line in registry_source.splitlines():
    match=re.match(r'\s+(?:\["([^"]+)"\]|([a-z][a-z0-9-]*))\s*=\s*"rbxassetid://\d+"',line)
    if match:
        official.append(match.group(1) or match.group(2))

assert len(official)>=100,"Icon registry fell below 100 official icons"
assert len(official)==len(set(official)),"Duplicate official icon name"

icon_docs=(ROOT/"Documentation"/"ICONS.md").read_text(encoding="utf-8")
undocumented=[name for name in official if f"`{name}`" not in icon_docs]
assert not undocumented,"Undocumented icons: " + ", ".join(undocumented)

bundle_size=(ROOT/"dist"/"Axiom.lua").stat().st_size
byte_claims=re.findall(r"(\d{1,3}(?:[.,]\d{3})+)\s*bytes",public_text)
assert byte_claims,"Missing public bundle size"
for claim in byte_claims:
    stated_size=int(re.sub(r"[.,]","",claim))
    assert stated_size==bundle_size,f"Stale bundle size: {claim} bytes"
print(f"Public validation passed: {len(official)} icons, {bundle_size} byte bundle")
