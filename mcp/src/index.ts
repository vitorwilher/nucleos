// MCP Análise Macro — v1 (núcleos do IPCA)
//
// Servidor MCP remoto e *authless* que expõe as séries analíticas do IPCA
// (Nota Técnica 57 do BCB) calculadas pelo pacote R `nucleos`. Os dados são um
// snapshot pré-calculado embutido (src/data.json); o Worker não coleta SIDRA
// nem roda R. Para atualizar, regenere o snapshot e re-deploye.
//
// Rotas: POST /mcp (Streamable HTTP) e /sse (legado). Adicione a URL .../mcp
// como "custom connector" no Claude.ai.

import { McpAgent } from "agents/mcp";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import snapshot from "./data.json";

// --- Dados -----------------------------------------------------------------

type Serie = { d: string[]; v: number[] };
const SERIES = snapshot.series as Record<string, Serie>;
const META = snapshot.metadata;
const NOMES = Object.keys(SERIES);
const NUCLEOS = NOMES.filter((n) => n.startsWith("Núcleo"));

const norm = (s: string) =>
  s
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .trim();

// Resolve um nome digitado (tolerante a acento/caixa/abreviação) para o nome
// canônico da série. Ex.: "ms" -> "Núcleo MS", "ipca" -> "IPCA cheio".
function resolveSerie(q: string): string | null {
  const nq = norm(q);
  let hit = NOMES.find((n) => norm(n) === nq);
  if (hit) return hit;
  hit = NOMES.find((n) => norm(n) === norm("Núcleo " + q));
  if (hit) return hit;
  const parciais = NOMES.filter((n) => norm(n).includes(nq));
  return parciais.length === 1 ? parciais[0] : (parciais[0] ?? null);
}

// A difusão não é uma variação de preço e sim um *nível*: a proporção (%) de
// itens do IPCA com variação positiva no mês. Compor essa série como se fosse
// juros produz numeros sem sentido (tres meses ~60% "acumulariam" ~300%), entao
// para ela reportamos a media do periodo, nao o acumulado composto.
const ehNivel = (nome: string) => norm(nome) === "difusao";

// Variação acumulada (composta) dos últimos n meses de uma série mensal (% a.m.).
function acumulado(v: number[], n: number): number | null {
  if (v.length < n) return null;
  const jan = v.slice(v.length - n);
  const fator = jan.reduce((acc, x) => acc * (1 + x / 100), 1);
  return Math.round((fator - 1) * 10000) / 100;
}

// Média simples dos últimos n meses — agregação correta para séries de nível.
function media(v: number[], n: number): number | null {
  if (v.length < n) return null;
  const jan = v.slice(v.length - n);
  return Math.round((jan.reduce((a, x) => a + x, 0) / n) * 100) / 100;
}

// Agrega os últimos n meses conforme a natureza da série.
const agregado = (nome: string, v: number[], n: number) =>
  ehNivel(nome) ? media(v, n) : acumulado(v, n);

const fmt = (x: number | null) => (x === null ? "—" : x.toFixed(2));

// --- Servidor MCP ----------------------------------------------------------

