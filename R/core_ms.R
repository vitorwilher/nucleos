#' Nucleo de medias aparadas com suavizacao (MS)
#'
#' Segue exatamente as mesmas cinco etapas do nucleo MA. A diferenca esta nas
#' variacoes usadas: para itens com reajustes infrequentes, a variacao do mes e
#' substituida pela variacao media dos ultimos doze meses (Subsecao 2.4 da Nota
#' Tecnica 57 do BCB).
#'
#' Os itens suavizados em cada estrutura do IPCA estao em [ipca_ms_itens]. Sao
#' nove na estrutura vigente -- combustiveis, energia eletrica, transporte
#' publico, servicos pessoais, fumo, cursos e comunicacao.
#'
#' Como a suavizacao olha doze meses para tras, o nucleo so pode ser calculado a
#' partir do decimo segundo mes presente em `data`. Para obter o MS de um mes
#' especifico, colete pelo menos onze meses de historico adicional.
#'
#' Nos primeiros onze meses de vigencia de uma estrutura, a janela de suavizacao
#' alcanca a estrutura anterior. Itens sem correspondencia direta usam as proxies
#' de [ipca_proxies]; o calculo e feito estrutura a estrutura para nao misturar
#' historicos de codigos que mudaram de significado.
#'
#' @param data Tibble devolvido por [get_ipca()], com historico suficiente.
#'
#' @return Tibble com as colunas `date` e `variacao`.
#' @export
#'
#' @seealso [core_ma()], [ipca_ms_itens], [ipca_proxies]
#'
#' @examples
#' \dontrun{
#' # Para o MS de 2024 em diante, colete a partir de 2023
#' ipca <- get_ipca(inicio = "2023-01")
#' core_ms(ipca)
#' }
core_ms <- function(data) {

  checa_ipca(data)

  if (!"pof" %in% names(data)) {
    rlang::abort("`data` precisa da coluna `pof`, devolvida por get_ipca().")
  }

  itens <- dplyr::filter(data, .data$nivel == "Item")
  itens <- desdobrar_bimestre_1991(itens)

  partes <- lapply(estruturas_presentes(itens), function(S) {
    ms_por_estrutura(itens, S)
  })

  res <- dplyr::bind_rows(partes)

  if (nrow(res) == 0) {
    rlang::abort(
      "Historico insuficiente: o nucleo MS exige doze meses de dados por item."
    )
  }

  dplyr::arrange(res, .data$date)
}


# Calcula o MS dos meses de uma unica estrutura, usando historico proprio
# estendido com proxies para a suavizacao dos primeiros onze meses.
ms_por_estrutura <- function(itens, S) {

  itens_S <- dplyr::filter(itens, .data$pof == S)

  suavizados <- ipca_ms_itens$codigo[ipca_ms_itens$pof == S]

  # Variacao suavizada por codigo, sobre o historico estendido (11 meses de
  # alcance da estrutura anterior).
  suave <- historico_com_proxy(itens, S, "MS", reach = 11L) |>
    dplyr::group_by(.data$codigo) |>
    dplyr::arrange(.data$date, .by_group = TRUE) |>
    dplyr::mutate(suave = media_movel_geometrica(.data$variacao, n = 12)) |>
    dplyr::ungroup() |>
    dplyr::select("codigo", "date", "suave")

  aug <- itens_S |>
    dplyr::left_join(suave, by = c("codigo", "date")) |>
    dplyr::mutate(
      eh_suavizado = .data$codigo %in% suavizados,
      variacao_ms  = dplyr::if_else(.data$eh_suavizado, .data$suave, .data$variacao)
    )

  # Meses em que algum item suavizado ainda nao tem doze observacoes nao podem
  # ser calculados: descarta o mes inteiro.
  incompletos <- aug |>
    dplyr::filter(.data$eh_suavizado, is.na(.data$variacao_ms)) |>
    dplyr::pull(.data$date) |>
    unique()

  aug <- dplyr::filter(aug, !.data$date %in% incompletos)
  if (nrow(aug) == 0) return(NULL)

  apara_medias(aug, "variacao_ms")
}


# Variacao media dos ultimos `n` meses, no sentido geometrico: a taxa mensal
# constante que, composta por `n` meses, reproduz a variacao acumulada do
# periodo. Devolve NA nos primeiros `n - 1` meses.
media_movel_geometrica <- function(x, n = 12) {
  # stats::filter() lanca erro, em vez de devolver NA, quando a serie e mais
  # curta que a janela. Como historico curto e uma condicao normal aqui (os
  # primeiros meses de qualquer coleta), trata-se o caso explicitamente.
  if (length(x) < n) return(rep(NA_real_, length(x)))

  log_fator <- log1p(x / 100)
  soma <- as.numeric(
    stats::filter(log_fator, rep(1, n), method = "convolution", sides = 1)
  )
  (exp(soma / n) - 1) * 100
}
