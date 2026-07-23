# Indice de difusao do IPCA

Percentual de subitens do IPCA com variacao de precos positiva no mes
(Subsecao 2.6 da Nota Tecnica 57 do BCB). Os pesos nao entram no
calculo.

## Usage

``` r
difusao(data)
```

## Arguments

- data:

  Tibble devolvido por
  [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md).

## Value

Tibble com as colunas `date` e `variacao`, esta ultima em pontos
percentuais de 0 a 100.

## Details

Apenas os subitens efetivamente pesquisados no mes sao considerados. Nas
bases do IBGE, subitens nao pesquisados aparecem com variacao registrada
como `'...'`, que
[`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md)
converte para `NA` – e nao para zero, o que os contaria erroneamente
como precos estaveis no denominador.

## See also

[`core_p55()`](https://vitorwilher.github.io/nucleos/reference/core_p55.md)

## Examples

``` r
if (FALSE) { # \dontrun{
ipca <- get_ipca(inicio = "2020-01")
difusao(ipca)
} # }
```
