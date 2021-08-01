#' Computes ad-hoc core inflation using the subitem exclusion method
#'
#' @param core A string specifying the inflation core exclusion method: ex0, ex1, ex2 or ex3.
#' @param data Dataframe object with inflation sub-items data.
#' @param change A string with the column name of the percentage change of the inflation sub-items.
#' @param weight A string with the column name of the weight of the inflation sub-items.
#' @param date A string with the name of the date column.
#' @importFrom rlang .data :=
#'
#' @return Calculated core inflation tibble.
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
