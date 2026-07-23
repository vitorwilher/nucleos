#' Coleta uma serie analitica do IPCA no SGS do Banco Central
#'
#' Baixa a serie oficial publicada pelo BCB no Sistema Gerenciador de Series
#' Temporais (SGS). Serve para conferir os resultados calculados pelo pacote
#' contra a fonte de verdade.
#'
#' Os codigos das 22 series consolidadas pela NT 57 estao em [series_sgs]. As
#' series anteriores a consolidacao continuam no SGS sob outros codigos, mas
#' deixaram de ser atualizadas.
#'
#' @param codigo Codigo numerico da serie no SGS.
#' @param inicio Primeiro mes, no formato `"AAAA-MM"`.
#' @param fim Ultimo mes, no formato `"AAAA-MM"`. Se `NULL` (padrao), vai ate o
#'   fim da serie.
#'
#' @return Tibble com as colunas `date` e `variacao`.
#' @export
#'
#' @seealso [series_sgs], [get_ipca()]
#'
#' @examples
#' \dontrun{
#' # Nucleo MA oficial
#' get_sgs(11426, inicio = "2020-01")
#' }
get_sgs <- function(codigo, inicio = "1991-01", fim = NULL) {

  if (!is.numeric(codigo) || length(codigo) != 1) {
    rlang::abort("`codigo` deve ser um unico numero de serie do SGS.")
  }

  de  <- parse_mes(inicio, "inicio")
  ate <- if (is.null(fim)) Sys.Date() else parse_mes(fim, "fim")

  url <- sprintf(
    paste0(
      "https://api.bcb.gov.br/dados/serie/bcdata.sgs.%d/dados",
      "?formato=json&dataInicial=%s&dataFinal=%s"
    ),
    codigo, format(de, "%d/%m/%Y"), format(ate, "%d/%m/%Y")
  )

  resp <- httr::GET(url, httr::timeout(120))

  if (httr::http_error(resp)) {
    rlang::abort(sprintf(
      "Falha ao consultar a serie %d no SGS (HTTP %d).",
      codigo, httr::status_code(resp)
    ))
  }

  texto <- httr::content(resp, as = "text", encoding = "UTF-8")

  # O SGS devolve HTML de erro, e nao JSON, quando o periodo pedido nao
  # intersecta a serie.
  if (!grepl("^\\s*\\[", texto)) {
    rlang::abort(sprintf(
      "A serie %d do SGS nao tem dados no periodo pedido.", codigo
    ))
  }

  bruto <- jsonlite::fromJSON(texto)

  tibble::tibble(
    date     = as.Date(bruto$data, format = "%d/%m/%Y"),
    variacao = as.numeric(bruto$valor)
  )
}
