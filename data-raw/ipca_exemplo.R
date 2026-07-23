# Dataset de exemplo embutido no pacote, para o tutorial e para experimentacao.
#
# E a saida de get_ipca() para o periodo jan/2015 a jun/2026 -- um recorte
# recente e plenamente reproduzivel da API do SIDRA, com historico suficiente
# para todos os nucleos (o DP exige 48 meses de janela).
#
# O snapshot foi coletado uma vez e salvo; este script apenas o promove a dado
# do pacote, para que a vinheta renderize sem depender de rede.

# Coleta ao vivo (equivalente ao snapshot usado):
# ipca_exemplo <- get_ipca(inicio = "2015-01", fim = "2026-06")

ipca_exemplo <- readRDS("tests/testthat/fixtures/ipca_2015_2026.rds")

stopifnot(
  all(c("date", "pof", "codigo", "nivel", "variacao", "peso") %in% names(ipca_exemplo)),
  min(ipca_exemplo$date) == as.Date("2015-01-01")
)

usethis::use_data(ipca_exemplo, overwrite = TRUE, compress = "xz")
