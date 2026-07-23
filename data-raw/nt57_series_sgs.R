# Codigos das series analiticas do IPCA no SGS do Banco Central.
#
# Fonte: Tabela 11 (Anexo II) da Nota Tecnica 57 do BCB (dez/2025).
#
# As series novas mantiveram os codigos que ja estavam em vigor. As series
# anteriores continuam disponiveis sob outros codigos, mas deixaram de ser
# atualizadas apos a publicacao da nota. Alimentacao no domicilio, MA, P55 e
# difusao nao sofreram modificacao alem da extensao do historico e por isso nao
# ganharam codigo para a versao anterior.

library(dplyr)

series_sgs <- tibble::tribble(
  ~serie,                      ~sgs,    ~sgs_anterior, ~funcao,
  "Administrados",              4449L,  29668L,        "agregar",
  "Livres",                    11428L,  29670L,        "agregar",
  "Alimentação no domicílio",  27864L,  NA_integer_,   "agregar",
  "Serviços",                  10844L,  29669L,        "agregar",
  "Bens industriais",          27863L,  29671L,        "agregar",
  "Comercializáveis",           4447L,  29666L,        "agregar",
  "Não comercializáveis",       4448L,  29667L,        "agregar",
  "Bens não duráveis",         10841L,  29672L,        "agregar",
  "Bens semiduráveis",         10842L,  29673L,        "agregar",
  "Bens duráveis",             10843L,  29674L,        "agregar",
  "Núcleo EX-FE",              28751L,  29682L,        "agregar",
  "Núcleo EX0",                11427L,  29677L,        "agregar",
  "Núcleo EX1",                16121L,  29678L,        "agregar",
  "Núcleo EX2",                27838L,  29679L,        "agregar",
  "Núcleo EX3",                27839L,  29680L,        "agregar",
  "EX3 Serviços",              29683L,  NA_integer_,   "agregar",
  "EX3 Industriais",           29684L,  NA_integer_,   "agregar",
  "Núcleo DP",                 16122L,  29681L,        "core_dp",
  "Núcleo MA",                 11426L,  NA_integer_,   "core_ma",
  "Núcleo MS",                  4466L,  29675L,        "core_ms",
  "Núcleo P55",                28750L,  NA_integer_,   "core_p55",
  "Difusão",                   21379L,  NA_integer_,   "difusao"
)

# Tabela 9: inicio das series novas. MS e DP comecam depois por exigirem
# historico minimo de observacoes.
series_sgs <- series_sgs |>
  mutate(
    inicio = dplyr::case_when(
      serie == "Núcleo MS" ~ as.Date("1991-12-01"),
      serie == "Núcleo DP" ~ as.Date("1995-01-01"),
      TRUE                 ~ as.Date("1991-01-01")
    )
  )

stopifnot(nrow(series_sgs) == 22)
stopifnot(!any(duplicated(series_sgs$sgs)))

usethis::use_data(series_sgs, overwrite = TRUE)