export class NucleosMCP extends McpAgent {
  server = new McpServer(
    {
      // `name` e o identificador programatico (estavel, sem acento); `title` e
      // o nome legivel que os clientes usam na interface e sugerem ao cadastrar
      // o conector -- sem ele, o usuario precisa inventar um rotulo na mao.
      name: "nucleos-ipca",
      title: "MCP Núcleos de Inflação — Brasil",
      version: "1.0.0",
    },
    {
      // Enviado ao cliente no handshake: orienta o modelo sobre o que este
      // servidor cobre e sobre as duas armadilhas do dominio (a unidade da
      // difusao e a natureza estatica do snapshot).
      instructions: [
        "Servidor das séries analíticas do IPCA (Banco Central do Brasil, Nota Técnica 57):",
        "9 núcleos de inflação, difusão, IPCA cheio e agregações por segmento — 23 séries mensais.",
        "",
        "Ao usar:",
        "- Comece por `nucleos_ultimas` para um panorama do mês; use `nucleos_serie` para",
        "  a história de uma série e `nucleos_comparar` para confrontar séries.",
        "- Os dados são um snapshot pré-calculado, não uma consulta ao vivo. Consulte",
        "  `nucleos_metadata` antes de afirmar que uma leitura é a mais recente disponível.",
        "- A Difusão é a proporção (%) de itens com variação positiva no mês — um nível, não",
        "  uma variação de preço. Não a acumule nem a compare em nível com os núcleos.",
        "- As séries reproduzem as oficiais do SGS/BCB até a 2ª casa decimal de 1999 em diante.",
      ].join("\n"),
    },
  );

