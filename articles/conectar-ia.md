# Conectar com IA

Os núcleos de inflação do IPCA estão disponíveis dentro do seu
assistente de IA. Você pergunta em português — *“os núcleos estão
desacelerando?”* — e a resposta vem com os números calculados pela
metodologia do Banco Central, conferidos contra as séries oficiais do
SGS.

**Não precisa instalar nada, criar conta nem colar chave de acesso.** O
servidor é público, gratuito, e só devolve dados: ele não acessa seus
arquivos.

O endereço é sempre este:

    https://nucleos-mcp.analisemacro.workers.dev/mcp

Escolha abaixo o programa que você usa.

## Claude (site e aplicativo)

O caminho mais simples — funciona em todos os planos, inclusive o
gratuito.

1.  Abra **Configurações → Connectors**.
2.  Clique em **Adicionar conector personalizado**.
3.  Preencha:

| Campo | O que colocar |
|----|----|
| Nome | `MCP Análise Macro — Núcleos de Inflação Brasil` |
| URL do servidor MCP remoto | `https://nucleos-mcp.analisemacro.workers.dev/mcp` |
| ID do Cliente OAuth | deixe vazio |
| Client Secret OAuth | deixe vazio |

4.  Clique em **Adicionar**.

Na primeira pergunta o Claude pede autorização para usar a ferramenta;
clique em **Sempre permitir**.

## Claude Code

Um comando só, no terminal:

``` bash
claude mcp add --scope user --transport http nucleos-ipca \
  https://nucleos-mcp.analisemacro.workers.dev/mcp
```

Confira com `claude mcp list` — deve aparecer como *Connected*. Dentro
de uma sessão, `/mcp` lista o servidor e suas ferramentas.

Trocando `--scope user` por `--scope project`, o conector fica gravado
no repositório (arquivo `.mcp.json`) e todo mundo que clonar o projeto
recebe o acesso junto — útil para turmas e equipes.

## Cursor

Crie ou edite o arquivo `~/.cursor/mcp.json`:

``` json
{
  "mcpServers": {
    "nucleos-ipca": {
      "url": "https://nucleos-mcp.analisemacro.workers.dev/mcp"
    }
  }
}
```

Para limitar a um projeto, use `.cursor/mcp.json` dentro dele.

Na tela de configurações do Cursor, na seção de MCP, o servidor aparece
com um ponto verde quando conecta. Se algo falhar, `Cmd+Shift+U` → **MCP
Logs** mostra o motivo.

O nome dessa tela muda entre versões do Cursor (“Tools & Integrations”,
“Tools & MCP”, “Customize”). O arquivo acima funciona em todas — por
isso o caminho recomendado aqui é editar o JSON.

## Codex (VS Code, terminal ou app do ChatGPT)

Crie ou edite o arquivo `~/.codex/config.toml`:

``` toml
[mcp_servers.nucleos_ipca]
url = "https://nucleos-mcp.analisemacro.workers.dev/mcp"
```

Os três — app do ChatGPT, Codex no terminal e extensão do VS Code — usam
o mesmo arquivo: configurou uma vez, vale em todos. Reinicie o VS Code
depois de salvar.

Na extensão há também caminho por menu: engrenagem → **MCP servers** →
**Add server** → **Streamable HTTP** → colar a URL.

**Se o Codex no VS Code não enxergar o servidor, não é erro seu:**
existe um problema conhecido e ainda aberto na extensão ([issue
\#6465](https://github.com/openai/codex/issues/6465)). Feche e abra o VS
Code por completo; se persistir, teste no Codex do terminal para
confirmar que a configuração está correta.

Não preencha nada de autenticação: o Codex tenta OAuth por padrão, mas
cai automaticamente para conexão sem autenticação, que é o caso aqui.

## Como saber se funcionou

Pergunte qualquer uma destas:

- *“Quais as últimas leituras dos núcleos do IPCA?”*
- *“Compare o núcleo MS com o IPCA cheio nos últimos 12 meses.”*
- *“A difusão do IPCA está subindo?”*
- *“Os núcleos estão convergindo para a meta?”*

Se vier uma tabela de números citando a Nota Técnica 57 do Banco
Central, está funcionando.

## O que ele responde

23 séries mensais do IPCA, de 2000 até a última divulgação:

- **9 núcleos de inflação:** EX0, EX1, EX2, EX3, EX-FE, MA, MS, DP e P55
- **Difusão** — proporção de itens que subiram no mês
- **IPCA cheio** e 12 agregações por segmento: serviços, administrados,
  livres, duráveis, comercializáveis, alimentação no domicílio, entre
  outras

As séries são calculadas por este pacote e reproduzem as oficiais do
SGS/BCB até a segunda casa decimal, de 1999 em diante, seguindo a [Nota
Técnica 57](https://www.bcb.gov.br/) (BCB, dezembro de 2025).

## Perguntas frequentes

**É seguro?** O servidor só devolve dados públicos do IPCA. Ele não lê
seus arquivos nem seus dados — no protocolo, um servidor desses apenas
responde ao que é perguntado.

**É pago?** Não.

**Com que frequência atualiza?** A cada divulgação mensal do IPCA.
Pergunte ao assistente se o dado está atualizado e ele informa a data do
último fechamento — e avisa quando o intervalo está grande demais.

**Preciso saber programar?** Não. O único passo técnico é colar uma
linha num arquivo de configuração; no Claude, nem isso.

**Como isso funciona por baixo?** Pelo [Model Context
Protocol](https://modelcontextprotocol.io), um padrão aberto que permite
a assistentes de IA consultarem fontes de dados externas. O código do
servidor está [no
repositório](https://github.com/vitorwilher/nucleos/tree/master/mcp).
