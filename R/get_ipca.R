#' Coleta as series do IPCA no SIDRA/IBGE
#'
#' Baixa variacao mensal e peso mensal de todos os componentes do IPCA -- indice
#' geral, grupos, subgrupos, itens e subitens -- para o periodo pedido,
#' costurando automaticamente as cinco estruturas do indice vigentes desde
#' janeiro de 1991 (Tabela 1 da Nota Tecnica 57 do BCB).
#'
#' Cada estrutura do IPCA e servida por uma tabela diferente do SIDRA, listadas
#' em [ipca_estruturas]. Nas duas estruturas mais antigas, variacao e peso estao
#' em tabelas separadas; a partir de julho de 2006 convivem na mesma tabela. A
#' funcao trata as duas formas e devolve sempre o mesmo formato.
#'
#' O codigo devolvido na coluna `codigo` e o codigo estrutural do IPCA -- o
#' mesmo usado pela NT 57 e por [ipca_vetores] -- extraido do descritor do
#' SIDRA. O indice geral recebe o codigo `"0"`.
#'
#' @section Reprodutibilidade do periodo pre-1996:
#' As series calculadas a partir destes dados reproduzem exatamente as series
#' oficiais do BCB (ate a segunda casa decimal) a partir de 1996 para os nucleos
#' de calculo direto e de agosto de 1999 para todas as series. No periodo de
#' alta inflacao e de transicao entre planos monetarios (Collor, 1991; Real,
#' 1994-1995), as variacoes publicadas na API publica do SIDRA divergem das que
#' o BCB utilizou -- construidas a partir de microdados do IBGE --, sobretudo
#' para itens de precos administrados. Nesses meses, mesmo as agregacoes simples
#' nao sao perfeitamente reproduziveis a partir dos dados publicos. O nucleo MS,
#' por suavizar justamente os itens administrados, permanece exato tambem nesse
#' periodo.
#'
#' @param inicio Primeiro mes, no formato `"AAAA-MM"`. O padrao, `"1991-01"`,
#'   e o inicio das series consolidadas pela NT 57.
#' @param fim Ultimo mes, no formato `"AAAA-MM"`. Se `NULL` (padrao), coleta
#'   ate o ultimo mes disponivel.
#' @param quiet Logico. Se `FALSE` (padrao), informa o progresso da coleta.
#'
#' @return Tibble com uma linha por componente e mes, com as colunas `date`,
#'   `pof`, `codigo`, `nivel`, `rotulo`, `variacao` e `peso`.
#' @export
#'
#' @seealso [ipca_estruturas], [ipca_vetores]
#'
#' @examples
#' \dontrun{
#' # Estrutura vigente
#' ipca <- get_ipca(inicio = "2020-01")
#'
#' # Serie completa consolidada pela NT 57 (coleta demorada)
#' ipca_completo <- get_ipca()
#' }
get_ipca <- function(inicio = "1991-01", fim = NULL, quiet = FALSE) {

  inicio <- parse_mes(inicio, "inicio")
  fim    <- if (is.null(fim)) NULL else parse_mes(fim, "fim")

  if (!is.null(fim) && fim < inicio) {
    rlang::abort("`fim` deve ser posterior ou igual a `inicio`.")
  }

  checa_conexao()

  estruturas <- ipca_estruturas
  limite_sup <- if (is.null(fim)) as.Date("9999-12-01") else fim

  # Estruturas que se sobrepoem ao intervalo pedido
  relevantes <- estruturas[
    estruturas$inicio <= limite_sup &
      (is.na(estruturas$fim) | estruturas$fim >= inicio),
    ,
    drop = FALSE
  ]

  if (nrow(relevantes) == 0) {
    rlang::abort("O periodo pedido nao intersecta nenhuma estrutura do IPCA.")
  }

  partes <- vector("list", nrow(relevantes))

  for (i in seq_len(nrow(relevantes))) {
    e <- relevantes[i, ]

    de  <- max(e$inicio, inicio)
    ate <- if (is.na(e$fim)) fim else min(e$fim, limite_sup)

    if (!quiet) {
      rlang::inform(sprintf(
        "Coletando %s (%s a %s)...",
        e$pof, format(de, "%Y-%m"),
        if (is.null(ate)) "ultimo disponivel" else format(ate, "%Y-%m")
      ))
    }

    # Sem limite superior explicito, descobre o ultimo mes publicado para
    # poder dividir o intervalo em lotes.
    if (is.null(ate)) ate <- ultimo_mes(e$tabela_variacao)

    if (e$tabela_variacao == e$tabela_peso) {
      dados <- busca_em_lotes(
        e$tabela_variacao, c(63, 66), de, ate, e$classificacao, e$n_componentes
      )
    } else {
      dados <- dplyr::bind_rows(
        busca_em_lotes(e$tabela_variacao, 63, de, ate, e$classificacao, e$n_componentes),
        busca_em_lotes(e$tabela_peso,     66, de, ate, e$classificacao, e$n_componentes)
      )
    }

    partes[[i]] <- dplyr::mutate(dados, pof = e$pof)
  }

  dplyr::bind_rows(partes) |>
    tidyr::pivot_wider(
      id_cols     = c("date", "pof", "codigo", "nivel", "rotulo"),
      names_from  = "variavel",
      values_from = "valor"
    ) |>
    dplyr::rename(variacao = "63", peso = "66") |>
    dplyr::arrange(.data$date, .data$codigo) |>
    dplyr::as_tibble()
}


