# Testes do tratamento de agosto e setembro de 1991 (Subsecao 2.7 da NT 57),
# exercitando os helpers internos diretamente com paineis sinteticos.

test_that("a raiz geometrica do bimestre reproduz o acumulado", {
  # Uma variacao mensal r aplicada dois meses reproduz o acumulado.
  r <- nucleos:::raiz_geometrica_bimestre(21)  # set/91 acumulado de 21%
  expect_equal((1 + r / 100)^2 - 1, 0.21, tolerance = 1e-12)
})

test_that("desdobrar cria agosto/91 igual a setembro com variacao mensal", {
  painel <- tibble::tibble(
    date     = as.Date(c("1991-07-01", "1991-09-01")),
    codigo   = "0",
    nivel    = "Geral",
    variacao = c(10, 21),   # set/91 e o acumulado do bimestre
    peso     = 100
  )
  out <- nucleos:::desdobrar_bimestre_1991(painel)

  expect_true(as.Date("1991-08-01") %in% out$date)
  ago <- out$variacao[out$date == as.Date("1991-08-01")]
  set <- out$variacao[out$date == as.Date("1991-09-01")]
  expect_equal(ago, set)
  expect_equal((1 + ago / 100)^2 - 1, 0.21, tolerance = 1e-12)
})

test_that("desdobrar nao mexe em paineis sem set/91", {
  painel <- tibble::tibble(
    date = as.Date(c("2020-01-01", "2020-02-01")),
    codigo = "0", nivel = "Geral", variacao = c(1, 2), peso = 100
  )
  expect_equal(nucleos:::desdobrar_bimestre_1991(painel), painel)
})

test_that("ajustar_resultado replica agosto sem media geometrica na difusao", {
  res <- tibble::tibble(
    date = as.Date(c("1991-07-01", "1991-09-01")),
    variacao = c(90, 96)
  )
  out <- nucleos:::ajustar_resultado_1991(res, geometrica = FALSE)
  ago <- out$variacao[out$date == as.Date("1991-08-01")]
  set <- out$variacao[out$date == as.Date("1991-09-01")]
  expect_equal(ago, 96)   # valor de set replicado, sem raiz
  expect_equal(set, 96)
})
