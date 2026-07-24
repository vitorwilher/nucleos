#!/usr/bin/env Rscript
# Gera o snapshot JSON embutido no Worker (mcp/src/data.json) a partir do
# artefato do dashboard (dashboard/dados/series_nucleos.rds).
#
# Rodar da raiz do repositório:
#   Rscript --vanilla mcp/gerar_snapshot.R
#
# Datas viram "YYYY-MM"; valores são arredondados a 2 casas (a precisão em que
# as séries reproduzem o SGS). Metadados vêm do próprio artefato.

suppressMessages({ library(jsonlite) })

art  <- readRDS("dashboard/dados/series_nucleos.rds")
df   <- art$series
meta <- art$metadata

nomes <- sort(unique(df$serie))
series_list <- list()
for (nm in nomes) {
  sub <- df[df$serie == nm, ]
  sub <- sub[order(sub$date), ]
  series_list[[nm]] <- list(
    d = format(as.Date(sub$date), "%Y-%m"),
    v = round(sub$variacao, 2)
  )
}

out <- list(
  metadata = list(
    atualizado_em = as.character(meta$atualizado_em),
    ultimo_mes    = format(as.Date(meta$ultimo_mes), "%Y-%m"),
    n_series      = length(nomes),
    fonte         = meta$fonte,
    metodologia   = meta$metodologia
  ),
  series = series_list
)

dir.create("mcp/src", recursive = TRUE, showWarnings = FALSE)
writeLines(
  toJSON(out, auto_unbox = TRUE, digits = 2, pretty = FALSE),
  "mcp/src/data.json"
)
cat("OK:", length(nomes), "séries, último mês",
    format(as.Date(meta$ultimo_mes), "%Y-%m"), "-> mcp/src/data.json\n")
