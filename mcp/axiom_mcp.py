#!/usr/bin/env python3
"""Dependency-free MCP server for the Axiom UI Engine documentation."""

from __future__ import annotations

from dataclasses import dataclass
import json
import math
from pathlib import Path
import re
import sys
import unicodedata
from typing import Any, BinaryIO


ROOT = Path(__file__).resolve().parent.parent
SERVER_NAME = "axiom-ui-docs"
SERVER_VERSION = "1.0.0"
PROTOCOL_VERSION = "2025-06-18"
SUPPORTED_PROTOCOL_VERSIONS = {PROTOCOL_VERSION, "2025-03-26", "2024-11-05"}
MAX_MESSAGE_BYTES = 4 * 1024 * 1024
MAX_HEADER_BYTES = 8192
MAX_ASSET_ID = 2**63 - 1


@dataclass(frozen=True)
class Document:
    key: str
    uri: str
    title: str
    description: str
    path: Path
    mime_type: str = "text/markdown"


@dataclass(frozen=True)
class SearchChunk:
    document: Document
    heading: str
    line_start: int
    text: str


DOCUMENTS = {
    document.key: document
    for document in (
        Document(
            "overview",
            "axiom://docs/overview",
            "Axiom overview",
            "Installation, capabilities, compatibility, and project structure.",
            ROOT / "README.md",
        ),
        Document(
            "api",
            "axiom://docs/api",
            "Axiom API reference",
            "Canonical Engine, Window, component, Config, Icon, and Theme API.",
            ROOT / "Documentation" / "API.md",
        ),
        Document(
            "icons",
            "axiom://docs/icons",
            "Axiom icon catalog",
            "Official Lucide icon names, aliases, normalization, and custom IDs.",
            ROOT / "Documentation" / "ICONS.md",
        ),
        Document(
            "design-system",
            "axiom://docs/design-system",
            "Axiom design system",
            "Layout, responsive behavior, semantic tokens, acrylic, and motion.",
            ROOT / "Documentation" / "DESIGN_SYSTEM.md",
        ),
        Document(
            "showcase",
            "axiom://examples/showcase",
            "Axiom showcase",
            "Runnable Luau example using the current public API.",
            ROOT / "Examples" / "Showcase.client.lua",
            "text/x-lua",
        ),
    )
}
DOCUMENTS_BY_URI = {document.uri: document for document in DOCUMENTS.values()}


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def normalize_text(value: str) -> str:
    decomposed = unicodedata.normalize("NFKD", value.casefold())
    return "".join(character for character in decomposed if not unicodedata.combining(character))


def section_chunks(document: Document) -> list[SearchChunk]:
    lines = read_text(document.path).splitlines()
    if document.mime_type != "text/markdown":
        return [
            SearchChunk(document, f"Lines {start + 1}-{min(start + 80, len(lines))}", start + 1, "\n".join(lines[start : start + 80]))
            for start in range(0, len(lines), 80)
        ]

    headings = [index for index, line in enumerate(lines) if re.match(r"^#{1,6}\s+", line)]
    if not headings:
        return [SearchChunk(document, document.title, 1, "\n".join(lines))]

    chunks = []
    for position, start in enumerate(headings):
        end = headings[position + 1] if position + 1 < len(headings) else len(lines)
        heading = re.sub(r"^#{1,6}\s+", "", lines[start]).strip()
        chunks.append(SearchChunk(document, heading, start + 1, "\n".join(lines[start:end]).strip()))
    return chunks


SEARCH_CHUNKS = [chunk for document in DOCUMENTS.values() for chunk in section_chunks(document)]


ICON_ENTRY = re.compile(r'^\s*(?:\["([^"]+)"\]|([a-z][a-z0-9-]*))\s*=\s*"([^"]+)"', re.MULTILINE)


def icon_registry() -> tuple[dict[str, str], dict[str, str]]:
    source = read_text(ROOT / "Services" / "Icons.lua")
    registry_source, aliases_source = source.split("local aliases =", 1)
    registry = {
        quoted or bare: value
        for quoted, bare, value in ICON_ENTRY.findall(registry_source)
        if value.startswith("rbxassetid://")
    }
    aliases_block = aliases_source.split("}", 1)[0]
    aliases = {
        quoted or bare: value
        for quoted, bare, value in ICON_ENTRY.findall(aliases_block)
    }
    return registry, aliases


