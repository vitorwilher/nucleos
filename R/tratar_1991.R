# Tratamento dos meses de agosto e setembro de 1991 (Subsecao 2.7 da NT 57).
#
# O IBGE nao divulgou a inflacao de agosto de 1991; o valor reportado para
# setembro e a variacao acumulada dos dois meses. A nota resolve isso de duas
# formas, conforme a serie:
#
#   - Series por agregacao simples, MA, P55 e difusao: calcula-se a serie
#     normalmente com os dados de set/91 e, em seguida, atribui-se a media
#     geometrica do resultado tanto a agosto quanto a setembro. Na difusao,
#     atribui-se o proprio valor de setembro aos dois meses.
#
#   - Nucleos MS e DP: o desdobramento ocorre antes do calculo, no painel de
#     itens. Para cada item e para o indice geral, a media geometrica da
#     variacao de set/91 e atribuida a agosto e a setembro; o nucleo e entao
#     calculado sobre esse historico ajustado.
#
# `raiz_geometrica_bimestre` converte a variacao acumulada de dois meses na
# variacao mensal constante que a reproduz: (1 + r/100) = sqrt(1 + acum/100).

SET91 <- as.Date("1991-09-01")
AGO91 <- as.Date("1991-08-01")

raiz_geometrica_bimestre <- function(acumulado) {
  (sqrt(1 + acumulado / 100) - 1) * 100
}

# Desdobra o painel de itens para MS e DP: substitui a linha de set/91 por duas
# linhas identicas (ago e set) com a variacao mensal media. Os pesos sao
# mantidos como os de setembro. Retorna o painel inalterado se set/91 nao
# estiver presente.
desdobrar_bimestre_1991 <- function(data) {
  if (!SET91 %in% data$date) return(data)

  set91 <- data[data$date == SET91, , drop = FALSE]
  set91$variacao <- raiz_geometrica_bimestre(set91$variacao)

  ago91 <- set91
  ago91$date <- AGO91

  outros <- data[data$date != SET91, , drop = FALSE]

  dplyr::arrange(dplyr::bind_rows(outros, ago91, set91), .data$date, .data$codigo)
}

# Ajusta a serie ja calculada (agregacoes, MA, P55): substitui o valor de
# set/91 pela media geometrica e replica em agosto. Se houver coluna `serie`
# (caso de agregar()), o ajuste e feito serie a serie.
ajustar_resultado_1991 <- function(res, geometrica = TRUE) {
  if (!SET91 %in% res$date) return(res)

  linha_set <- res[res$date == SET91, , drop = FALSE]
  if (geometrica) {
    linha_set$variacao <- raiz_geometrica_bimestre(linha_set$variacao)
  }

  linha_ago <- linha_set
  linha_ago$date <- AGO91

  outros <- res[!res$date %in% c(AGO91, SET91), , drop = FALSE]

  ordenar <- if ("serie" %in% names(res)) {
    function(x) dplyr::arrange(x, .data$serie, .data$date)
  } else {
    function(x) dplyr::arrange(x, .data$date)
  }

  ordenar(dplyr::bind_rows(outros, linha_ago, linha_set))
}