  async init() {
    // 1) Listar séries disponíveis --------------------------------------
    this.server.tool(
      "nucleos_listar",
      "Lista todas as séries analíticas do IPCA disponíveis (núcleos, agregações por segmento, difusão e IPCA cheio).",
      {},
      async () => {
        const txt = [
          `**${NOMES.length} séries disponíveis** (metodologia NT 57 do BCB).`,
          "",
          `**Núcleos de inflação (${NUCLEOS.length}):** ${NUCLEOS.join(", ")}`,
          "",
          `**Demais séries:** ${NOMES.filter((n) => !NUCLEOS.includes(n)).join(", ")}`,
        ].join("\n");
        return { content: [{ type: "text", text: txt }] };
      },
    );

    // 2) Metadados -------------------------------------------------------
    this.server.tool(
      "nucleos_metadata",
      "Retorna a proveniência e o estado do conjunto de dados: última referência mensal, data de atualização, fonte, metodologia e há quanto tempo o snapshot foi gerado. Consulte antes de afirmar que um dado é o mais recente.",
      {},
      async () => {
        // O snapshot é estático (embutido no Worker) e só muda por re-deploy.
        // Calculamos a idade em tempo de execução para que uma versão esquecida
        // no ar não passe por dado corrente.
        const dias = Math.floor(
          (Date.now() - Date.parse(META.atualizado_em)) / 86_400_000,
        );
        const alerta =
          dias > 45
            ? `\n> ⚠️ **Snapshot gerado há ${dias} dias.** O IPCA é mensal; um intervalo assim sugere que há divulgação mais recente do IBGE ainda não refletida aqui. Confira antes de tratar estes números como os últimos disponíveis.`
            : "";
        const txt = [
          `**Último mês de referência:** ${META.ultimo_mes}`,
          `**Atualizado em:** ${META.atualizado_em} (há ${dias} dia${dias === 1 ? "" : "s"})`,
          `**Nº de séries:** ${META.n_series}`,
          `**Fonte:** ${META.fonte}`,
          `**Metodologia:** ${META.metodologia}`,
          alerta,
          "",
          "_As séries reproduzem as oficiais do SGS/BCB até a 2ª casa decimal (de 1999 em diante). Os dados são um snapshot pré-calculado, atualizado por re-deploy — não uma consulta ao vivo ao SIDRA._",
        ].filter(Boolean).join("\n");
        return { content: [{ type: "text", text: txt }] };
      },
    );

    // 3) Últimas leituras + aceleração + acumulados ----------------------
    this.server.tool(
      "nucleos_ultimas",
      "Últimas leituras de todas as séries no mês de referência: variação mensal (%), aceleração vs. o mês anterior (p.p.) e acumulados em 3 e 12 meses. Use para um panorama rápido.",
      { apenas_nucleos: z.boolean().optional().describe("Se true, restringe aos 9 núcleos + IPCA cheio.") },
      async ({ apenas_nucleos }) => {
        const alvo = apenas_nucleos ? [...NUCLEOS, "IPCA cheio"] : NOMES;
        const ordenado = [
          ...NUCLEOS.filter((n) => alvo.includes(n)),
          ...alvo.filter((n) => !NUCLEOS.includes(n)),
        ];
        const linhas = ordenado.map((nm) => {
          const s = SERIES[nm];
          const n = s.v.length;
          const mm = s.v[n - 1];
          const acel = n >= 2 ? Math.round((mm - s.v[n - 2]) * 100) / 100 : null;
          return `| ${nm} | ${fmt(mm)} | ${acel === null ? "—" : (acel > 0 ? "+" : "") + acel.toFixed(2)} | ${fmt(agregado(nm, s.v, 3))} | ${fmt(agregado(nm, s.v, 12))} |`;
        });
        const temNivel = ordenado.some(ehNivel);
        const txt = [
          `**IPCA — leituras de ${META.ultimo_mes}** (variação % ao mês)`,
          "",
          "| Série | Mês (%) | Aceleração (p.p.) | Acum. 3m (%) | Acum. 12m (%) |",
          "|---|---:|---:|---:|---:|",
          ...linhas,
          "",
          temNivel
            ? "_A Difusão é a proporção (%) de itens com variação positiva no mês, não uma variação de preço: para ela, as colunas 3m/12m trazem a **média** do período, não o acumulado._"
            : "",
          `_Fonte: ${META.fonte}. NT 57/BCB. Atualizado em ${META.atualizado_em}._`,
        ].filter(Boolean).join("\n");
        return { content: [{ type: "text", text: txt }] };
      },
    );

    // 4) Série temporal --------------------------------------------------
    this.server.tool(
      "nucleos_serie",
      "Retorna a série temporal (mensal) de uma série nomeada. Filtre por período (desde/ate, formato YYYY-MM) ou pelos últimos N meses.",
      {
        serie: z.string().describe('Nome da série, ex.: "Núcleo MS", "MS", "IPCA cheio", "Difusão".'),
        desde: z.string().optional().describe("Primeiro mês, formato YYYY-MM."),
        ate: z.string().optional().describe("Último mês, formato YYYY-MM."),
        ultimos: z.number().int().positive().optional().describe("Nº de meses mais recentes (ignora desde/ate)."),
      },
      async ({ serie, desde, ate, ultimos }) => {
        const nome = resolveSerie(serie);
        if (!nome) {
          return {
            content: [{ type: "text", text: `Série "${serie}" não encontrada. Use nucleos_listar para ver os nomes disponíveis.` }],
            isError: true,
          };
        }
        const s = SERIES[nome];
        let idx = s.d.map((_, i) => i);
        if (ultimos) {
          idx = idx.slice(-ultimos);
        } else {
          if (desde) idx = idx.filter((i) => s.d[i] >= desde);
          if (ate) idx = idx.filter((i) => s.d[i] <= ate);
        }
        if (idx.length === 0) {
          return { content: [{ type: "text", text: `Sem observações de "${nome}" no período pedido.` }], isError: true };
        }
        const linhas = idx.map((i) => `| ${s.d[i]} | ${s.v[i].toFixed(2)} |`);
        const vv = idx.map((i) => s.v[i]);
        const nivel = ehNivel(nome);
        const txt = [
          nivel
            ? `**${nome}** — % dos itens do IPCA com variação positiva (${s.d[idx[0]]} a ${s.d[idx[idx.length - 1]]}, ${idx.length} meses)`
            : `**${nome}** — variação % ao mês (${s.d[idx[0]]} a ${s.d[idx[idx.length - 1]]}, ${idx.length} meses)`,
          "",
          nivel ? "| Mês | Itens em alta (%) |" : "| Mês | Var. (%) |",
          "|---|---:|",
          ...linhas,
          "",
          nivel
            ? `Média no período: ${fmt(media(vv, vv.length))}%. _A difusão é um nível, não uma variação de preço — não se acumula._`
            : `Acumulado no período: ${fmt(acumulado(vv, vv.length))}%.`,
          `_NT 57/BCB. Atualizado em ${META.atualizado_em}._`,
        ].join("\n");
        return { content: [{ type: "text", text: txt }] };
      },
    );

    // 5) Comparar séries -------------------------------------------------
    this.server.tool(
      "nucleos_comparar",
      "Compara várias séries lado a lado: variação no mês de referência, aceleração e acumulados 3m/12m. Útil para confrontar núcleos entre si ou contra o IPCA cheio.",
      {
        series: z.array(z.string()).min(2).describe('Nomes das séries a comparar, ex.: ["Núcleo MS","Núcleo P55","IPCA cheio"].'),
        mes: z.string().optional().describe("Mês de referência YYYY-MM (padrão: último disponível)."),
      },
      async ({ series, mes }) => {
        const naoachou: string[] = [];
        const nomes = series.map((q) => {
          const n = resolveSerie(q);
          if (!n) naoachou.push(q);
          return n;
        }).filter((n): n is string => n !== null);
        if (nomes.length < 2) {
          return { content: [{ type: "text", text: `Não reconheci séries suficientes. Não encontradas: ${naoachou.join(", ")}. Use nucleos_listar.` }], isError: true };
        }
        const linhas = nomes.map((nm) => {
          const s = SERIES[nm];
          let j = s.v.length - 1;
          if (mes) {
            const k = s.d.indexOf(mes);
            if (k >= 0) j = k;
          }
          const mm = s.v[j];
          const acel = j >= 1 ? Math.round((mm - s.v[j - 1]) * 100) / 100 : null;
          const a3 = agregado(nm, s.v.slice(0, j + 1), 3);
          const a12 = agregado(nm, s.v.slice(0, j + 1), 12);
          return `| ${nm} | ${s.d[j]} | ${fmt(mm)} | ${acel === null ? "—" : (acel > 0 ? "+" : "") + acel.toFixed(2)} | ${fmt(a3)} | ${fmt(a12)} |`;
        });
        const txt = [
          `**Comparação de séries** (variação % ao mês)`,
          naoachou.length ? `_Ignoradas (não encontradas): ${naoachou.join(", ")}._\n` : "",
          "| Série | Mês | Var. (%) | Aceleração (p.p.) | Acum. 3m (%) | Acum. 12m (%) |",
          "|---|---|---:|---:|---:|---:|",
          ...linhas,
          "",
          nomes.some(ehNivel)
            ? "_A Difusão é a proporção (%) de itens com variação positiva no mês, não uma variação de preço: para ela, as colunas 3m/12m trazem a **média** do período. Não é comparável em nível com as demais séries._"
            : "",
          `_NT 57/BCB. Atualizado em ${META.atualizado_em}._`,
        ].filter(Boolean).join("\n");
        return { content: [{ type: "text", text: txt }] };
      },
    );
  }
}

// --- Roteamento HTTP -------------------------------------------------------

export default {
  fetch(request: Request, env: unknown, ctx: ExecutionContext) {
    const url = new URL(request.url);
    if (url.pathname === "/mcp") {
      return NucleosMCP.serve("/mcp").fetch(request, env as never, ctx);
    }
    if (url.pathname === "/sse" || url.pathname === "/sse/message") {
      return NucleosMCP.serveSSE("/sse").fetch(request, env as never, ctx);
    }
    if (url.pathname === "/" || url.pathname === "/health") {
      return new Response(
        `MCP Análise Macro — Núcleos do IPCA (NT 57/BCB)\nÚltimo mês: ${META.ultimo_mes} | Atualizado: ${META.atualizado_em}\nConector MCP em: ${url.origin}/mcp`,
        { headers: { "content-type": "text/plain; charset=utf-8" } },
      );
    }
    return new Response("Not found", { status: 404 });
  },
};
