# MCP Análise Macro — Núcleos do IPCA (v1)

Servidor **MCP remoto e sem autenticação** que expõe as séries analíticas do
IPCA (Nota Técnica 57 do BCB), calculadas pelo pacote R [`nucleos`](../).

Qualquer pessoa adiciona a URL no Claude, Cursor ou Codex e passa a consultar
os núcleos ao vivo — sem instalar nada, sem chave.

> **Escopo.** Este Worker é o **piloto dos núcleos do IPCA**, casado com este
> repositório: serve o que o pacote `nucleos` calcula, e só isso. O produto
> guarda-chuva **MCP Análise Macro** — que reunirá Selic/COPOM, câmbio,
> atividade, fiscal e Focus — nasce em projeto e infraestrutura próprios. Não
> expanda este servidor para outras séries; ele existe para validar o design
> das ferramentas no uso real.

## Arquitetura

- **Dados embutidos.** `src/data.json` é um snapshot pré-calculado (23 séries,
  2000–2026) gerado a partir do artefato do dashboard. O Worker **não coleta
  SIDRA nem roda R** — só lê o snapshot. Atualização é por re-deploy mensal.
- **Cloudflare Workers** (authless, Streamable HTTP). Custo ocioso ~zero.
- Rotas: `POST /mcp` (Streamable HTTP, use esta no Claude.ai) e `/sse` (legado).

## Ferramentas

| Tool | O que faz |
|---|---|
| `nucleos_listar` | Lista as 23 séries (núcleos, agregações, difusão, IPCA cheio). |
| `nucleos_metadata` | Última referência, data de atualização, fonte, metodologia. |
| `nucleos_ultimas` | Leituras do mês: variação, aceleração, acum. 3m/12m. |
| `nucleos_serie` | Série temporal de uma série (por período ou últimos N meses). |
| `nucleos_comparar` | Compara várias séries lado a lado. |

> **Unidades.** 22 das 23 séries são variação % ao mês e se acumulam de forma
> composta. A **Difusão** é exceção: é a proporção (%) de itens do IPCA com
> variação positiva no mês — um *nível*, que não se acumula. Para ela as tools
> reportam a **média** do período, com nota explícita na resposta.

## Pré-requisitos

- **Node.js 18+** e **npm** (para o `wrangler`).
- Conta **Cloudflare** gratuita (<https://dash.cloudflare.com/sign-up>).

## Deploy

```bash
cd mcp
npm install
npm run check               # typecheck + build de validação, sem precisar de login
npx wrangler login          # abre o navegador para autenticar na Cloudflare
npm run deploy              # publica e imprime a URL pública
```

O `npm run check` valida o bundle inteiro (~391 KB gzip, folgado no limite de
3 MB do plano gratuito) sem tocar na sua conta — rode antes de qualquer deploy.

O deploy imprime algo como:

```
https://nucleos-mcp.<seu-subdominio>.workers.dev
```

O endpoint MCP é essa URL **+ `/mcp`**:

```
https://nucleos-mcp.<seu-subdominio>.workers.dev/mcp
```

Abra a URL raiz no navegador para um health-check (mostra o último mês e o
endpoint do conector).

## Conectar (o que você manda para a sua rede)

O servidor é **authless** e fala **Streamable HTTP**, o transporte que os três
clientes abaixo suportam nativamente por URL — ninguém precisa instalar ponte
(`mcp-remote`), colar chave nem logar. Em todos, a URL é a mesma, terminada
em `/mcp`.

### Claude (claude.ai e Claude Desktop)

1. **Configurações → Connectors → Adicionar conector personalizado**.
2. Cole a URL terminada em `/mcp`.
3. Salvar. As ferramentas `nucleos_*` ficam disponíveis no chat.

> Funciona em **todos os planos** (Free inclusive — o Free permite 1 conector
> personalizado).

### Cursor

Em `~/.cursor/mcp.json` (global) ou `.cursor/mcp.json` (só no projeto):

```json
{
  "mcpServers": {
    "nucleos-ipca": {
      "url": "https://nucleos-mcp.<seu-subdominio>.workers.dev/mcp"
    }
  }
}
```

### Codex CLI

Em `~/.codex/config.toml` (global) ou `.codex/config.toml` (só no projeto):

```toml
[mcp_servers.nucleos_ipca]
url = "https://nucleos-mcp.<seu-subdominio>.workers.dev/mcp"
```

> `codex mcp add` serve para servidores stdio; para servidor remoto por URL,
> edite o `config.toml` direto. Sem autenticação, nenhum token é necessário.

### Teste rápido

Pergunte no chat: *"Quais as últimas leituras dos núcleos do IPCA?"*,
*"Compare o Núcleo MS com o IPCA cheio."* ou *"A difusão está subindo?"*

## Desenvolvimento local

```bash
npm run dev            # http://localhost:8787/mcp
npm run typecheck      # tsc --noEmit
```

Inspecione com o MCP Inspector: `npx @modelcontextprotocol/inspector`, apontando
para `http://localhost:8787/mcp` (transporte Streamable HTTP).

## Atualizar os dados (mensal)

O snapshot é regenerado a partir do artefato do dashboard:

```bash
# a partir da raiz do repositório, com o artefato em dashboard/dados/
Rscript --vanilla mcp/gerar_snapshot.R   # gera mcp/src/data.json
cd mcp && npm run deploy
```

> Evolução prevista (Fase 2 do MCP): em vez de embutir, o Worker faz `fetch` do
> asset JSON do release `dashboard-dados`, atualizando sozinho pelo workflow
> mensal. Ver `CLAUDE.md` → "MCP Análise Macro".
