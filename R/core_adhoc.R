#' Title
#'
#' @param core Inflation core
#' @param data Data frame
#' @param change Percent change
#' @param weight Inflation weight
#' @param date Date column
#' @importFrom rlang .data :=
#'
#' @return Tibble
#' @export
#'
core_adhoc <- function(core, data, change, weight, date){

  ci <- core
  df <- data
  pc <- change
  we <- weight
  dt <- date

  # Check valid inflation cores
  if(!ci %in% c("ex0", "ex1", "ex2", "ex3") | rlang::is_null(ci)) {
    rlang::abort("Pass a valid inflation {core} to be calculated.")
  } else ci <- paste0("ipca_", ci)

  # Check if data is tibble
  if(!is.data.frame(df)) {
    rlang::abort("Data must be a data frame")
  }

  # Check if inflation percent change column is present in data
  if(!pc %in% colnames(df) | !rlang::is_double(df[[pc]])){
    rlang::abort("The percent {change} column must be numeric and present in the data.")
  }

  # Check if inflation weight column is present in data
  if(!we %in% colnames(df) | !rlang::is_double(df[[we]])){
    rlang::abort("Column {weight} must be numeric and present in the data.")
  }

  # Check if date column is present in data
  if(!dt %in% colnames(df) | !lubridate::is.Date(df[[dt]])){
    rlang::abort("Column {date} must be of class Date and be present in the data.")
  }

  # Calculate inflation core
  ipca_core <- dplyr::tibble(
    "date" = df[[dt]],
    "pctc" = df[[pc]],
    "weig" = df[[we]]
    ) %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(
      {{ci}} := stats::weighted.mean(.data$pctc, .data$weig, na.rm = TRUE)
      )

  return(ipca_core)

}
