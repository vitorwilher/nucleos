#' Indice de difusao do IPCA
#'
#' Percentual de subitens do IPCA com variacao de precos positiva no mes
#' (Subsecao 2.6 da Nota Tecnica 57 do BCB). Os pesos nao entram no calculo.
#'
#' Apenas os subitens efetivamente pesquisados no mes sao considerados. Nas
#' bases do IBGE, subitens nao pesquisados aparecem com variacao registrada
#' como `'...'`, que [get_ipca()] converte para `NA` -- e nao para zero, o que
#' os contaria erroneamente como precos estaveis no denominador.
#'
#' @param data Tibble devolvido por [get_ipca()].
#'
#' @return Tibble com as colunas `date` e `variacao`, esta ultima em pontos
#'   percentuais de 0 a 100.
#' @export
#'
#' @seealso [core_p55()]
#'
#' @examples
#' \dontrun{
#' ipca <- get_ipca(inicio = "2020-01")
#' difusao(ipca)
#' }
difusao <- function(data) {

  checa_ipca(data)

  res <- data |>
    dplyr::filter(.data$nivel == "Subitem", !is.na(.data$variacao)) |>
    dplyr::group_by(.data$date) |>
    dplyr::summarise(
      variacao = mean(.data$variacao > 0) * 100,
      .groups  = "drop"
    ) |>
    dplyr::arrange(.data$date)

  # Na difusao, atribui-se o proprio valor de set/91 a agosto, sem media
  # geometrica (Subsecao 2.7 da NT 57).
  ajustar_resultado_1991(res, geometrica = FALSE)
}
