# Vetores de agregacao da Nota Tecnica 57 do BCB (dez/2025)
#
# Fonte: Vetores_NT_57.xlsx, anexo da NT 57 "Nucleos de inflacao e outras series
# analiticas derivadas do IPCA: metodologia consolidada".
#
# O arquivo traz, para cada um dos seis subperiodos do IPCA, uma matriz 0/1 que
# indica quais componentes compoem cada uma das 17 series obtidas por agregacao
# simples (Secao 2.1.2 da nota). Duas convencoes definem o vetor de forma unica:
#   (i)  o vetor contem apenas 0s e 1s -- componentes sao somados, nunca subtraidos;
#   (ii) a inclusao ocorre no nivel hierarquico mais alto possivel.
#
# Este script converte essa matriz para formato longo, guardando apenas os
# componentes efetivamente incluidos em cada serie.

library(dplyr)

arquivo <- "Vetores_NT_57.xlsx"

# Subperiodos do anexo. Note que a estrutura ago/99-jun/06 e subdividida em
# ago/99-dez/05 e jan/06-jun/06, por conta das mudancas de composicao
# introduzidas em janeiro de 2006 (nota de rodape 8 da NT 57).
periodos <- tibble::tribble(
  ~aba,              ~inicio,        ~fim,           ~pof,
  "jan91-jul99",     "1991-01-01",   "1999-07-01",   "POF 1987-1988",
  "ago99-dez05",     "1999-08-01",   "2005-12-01",   "POF 1995-1996",
  "jan06-jun06",     "2006-01-01",   "2006-06-01",   "POF 1995-1996",
  "jul06-dez11",     "2006-07-01",   "2011-12-01",   "POF 2002-2003",
  "jan12-dez19",     "2012-01-01",   "2019-12-01",   "POF 2008-2009",
  "jan20-presente",  "2020-01-01",   NA_character_,  "POF 2017-2018"
) |>
  mutate(inicio = as.Date(inicio), fim = as.Date(fim))

ler_aba <- function(aba, inicio, fim, pof) {
  d <- readxl::read_excel(arquivo, sheet = aba, .name_repair = "minimal")

  nomes_series <- names(d)[-1]
  componente   <- d[[1]]

  # O nome do componente embute o codigo estrutural do IPCA: "1101002.Arroz".
  codigo <- sub("[.].*$", "", componente)
  rotulo <- sub("^[^.]*[.]", "", componente)

  # Nivel hierarquico pelo numero de digitos (nota de rodape 6 da NT 57).
  nivel <- dplyr::case_when(
    codigo == "0"      ~ "Geral",
    nchar(codigo) == 1 ~ "Grupo",
    nchar(codigo) == 2 ~ "Subgrupo",
    nchar(codigo) == 4 ~ "Item",
    nchar(codigo) == 7 ~ "Subitem"
  )

  stopifnot(!any(is.na(nivel)))

  matriz <- as.matrix(d[, -1])
  stopifnot(all(matriz %in% c(0, 1)))  # convencao (i)

  idx <- which(matriz == 1, arr.ind = TRUE)

  tibble::tibble(
    pof     = pof,
    inicio  = inicio,
    fim     = fim,
    serie   = nomes_series[idx[, "col"]],
    codigo  = codigo[idx[, "row"]],
    nivel   = nivel[idx[, "row"]],
    rotulo  = rotulo[idx[, "row"]]
  )
}

ipca_vetores <- purrr::pmap_dfr(
  list(periodos$aba, periodos$inicio, periodos$fim, periodos$pof),
  ler_aba
) |>
  arrange(inicio, serie, codigo)

stopifnot(dplyr::n_distinct(ipca_vetores$serie) == 17)

usethis::use_data(ipca_vetores, overwrite = TRUE)