ICONS, ICON_ALIASES = icon_registry()
COMPACT_ICONS = {name.replace("-", ""): name for name in ICONS}


def normalize_icon_name(value: str) -> str:
    key = re.sub(r"[\s_]+", "-", value.casefold())
    return re.sub(r"-+", "-", key).strip("-")


def valid_icon_number(value: Any) -> bool:
    if isinstance(value, bool):
        return False
    if isinstance(value, int):
        return 0 < value <= MAX_ASSET_ID
    return isinstance(value, float) and math.isfinite(value) and 0 < value <= MAX_ASSET_ID


def resolve_icon(value: str | int | float) -> dict[str, Any]:
    if valid_icon_number(value):
        return {"query": value, "kind": "custom-id", "asset": f"rbxassetid://{math.floor(value)}", "exists": False}
    if not isinstance(value, str):
        raise ValueError("Icon name must be a string or positive number")
    if re.match(r"^(?:rbxassetid://\d+|rbxasset://.+|https?://.+)$", value):
        return {"query": value, "kind": "custom-content", "asset": value, "exists": False}

    normalized = normalize_icon_name(value)
    if normalized in ICONS:
        canonical = normalized
        kind = "official"
    elif normalized in ICON_ALIASES:
        canonical = ICON_ALIASES[normalized]
        kind = "alias"
    elif normalized in COMPACT_ICONS:
        canonical = COMPACT_ICONS[normalized]
        kind = "normalized"
    else:
        return {
            "query": value,
            "normalized": normalized,
            "kind": "unknown",
            "canonical": "info",
            "asset": ICONS["info"],
            "exists": False,
            "note": "Axiom.Icons.Get uses the validated info icon as its fallback.",
        }

    return {
        "query": value,
        "normalized": normalized,
        "kind": kind,
        "canonical": canonical,
        "asset": ICONS[canonical],
        "exists": True,
    }


def project_metadata() -> dict[str, Any]:
    engine = read_text(ROOT / "Core" / "Engine.lua")
    version_match = re.search(r'Version="([^"]+)"', engine)
    modules = [
        path
        for path in ROOT.rglob("*.lua")
        if "dist" not in path.parts and "Examples" not in path.parts
    ]
    return {
        "name": "Axiom UI Engine",
        "version": version_match.group(1) if version_match else "unknown",
        "bundleBytes": (ROOT / "dist" / "Axiom.lua").stat().st_size,
        "moduleCount": len(modules),
        "componentCount": 8,
        "officialIconCount": len(ICONS),
        "aliasCount": len(ICON_ALIASES),
        "license": "MIT",
        "requirements": ["loadstring", "game:HttpGet"],
        "optionalFilesystem": ["writefile", "readfile", "isfile", "makefolder"],
        "repository": "https://github.com/Ryanabcraft/AxiomUI",
        "site": "https://ryanabcraft.github.io/AxiomUI/",
        "bundle": "https://raw.githubusercontent.com/Ryanabcraft/AxiomUI/main/dist/Axiom.lua",
    }


def search_docs(query: str, limit: int = 5) -> list[dict[str, Any]]:
    normalized_query = normalize_text(query).strip()
    terms = [term for term in re.split(r"[^a-z0-9]+", normalized_query) if len(term) > 1]
    if not terms:
        return []

    ranked = []
    for chunk in SEARCH_CHUNKS:
        heading = normalize_text(chunk.heading)
        body = normalize_text(chunk.text)
        matched = [term for term in terms if term in heading or term in body]
        if not matched:
            continue
        score = sum(5 if term in heading else 1 for term in matched)
        if normalized_query in heading:
            score += 12
        elif normalized_query in body:
            score += 6
        if len(matched) == len(terms):
            score += 4
        ranked.append((score, chunk))

    ranked.sort(key=lambda item: (-item[0], item[1].document.key, item[1].line_start))
    return [
        {
            "document": chunk.document.key,
            "uri": chunk.document.uri,
            "heading": chunk.heading,
            "lineStart": chunk.line_start,
            "score": score,
            "content": chunk.text[:3000],
        }
        for score, chunk in ranked[:limit]
    ]


