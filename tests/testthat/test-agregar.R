test_that("agregar devolve as 17 series quando nenhuma e pedida", {
  res <- agregar(ipca_fixture())
  expect_setequal(unique(res$serie), unique(ipca_vetores$serie))
  expect_length(unique(res$serie), 17)
})

test_that("agregar aceita o nome da serie sem acentuacao", {
  ipca <- ipca_fixture()
  expect_equal(
    agregar(ipca, "Nucleo EX1"),
    agregar(ipca, "Núcleo EX1")
  )
})

test_that("agregar rejeita serie desconhecida", {
  expect_error(agregar(ipca_fixture(), "Nucleo EX9"), "Serie desconhecida")
})

test_that("agregar rejeita dados que nao vem de get_ipca", {
  expect_error(agregar(data.frame(x = 1)), "faltam as colunas")
  expect_error(agregar("nao e data frame"), "deve ser um data frame")
})

test_that("EX0 e a agregacao de servicos e bens industriais", {
  # A NT 57 define o EX0 como todos os precos livres exceto alimentacao no
  # domicilio, ou seja, servicos mais bens industriais. As composicoes usam
  # niveis hierarquicos diferentes, entao a conferencia e pela uniao dos
  # subitens cobertos, nao pelos codigos em si.
  vig <- dplyr::filter(ipca_vetores, inicio == as.Date("2020-01-01"))
  cobre <- function(serie) {
    codigos <- vig$codigo[vig$serie == serie]
    sub <- vig$codigo[vig$nivel == "Subitem"]
    unique(sub[vapply(sub, function(s) any(startsWith(s, codigos)), logical(1))])
  }
  expect_setequal(
    cobre("Núcleo EX0"),
    union(cobre("Serviços"), cobre("Bens industriais"))
  )
})

test_that("os vetores usam apenas niveis hierarquicos validos", {
  expect_setequal(
    unique(ipca_vetores$nivel),
    c("Grupo", "Subgrupo", "Item", "Subitem")
  )
})
