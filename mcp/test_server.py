"""Tests for the dependency-free Axiom MCP server."""

from io import BytesIO
import json
from pathlib import Path
import subprocess
import sys
import unittest

from mcp import axiom_mcp
from api.mcp import process_jsonrpc


ROOT = Path(__file__).resolve().parent.parent
SERVER = ROOT / "mcp" / "axiom_mcp.py"


class AxiomMcpTests(unittest.TestCase):
    def test_repository_metadata(self):
        metadata = axiom_mcp.project_metadata()
        self.assertEqual(metadata["officialIconCount"], 247)
        self.assertEqual(metadata["aliasCount"], 51)
        self.assertEqual(metadata["componentCount"], 8)
        self.assertEqual(metadata["moduleCount"], 24)
        self.assertEqual(metadata["bundleBytes"], (ROOT / "dist" / "Axiom.lua").stat().st_size)

    def test_icon_resolution_matches_engine_rules(self):
        official = axiom_mcp.resolve_icon("Map Pin")
        alias = axiom_mcp.resolve_icon("aimbot")
        custom = axiom_mcp.resolve_icon(123456.9)
        numeric_string = axiom_mcp.resolve_icon("123456")
        unknown = axiom_mcp.resolve_icon("not-an-axiom-icon")

        self.assertEqual(official["canonical"], "map-pin")
        self.assertEqual(alias["canonical"], "crosshair")
        self.assertEqual(alias["kind"], "alias")
        self.assertEqual(custom["asset"], "rbxassetid://123456")
        self.assertFalse(custom["exists"])
        self.assertEqual(numeric_string["kind"], "unknown")
        self.assertEqual(unknown["canonical"], "info")
        self.assertFalse(unknown["exists"])
        with self.assertRaises(ValueError):
            axiom_mcp.resolve_icon(2**80)

    def test_document_search_is_section_aware(self):
        results = axiom_mcp.search_docs("ReopenPill", 3)
        self.assertTrue(results)
        self.assertTrue(any("ReopenPill" in result["content"] for result in results))
        self.assertTrue(all(result["uri"].startswith("axiom://") for result in results))
        self.assertTrue(axiom_mcp.search_docs("safe_area", 3))

    def test_document_section_prefers_exact_heading(self):
        section = axiom_mcp.document_content("api", "Window")
        self.assertEqual(section["heading"], "Window")
        self.assertIn("GetDeviceMode", section["content"])

    def test_protocol_validation_preserves_request_id(self):
        unsupported = axiom_mcp.handle_request(
            {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2099-01-01"}}
        )
        bad_params = axiom_mcp.handle_request(
            {"jsonrpc": "2.0", "id": 2, "method": "tools/call", "params": []}
        )
        null_id = axiom_mcp.handle_request({"jsonrpc": "2.0", "id": None, "method": "ping"})
        invalid = axiom_mcp.handle_request({"jsonrpc": "1.0", "id": 3, "method": "ping"})
        invalid_id = axiom_mcp.handle_request({"jsonrpc": "2.0", "id": [], "method": "ping"})
        unknown_tool = axiom_mcp.handle_request(
            {"jsonrpc": "2.0", "id": 4, "method": "tools/call", "params": {"name": "missing", "arguments": {}}}
        )
        bad_arguments = axiom_mcp.handle_request(
            {"jsonrpc": "2.0", "id": 5, "method": "tools/call", "params": {"name": "search_axiom_docs", "arguments": []}}
        )

        self.assertEqual(unsupported["result"]["protocolVersion"], axiom_mcp.PROTOCOL_VERSION)
        self.assertEqual(bad_params["id"], 2)
        self.assertEqual(bad_params["error"]["code"], -32602)
        self.assertIn("result", null_id)
        self.assertEqual(invalid["error"]["code"], -32600)
        self.assertIsNone(invalid_id["id"])
        self.assertEqual(invalid_id["error"]["code"], -32600)
        self.assertEqual(unknown_tool["error"]["code"], -32602)
        self.assertEqual(bad_arguments["error"]["code"], -32602)

    def test_line_protocol_end_to_end(self):
        messages = [
            {"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {"protocolVersion": "2024-11-05"}},
            {"jsonrpc": "2.0", "method": "notifications/initialized"},
            {"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}},
            {
                "jsonrpc": "2.0",
                "id": 3,
                "method": "resources/read",
                "params": {"uri": "axiom://docs/api"},
            },
            {
                "jsonrpc": "2.0",
                "id": 4,
                "method": "tools/call",
                "params": {"name": "lookup_axiom_icon", "arguments": {"name": "map_pin"}},
            },
        ]
        payload = "".join(json.dumps(message) + "\n" for message in messages)
        process = subprocess.run(
            [sys.executable, str(SERVER)],
            input=payload,
            text=True,
            encoding="utf-8",
            capture_output=True,
            cwd=ROOT,
            check=True,
        )
        responses = [json.loads(line) for line in process.stdout.splitlines()]
        self.assertEqual([response["id"] for response in responses], [1, 2, 3, 4])
        self.assertEqual(responses[0]["result"]["serverInfo"]["name"], "axiom-ui-docs")
        self.assertEqual(len(responses[1]["result"]["tools"]), 4)
        self.assertIn("Axiom:CreateWindow", responses[2]["result"]["contents"][0]["text"])
        self.assertEqual(responses[3]["result"]["structuredContent"]["canonical"], "map-pin")

    def test_prompt_is_grounded_in_official_resources(self):
        response = axiom_mcp.handle_request(
            {
                "jsonrpc": "2.0",
                "id": 1,
                "method": "prompts/get",
                "params": {"name": "build-axiom-interface", "arguments": {"goal": "Create a settings panel"}},
            }
        )
        text = response["result"]["messages"][0]["content"]["text"]
        self.assertIn("axiom://docs/api", text)
        self.assertIn("lookup_axiom_icon", text)

    def test_content_length_protocol(self):
        request = json.dumps(
            {"jsonrpc": "2.0", "id": "ping", "method": "ping"}, separators=(",", ":")
        ).encode("utf-8")
        stdin = BytesIO(f"Content-Length: {len(request)}\r\n\r\n".encode("ascii") + request)
        stdout = BytesIO()
        axiom_mcp.serve(stdin, stdout)
        raw = stdout.getvalue()
        header, payload = raw.split(b"\r\n\r\n", 1)
        self.assertEqual(int(header.split(b":", 1)[1]), len(payload))
        self.assertEqual(json.loads(payload), {"jsonrpc": "2.0", "id": "ping", "result": {}})

    def test_parser_rejects_unsafe_framing_and_non_finite_json(self):
        with self.assertRaises(ValueError):
            axiom_mcp.read_message(BytesIO(b"Content-Length: -1\r\n\r\n"))
        with self.assertRaises(ValueError):
            axiom_mcp.read_message(BytesIO(b"Content-Length: 20\r\n\r\n{}"))
        with self.assertRaises(ValueError):
            axiom_mcp.read_message(BytesIO(b'{"value":NaN}\n'))

    def test_http_adapter_handles_requests_notifications_and_bad_json(self):
        request = json.dumps({"jsonrpc": "2.0", "id": 7, "method": "tools/list", "params": {}}).encode()
        notification = json.dumps({"jsonrpc": "2.0", "method": "notifications/initialized"}).encode()

        status, response = process_jsonrpc(request)
        notification_status, notification_response = process_jsonrpc(notification)
        invalid_status, invalid_response = process_jsonrpc(b'{"jsonrpc":')
        large_status, large_response = process_jsonrpc(b"")

        self.assertEqual(status, 200)
        self.assertEqual(len(response["result"]["tools"]), 4)
        self.assertEqual((notification_status, notification_response), (202, None))
        self.assertEqual(invalid_status, 400)
        self.assertEqual(invalid_response["error"]["code"], -32700)
        self.assertEqual(large_status, 413)
        self.assertEqual(large_response["error"]["code"], -32600)


if __name__ == "__main__":
    unittest.main()
