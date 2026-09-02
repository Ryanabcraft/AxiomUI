#!/usr/bin/env python3
"""Build the modular Axiom package into one loadstring-compatible Luau file."""
from pathlib import Path
import re

ROOT=Path(__file__).parent
OUT=ROOT/"dist"/"Axiom.lua"
MODULES=[p for p in ROOT.rglob("*.lua") if "dist" not in p.parts and "Examples" not in p.parts]

def module_id(path: Path) -> str:
    rel=path.relative_to(ROOT).with_suffix("")
    return "init" if rel.as_posix()=="init" else rel.as_posix()

def resolve(current: str, expression: str) -> str:
    parts=[] if current=="init" else current.split("/")
    for token in expression.split(".")[1:]:
        if token=="Parent": parts.pop()
        else: parts.append(token)
    return "/".join(parts)

def transform(current: str, source: str) -> str:
    pattern=r"require\((script(?:\.[A-Za-z_][A-Za-z0-9_]*)+)\)"
    return re.sub(pattern,lambda m:f'__require("{resolve(current,m.group(1))}")',source)

chunks=["-- AXIOM UI ENGINE · generated distribution\nlocal __modules,__cache={},{}\nlocal function __require(id)\n if __cache[id]~=nil then return __cache[id] end\n local factory=assert(__modules[id],\"Missing Axiom module: \"..id)\n local value=factory()\n __cache[id]=value\n return value\nend\n"]
for path in sorted(MODULES,key=lambda p:(module_id(p)=="init",module_id(p))):
    mid=module_id(path)
    chunks.append(f'__modules["{mid}"]=function()\n{transform(mid,path.read_text(encoding="utf-8"))}\nend\n')
chunks.append('return __require("init")\n')
OUT.parent.mkdir(exist_ok=True)
OUT.write_text("\n".join(chunks),encoding="utf-8")
print(f"Built {OUT} ({OUT.stat().st_size} bytes, {len(MODULES)} modules)")
