#' Calcula as series obtidas por agregacao simples do IPCA
#'
#' Aplica a formula geral da Subsecao 2.1.2 da Nota Tecnica 57 do BCB: a
#' variacao mensal de uma serie e a media das variacoes dos componentes que a
#' integram, ponderada pelos pesos originais do IPCA.
#'
#' \deqn{\pi_t = \frac{\sum_i a_{i,t}\, w_{i,t}\, \pi_{i,t}}{\sum_i a_{i,t}\, w_{i,t}}}
#'
#' em que \eqn{a_{i,t}} e o vetor de agregacao da serie -- 1 se o componente
#' integra a serie no mes, 0 caso contrario. Os vetores estao em [ipca_vetores]
#' e mudam entre os seis subperiodos do IPCA; a funcao seleciona o vetor
#' vigente em cada mes automaticamente.
#'
#' Como os vetores incluem cada componente no nivel hierarquico mais alto
#' possivel, os componentes selecionados nunca se sobrepoem: somar um grupo e
#' somar todos os seus subitens sao alternativas excludentes, e a convencao
#' escolhe a primeira.
#'
#' As 17 series disponiveis sao: `"Administrados"`, `"Livres"`,
#' `"Alimentacao no domicilio"`, `"Servicos"`, `"Bens industriais"`,
#' `"Comercializaveis"`, `"Nao comercializaveis"`, `"Bens nao duraveis"`,
#' `"Bens semiduraveis"`, `"Bens duraveis"`, `"Nucleo EX-FE"`, `"Nucleo EX0"`,
#' `"Nucleo EX1"`, `"Nucleo EX2"`, `"Nucleo EX3"`, `"EX3 Servicos"` e
#' `"EX3 Industriais"`. Os nomes aceitos sao os de [ipca_vetores], com ou sem
#' acentuacao.
#'
#' @param data Tibble devolvido por [get_ipca()].
#' @param serie Nome da serie a calcular. Se `NULL` (padrao), calcula todas as
#'   17 series.
#'
#' @return Tibble com as colunas `date`, `serie` e `variacao`.
#' @export
#'
#' @seealso [ipca_vetores], [core_ma()], [core_p55()]
#'
#' @examples
#' \dontrun{
#' ipca <- get_ipca(inicio = "2020-01")
#'
#' # Uma serie
#' ex1 <- agregar(ipca, "Nucleo EX1")
#'
#' # Todas as 17
#' todas <- agregar(ipca)
#' }
agregar <- function(data, serie = NULL) {

  checa_ipca(data)

  vetores <- ipca_vetores
  disponiveis <- unique(vetores$serie)

  if (!is.null(serie)) {
    if (!rlang::is_character(serie) || length(serie) != 1) {
      rlang::abort("`serie` deve ser um unico nome de serie, ou NULL.")
    }
    alvo <- casa_serie(serie, disponiveis)
    vetores <- vetores[vetores$serie == alvo, , drop = FALSE]
  }

  # Cada mes usa o vetor do subperiodo vigente. O `fim` da estrutura corrente
  # e NA, entao vira uma data no futuro distante para o teste de intervalo.
  vetores <- dplyr::mutate(
    vetores,
    fim = dplyr::coalesce(.data$fim, as.Date("9999-12-01"))
  )

  res <- dplyr::inner_join(
    data[, c("date", "codigo", "variacao", "peso")],
    vetores[, c("serie", "codigo", "inicio", "fim")],
    by = "codigo",
    relationship = "many-to-many"
  ) |>
    dplyr::filter(.data$date >= .data$inicio, .data$date <= .data$fim) |>
    dplyr::group_by(.data$date, .data$serie) |>
    dplyr::summarise(
      variacao = stats::weighted.mean(.data$variacao, .data$peso, na.rm = TRUE),
      .groups  = "drop"
    ) |>
    dplyr::arrange(.data$serie, .data$date)

  ajustar_resultado_1991(res, geometrica = TRUE)
}


# Helpers compartilhados pelos calculos -------------------------------------

checa_ipca <- function(data) {
  if (!is.data.frame(data)) {
    rlang::abort("`data` deve ser um data frame, como o devolvido por get_ipca().")
  }
  faltando <- setdiff(c("date", "codigo", "nivel", "variacao", "peso"), names(data))
  if (length(faltando) > 0) {
    rlang::abort(paste0(
      "`data` nao parece vir de get_ipca(): faltam as colunas ",
      paste(faltando, collapse = ", "), "."
    ))
  }
  if (!inherits(data$date, "Date")) {
    rlang::abort("A coluna `date` deve ser da classe Date.")
  }
  invisible(TRUE)
}

# Aceita o nome da serie com ou sem acentuacao, para nao obrigar o usuario a
# digitar "Nao comercializaveis" exatamente como aparece no anexo do BCB.
casa_serie <- function(serie, disponiveis) {
  chave <- function(x) tolower(iconv(x, to = "ASCII//TRANSLIT"))
  idx <- match(chave(serie), chave(disponiveis))
  if (is.na(idx)) {
    rlang::abort(paste0(
      "Serie desconhecida: '", serie, "'.\nSeries disponiveis: ",
      paste(disponiveis, collapse = "; "), "."
    ))
  }
  disponiveis[idx]
}