def document_content(key: str, section: str | None = None) -> dict[str, Any]:
    document = DOCUMENTS.get(key)
    if not document:
        raise ValueError(f"Unknown document: {key}")
    content = read_text(document.path)
    heading = None
    line_start = 1
    if section:
        requested = normalize_text(section)
        chunks = section_chunks(document)
        exact = [chunk for chunk in chunks if requested == normalize_text(chunk.heading)]
        matches = exact or [chunk for chunk in chunks if requested in normalize_text(chunk.heading)]
        if not matches:
            raise ValueError(f"Section not found in {key}: {section}")
        if len(matches) > 1:
            headings = ", ".join(chunk.heading for chunk in matches[:5])
            raise ValueError(f"Ambiguous section in {key}: {section}. Matches: {headings}")
        chunk = matches[0]
        content = chunk.text
        heading = chunk.heading
        line_start = chunk.line_start
    return {
        "document": key,
        "uri": document.uri,
        "title": document.title,
        "heading": heading,
        "lineStart": line_start,
        "content": content,
    }


TOOLS = [
    {
        "name": "search_axiom_docs",
        "description": "Search the canonical Axiom documentation by concept, API name, option, component, or behavior.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {"type": "string", "minLength": 2, "description": "What to find, for example ReopenPill or autosave."},
                "limit": {"type": "integer", "minimum": 1, "maximum": 10, "default": 5},
            },
            "required": ["query"],
            "additionalProperties": False,
        },
    },
    {
        "name": "get_axiom_document",
        "description": "Read an official Axiom document or one of its named sections.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "document": {"type": "string", "enum": list(DOCUMENTS)},
                "section": {"type": "string", "description": "Optional heading or partial heading."},
            },
            "required": ["document"],
            "additionalProperties": False,
        },
    },
    {
        "name": "lookup_axiom_icon",
        "description": "Resolve an Axiom icon name, alias, compact name, numeric ID, or content URL exactly as the engine does.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "name": {
                    "oneOf": [
                        {"type": "string", "minLength": 1},
                        {"type": "number", "exclusiveMinimum": 0, "maximum": MAX_ASSET_ID},
                    ]
                }
            },
            "required": ["name"],
            "additionalProperties": False,
        },
    },
    {
        "name": "get_axiom_metadata",
        "description": "Return version, bundle size, module/component/icon counts, requirements, and canonical links derived from the repository.",
        "inputSchema": {"type": "object", "properties": {}, "additionalProperties": False},
    },
]


PROMPTS = [
    {
        "name": "build-axiom-interface",
        "description": "Ground an AI in the official Axiom API before it writes a Luau interface.",
        "arguments": [
            {"name": "goal", "description": "What the interface should do.", "required": True},
            {"name": "layout", "description": "Optional layout or device requirements.", "required": False},
        ],
    }
]


def text_result(data: Any) -> dict[str, Any]:
    text = data if isinstance(data, str) else json.dumps(data, ensure_ascii=False, indent=2)
    result = {"content": [{"type": "text", "text": text}]}
    if not isinstance(data, str):
        result["structuredContent"] = data
    return result


def call_tool(name: str, arguments: dict[str, Any]) -> dict[str, Any]:
    if name == "search_axiom_docs":
        query = arguments.get("query")
        if not isinstance(query, str) or len(query.strip()) < 2:
            raise ValueError("query must contain at least two characters")
        limit = arguments.get("limit", 5)
        if not isinstance(limit, int) or isinstance(limit, bool) or not 1 <= limit <= 10:
            raise ValueError("limit must be an integer between 1 and 10")
        return text_result({"query": query, "results": search_docs(query, limit)})
    if name == "get_axiom_document":
        key = arguments.get("document")
        section = arguments.get("section")
        if not isinstance(key, str) or (section is not None and not isinstance(section, str)):
            raise ValueError("document must be a valid key and section must be a string")
        return text_result(document_content(key, section))
    if name == "lookup_axiom_icon":
        icon_name = arguments.get("name")
        valid_number = valid_icon_number(icon_name)
        if not (isinstance(icon_name, str) and icon_name) and not valid_number:
            raise ValueError("name must be a non-empty string or positive number")
        return text_result(resolve_icon(icon_name))
    if name == "get_axiom_metadata":
        if arguments:
            raise ValueError("get_axiom_metadata does not accept arguments")
        return text_result(project_metadata())
    raise ValueError(f"Unknown tool: {name}")


