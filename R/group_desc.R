#' Create IPCA groups, subsgroups, etc. descriptions and codes
#'
#' @param data Output from get_ipca()
#'
#' @return List of data frames with new columns
#' @export
#'
#' @examples
#' \dontrun{
#' library(magrittr)
#' my_df <- get_sidra(period = "last") %>%
#' group_desc()
#' }
group_desc <- function(data) {

  df_desc <- data %>%
    purrr::map(
      ~dplyr::mutate(
        .x,
        snipc = stringr::str_count(desc, "\\d"),
        group = dplyr::case_when(
          snipc == 0 ~ "Geral",
          snipc == 1 ~ "Grupo",
          snipc == 2 ~ "Subgrupo",
          snipc == 4 ~ "Item",
          snipc == 7 ~ "Subitem"
          ),
        snipc = stringr::str_sub(desc, 1, stringr::str_count(desc, "\\d"))
        )
      )

  return(df_desc)

}
