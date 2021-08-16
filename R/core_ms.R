#' Computes core inflation using the smoothed trimmed means method
#'
#' @param data Dataframe object with inflation items data.
#' @param change A string with the column name of the percentage change of the inflation items.
#' @param weight A string with the column name of the weight of the inflation items.
#' @param code A string with the column name of the code of the inflation items as provided in [get_ipca()].
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
#' ipca_ms <- get_ipca(period = "all") %>%
#' group_desc() %>%
#' dplyr::filter(group == "Item") %>%
#' core_ms(., "pct_change", "weight", "code", "date")
#' }
core_ms <- function(data, change, weight, code, date){

  df <- data
  pc <- change
  we <- weight
  cd <- code
  dt <- date

  # Check if data is data frame
  if(!is.data.frame(df)) {
    rlang::abort("{data} must be a data frame.")
  }

  # Check if inflation percent change column is present in dataset
  if(!pc %in% colnames(df) | !rlang::is_double(df[[pc]])){
    rlang::abort("The percent {change} column must be numeric and present in the dataset.")
  }

  # Check if inflation weight column is present in dataset
  if(!we %in% colnames(df) | !rlang::is_double(df[[we]])){
    rlang::abort("Column of {weight} must be numeric and present in the dataset.")
  }

  # Check if inflation items code is presente in dataset
  if(!cd %in% colnames(df) | !rlang::is_double(df[[cd]])) {
    rlang::abort("Column of {code} must be numeric and present in the dataset.")
  }

  # Check if items to smooth is presente in dataset
  if(
    !all(
      unique(c(ipca_classes_2012[["smoothed"]], ipca_classes_2020[["smoothed"]])) %in%
      df[[cd]]
      )
    ){
    rlang::abort("Items to smooth are not present in the dataset.")
  }

  # Check if date column is present in dataset
  if(!dt %in% colnames(df) | !lubridate::is.Date(df[[dt]])){
    rlang::abort("Column of {date} must be of class Date and be present in the dataset.")
  }

  # Inflation core data
  ipca_core <- dplyr::tibble(
    "date" = df[[dt]],
    "pctc" = df[[pc]],
    "weig" = df[[we]],
    "code" = df[[cd]]
  )

  # Calculate inflation core
  ipca_core <- ipca_core %>%
    dplyr::group_by(.data$code) %>%
    dplyr::mutate(
      new_pctc = dplyr::if_else(
        .data$code %in% c(ipca_classes_2012[["smoothed"]], ipca_classes_2020[["smoothed"]]),
        ((RcppRoll::roll_prodr((1 + (.data$pctc / 100)), n = 12) - 1) / 12) * 100,
        .data$pctc
        )
      ) %>%
    dplyr::group_by(.data$date) %>%
    dplyr::filter(!any(is.na(.data$new_pctc))) %>%
    dplyr::ungroup() %>%
    core_ma(., "new_pctc", "weig", "date") %>%
    dplyr::rename("core_ms" = 2)

  return(ipca_core)

}
