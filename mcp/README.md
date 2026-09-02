# Axiom MCP Server

Servidor MCP local que transforma a documentação e o registry do Axiom em contexto estruturado para assistentes de IA. Ele lê o próprio repositório, portanto versão, tamanho do bundle e catálogo de ícones não ficam duplicados em uma base separada.

## Requisitos

- Python 3.11 ou superior (`py -3.11` no Windows ou `python3` no Linux/macOS também funcionam).
- Uma cópia local deste repositório.
- Nenhuma dependência Python externa.

## Executar

```bash
python mcp/axiom_mcp.py
```

O processo usa `stdio` e deve ser iniciado por um cliente MCP. Logs nunca são escritos em stdout.

## Ferramentas

| Tool | Uso |
| --- | --- |
| `search_axiom_docs` | Pesquisa conceitos, métodos, options e comportamentos por seção |
| `get_axiom_document` | Lê um documento oficial completo ou um heading específico |
| `lookup_axiom_icon` | Resolve nome, alias, forma compacta, ID ou ContentId como o engine |
| `get_axiom_metadata` | Retorna versão, tamanho, contagens, requisitos e links canônicos |

## Resources

- `axiom://docs/overview`
- `axiom://docs/api`
- `axiom://docs/icons`
- `axiom://docs/design-system`
- `axiom://examples/showcase`

O prompt `build-axiom-interface` instrui o modelo a consultar a API e validar ícones antes de produzir Luau.

## Claude Desktop e Cursor

Use o caminho absoluto do seu clone. No Windows, duplique as barras invertidas em JSON:

```json
{
  "mcpServers": {
    "axiom": {
      "command": "python",
      "args": ["C:\\caminho\\AxiomUI\\mcp\\axiom_mcp.py"]
    }
  }
}
```

No Claude Desktop, o objeto entra em `claude_desktop_config.json`. No Cursor, use `.cursor/mcp.json`.

## OpenCode

```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "axiom": {
      "type": "local",
      "command": ["python", "C:\\caminho\\AxiomUI\\mcp\\axiom_mcp.py"],
      "enabled": true
    }
  }
}
```

## Testes

```bash
python -m unittest mcp.test_server
```

Os testes cobrem handshake, validação JSON-RPC, tools, resources, prompt, framing, limites de transporte, busca documental, metadados e as regras reais de resolução de ícones.
