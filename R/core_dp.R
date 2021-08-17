#' Computes core inflation using the double weight method
#'
#' @param data Dataframe object with inflation index and items data.
#' @param change A string with the column name of the percentage change of the inflation index and items.
#' @param weight A string with the column name of the weight of the inflation index and items.
#' @param code A string with the column name of the code of the inflation index and items as provided in [get_ipca()].
#' @param group A string with the column name of the group of the inflation index and items as provided in [group_desc()].
#' @param date A string with the name of the date column.
#' @importFrom rlang .data
#' @author Fernando da Silva <<fernando@fortietwo.com>>
#'
#' @return Calculated core inflation tibble.
#' @export
#'
#' @examples
#' \dontrun{
#' library(magrittr)
#'
#' ipca_dp <- get_ipca(period = "all") %>%
#' group_desc() %>%
#' core_dp(., "pct_change", "weight", "code", "group", "date")
#' }
core_dp <- function(data, change, weight, code, group, date){

  df <- data
  pc <- change
  we <- weight
  cd <- code
  gp <- group
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

  # Check if inflation items group description is presente in dataset
  if(!gp %in% colnames(df) | !rlang::is_character(df[[gp]])) {
    rlang::abort("Column of {group} must be character and present in the dataset.")
  }

  # Check if date column is present in dataset
  if(!dt %in% colnames(df) | !lubridate::is.Date(df[[dt]])){
    rlang::abort("Column of {date} must be of class Date and be present in the dataset.")
  }

  # Inflation core data
  ipca_core <- dplyr::tibble(
    "date" = df[[dt]],
    "pctch" = df[[pc]],
    "weigh" = df[[we]],
    "code"  = df[[cd]],
    "group" = df[[gp]]
  )

  # Monthly percentage change in the inflation index (IPCA)
  idx_change <- ipca_core %>%
    dplyr::filter(group == "Geral") %>%
    dplyr::select(date, "ipca" = .data$pctch)

  idx_change <-  stats::ts(
    data = idx_change$ipca,
    start = c(
      lubridate::year(dplyr::first(idx_change$date)),
      lubridate::month(dplyr::first(idx_change$date))
      ),
    frequency = 12
    )

  # Monthly percentage change in inflation index items
  items_change <- ipca_core %>%
    dplyr::filter(group == "Item") %>%
    tidyr::pivot_wider(
      id_cols     = date,
      names_from  = code,
      values_from = .data$pctch
      ) %>%
    timetk::tk_ts(
      select = -date,
      start = c(
        lubridate::year(dplyr::first(ipca_core$date)),
        lubridate::month(dplyr::first(ipca_core$date))
        ),
      frequency = 12
    )

  # Monthly weight of inflation index items
  items_weight <- ipca_core %>%
    dplyr::filter(group == "Item") %>%
    tidyr::pivot_wider(
      id_cols     = date,
      names_from  = code,
      values_from = .data$weigh
      ) %>%
    timetk::tk_ts(
      select = -date,
      start = c(
        lubridate::year(dplyr::first(ipca_core$date)),
        lubridate::month(dplyr::first(ipca_core$date))
        ),
      frequency = 12
    )


  # Calculate series of differences between item variation and index (IPCA) variation
  items_diff <- items_change - idx_change
  colnames(items_diff) <- colnames(items_change)

  # Create a sequence of all the dates=
  dates_df <- unique(ipca_core$date)

  # Create an empty matrix of dim = dim(items_change)
  dp_weight <- items_change * 0

  roll <- 48

  # Loop over rolling 48 months: Standard Deviation
  for(i in nrow(items_diff):roll){

    # Get rolling's starting year and month
    start_year <- lubridate::year(dates_df[i - roll + 1])
    start_mth <- lubridate::month(dates_df[i - roll + 1])

    # Get rolling's ending year and month
    end_year <- lubridate::year(dates_df[i])
    end_mth <- lubridate::month(dates_df[i])

    # Get rolling data
    items_diff_roll <- stats::window(
      items_diff,
      start     = c(start_year, start_mth),
      end       = c(end_year, end_mth),
      frequency = 12
      )

    # Calculate standard deviations of the differences
    std_dev <- apply(items_diff_roll, MARGIN = 2, FUN = stats::sd, na.rm = T)

    # Calculate new weights
    dp_weight[i,] <- ((1 / std_dev) / sum(1 / std_dev, na.rm = T)) * items_weight[i,]

  }

  # Rebalance weights
  dp_weight <- dp_weight / rowSums(dp_weight, na.rm = T)

  # Remove first rolling rows from items_change
  items_change <- stats::window(
    items_change,
    start = c(
      lubridate::year(dates_df[roll + 1]),
      lubridate::month(dates_df[roll + 1])
    ),
    frequency = 12
    )

  # Calculate inflation core
  core <- stats::ts(
    rowSums(dp_weight * items_change, na.rm = T),
    start = stats::start(items_change),
    frequency = 12
    )

  ipca_core_dp <- dplyr::tibble(
    date = dates_df[dates_df >= dates_df[roll + 1]],
    core_dp = as.vector(core) %>% round(2)
  )

  return(ipca_core_dp)

}
