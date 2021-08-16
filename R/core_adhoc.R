#' Computes ad-hoc core inflation using the subitem exclusion method
#'
#' @param core A string specifying the inflation core exclusion method: ex0, ex1, ex2 or ex3.
#' @param data Dataframe object with inflation sub-items data.
#' @param change A string with the column name of the percentage change of the inflation sub-items.
#' @param weight A string with the column name of the weight of the inflation sub-items.
#' @param code A string with the column name of the code of the inflation sub-items as provided in [get_ipca()].
#' @param date A string with the name of the date column.
#' @importFrom rlang .data :=
#'
#' @return Calculated core inflation tibble.
#' @export
#'
#' @examples
#' \dontrun{
#' library(magrittr)
#' ipca_ex0 <- get_ipca(period = "all") %>%
#' core_adhoc("ex0", ., "pct_change", "weight", "code", "date")
#' }
core_adhoc <- function(core, data, change, weight, code, date){

  ci <- core
  df <- data
  pc <- change
  we <- weight
  cd <- code
  dt <- date

  # Check valid inflation cores
  if(!ci %in% c("ex0", "ex1", "ex2", "ex3") | rlang::is_null(ci)) {
    rlang::abort("Pass a valid inflation {core} to be calculated.")
  }

  # Check if data is data frame
  if(!is.data.frame(df)) {
    rlang::abort("Data must be a data frame")
  }

  # Check if inflation percent change column is present in data
  if(!pc %in% colnames(df) | !rlang::is_double(df[[pc]])){
    rlang::abort("The percent {change} column must be numeric and present in the data.")
  }

  # Check if inflation weight column is present in data
  if(!we %in% colnames(df) | !rlang::is_double(df[[we]])){
    rlang::abort("Column of {weight} must be numeric and present in the data.")
  }

  # Check if inflation sub-items code is presente in data
  if(!cd %in% colnames(df) | !rlang::is_double(df[[cd]])) {
    rlang::abort("Column of {code} must be numeric and present in the data.")
  }

  # Check if date column is present in data
  if(!dt %in% colnames(df) | !lubridate::is.Date(df[[dt]])){
    rlang::abort("Column of {date} must be of class Date and be present in the data.")
  }

  # Inflation core data
  ipca_core <- dplyr::tibble(
    "date" = df[[dt]],
    "pctc" = df[[pc]],
    "weig" = df[[we]],
    "code" = df[[cd]]
    )

  # Filter the sub-items according to the core inflation exclusion method
  if(ci == "ex0") {
    ipca_core <- ipca_core %>%
      dplyr::filter(
        dplyr::case_when(
          date >= lubridate::as_date("2020-01-01") ~ code %in% ipca_classes_2020[["ex0"]],
          TRUE ~ code %in% ipca_classes_2012[["ex0"]]
          )
        )
  } else if(ci == "ex1") {
    ipca_core <- ipca_core %>%
      dplyr::filter(
        dplyr::case_when(
          date >= lubridate::as_date("2020-01-01") ~ code %in% ipca_classes_2020[["ex1"]],
          TRUE ~ code %in% ipca_classes_2012[["ex1"]]
        )
      )
  } else if(ci == "ex2") {
    ipca_core <- ipca_core %>%
      dplyr::filter(
        dplyr::case_when(
          date >= lubridate::as_date("2020-01-01") ~ code %in% ipca_classes_2020[["ex2"]],
          TRUE ~ code %in% ipca_classes_2012[["ex2"]]
        )
      )
  } else if(ci == "ex3") {
    ipca_core <- ipca_core %>%
      dplyr::filter(
        dplyr::case_when(
          date >= lubridate::as_date("2020-01-01") ~ code %in% ipca_classes_2020[["ex3"]],
          TRUE ~ code %in% ipca_classes_2012[["ex3"]]
        )
      )
  }
  ci <- paste0("ipca_", ci)

  # Calculate inflation core
  ipca_core <- ipca_core %>%
    dplyr::group_by(date) %>%
    dplyr::summarise(
      {{ci}} := stats::weighted.mean(.data$pctc, .data$weig, na.rm = TRUE)
      )

  return(ipca_core)

}
