#' Computes core inflation using the non-smoothed trimmed means method
#'
#' @param data Dataframe object with inflation items data.
#' @param change A string with the column name of the percentage change of the inflation items.
#' @param weight A string with the column name of the weight of the inflation items.
#' @param date A string with the name of the date column.
#' @importFrom rlang .data
#'
#' @return Calculated core inflation tibble.
#' @export
#'
#' @examples
#' \dontrun{
#' library(magrittr)
#' library(dplyr)
#'
#' ipca_ma <- get_ipca(period = "all") %>%
#' group_desc() %>%
#' dplyr::filter(group == "Item") %>%
#' core_ma(., "pct_change", "weight", "date")
#' }
core_ma <- function(data, change, weight, date){

  df <- data
  pc <- change
  we <- weight
  dt <- date

  # Check if data is data frame
  if(!is.data.frame(df)) {
    rlang::abort("{data} must be a data frame.")
  }

  # Check if inflation percent change column is present in data
  if(!pc %in% colnames(df) | !rlang::is_double(df[[pc]])){
    rlang::abort("The percent {change} column must be numeric and present in the dataset.")
  }

  # Check if inflation weight column is present in data
  if(!we %in% colnames(df) | !rlang::is_double(df[[we]])){
    rlang::abort("Column of {weight} must be numeric and present in the dataset.")
  }

  # Check if date column is present in data
  if(!dt %in% colnames(df) | !lubridate::is.Date(df[[dt]])){
    rlang::abort("Column of {date} must be of class Date and be present in the dataset.")
  }

  # Inflation core data
  ipca_core <- dplyr::tibble(
    "date" = df[[dt]],
    "pctc" = df[[pc]],
    "weig" = df[[we]]
  )

  # Calculate inflation core
  ipca_core <- ipca_core %>%
    dplyr::group_by(.data$date) %>%
    dplyr::arrange(.data$pctc) %>%
    dplyr::mutate(csum = cumsum(.data$weig)) %>%
    dplyr::filter(.data$csum >= 20 & .data$csum <= 80) %>%
    dplyr::mutate(
      new_weig = dplyr::case_when(
        dplyr::row_number() == 1L & dplyr::first(.data$csum) > 20 ~ dplyr::first(.data$csum) - 20,
        dplyr::row_number() == max(dplyr::row_number()) &
          dplyr::last(.data$csum) > 80 ~ 80 - dplyr::last(.data$csum),
        TRUE ~ .data$weig
        )
      ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      new_weig = .data$new_weig / sum(.data$new_weig)
      ) %>%
    dplyr::group_by(.data$date) %>%
    dplyr::summarise(
      ipca_ma = stats::weighted.mean(.data$pctc, .data$new_weig, na.rm = TRUE) %>%
        round(2)
      )

  return(ipca_core)
}
