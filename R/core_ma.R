#' Nucleo de medias aparadas sem suavizacao (MA)
#'
#' Ordena os itens do IPCA pela variacao de precos, descarta as caudas ate que
#' os pesos acumulados atinjam 20% de cada lado e devolve a media ponderada das
#' variacoes remanescentes (Subsecao 2.3 da Nota Tecnica 57 do BCB).
#'
#' Os itens que atravessam os limites de 20% e 80% nao entram nem saem por
#' inteiro: entram com o peso correspondente apenas a fracao dentro da faixa,
#' conforme a etapa (iv) da nota. Na pratica isso equivale a atribuir a cada
#' item o peso
#'
#' \deqn{\tilde{w}_i = \min(W_i, 80) - \max(W_{i-1}, 20)}
#'
#' em que \eqn{W_i} e o peso acumulado ate o item \eqn{i}, descartando os itens
#' para os quais essa expressao seja negativa ou nula.
#'
#' O calculo usa apenas os componentes de nivel `"Item"`; a filtragem e feita
#' internamente.
#'
#' @param data Tibble devolvido por [get_ipca()].
#'
#' @return Tibble com as colunas `date` e `variacao`.
#' @export
#'
#' @seealso [core_ms()], [core_p55()], [agregar()]
#'
#' @examples
#' \dontrun{
#' ipca <- get_ipca(inicio = "2020-01")
#' core_ma(ipca)
#' }
core_ma <- function(data) {
  checa_ipca(data)
  itens <- dplyr::filter(data, .data$nivel == "Item")
  res   <- apara_medias(itens, "variacao")
  ajustar_resultado_1991(res, geometrica = TRUE)
}


# Etapas (i) a (v) da Subsecao 2.3. Isolado numa funcao propria porque o
# nucleo MS reaproveita exatamente o mesmo procedimento, mudando apenas a
# coluna de variacao usada.
apara_medias <- function(itens, coluna) {

  itens |>
    dplyr::filter(!is.na(.data[[coluna]]), !is.na(.data$peso)) |>
    dplyr::group_by(.data$date) |>
    dplyr::arrange(.data[[coluna]], .by_group = TRUE) |>
    dplyr::mutate(
      acum     = cumsum(.data$peso),
      acum_ant = dplyr::lag(.data$acum, default = 0),
      # Peso da fatia do item que cai dentro da faixa [20, 80]
      peso_aparado = pmin(.data$acum, 80) - pmax(.data$acum_ant, 20)
    ) |>
    dplyr::filter(.data$peso_aparado > 0) |>
    dplyr::summarise(
      variacao = stats::weighted.mean(.data[[coluna]], .data$peso_aparado),
      .groups  = "drop"
    ) |>
    dplyr::arrange(.data$date)
}
