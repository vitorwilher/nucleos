# Historico de variacoes para a janela dos nucleos MS e DP, com proxies de
# transicao (Subsecoes 2.2 e 2.4 da NT 57).
#
# Os nucleos MS e DP dependem do historico recente de cada item -- 11 e 48
# meses. Nos primeiros meses de vigencia de uma estrutura, essa janela alcanca a
# estrutura anterior. Para a maioria dos itens, basta concatenar as variacoes do
# item de mesmo codigo na estrutura antiga. Para os itens sem correspondencia
# direta, a nota define proxies: uma media ponderada de componentes da estrutura
# anterior, com sinais.
#
# O historico e construido POR estrutura de destino, e nao de forma global,
# porque um mesmo codigo pode existir em duas estruturas com significados
# diferentes (por exemplo '8101.Cursos'). A extensao de uma estrutura nunca
# altera o historico proprio da estrutura anterior.
#
# Devolve um tibble (codigo, date, variacao) cobrindo os meses da estrutura
# `alvo` mais os `reach` meses anteriores necessarios a janela. Serve apenas
# para alimentar a suavizacao (MS) ou a volatilidade (DP) dos itens reais de
# `alvo`; nao e um painel de itens para agregacao.
historico_com_proxy <- function(itens, alvo, nucleo, reach) {

  estrut <- ipca_estruturas[order(ipca_estruturas$inicio), ]
  pos    <- match(alvo, estrut$pof)

  items_S <- itens[itens$pof == alvo, c("codigo", "date", "variacao")]
  codes_S <- unique(items_S$codigo)

  # Primeira estrutura: nao ha o que concatenar antes.
  if (is.na(pos) || pos == 1L) {
    return(dplyr::arrange(items_S, .data$codigo, .data$date))
  }

  anterior <- estrut$pof[pos - 1L]
  ant <- itens[itens$pof == anterior, c("codigo", "date", "variacao", "peso")]

  # Apenas os `reach` ultimos meses da estrutura anterior importam para a janela.
  meses_reach <- utils::tail(sort(unique(ant$date)), reach)
  ant <- ant[ant$date %in% meses_reach, , drop = FALSE]

  prox <- ipca_proxies[
    ipca_proxies$nucleo == nucleo & ipca_proxies$pof_destino == alvo, ,
    drop = FALSE
  ]
  itens_proxy <- unique(prox$item)

  # Itens de `alvo` que concatenam diretamente com o mesmo codigo na estrutura
  # anterior (todos menos os que tem proxy).
  conc <- ant[
    ant$codigo %in% setdiff(codes_S, itens_proxy),
    c("codigo", "date", "variacao")
  ]

  # Itens com proxy: variacao reconstruida a partir dos componentes antigos.
  proxy_rows <- lapply(intersect(itens_proxy, codes_S), function(item) {
    comps <- prox[prox$item == item, c("componente", "sinal")]
    ant |>
      dplyr::inner_join(comps, by = c("codigo" = "componente")) |>
      dplyr::group_by(.data$date) |>
      dplyr::summarise(
        variacao = sum(.data$sinal * .data$peso * .data$variacao) /
          sum(.data$sinal * .data$peso),
        .groups = "drop"
      ) |>
      dplyr::mutate(codigo = item) |>
      dplyr::select("codigo", "date", "variacao")
  })

  dplyr::arrange(
    dplyr::bind_rows(conc, dplyr::bind_rows(proxy_rows), items_S),
    .data$codigo, .data$date
  )
}

# Estruturas presentes em `itens`, na ordem cronologica da NT 57.
estruturas_presentes <- function(itens) {
  ordem <- ipca_estruturas$pof[order(ipca_estruturas$inicio)]
  intersect(ordem, unique(itens$pof))
}