# Helpers internos -----------------------------------------------------------

parse_mes <- function(x, arg) {
  if (!rlang::is_character(x) || length(x) != 1 || !grepl("^\\d{4}-\\d{2}$", x)) {
    rlang::abort(sprintf('`%s` deve ser uma string no formato "AAAA-MM".', arg))
  }
  as.Date(paste0(x, "-01"))
}

# A API do SIDRA impoe dois limites praticos: recusa consultas acima de 50.000
# valores e, para respostas grandes, o download pode estourar o tempo. Os lotes
# sao dimensionados pelo menor dos dois tetos.
LIMITE_SIDRA <- 45000L  # valores por requisicao
MESES_MAX    <- 24L     # teto de meses por lote, para respostas gerenciaveis

busca_em_lotes <- function(tabela, variaveis, de, ate, classificacao, n_componentes) {

  por_mes  <- n_componentes * length(variaveis)
  max_mes  <- max(1L, min(LIMITE_SIDRA %/% por_mes, MESES_MAX))

  meses  <- seq(de, ate, by = "month")
  lotes  <- split(meses, ceiling(seq_along(meses) / max_mes))

  dplyr::bind_rows(lapply(lotes, function(bloco) {
    periodo <- paste0(
      format(min(bloco), "%Y%m"), "-", format(max(bloco), "%Y%m")
    )
    busca_sidra(tabela, variaveis, periodo, classificacao)
  }))
}

# Ultimo mes publicado numa tabela, segundo os metadados do IBGE.
ultimo_mes <- function(tabela) {
  u <- sprintf("https://servicodados.ibge.gov.br/api/v3/agregados/%d/metadados", tabela)
  meta <- jsonlite::fromJSON(u, simplifyVector = FALSE)
  fim <- meta$periodicidade$fim
  if (is.null(fim)) {
    rlang::abort(sprintf(
      "Nao foi possivel descobrir o ultimo mes da tabela %d do SIDRA.", tabela
    ))
  }
  as.Date(paste0(fim, "01"), format = "%Y%m%d")
}

