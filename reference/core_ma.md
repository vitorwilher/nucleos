# Nucleo de medias aparadas sem suavizacao (MA)

Ordena os itens do IPCA pela variacao de precos, descarta as caudas ate
que os pesos acumulados atinjam 20% de cada lado e devolve a media
ponderada das variacoes remanescentes (Subsecao 2.3 da Nota Tecnica 57
do BCB).

## Usage

``` r
core_ma(data)
```

## Arguments

- data:

  Tibble devolvido por
  [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md).

## Value

Tibble com as colunas `date` e `variacao`.

## Details

Os itens que atravessam os limites de 20% e 80% nao entram nem saem por
inteiro: entram com o peso correspondente apenas a fracao dentro da
faixa, conforme a etapa (iv) da nota. Na pratica isso equivale a
atribuir a cada item o peso

\$\$\tilde{w}\_i = \min(W_i, 80) - \max(W\_{i-1}, 20)\$\$

em que \\W_i\\ e o peso acumulado ate o item \\i\\, descartando os itens
para os quais essa expressao seja negativa ou nula.

O calculo usa apenas os componentes de nivel `"Item"`; a filtragem e
feita internamente.

## See also

[`core_ms()`](https://vitorwilher.github.io/nucleos/reference/core_ms.md),
[`core_p55()`](https://vitorwilher.github.io/nucleos/reference/core_p55.md),
[`agregar()`](https://vitorwilher.github.io/nucleos/reference/agregar.md)

## Examples

``` r
if (FALSE) { # \dontrun{
ipca <- get_ipca(inicio = "2020-01")
core_ma(ipca)
} # }
```
