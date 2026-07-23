# Tabelas da Nota Tecnica 57 do BCB (dez/2025), transcritas do PDF.
#
# Fonte: https://www.bcb.gov.br/content/publicacoes/notastecnicas/NT_57_202512.pdf
#
# Gera tres conjuntos de dados:
#   ipca_estruturas   -- Tabela 1 + tabelas do SIDRA correspondentes
#   ipca_ms_itens     -- Tabela 5 (itens com variacao suavizada no nucleo MS)
#   ipca_proxies      -- Tabelas 2-4 (DP) e 6-8 (MS)

library(dplyr)

# --- Tabela 1: estruturas do IPCA -------------------------------------------
#
# As tabelas do SIDRA foram identificadas consultando os metadados da API do
# IBGE (servicodados.ibge.gov.br/api/v3/agregados/<id>/metadados). A cobertura
# das cinco tabelas e continua entre jan/1991 e o presente.
#
# Nas estruturas mais antigas, variacao mensal e peso mensal estao em tabelas
# separadas; a partir de jul/2006 as duas variaveis convivem na mesma tabela.

# A classificacao que carrega a hierarquia do IPCA muda de codigo entre as
# tabelas: as duas mais antigas usam 'c72', as demais 'c315'. O numero de
# categorias de cada tabela coincide exatamente com o numero de componentes da
# aba correspondente do Vetores_NT_57.xlsx (423, 593, 465, 464 e 457).

# `n_componentes` e o numero de categorias da classificacao em cada tabela.
# Serve para dimensionar os lotes de requisicao: a API do SIDRA recusa
# consultas acima de 50.000 valores. Confere exatamente com o numero de
# componentes da aba correspondente do Vetores_NT_57.xlsx.

ipca_estruturas <- tibble::tribble(
  ~pof,             ~inicio,       ~fim,          ~tabela_variacao, ~tabela_peso, ~classificacao, ~n_componentes,
  "POF 1987-1988",  "1991-01-01",  "1999-07-01",  58L,              61L,          "c72",          423L,
  "POF 1995-1996",  "1999-08-01",  "2006-06-01",  655L,             656L,         "c315",         593L,
  "POF 2002-2003",  "2006-07-01",  "2011-12-01",  2938L,            2938L,        "c315",         465L,
  "POF 2008-2009",  "2012-01-01",  "2019-12-01",  1419L,            1419L,        "c315",         464L,
  "POF 2017-2018",  "2020-01-01",  NA_character_, 7060L,            7060L,        "c315",         457L
) |>
  mutate(inicio = as.Date(inicio), fim = as.Date(fim))

# --- Tabela 5: itens com variacao suavizada no nucleo MS --------------------
#
# Nove itens por estrutura, com duas excecoes: '8104.Cursos diversos' ainda nao
# existia ate jun/2006, e entre jan/91-jul/99 os itens '7301.Educacao' e
# '5201.Comunicacoes' substituem '8101.Cursos regulares' e '9101.Comunicacao'.

ipca_ms_itens <- tibble::tribble(
  ~pof,             ~codigo,
  "POF 1987-1988",  c("2201", "2202", "5101", "5104", "7101", "7202", "7301", "5201"),
  "POF 1995-1996",  c("2201", "2202", "5101", "5104", "7101", "7202", "8101", "9101"),
  "POF 2002-2003",  c("2201", "2202", "5101", "5104", "7101", "7202", "8101", "8104", "9101"),
  "POF 2008-2009",  c("2201", "2202", "5101", "5104", "7101", "7202", "8101", "8104", "9101"),
  "POF 2017-2018",  c("2201", "2202", "5101", "5104", "7101", "7202", "8101", "8104", "9101")
) |>
  tidyr::unnest(codigo)

