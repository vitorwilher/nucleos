# Calcula as series obtidas por agregacao simples do IPCA

Aplica a formula geral da Subsecao 2.1.2 da Nota Tecnica 57 do BCB: a
variacao mensal de uma serie e a media das variacoes dos componentes que
a integram, ponderada pelos pesos originais do IPCA.

## Usage

``` r
agregar(data, serie = NULL)
```

## Arguments

- data:

  Tibble devolvido por
  [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md).

- serie:

  Nome da serie a calcular. Se `NULL` (padrao), calcula todas as 17
  series.

## Value

Tibble com as colunas `date`, `serie` e `variacao`.

## Details

\$\$\pi_t = \frac{\sum_i a\_{i,t}\\ w\_{i,t}\\ \pi\_{i,t}}{\sum_i
a\_{i,t}\\ w\_{i,t}}\$\$

em que \\a\_{i,t}\\ e o vetor de agregacao da serie – 1 se o componente
integra a serie no mes, 0 caso contrario. Os vetores estao em
[ipca_vetores](https://vitorwilher.github.io/nucleos/reference/ipca_vetores.md)
e mudam entre os seis subperiodos do IPCA; a funcao seleciona o vetor
vigente em cada mes automaticamente.

Como os vetores incluem cada componente no nivel hierarquico mais alto
possivel, os componentes selecionados nunca se sobrepoem: somar um grupo
e somar todos os seus subitens sao alternativas excludentes, e a
convencao escolhe a primeira.

As 17 series disponiveis sao: `"Administrados"`, `"Livres"`,
`"Alimentacao no domicilio"`, `"Servicos"`, `"Bens industriais"`,
`"Comercializaveis"`, `"Nao comercializaveis"`, `"Bens nao duraveis"`,
`"Bens semiduraveis"`, `"Bens duraveis"`, `"Nucleo EX-FE"`,
`"Nucleo EX0"`, `"Nucleo EX1"`, `"Nucleo EX2"`, `"Nucleo EX3"`,
`"EX3 Servicos"` e `"EX3 Industriais"`. Os nomes aceitos sao os de
[ipca_vetores](https://vitorwilher.github.io/nucleos/reference/ipca_vetores.md),
com ou sem acentuacao.

## See also

[ipca_vetores](https://vitorwilher.github.io/nucleos/reference/ipca_vetores.md),
[`core_ma()`](https://vitorwilher.github.io/nucleos/reference/core_ma.md),
[`core_p55()`](https://vitorwilher.github.io/nucleos/reference/core_p55.md)

## Examples

``` r
if (FALSE) { # \dontrun{
ipca <- get_ipca(inicio = "2020-01")

# Uma serie
ex1 <- agregar(ipca, "Nucleo EX1")

# Todas as 17
todas <- agregar(ipca)
} # }
```
