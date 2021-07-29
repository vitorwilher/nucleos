raw_ipca_1419 <- sidrar::info_sidra(1419) %>%
  magrittr::extract2(3) %>%
  dplyr::as_tibble() %>%
  dplyr::mutate(
    dados = purrr::map(
      cod,
      ~sidrar::get_sidra(
        x        = 1419,
        variable = .x,
        period   = "all"
      )
    )
  )