# --- Tabelas 2-4 e 6-8: proxies de transicao entre estruturas ---------------
#
# Cada proxy define a serie de um item da estrutura nova em termos de
# componentes da estrutura anterior, como media ponderada com os sinais
# indicados. Usadas apenas nos primeiros meses de vigencia de cada estrutura:
# 48 meses no nucleo DP e 11 meses no MS.
#
# As proxies do MS (Tabelas 6-8) seguem as mesmas definicoes das do DP, mas
# cobrem apenas o subconjunto de itens que o MS suaviza.

proxy <- function(nucleo, pof_destino, item, alvo, sinal, origem) {
  tibble::tibble(
    nucleo      = nucleo,
    pof_destino = pof_destino,
    item        = item,
    sinal       = sinal,
    componente  = origem,
    rotulo      = alvo
  )
}

# Tabela 2 - DP: jan/91-jul/99 -> ago/99-jun/06
dp_t2 <- dplyr::bind_rows(
  proxy("DP", "POF 1995-1996", "1117", "Alimentos prontos",               +1, "11"),
  proxy("DP", "POF 1995-1996", "3301", "Consertos e manutencao",          +1, "3102038"),
  proxy("DP", "POF 1995-1996", "3102", "Utensilios e enfeites",           +1, "3102"),
  proxy("DP", "POF 1995-1996", "3102", "Utensilios e enfeites",           -1, "3102038"),
  proxy("DP", "POF 1995-1996", "6203", "Plano de saude",                  +1, "6202005"),
  proxy("DP", "POF 1995-1996", "6202", "Servicos laboratoriais e hosp.",  +1, "6202"),
  proxy("DP", "POF 1995-1996", "6202", "Servicos laboratoriais e hosp.",  -1, "6202005"),
  proxy("DP", "POF 1995-1996", "7203", "Fotografia e filmagem",           +1, "7201011"),
  proxy("DP", "POF 1995-1996", "7203", "Fotografia e filmagem",           +1, "7201013"),
  proxy("DP", "POF 1995-1996", "7201", "Recreacao",                       +1, "7201"),
  proxy("DP", "POF 1995-1996", "7201", "Recreacao",                       -1, "7201011"),
  proxy("DP", "POF 1995-1996", "7201", "Recreacao",                       -1, "7201013"),
  proxy("DP", "POF 1995-1996", "8101", "Cursos",                          +1, "7301004"),
  proxy("DP", "POF 1995-1996", "8101", "Cursos",                          +1, "7301006"),
  proxy("DP", "POF 1995-1996", "8101", "Cursos",                          +1, "7301007"),
  proxy("DP", "POF 1995-1996", "8101", "Cursos",                          +1, "7301020"),
  proxy("DP", "POF 1995-1996", "8101", "Cursos",                          +1, "7301021"),
  proxy("DP", "POF 1995-1996", "8103", "Papelaria",                       +1, "7301002"),
  proxy("DP", "POF 1995-1996", "8103", "Papelaria",                       +1, "7301003"),
  proxy("DP", "POF 1995-1996", "8102", "Leitura",                         +1, "7302"),
  proxy("DP", "POF 1995-1996", "9101", "Comunicacao",                     +1, "5201")
)

# Tabela 3 - DP: ago/99-jun/06 -> jul/06-dez/11
dp_t3 <- dplyr::bind_rows(
  proxy("DP", "POF 2002-2003", "8104", "Cursos diversos", +1, "8101014"),
  proxy("DP", "POF 2002-2003", "8102", "Leitura",         +1, "8102"),
  proxy("DP", "POF 2002-2003", "8102", "Leitura",         +1, "8101018"),
  proxy("DP", "POF 2002-2003", "8102", "Leitura",         +1, "8101024"),
  proxy("DP", "POF 2002-2003", "8101", "Cursos",          +1, "8101"),
  proxy("DP", "POF 2002-2003", "8101", "Cursos",          -1, "8101014"),
  proxy("DP", "POF 2002-2003", "8101", "Cursos",          -1, "8101018"),
  proxy("DP", "POF 2002-2003", "8101", "Cursos",          -1, "8101024")
)

