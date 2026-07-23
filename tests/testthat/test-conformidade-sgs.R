# Testes de conformidade: comparam o resultado do pacote com a serie oficial
# publicada pelo BCB no SGS. Sao a unica evidencia de que os numeros calculados
# aqui sao mesmo os do Banco Central, e nao apenas plausiveis.
#
# Exigem rede e sao pulados no CRAN.

TOLERANCIA <- 0.01  # as series do BCB sao publicadas com duas casas decimais

confere <- function(calculado, codigo_sgs, desde = "2024-01") {
  ofi <- get_sgs(codigo_sgs, inicio = desde, fim = "2026-06")
  cmp <- dplyr::inner_join(calculado, ofi, by = "date", suffix = c("", "_oficial"))
  expect_gt(nrow(cmp), 0)
  expect_lte(
    max(abs(round(cmp$variacao, 2) - cmp$variacao_oficial)),
    TOLERANCIA
  )
  invisible(cmp)
}

test_that("as 17 series de agregacao simples reproduzem o SGS", {
  pula_sem_rede()

  ipca <- ipca_fixture()
  calc <- agregar(ipca)
  mapa <- dplyr::filter(series_sgs, funcao == "agregar")

  for (i in seq_len(nrow(mapa))) {
    serie <- mapa$serie[i]
    confere(dplyr::filter(calc, .data$serie == !!serie)[, c("date", "variacao")],
            mapa$sgs[i])
  }
})

test_that("o nucleo MA reproduz o SGS", {
  pula_sem_rede()
  confere(core_ma(ipca_fixture()), 11426)
})

test_that("o nucleo MS reproduz o SGS", {
  pula_sem_rede()
  confere(core_ms(ipca_fixture()), 4466, desde = "2021-01")
})

test_that("o nucleo DP reproduz o SGS", {
  pula_sem_rede()
  confere(core_dp(ipca_fixture()), 16122)
})

test_that("o nucleo P55 reproduz o SGS", {
  pula_sem_rede()
  confere(core_p55(ipca_fixture()), 28750)
})

test_that("a difusao reproduz o SGS", {
  pula_sem_rede()
  confere(difusao(ipca_fixture()), 21379)
})

test_that("get_ipca devolve o mesmo painel do snapshot", {
  pula_sem_rede()

  vivo <- get_ipca(inicio = "2024-01", fim = "2024-03", quiet = TRUE)
  fix  <- dplyr::filter(
    ipca_fixture(),
    date >= as.Date("2024-01-01"), date <= as.Date("2024-03-01")
  )
  expect_equal(
    dplyr::arrange(vivo, date, codigo),
    dplyr::arrange(fix, date, codigo)
  )
})
