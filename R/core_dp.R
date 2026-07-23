#' Nucleo de dupla ponderacao (DP)
#'
#' Media ponderada das variacoes de precos dos itens do IPCA com pesos ajustados
#' que reduzem a influencia dos itens mais volateis (Subsecao 2.2 da Nota
#' Tecnica 57 do BCB). O ajuste combina dois ponderadores: o peso original do
#' item no indice e o inverso da volatilidade de suas variacoes.
#'
#' O calculo tem tres etapas. Primeiro, para cada item, calcula-se o desvio
#' padrao da serie de diferencas entre sua variacao mensal e a do IPCA cheio.
#' Em seguida o peso original e dividido por esse desvio padrao. Por fim os
#' pesos ajustados sao normalizados e aplicados as variacoes do mes.
#'
#' A janela de volatilidade cobre os **48 meses anteriores** ao mes de
#' referencia, sem inclui-lo: como diz a nota, o nucleo de um dado mes depende
#' das variacoes "do proprio mes e dos 48 meses anteriores" -- a variacao
#' corrente entra no nucleo, e os 48 meses previos estimam a volatilidade.
#'
#' O desvio padrao usa o estimador nao viesado, com denominador 47 -- e o que
#' a funcao [stats::sd()] ja faz para uma janela de 48 observacoes.
#'
#' O nucleo so pode ser calculado a partir do quadragesimo nono mes presente em
#' `data`. Para obter o DP de um mes especifico, colete pelo menos 48 meses de
#' historico adicional.
#'
#' Nos primeiros 48 meses de vigencia de uma estrutura, a janela de volatilidade
#' alcanca a estrutura anterior. Itens sem correspondencia direta usam as proxies
#' de [ipca_proxies]; o calculo e feito estrutura a estrutura para nao misturar
#' historicos de codigos que mudaram de significado.
#'
#' @param data Tibble devolvido por [get_ipca()], com historico suficiente.
#' @param janela Numero de meses da janela de volatilidade. O padrao, `48`, e o
#'   valor adotado pelo BCB; alterar afasta o resultado da serie oficial.
#'
#' @return Tibble com as colunas `date` e `variacao`.
#' @export
#'
#' @seealso [core_ma()], [core_ms()], [ipca_proxies]
#'
#' @examples
#' \dontrun{
#' # Para o DP de 2024 em diante, colete a partir de 2020
#' ipca <- get_ipca(inicio = "2020-01")
#' core_dp(ipca)
#' }
core_dp <- function(data, janela = 48L) {

  checa_ipca(data)

  if (!"pof" %in% names(data)) {
    rlang::abort("`data` precisa da coluna `pof`, devolvida por get_ipca().")
  }
  if (!"0" %in% data$codigo) {
    rlang::abort("`data` nao contem o indice geral (codigo '0').")
  }

  # O indice cheio, tambem tratado para ago-set/1991, e continuo entre
  # estruturas -- serve de referencia para a volatilidade de todas elas.
  data <- desdobrar_bimestre_1991(data)
  ipca_cheio <- data |>
    dplyr::filter(.data$codigo == "0") |>
    dplyr::select("date", ipca = "variacao")

  itens <- dplyr::filter(data, .data$nivel == "Item")

  partes <- lapply(estruturas_presentes(itens), function(S) {
    dp_por_estrutura(itens, S, ipca_cheio, janela)
  })

  dplyr::arrange(dplyr::bind_rows(partes), .data$date)
}


# Calcula o DP dos meses de uma unica estrutura. A volatilidade de cada item usa
# historico proprio estendido com proxies; os pesos e as variacoes do nucleo
# vem dos meses reais da estrutura.
dp_por_estrutura <- function(itens, S, ipca_cheio, janela) {

  itens_S <- dplyr::filter(itens, .data$pof == S)

  vol <- historico_com_proxy(itens, S, "DP", reach = janela) |>
    dplyr::left_join(ipca_cheio, by = "date") |>
    dplyr::mutate(desvio = .data$variacao - .data$ipca) |>
    dplyr::group_by(.data$codigo) |>
    dplyr::arrange(.data$date, .by_group = TRUE) |>
    dplyr::mutate(volatilidade = desvio_padrao_movel(.data$desvio, n = janela)) |>
    dplyr::ungroup() |>
    dplyr::select("codigo", "date", "volatilidade")

  itens_S |>
    dplyr::left_join(vol, by = c("codigo", "date")) |>
    dplyr::filter(
      !is.na(.data$volatilidade),
      .data$volatilidade > 0,
      !is.na(.data$variacao),
      !is.na(.data$peso)
    ) |>
    dplyr::group_by(.data$date) |>
    dplyr::mutate(peso_dp = .data$peso / .data$volatilidade) |>
    dplyr::summarise(
      variacao = stats::weighted.mean(.data$variacao, .data$peso_dp),
      .groups  = "drop"
    )
}


# Desvio padrao dos `n` valores que antecedem cada ponto, sem inclui-lo.
# Devolve NA nos primeiros `n` meses e em janelas com dados faltantes.
desvio_padrao_movel <- function(x, n = 48L) {
  N <- length(x)
  out <- rep(NA_real_, N)
  for (i in seq_len(N)) {
    fim <- i - 1L
    ini <- fim - n + 1L
    if (ini >= 1L) {
      janela <- x[ini:fim]
      if (!anyNA(janela)) out[i] <- stats::sd(janela)
    }
  }
  out
}