# Tabela 4 - DP: jan/12-dez/19 -> jan/20-presente
# (a transicao jul/06-dez/11 -> jan/12-dez/19 nao exigiu compatibilizacao)
dp_t4 <- dplyr::bind_rows(
  proxy("DP", "POF 2017-2018", "8101", "Cursos regulares", +1, "8101"),
  proxy("DP", "POF 2017-2018", "8101", "Cursos regulares", +1, "8104002"),
  proxy("DP", "POF 2017-2018", "8104", "Cursos diversos",  +1, "8104"),
  proxy("DP", "POF 2017-2018", "8104", "Cursos diversos",  -1, "8104002")
)

# Tabela 6 - MS: jan/91-jul/99 -> ago/99-jun/06
ms_t6 <- dplyr::bind_rows(
  proxy("MS", "POF 1995-1996", "8101", "Cursos",      +1, "7301004"),
  proxy("MS", "POF 1995-1996", "8101", "Cursos",      +1, "7301006"),
  proxy("MS", "POF 1995-1996", "8101", "Cursos",      +1, "7301007"),
  proxy("MS", "POF 1995-1996", "8101", "Cursos",      +1, "7301020"),
  proxy("MS", "POF 1995-1996", "8101", "Cursos",      +1, "7301021"),
  proxy("MS", "POF 1995-1996", "9101", "Comunicacao", +1, "5201")
)

# Tabela 7 - MS: ago/99-jun/06 -> jul/06-dez/11
ms_t7 <- dplyr::bind_rows(
  proxy("MS", "POF 2002-2003", "8104", "Cursos diversos", +1, "8101014"),
  proxy("MS", "POF 2002-2003", "8101", "Cursos",          +1, "8101"),
  proxy("MS", "POF 2002-2003", "8101", "Cursos",          -1, "8101014"),
  proxy("MS", "POF 2002-2003", "8101", "Cursos",          -1, "8101018"),
  proxy("MS", "POF 2002-2003", "8101", "Cursos",          -1, "8101024")
)

# Tabela 8 - MS: jan/12-dez/19 -> jan/20-presente
ms_t8 <- dplyr::bind_rows(
  proxy("MS", "POF 2017-2018", "8101", "Cursos regulares", +1, "8101"),
  proxy("MS", "POF 2017-2018", "8101", "Cursos regulares", +1, "8104002"),
  proxy("MS", "POF 2017-2018", "8104", "Cursos diversos",  +1, "8104"),
  proxy("MS", "POF 2017-2018", "8104", "Cursos diversos",  -1, "8104002")
)

ipca_proxies <- dplyr::bind_rows(dp_t2, dp_t3, dp_t4, ms_t6, ms_t7, ms_t8) |>
  dplyr::relocate(rotulo, .after = item)

# --- Verificacoes -----------------------------------------------------------

# A cobertura das estruturas deve ser continua, sem buracos nem sobreposicao.
# As datas sao marcadores de mes (sempre dia 1), entao o inicio de cada
# estrutura deve ser exatamente o mes seguinte ao fim da anterior.
mes_seguinte <- function(x) as.Date(format(seq(x, by = "month", length.out = 2)[2]))
stopifnot(all(
  ipca_estruturas$inicio[-1] ==
    vapply(ipca_estruturas$fim[-nrow(ipca_estruturas)], mes_seguinte, as.Date(NA))
))

# Tabela 5: nove itens por estrutura, exceto as duas primeiras (sem '8104').
stopifnot(identical(
  as.integer(table(ipca_ms_itens$pof)[ipca_estruturas$pof]),
  c(8L, 8L, 9L, 9L, 9L)
))

stopifnot(all(ipca_proxies$sinal %in% c(-1, 1)))

usethis::use_data(ipca_estruturas, ipca_ms_itens, ipca_proxies, overwrite = TRUE)
