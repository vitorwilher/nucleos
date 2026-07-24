# Como instalar o MCP Análise Macro — Núcleos de Inflação Brasil

Guia para conectar os núcleos de inflação do IPCA ao seu assistente de IA.
Depois de instalado, você pergunta em português — *"os núcleos estão
desacelerando?"* — e a resposta vem com os números oficiais, calculados pela
metodologia do Banco Central.

**Não precisa instalar nada no seu computador, nem criar conta, nem colar
chave.** O servidor é público e só devolve dados; ele não acessa seus arquivos.

O endereço é sempre este:

```
https://nucleos-mcp.analisemacro.workers.dev/mcp
```

Escolha abaixo o programa que você usa.

---

## Claude (site e aplicativo) — o mais simples

Funciona em todos os planos, inclusive o gratuito.

1. Abra **Configurações → Connectors**.
2. Clique em **Adicionar conector personalizado**.
3. Preencha:

   | Campo | O que colocar |
   |---|---|
   | Nome | `MCP Análise Macro — Núcleos de Inflação Brasil` |
   | URL do servidor MCP remoto | `https://nucleos-mcp.analisemacro.workers.dev/mcp` |
   | ID do Cliente OAuth | deixe **vazio** |
   | Client Secret OAuth | deixe **vazio** |

4. Clique em **Adicionar**.

Na primeira pergunta, o Claude vai pedir autorização para usar a ferramenta —
clique em **Sempre permitir**.

---

## Claude Code (terminal ou VS Code)

Um comando só:

```bash
claude mcp add --scope user --transport http nucleos-ipca https://nucleos-mcp.analisemacro.workers.dev/mcp
```

Confira com `claude mcp list` — deve aparecer como *Connected*. Dentro de uma
sessão, `/mcp` mostra o servidor e suas ferramentas.

> Use `--scope project` no lugar de `--scope user` se quiser que o conector
> fique gravado no repositório (arquivo `.mcp.json`), para que todo mundo que
> clonar o projeto já receba o acesso.

---

## Cursor

Crie ou edite o arquivo `~/.cursor/mcp.json` (vale para todos os projetos):

```json
{
  "mcpServers": {
    "nucleos-ipca": {
      "url": "https://nucleos-mcp.analisemacro.workers.dev/mcp"
    }
  }
}
```

Se preferir limitar a um projeto, use `.cursor/mcp.json` dentro dele.

Para conferir, abra **Cursor Settings** e procure a seção de MCP / Tools: o
servidor aparece com um **ponto verde** quando está conectado. Se der erro,
`Cmd+Shift+U` → **MCP Logs** mostra o motivo.

> A tela de configuração do Cursor muda de nome entre versões (já se chamou
> "Tools & Integrations", "Tools & MCP", "Customize"). O arquivo acima funciona
> em todas — por isso o caminho recomendado aqui é editar o JSON.

---

## Codex (VS Code ou terminal)

Crie ou edite o arquivo `~/.codex/config.toml`:

```toml
[mcp_servers.nucleos_ipca]
url = "https://nucleos-mcp.analisemacro.workers.dev/mcp"
```

O aplicativo do ChatGPT, o Codex no terminal e a extensão do VS Code **usam o
mesmo arquivo** — configurou uma vez, vale nos três. Reinicie o VS Code depois
de salvar.

Na extensão também existe caminho por menu: engrenagem → **MCP servers** →
**Add server** → escolher **Streamable HTTP** → colar a URL.

> **Se o Codex no VS Code não enxergar o servidor**, não é erro seu: existe um
> problema conhecido e ainda aberto na extensão
> ([issue #6465](https://github.com/openai/codex/issues/6465)). Feche e abra o
> VS Code por completo; se persistir, teste no Codex do terminal para
> confirmar que a configuração está certa.

> Não preencha nada de autenticação. O Codex tenta OAuth por padrão, mas cai
> automaticamente para conexão sem autenticação — que é o caso aqui.

---

## Como saber se funcionou

Pergunte qualquer uma destas:

- *"Quais as últimas leituras dos núcleos do IPCA?"*
- *"Compare o núcleo MS com o IPCA cheio nos últimos 12 meses."*
- *"A difusão do IPCA está subindo?"*
- *"Os núcleos estão convergindo para a meta?"*

Se o assistente responder com uma tabela de números e citar a Nota Técnica 57
do Banco Central, está funcionando.

---

## O que ele sabe responder

23 séries mensais do IPCA, de 2000 até hoje:

- **9 núcleos de inflação:** EX0, EX1, EX2, EX3, EX-FE, MA, MS, DP e P55
- **Difusão** — proporção de itens que subiram no mês
- **IPCA cheio** e 12 agregações: serviços, administrados, livres, duráveis,
  comercializáveis, alimentação no domicílio, entre outras

Os números reproduzem as séries oficiais do **SGS/Banco Central** até a segunda
casa decimal, de 1999 em diante. O cálculo segue a **Nota Técnica 57** (BCB,
dez/2025) e é feito pelo pacote R [`nucleos`](https://github.com/vitorwilher/nucleos),
de código aberto.

## Perguntas frequentes

**É seguro?** O servidor só devolve dados públicos do IPCA. Ele não lê seus
arquivos nem seus dados — no protocolo, um servidor desses só responde ao que
é perguntado.

**É pago?** Não.

**Com que frequência atualiza?** A cada divulgação mensal do IPCA. Se você
perguntar se o dado está atualizado, o próprio assistente informa a data do
último fechamento — e avisa quando o intervalo está grande demais.

**Preciso saber programar?** Não. O único passo "técnico" é colar uma linha num
arquivo de configuração, e no Claude nem isso.
