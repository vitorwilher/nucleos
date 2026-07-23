test_that("core_ma apara simetricamente as duas caudas", {
  # Painel artificial: 10 itens de peso 10 cada, variacoes de 1 a 10.
  # Aparando 20% de cada lado, sobram os pesos 20..80, ou seja os itens de
  # variacao 3 a 8, cada um com peso 10. A media e 5,5.
  painel <- tibble::tibble(
    date     = as.Date("2020-01-01"),
    codigo   = sprintf("%04d", 1:10),
    nivel    = "Item",
    variacao = as.numeric(1:10),
    peso     = 10
  )
  expect_equal(core_ma(painel)$variacao, 5.5)
})

test_that("core_ma inclui parcialmente os itens que atravessam os limites", {
  # Tres itens: pesos 30, 40, 30. A faixa [20, 80] pega 10 do primeiro,
  # 40 do segundo e 10 do terceiro. Media = (10*0 + 40*10 + 10*100)/60.
  painel <- tibble::tibble(
    date     = as.Date("2020-01-01"),
    codigo   = c("0001", "0002", "0003"),
    nivel    = "Item",
    variacao = c(0, 10, 100),
    peso     = c(30, 40, 30)
  )
  expect_equal(core_ma(painel)$variacao, (10 * 0 + 40 * 10 + 10 * 100) / 60)
})

test_that("difusao conta apenas subitens pesquisados", {
  # Quatro subitens, um nao pesquisado (NA). Dos tres restantes, dois sobem.
  painel <- tibble::tibble(
    date     = as.Date("2020-01-01"),
    codigo   = c("1101001", "1101002", "1101003", "1101004"),
    nivel    = "Subitem",
    variacao = c(1, 2, -1, NA),
    peso     = 25
  )
  expect_equal(difusao(painel)$variacao, 2 / 3 * 100)
})

test_that("core_p55 devolve a variacao do subitem no percentil 55", {
  # Pesos iguais de 10 em 10 subitens: o acumulado alcanca 55 no sexto,
  # cuja variacao e 6.
  painel <- tibble::tibble(
    date     = as.Date("2020-01-01"),
    codigo   = sprintf("110100%d", 1:10),
    nivel    = "Subitem",
    variacao = as.numeric(1:10),
    peso     = 10
  )
  expect_equal(core_p55(painel)$variacao, 6)
})

test_that("core_ms exige historico de doze meses", {
  ipca <- ipca_fixture()
  curto <- dplyr::filter(ipca, date < as.Date("2020-06-01"))
  expect_error(core_ms(curto), "Historico insuficiente")
})

test_that("core_ms comeca no decimo segundo mes disponivel", {
  res <- core_ms(ipca_fixture())
  expect_equal(min(res$date), as.Date("2020-12-01"))
})

test_that("core_dp comeca no quadragesimo nono mes disponivel", {
  # A janela de volatilidade cobre os 48 meses anteriores, sem incluir o mes
  # de referencia -- por isso o primeiro calculavel e o 49o.
  res <- core_dp(ipca_fixture())
  expect_equal(min(res$date), as.Date("2024-01-01"))
})

test_that("core_dp exige o indice geral no painel", {
  sem_geral <- dplyr::filter(ipca_fixture(), codigo != "0")
  expect_error(core_dp(sem_geral), "indice geral")
})
