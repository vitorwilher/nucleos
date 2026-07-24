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

## URL pública

O servidor está no ar em:

```
https://nucleos-mcp.analisemacro.workers.dev
```

**O endpoint MCP — o que você cola nos clientes — é essa URL + `/mcp`:**

```
https://nucleos-mcp.analisemacro.workers.dev/mcp
```

Abra a URL raiz no navegador para um health-check (mostra o último mês e o
endpoint do conector).

> **`/mcp` não abre no navegador — e isso é o correto.** Ao acessá-la direto,
> você recebe `Not Acceptable: Client must accept text/event-stream`. É o
> servidor dizendo que o navegador não fala o protocolo MCP: ele não envia o
> header `Accept: text/event-stream` que o Streamable HTTP exige. Quem envia é
> o cliente MCP (Claude, Cursor, Codex), e para esses a mesma URL responde
> 200. Para conferir no navegador que o servidor está vivo, use a **raiz**.

## Conectar (o que você manda para a sua rede)

> Para divulgar, use a página **[Conectar com
> IA](https://vitorwilher.github.io/nucleos/articles/conectar-ia.html)** —
> mesmo conteúdo escrito para quem não é desenvolvedor, cobrindo Claude,
> Claude Code, Cursor e Codex. O que segue aqui é a versão técnica.

O servidor é **authless** e fala **Streamable HTTP**, o transporte que os três
clientes abaixo suportam nativamente por URL — ninguém precisa instalar ponte
(`mcp-remote`), colar chave nem logar. Em todos, a URL é a mesma, terminada
em `/mcp`.

### Claude (claude.ai e Claude Desktop)

**Configurações → Connectors → Adicionar conector personalizado**, e preencha:

| Campo | Valor |
|---|---|
| Nome | `MCP Análise Macro — Núcleos de Inflação Brasil` |
| URL do servidor MCP remoto | `https://nucleos-mcp.analisemacro.workers.dev/mcp` |
| ID do Cliente OAuth | *(vazio)* |
| Client Secret OAuth | *(vazio)* |

Os campos de OAuth ficam vazios: o servidor é authless. Salvo, as ferramentas
`nucleos_*` aparecem no chat.

> O formulário pede o **nome antes da URL**, então o cliente não tem como
> sugeri-lo — ele ainda não falou com o servidor. Copie o nome da tabela para
> manter o rótulo consistente entre as pessoas.

> Funciona em **todos os planos** (Free inclusive — o Free permite 1 conector
> personalizado).

### Cursor

Em `~/.cursor/mcp.json` (global) ou `.cursor/mcp.json` (só no projeto):

```json
{
  "mcpServers": {
    "nucleos-ipca": {
      "url": "https://nucleos-mcp.analisemacro.workers.dev/mcp"
    }
  }
}
```

### Claude Code (terminal e VS Code)

```bash
# disponivel em todos os seus projetos
claude mcp add --scope user --transport http nucleos-ipca https://nucleos-mcp.analisemacro.workers.dev/mcp
```

Troque por `--scope project` para gravar um `.mcp.json` na raiz do repositório
— versionado no git, então quem clonar herda o conector (útil para turma ou
equipe). Confira com `claude mcp list` ou `/mcp` dentro da sessão.

### Codex CLI

Em `~/.codex/config.toml` (global) ou `.codex/config.toml` (só no projeto):

```toml
[mcp_servers.nucleos_ipca]
url = "https://nucleos-mcp.analisemacro.workers.dev/mcp"
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