def request_error(request_id: Any, code: int, message: str) -> dict[str, Any]:
    return {"jsonrpc": "2.0", "id": request_id, "error": {"code": code, "message": message}}


def valid_request_id(value: Any) -> bool:
    if value is None or isinstance(value, str):
        return True
    if isinstance(value, bool):
        return False
    if isinstance(value, int):
        return True
    return isinstance(value, float) and math.isfinite(value)


def object_params(message: dict[str, Any]) -> dict[str, Any]:
    params = message.get("params", {})
    if params is None:
        return {}
    if not isinstance(params, dict):
        raise ValueError("params must be an object")
    return params


def handle_request(message: Any) -> dict[str, Any] | None:
    request_id = message.get("id") if isinstance(message, dict) else None
    safe_request_id = request_id if valid_request_id(request_id) else None
    if not isinstance(message, dict) or message.get("jsonrpc") != "2.0" or not isinstance(message.get("method"), str):
        return request_error(safe_request_id, -32600, "Invalid Request")
    if "id" in message and not valid_request_id(request_id):
        return request_error(None, -32600, "Invalid Request ID")
    if "id" not in message:
        return None

    method = message["method"]
    try:
        params = object_params(message)
    except ValueError as error:
        return request_error(request_id, -32602, str(error))

    try:
        if method == "initialize":
            requested_version = params.get("protocolVersion")
            negotiated_version = requested_version if requested_version in SUPPORTED_PROTOCOL_VERSIONS else PROTOCOL_VERSION
            result = {
                "protocolVersion": negotiated_version,
                "capabilities": {
                    "tools": {"listChanged": False},
                    "resources": {"subscribe": False, "listChanged": False},
                    "prompts": {"listChanged": False},
                },
                "serverInfo": {"name": SERVER_NAME, "version": SERVER_VERSION},
                "instructions": "Use Axiom resources and tools as the source of truth. Do not invent methods or claim drop-in compatibility with other Roblox UI libraries.",
            }
        elif method == "ping":
            result = {}
        elif method == "tools/list":
            result = {"tools": TOOLS}
        elif method == "tools/call":
            tool_name = params.get("name")
            if tool_name not in {tool["name"] for tool in TOOLS}:
                return request_error(request_id, -32602, f"Unknown tool: {tool_name}")
            arguments = params.get("arguments", {})
            if not isinstance(arguments, dict):
                return request_error(request_id, -32602, "arguments must be an object")
            try:
                result = call_tool(tool_name, arguments)
            except (OverflowError, TypeError, ValueError) as error:
                return request_error(request_id, -32602, str(error))
        elif method == "resources/list":
            result = {
                "resources": [
                    {
                        "uri": document.uri,
                        "name": document.key,
                        "title": document.title,
                        "description": document.description,
                        "mimeType": document.mime_type,
                    }
                    for document in DOCUMENTS.values()
                ]
            }
        elif method == "resources/read":
            uri = params.get("uri")
            document = DOCUMENTS_BY_URI.get(uri)
            if not document:
                raise ValueError(f"Unknown resource URI: {uri}")
            result = {
                "contents": [
                    {"uri": uri, "mimeType": document.mime_type, "text": read_text(document.path)}
                ]
            }
        elif method == "prompts/list":
            result = {"prompts": PROMPTS}
        elif method == "prompts/get":
            if params.get("name") != "build-axiom-interface":
                raise ValueError(f"Unknown prompt: {params.get('name')}")
            arguments = params.get("arguments", {})
            if not isinstance(arguments, dict):
                raise ValueError("arguments must be an object")
            goal = arguments.get("goal")
            if not isinstance(goal, str) or not goal.strip():
                raise ValueError("The goal argument is required")
            layout = arguments.get("layout")
            layout_line = f"\nLayout requirements: {layout}" if layout else ""
            result = {
                "description": "Build an interface using only documented Axiom APIs.",
                "messages": [
                    {
                        "role": "user",
                        "content": {
                            "type": "text",
                            "text": (
                                "Build this Roblox Luau interface with Axiom: "
                                f"{goal}{layout_line}\n\n"
                                "Before writing code, consult axiom://docs/api and search any uncertain method or option. "
                                "Use lookup_axiom_icon for every icon name. Return a complete runnable snippet, do not invent APIs, "
                                "and do not assume Rayfield or WindUI compatibility."
                            ),
                        },
                    }
                ],
            }
        else:
            return request_error(request_id, -32601, f"Method not found: {method}")
        return {"jsonrpc": "2.0", "id": request_id, "result": result}
    except (KeyError, OverflowError, TypeError, ValueError) as error:
        return request_error(request_id, -32602, str(error))