checa_conexao <- function() {
  if (!curl::has_internet()) {
    rlang::abort("Sem conexao com a internet.")
  }
  resp <- tryCatch(
    httr::GET("https://apisidra.ibge.gov.br/", httr::timeout(60)),
    error = function(e) e
  )
  # Nao mascarar a causa: um erro de ambiente (pacote ausente, proxy, DNS) nao
  # e a mesma coisa que a API estar fora do ar.
  if (inherits(resp, "error")) {
    rlang::abort(paste0(
      "Falha ao contatar a API do SIDRA/IBGE: ", conditionMessage(resp)
    ))
  }
  if (httr::http_error(resp)) {
    rlang::abort(sprintf(
      "A API do SIDRA/IBGE respondeu com erro (HTTP %d).",
      httr::status_code(resp)
    ))
  }
  invisible(TRUE)
}

busca_sidra <- function(tabela, variaveis, periodo, classificacao, tentativas = 3L) {

  url <- sprintf(
    "https://apisidra.ibge.gov.br/values/t/%d/n1/all/v/%s/p/%s/%s/all?formato=json",
    tabela, paste(variaveis, collapse = ","), periodo, classificacao
  )

  # O SIDRA ocasionalmente expira em respostas grandes; tenta de novo antes de
  # desistir, com espera crescente entre as tentativas.
  resp <- NULL
  for (t in seq_len(tentativas)) {
    resp <- tryCatch(
      httr::GET(url, httr::timeout(180)),
      error = function(e) e
    )
    if (!inherits(resp, "error")) break
    if (t < tentativas) Sys.sleep(2 * t)
  }
  if (inherits(resp, "error")) {
    rlang::abort(sprintf(
      "Falha de rede ao consultar a tabela %d do SIDRA: %s",
      tabela, conditionMessage(resp)
    ))
  }

  if (httr::http_error(resp)) {
    rlang::abort(sprintf(
      "Falha ao consultar a tabela %d do SIDRA (HTTP %d).",
      tabela, httr::status_code(resp)
    ))
  }

  bruto <- jsonlite::fromJSON(
    httr::content(resp, as = "text", encoding = "UTF-8"),
    simplifyDataFrame = TRUE
  )

  if (!is.data.frame(bruto) || nrow(bruto) < 2) {
    rlang::abort(sprintf("A tabela %d do SIDRA nao devolveu dados.", tabela))
  }

  # A primeira linha e o cabecalho descritivo da API, nao um dado.
  bruto <- bruto[-1, , drop = FALSE]

  # Subitens nao pesquisados no mes vem como '...' (nota de rodape 13 da NT 57)
  # e devem virar NA, nao zero.
  valor <- suppressWarnings(as.numeric(bruto$V))

  tibble::tibble(
    date     = as.Date(paste0(bruto$D3C, "01"), format = "%Y%m%d"),
    variavel = bruto$D2C,
    rotulo   = extrai_rotulo(bruto$D4N),
    codigo   = extrai_codigo(bruto$D4N),
    valor    = valor
  ) |>
    dplyr::mutate(nivel = classifica_nivel(.data$codigo))
}

# O descritor do SIDRA traz o codigo estrutural como prefixo -- por exemplo
# "1101002.Arroz". O indice geral vem como "Indice geral", sem prefixo, e
# recebe o codigo "0", como no anexo da NT 57.
extrai_codigo <- function(descritor) {
  ifelse(grepl("^[0-9]+[.]", descritor), sub("[.].*$", "", descritor), "0")
}

extrai_rotulo <- function(descritor) {
  sub("^[0-9]+[.]", "", descritor)
}

# Nivel hierarquico pelo numero de digitos do codigo (nota de rodape 6 da NT 57).
classifica_nivel <- function(codigo) {
  n <- nchar(codigo)
  nivel <- dplyr::case_when(
    codigo == "0" ~ "Geral",
    n == 1        ~ "Grupo",
    n == 2        ~ "Subgrupo",
    n == 4        ~ "Item",
    n == 7        ~ "Subitem"
  )
  if (anyNA(nivel)) {
    rlang::abort(paste(
      "Codigo do SIDRA fora do padrao hierarquico esperado:",
      paste(unique(codigo[is.na(nivel)]), collapse = ", ")
    ))
  }
  nivel
}
