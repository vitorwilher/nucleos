#' Fetch IPCA table's from SIDRA/IBGE
#'
#' @param table A table from IBGE's SIDRA API.
#' @param period A character vector describing the period of data.
#'
#' @return List with data frames.
#' @export
#'
#' @examples
#' \dontrun{
#' my_df <- get_sidra(1419, "last")
#' }
get_ipca <- function(table = c(1419, 7060), period = "all") {

  # Check valid SIDRA tables
  if(!all(table %in% c(1419, 7060))) {
    rlang::abort("Pass a valid IPCA/SIDRA table.")
  }

  # Check valid period
  if(
    !rlang::is_character(period) |
    !length(period) == 1 |
    !all(period %in% c("first", "last", "all"))
    ) {
    rlang::abort("Pass a valid period.")
  } else rlang::inform("Fetching SIDRA data...")

  # Check internet connection
  if (
    !curl::has_internet() ||
    httr::http_error(
      httr::GET("https://apisidra.ibge.gov.br/", httr::timeout(60))
      )
    ) {
    rlang::abort("Connection with SIDRA/IBGE website is unavailable.")
  }

  # Fetch data
  df_sidra <- {{table}} %>%
    purrr::set_names(paste0("table_", .)) %>%
    as.list() %>%
    purrr::map(
      ~purrr::map(
        .x = c(
          "IPCA - Variacao mensal (%)"              = 63,
          "IPCA - Variacao acumulada no ano (%)"    = 69,
          "IPCA - Variacao acumulada em  meses (%)" = 2265,
          "IPCA - Peso mensal"                      = 66
          ),
        ~sidrar::get_sidra(
          x        = .y,
          variable = .x,
          period   = {{period}}
          ),
        .y = .x
        )
      )

  return(df_sidra)

}