def strict_json_loads(payload: bytes) -> Any:
    def reject_constant(value: str) -> None:
        raise ValueError(f"Invalid JSON constant: {value}")

    return json.loads(payload.decode("utf-8"), parse_constant=reject_constant)


def read_message(stream: BinaryIO) -> tuple[dict[str, Any] | None, str]:
    while True:
        first_line = stream.readline(MAX_MESSAGE_BYTES + 1)
        if not first_line:
            return None, "lines"
        if len(first_line) > MAX_MESSAGE_BYTES:
            raise ValueError("Message exceeds the size limit")
        if first_line.strip():
            break

    if first_line.lower().startswith(b"content-length:"):
        try:
            length = int(first_line.split(b":", 1)[1].strip())
        except ValueError as error:
            raise ValueError("Invalid Content-Length header") from error
        if not 0 < length <= MAX_MESSAGE_BYTES:
            raise ValueError("Content-Length is outside the accepted range")
        header_bytes = len(first_line)
        while True:
            header = stream.readline(MAX_HEADER_BYTES + 1)
            if not header or header in {b"\n", b"\r\n"}:
                break
            header_bytes += len(header)
            if len(header) > MAX_HEADER_BYTES or header_bytes > MAX_HEADER_BYTES:
                raise ValueError("Headers exceed the size limit")
        payload = bytearray()
        while len(payload) < length:
            chunk = stream.read(length - len(payload))
            if not chunk:
                raise ValueError("Unexpected EOF in framed message")
            payload.extend(chunk)
        return strict_json_loads(bytes(payload)), "headers"

    return strict_json_loads(first_line), "lines"


def write_message(stream: BinaryIO, message: dict[str, Any], mode: str) -> None:
    payload = json.dumps(message, ensure_ascii=False, allow_nan=False, separators=(",", ":")).encode("utf-8")
    if mode == "headers":
        stream.write(f"Content-Length: {len(payload)}\r\n\r\n".encode("ascii"))
        stream.write(payload)
    else:
        stream.write(payload + b"\n")
    stream.flush()


def serve(stdin: BinaryIO | None = None, stdout: BinaryIO | None = None) -> None:
    input_stream = stdin or sys.stdin.buffer
    output_stream = stdout or sys.stdout.buffer
    mode = "lines"
    while True:
        try:
            message, mode = read_message(input_stream)
            if message is None:
                return
            response = handle_request(message)
            if response is not None:
                write_message(output_stream, response, mode)
        except (json.JSONDecodeError, UnicodeDecodeError, ValueError) as error:
            write_message(
                output_stream,
                {"jsonrpc": "2.0", "id": None, "error": {"code": -32700, "message": f"Parse error: {error}"}},
                mode,
            )
        except Exception as error:  # Keep protocol output valid if repository data is unavailable.
            write_message(
                output_stream,
                {"jsonrpc": "2.0", "id": None, "error": {"code": -32603, "message": f"Internal error: {error}"}},
                mode,
            )


if __name__ == "__main__":
    serve()
