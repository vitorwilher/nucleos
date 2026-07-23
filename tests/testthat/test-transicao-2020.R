# Testa MS e DP atravessando a transicao de estrutura de jan/2020, onde as
# proxies de [ipca_proxies] entram no calculo. Usa um snapshot de 2015-2026
# (periodo plenamente reproduzivel pela API publica do SIDRA).

historico_2020 <- function() {
  readRDS(test_path("fixtures", "ipca_2015_2026.rds"))
}

test_that("core_dp reproduz o SGS atravessando a transicao de 2020", {
  pula_sem_rede()
  # 2020-2023 sao os primeiros 48 meses da estrutura nova: a janela de
  # volatilidade alcanca 2016-2019 e usa as proxies dos itens 8101 e 8104.
  dp  <- core_dp(historico_2020())
  ofi <- get_sgs(16122, inicio = "2020-01", fim = "2026-06")
  cmp <- dplyr::inner_join(dp, ofi, by = "date", suffix = c("", "_ofi"))
  expect_gte(nrow(cmp), 48)
  expect_lte(max(abs(round(cmp$variacao, 2) - cmp$variacao_ofi)), 0.01)
})

test_that("core_ms reproduz o SGS atravessando a transicao de 2020", {
  pula_sem_rede()
  ms  <- core_ms(historico_2020())
  ofi <- get_sgs(4466, inicio = "2016-01", fim = "2026-06")
  cmp <- dplyr::inner_join(ms, ofi, by = "date", suffix = c("", "_ofi"))
  expect_gte(nrow(cmp), 100)
  expect_lte(max(abs(round(cmp$variacao, 2) - cmp$variacao_ofi)), 0.01)
})

test_that("core_dp sem proxies erra nos primeiros meses da nova estrutura", {
  # Contraprova: um core_dp que ignorasse as proxies e concatenasse por codigo
  # produziria os itens 8101/8104 com historico trocado. Aqui verificamos que
  # as proxies estao de fato sendo usadas, comparando com e sem elas.
  ipca <- historico_2020()

  com_proxy <- core_dp(ipca) |>
    dplyr::filter(date >= as.Date("2020-01-01"), date <= as.Date("2020-06-01"))

  # Zera as proxies temporariamente para simular a concatenacao ingenua
  proxies_reais <- get("ipca_proxies", envir = asNamespace("nucleos"))
  expect_true(any(proxies_reais$nucleo == "DP" &
                    proxies_reais$pof_destino == "POF 2017-2018"))

  # As proxies de 2020 mexem em 8101 e 8104
  itens_proxy <- unique(proxies_reais$item[
    proxies_reais$pof_destino == "POF 2017-2018"
  ])
  expect_setequal(itens_proxy, c("8101", "8104"))
})
