# CLAUDE.md

Guia para trabalhar neste repositório. O pacote R `nucleos` calcula as
séries analíticas derivadas do IPCA publicadas pelo Banco Central,
seguindo a **Nota Técnica 57** (dez/2025).

## Visão geral

- **Pacote R** que reproduz as **22 séries analíticas do IPCA** da NT
  57, das quais **9 são núcleos de inflação** (EX0–EX3, EX-FE, MA, MS,
  DP, P55). As demais: difusão, EX3 Serviços/Industriais e 10 agregações
  por segmento.
- Cada série é verificada contra a série oficial do **SGS** do BCB;
  reproduz até a 2ª casa decimal **de 1999 em diante** (MS exato desde
  1991).
- **Casa canônica:** `github.com/vitorwilher/nucleos` (público). O
  antigo `analisemacropro/nucleos` foi **arquivado**.
- **Site pkgdown:** <https://vitorwilher.github.io/nucleos/> (publicado
  via CI).

## Estrutura

- `R/` — funções:
  [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md),
  [`get_sgs()`](https://vitorwilher.github.io/nucleos/reference/get_sgs.md),
  [`agregar()`](https://vitorwilher.github.io/nucleos/reference/agregar.md)
  (17 agregações), `core_ma/ms/dp/p55()`,
  [`difusao()`](https://vitorwilher.github.io/nucleos/reference/difusao.md);
  helpers em `proxies.R`, `tratar_1991.R`.
- `data/` — datasets: `ipca_vetores`, `ipca_estruturas`,
  `ipca_ms_itens`, `ipca_proxies`, `series_sgs`, `ipca_exemplo` (recorte
  2015–2026).
- `data-raw/` — scripts que geram os datasets (a partir de
  `Vetores_NT_57.xlsx` e das tabelas transcritas da NT 57).
- `tests/testthat/` — 74 asserções, incl. conformidade contra o SGS.
- `vignettes/nucleos.Rmd` — tutorial com gráficos ggplot2.
- `paper/` — relatório técnico reprodutível (Quarto → PDF).
- `dashboard/` — pipeline de dados do dashboard (Fase 1; ver abaixo).

## Conceitos que não são óbvios no código

- O IPCA teve **5 estruturas** (POF) desde 1991; cada uma é uma tabela
  SIDRA diferente (58/61, 655/656, 2938, 1419, 7060).
  [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md)
  costura as cinco e devolve o **código estrutural** do IPCA (não o id
  interno do SIDRA).
- MS/DP usam **proxies de transição** entre estruturas (`ipca_proxies`)
  e são calculados **estrutura a estrutura** — um mesmo código (ex.:
  `8101.Cursos`) muda de significado entre estruturas, então uma
  história única por código contaminaria o cálculo.
- A janela de volatilidade do DP termina em **t-1** (não t).
- **Limitação conhecida:** 1991–1995 (planos Collor/Real) não é
  perfeitamente reproduzível da API pública do SIDRA — a divergência é
  de **fonte de dados**, não do método (até agregações simples divergem;
  o MS, que suaviza itens administrados, permanece exato). Ver
  [`?get_ipca`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md).

## Comandos de desenvolvimento

Rodar com
`RENV_CONFIG_AUTOLOADER_ENABLED=FALSE R_PROFILE_USER=/dev/null` para
ignorar o `renv` do projeto e usar a biblioteca do sistema (R 4.6).

``` bash
# Regenerar documentação e NAMESPACE
Rscript --vanilla -e 'roxygen2::roxygenise(".")'

# Rodar os testes
Rscript --vanilla -e 'devtools::load_all("."); testthat::test_local(".")'

# Instalar (pacote R puro, dispensa Rtools)
R CMD INSTALL . --no-multiarch --no-byte-compile

# Regenerar um dataset
Rscript data-raw/nt57_vetores.R

# Renderizar vignette / paper / README (precisa apontar o pandoc do Quarto)
Sys.setenv(RSTUDIO_PANDOC="c:/Users/vitor.lima/AppData/Local/Programs/Quarto/bin/tools")
```

## Armadilhas do ambiente (esta máquina)

- **Sem Rtools:** `devtools::check()` trava na checagem de build-tools
  mesmo sendo pacote R puro. Validar com `R CMD INSTALL` + testes. O
  `R CMD check` formal só roda no CI (Ubuntu).
- **`cdnjs.cloudflare.com` bloqueado:** o build local do pkgdown falha
  ao baixar JS (headroom, clipboard, fuse…). **Sempre construir o site
  via GitHub Actions**, não localmente.
- **`github.io` bloqueado:** não dá para abrir o site publicado a partir
  daqui; verificar via API do GitHub (conteúdo do branch `gh-pages`).
- **Repo dentro do Dropbox:** o sync trava arquivos em `.git` —
  operações git (branch, filter-branch, rm de pastas grandes) podem
  falhar na 1ª tentativa; repetir costuma resolver.
- **Git Bash quebra [`cat()`](https://rdrr.io/r/base/cat.html)
  multi-argumento do R** com aspas: escrever scripts R em arquivo e
  rodar com `Rscript`, não via `-e "..."` com muitas aspas.
- **Coleta do SIDRA é lenta e limitada a ~50k valores/requisição:**
  [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md)
  já pagina; a coleta histórica completa leva minutos.

## Contas e publicação

- **GitHub:** duas contas no `gh` — `vitorwilher` (pessoal, dona do
  repo) e `analisemacro` (admin na org). Trocar com
  `gh auth switch --user <conta>`. Push ao repo exige a conta
  `vitorwilher` ativa.
- **CI:** `pkgdown.yaml` publica o site em `gh-pages`;
  `dados-dashboard.yaml` atualiza os dados do dashboard mensalmente.

## Dashboard (em construção)

Produto: monitor dos núcleos do IPCA, atualizado mensalmente.
Arquitetura: **dados pré-calculados fora da sessão** (nunca coletar
SIDRA ao vivo no app).

- **Fase 1 (feita):** `dashboard/gerar_dados.R` calcula as séries e
  publica um artefato compacto como asset do release
  **`dashboard-dados`**. O app lê de
  `https://github.com/vitorwilher/nucleos/releases/download/dashboard-dados/series_nucleos.rds`.
  O artefato tem `series` (long: date, serie, variacao), `conformidade`
  e `metadata` (atualizado_em, ultimo_mes).
- **Fase 2 (próxima):** app Shiny lendo o artefato; deploy no
  **shinyapps.io** (conta paga da Análise Macro para cliente; a gratuita
  do Vítor só p/ teste). Escopo do beta: tela-resumo, leque de núcleos,
  núcleo médio, difusão, tabela + download, rodapé de confiança (selo
  “reproduz o SGS”).
