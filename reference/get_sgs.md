# Coleta uma serie analitica do IPCA no SGS do Banco Central

Baixa a serie oficial publicada pelo BCB no Sistema Gerenciador de
Series Temporais (SGS). Serve para conferir os resultados calculados
pelo pacote contra a fonte de verdade.

## Usage

``` r
get_sgs(codigo, inicio = "1991-01", fim = NULL)
```

## Arguments

- codigo:

  Codigo numerico da serie no SGS.

- inicio:

  Primeiro mes, no formato `"AAAA-MM"`.

- fim:

  Ultimo mes, no formato `"AAAA-MM"`. Se `NULL` (padrao), vai ate o fim
  da serie.

## Value

Tibble com as colunas `date` e `variacao`.

## Details

Os codigos das 22 series consolidadas pela NT 57 estao em
[series_sgs](https://vitorwilher.github.io/nucleos/reference/series_sgs.md).
As series anteriores a consolidacao continuam no SGS sob outros codigos,
mas deixaram de ser atualizadas.

## See also

[series_sgs](https://vitorwilher.github.io/nucleos/reference/series_sgs.md),
[`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Nucleo MA oficial
get_sgs(11426, inicio = "2020-01")
} # }
```
