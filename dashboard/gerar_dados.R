#!/usr/bin/env Rscript
# Pipeline de dados do dashboard de núcleos de inflação.
#
# Coleta o IPCA, calcula as 22 séries analíticas com o pacote nucleos, confere
# contra a série oficial do SGS e grava um artefato compacto que o app Shiny lê
# no startup. Roda mensalmente no GitHub Actions, após a divulgação do IPCA.
#
# Saídas (em dashboard/dados/):
#   series_nucleos.rds  -- lista com series, conformidade e metadados (para o app)
#   series_nucleos.csv  -- as séries em formato longo (portabilidade / download)
#
# Variáveis de ambiente (opcionais):
#   NUCLEOS_INICIO   primeiro mês coletado (padrão "1996-01"; DP precisa de 48m
#                    de histórico antes do primeiro mês exibido)
#   NUCLEOS_EXIBIR   primeiro mês exibido no artefato (padrão "2000-01")
#   NUCLEOS_PANEL    caminho de um painel get_ipca() já salvo (.rds), para
#                    testes locais sem recoletar do SIDRA

suppressMessages({
  library(nucleos)
  library(dplyr)
})

inicio <- Sys.getenv("NUCLEOS_INICIO", "1996-01")
exibir <- as.Date(paste0(Sys.getenv("NUCLEOS_EXIBIR", "2000-01"), "-01"))
painel <- Sys.getenv("NUCLEOS_PANEL", "")

message("== Coletando o IPCA ==")
if (nzchar(painel) && file.exists(painel)) {
  message("Usando painel local: ", painel)
  ipca <- readRDS(painel)
} else {
  ipca <- get_ipca(inicio = inicio, quiet = TRUE)
}
message("Painel: ", nrow(ipca), " linhas, ", dplyr::n_distinct(ipca$date), " meses")

# --- Calcula todas as séries em formato longo (date, serie, variacao) --------

message("== Calculando as séries ==")

agregacoes <- agregar(ipca)  # 17 séries por agregação simples

direto <- dplyr::bind_rows(
  dplyr::mutate(core_ma(ipca),  serie = "Núcleo MA"),
  dplyr::mutate(core_ms(ipca),  serie = "Núcleo MS"),
  dplyr::mutate(core_dp(ipca),  serie = "Núcleo DP"),
  dplyr::mutate(core_p55(ipca), serie = "Núcleo P55"),
  dplyr::mutate(difusao(ipca),  serie = "Difusão")
)

ipca_cheio <- ipca |>
  dplyr::filter(codigo == "0") |>
  dplyr::transmute(date, serie = "IPCA cheio", variacao)

series <- dplyr::bind_rows(agregacoes, direto, ipca_cheio) |>
  dplyr::filter(date >= exibir) |>
  dplyr::arrange(serie, date) |>
  dplyr::select(date, serie, variacao)

message("Séries: ", dplyr::n_distinct(series$serie),
        " | período ", format(min(series$date)), " a ", format(max(series$date)))

# --- Confere contra o SGS (últimos 24 meses, onde há série oficial) ----------

message("== Conferindo contra o SGS ==")

# 24 meses antes do último mês exibido
desde_conf <- format(
  seq(max(series$date), by = "-24 months", length.out = 2)[2], "%Y-%m"
)

conferir_serie <- function(nome, codigo_sgs) {
  calc <- dplyr::filter(series, serie == nome)
  # O SGS ocasionalmente falha; tenta algumas vezes antes de desistir.
  ofi <- NULL
  for (tentativa in 1:3) {
    ofi <- tryCatch(get_sgs(codigo_sgs, inicio = desde_conf),
                    error = function(e) NULL)
    if (!is.null(ofi) && nrow(ofi) > 0) break
    Sys.sleep(1)
  }
  if (is.null(ofi) || nrow(ofi) == 0) {
    return(tibble::tibble(serie = nome, meses = 0L, erro_max = NA_real_))
  }
  cmp <- dplyr::inner_join(calc, ofi, by = "date", suffix = c("", "_ofi"))
  tibble::tibble(
    serie    = nome,
    meses    = nrow(cmp),
    erro_max = max(abs(round(cmp$variacao, 2) - cmp$variacao_ofi))
  )
}

conformidade <- dplyr::bind_rows(
  Map(conferir_serie, series_sgs$serie, series_sgs$sgs)
)

# --- Metadados ---------------------------------------------------------------

metadata <- list(
  atualizado_em = Sys.Date(),
  ultimo_mes    = max(series$date),
  n_series      = dplyr::n_distinct(series$serie),
  fonte         = "IPCA/SIDRA (IBGE); séries oficiais do SGS (BCB)",
  metodologia   = "Nota Técnica 57 do Banco Central do Brasil (dez/2025)"
)

artefato <- list(
  series       = series,
  conformidade = conformidade,
  metadata     = metadata
)

dir.create("dashboard/dados", showWarnings = FALSE, recursive = TRUE)
saveRDS(artefato, "dashboard/dados/series_nucleos.rds")
utils::write.csv(series, "dashboard/dados/series_nucleos.csv", row.names = FALSE)

message("\n== Pronto ==")
message("Atualizado em: ", metadata$atualizado_em,
        " | último mês: ", format(metadata$ultimo_mes, "%b/%Y"))
message("Conformidade (erro máx. sobre os últimos 24 meses):")
print(as.data.frame(conformidade))
