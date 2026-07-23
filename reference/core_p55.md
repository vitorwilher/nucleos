# Nucleo percentil 55 (P55)

Devolve a variacao de precos do subitem que ocupa o 55o percentil da
distribuicao ponderada pelos pesos dos subitens do IPCA (Subsecao 2.5 da
Nota Tecnica 57 do BCB).

## Usage

``` r
core_p55(data)
```

## Arguments

- data:

  Tibble devolvido por
  [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md).

## Value

Tibble com as colunas `date` e `variacao`.

## Details

O percentil 55, e nao a mediana, foi escolhido por minimizar o vies em
relacao a inflacao cheia: a distribuicao das variacoes de precos e
assimetrica a direita, de modo que a mediana tende a subestimar a
inflacao.

Diferentemente dos nucleos MA e MS, que operam sobre itens, o P55 e
calculado sobre subitens. A filtragem e feita internamente.

## See also

[`core_ma()`](https://vitorwilher.github.io/nucleos/reference/core_ma.md),
[`difusao()`](https://vitorwilher.github.io/nucleos/reference/difusao.md)

## Examples

``` r
if (FALSE) { # \dontrun{
ipca <- get_ipca(inicio = "2020-01")
core_p55(ipca)
} # }
```
