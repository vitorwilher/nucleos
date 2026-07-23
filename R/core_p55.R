#' Nucleo percentil 55 (P55)
#'
#' Devolve a variacao de precos do subitem que ocupa o 55o percentil da
#' distribuicao ponderada pelos pesos dos subitens do IPCA (Subsecao 2.5 da
#' Nota Tecnica 57 do BCB).
#'
#' O percentil 55, e nao a mediana, foi escolhido por minimizar o vies em
#' relacao a inflacao cheia: a distribuicao das variacoes de precos e assimetrica
#' a direita, de modo que a mediana tende a subestimar a inflacao.
#'
#' Diferentemente dos nucleos MA e MS, que operam sobre itens, o P55 e calculado
#' sobre subitens. A filtragem e feita internamente.
#'
#' @param data Tibble devolvido por [get_ipca()].
#'
#' @return Tibble com as colunas `date` e `variacao`.
#' @export
#'
#' @seealso [core_ma()], [difusao()]
#'
#' @examples
#' \dontrun{
#' ipca <- get_ipca(inicio = "2020-01")
#' core_p55(ipca)
#' }
core_p55 <- function(data) {

  checa_ipca(data)

  res <- data |>
    dplyr::filter(
      .data$nivel == "Subitem",
      !is.na(.data$variacao),
      !is.na(.data$peso)
    ) |>
    dplyr::group_by(.data$date) |>
    dplyr::arrange(.data$variacao, .by_group = TRUE) |>
    dplyr::mutate(
      # Percentis sobre a distribuicao de pesos dos subitens efetivamente
      # pesquisados no mes, reescalada para somar 100.
      acum = cumsum(.data$peso) / sum(.data$peso) * 100
    ) |>
    # O subitem do 55o percentil e o primeiro cujo peso acumulado alcanca 55
    dplyr::filter(.data$acum >= 55) |>
    dplyr::slice_head(n = 1) |>
    dplyr::ungroup() |>
    dplyr::select("date", "variacao") |>
    dplyr::arrange(.data$date)

  ajustar_resultado_1991(res, geometrica = TRUE)
}
