# Snapshot do IPCA coletado do SIDRA em julho de 2026, cobrindo jan/2020 a
# jun/2026 -- toda a estrutura POF 2017-2018. Permite testar os calculos sem
# depender da rede.
ipca_fixture <- function() {
  readRDS(test_path("fixtures", "ipca_2020_2026.rds"))
}

# Valores oficiais do SGS para o mesmo periodo, usados quando ha rede.
oficial <- function(codigo, inicio = "2024-01", fim = "2026-06") {
  get_sgs(codigo, inicio = inicio, fim = fim)
}

pula_sem_rede <- function() {
  testthat::skip_on_cran()
  testthat::skip_if_offline()
}
