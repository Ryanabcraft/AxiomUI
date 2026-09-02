"""Vercel Streamable HTTP adapter for the stateless Axiom MCP server."""

from http.server import BaseHTTPRequestHandler
import json
from pathlib import Path
from typing import Any

from mcp.axiom_mcp import MAX_MESSAGE_BYTES, PROTOCOL_VERSION, handle_request, strict_json_loads


ROOT = Path(__file__).resolve().parent.parent


def process_jsonrpc(payload: bytes) -> tuple[int, dict[str, Any] | None]:
    if not payload or len(payload) > MAX_MESSAGE_BYTES:
        return 413, {"jsonrpc": "2.0", "id": None, "error": {"code": -32600, "message": "Invalid request size"}}
    try:
        message = strict_json_loads(payload)
    except (UnicodeDecodeError, ValueError, json.JSONDecodeError) as error:
        return 400, {"jsonrpc": "2.0", "id": None, "error": {"code": -32700, "message": f"Parse error: {error}"}}
    response = handle_request(message)
    return (202, None) if response is None else (200, response)


class handler(BaseHTTPRequestHandler):
    def _cors(self) -> None:
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type, Accept, MCP-Protocol-Version")
        self.send_header("Access-Control-Expose-Headers", "MCP-Protocol-Version")
        self.send_header("MCP-Protocol-Version", PROTOCOL_VERSION)

    def _send(self, status: int, content_type: str, payload: bytes) -> None:
        self.send_response(status)
        self._cors()
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(payload)))
        self.send_header("Cache-Control", "no-store")
        self.end_headers()
        self.wfile.write(payload)

    def do_OPTIONS(self) -> None:
        self.send_response(204)
        self._cors()
        self.send_header("Content-Length", "0")
        self.end_headers()

    def do_GET(self) -> None:
        if "text/html" not in self.headers.get("Accept", "text/html"):
            self._send(405, "application/json; charset=utf-8", b'{"error":"Use POST for MCP requests"}')
            return
        self._send(200, "text/html; charset=utf-8", (ROOT / "docs" / "mcp.html").read_bytes())

    def do_POST(self) -> None:
        try:
            length = int(self.headers.get("Content-Length", "0"))
        except ValueError:
            length = 0
        status, response = process_jsonrpc(self.rfile.read(length) if 0 < length <= MAX_MESSAGE_BYTES else b"")
        if response is None:
            self._send(status, "application/json; charset=utf-8", b"")
            return
        payload = json.dumps(response, ensure_ascii=False, allow_nan=False, separators=(",", ":")).encode("utf-8")
        self._send(status, "application/json; charset=utf-8", payload)

    def log_message(self, _format: str, *_args: Any) -> None:
        return
