
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nucleos

<!-- badges: start -->

[![R-CMD-check](https://github.com/analisemacropro/nucleos/workflows/R-CMD-check/badge.svg)](https://github.com/analisemacropro/nucleos/actions)
<!-- badges: end -->

O objetivo deste pacote é **calcular as medidas de núcleos de inflação**
divulgadas pelo Banco Central do Brasil a partir dos dados desagregados
do IPCA/IBGE. O pacote contempla o cálculo dos núcleos por exclusão e
estatísticos comumente acompanhados pela autoridade monetária: IPCA-EX0,
IPCA-EX1, IPCA-EX2, IPCA-EX3, IPCA-MA, IPCA-MS e IPCA-DP.

Este pacote desenvolvido em `R` e faz parte dos **cursos da [Análise
Macro](https://analisemacro.com.br/)**.

## Licença

Copyright 2021 Análise Macro. All rights reserved.

## Instalação

O pacote pode ser instalado através do [GitHub](https://github.com/) com
o `remotes`:

``` r
if(!require("remotes")) install.packages("remotes")
remotes::install_github("analisemacropro/nucleos")
```

## Funcionalidades

Resumo das principais funcionalidade do pacote:

| Tipo             | Núcleo   | Função                  |
|------------------|----------|-------------------------|
| Exclusão         | IPCA-EX0 | `nucleos::core_adhoc()` |
| Exclusão         | IPCA-EX1 | `nucleos::core_adhoc()` |
| Exclusão         | IPCA-EX2 | `nucleos::core_adhoc()` |
| Exclusão         | IPCA-EX3 | `nucleos::core_adhoc()` |
| Média aparada    | IPCA-MA  | `nucleos::core_ma()`    |
| Média aparada    | IPCA-MS  | `nucleos::core_ms()`    |
| Dupla ponderação | IPCA-DP  | `nucleos::core_dp()`    |

## Utilização

Exemplos de utilização, primeiro colete os dados:

``` r
# Carregar pacotes para exemplos
if(!require("pacman")) install.packages("pacman")
#> Loading required package: pacman
pacman::p_load("nucleos", "dplyr", "magrittr")

# Coletar e tratar dados desagregados do IPCA
ipca_core <- nucleos::get_ipca(table = c(1419, 7060), period = "all") %>%
  nucleos::group_desc()
#> Fetching SIDRA data...
#> Considering all categories once 'classific' was set to 'all' (default)
#> Considering all categories once 'classific' was set to 'all' (default)
#> Considering all categories once 'classific' was set to 'all' (default)
#> Considering all categories once 'classific' was set to 'all' (default)

# Resultado
ipca_core
#> # A tibble: 53,227 x 8
#>    date       table  code desc                 pct_change   weight snipc  group 
#>    <date>     <chr> <dbl> <chr>                     <dbl>    <dbl> <chr>  <chr> 
#>  1 2012-01-01 1419   7169 Índice geral               0.56 100      ""     Geral 
#>  2 2012-01-01 1419   7170 1.Alimentação e beb~       0.86  23.1    "1"    Grupo 
#>  3 2012-01-01 1419   7171 11.Alimentação no d~       0.68  15.2    "11"   Subgr~
#>  4 2012-01-01 1419   7172 1101.Cereais, legum~       5.44   0.822  "1101" Item  
#>  5 2012-01-01 1419   7173 1101002.Arroz              1.32   0.505  "1101~ Subit~
#>  6 2012-01-01 1419   7175 1101051.Feijão - mu~      16.0    0.0216 "1101~ Subit~
#>  7 2012-01-01 1419   7176 1101052.Feijão - pr~       5.42   0.0537 "1101~ Subit~
#>  8 2012-01-01 1419   7177 1101053.Feijão - ma~       1.17   0.0336 "1101~ Subit~
#>  9 2012-01-01 1419  12222 1101073.Feijão - ca~      15.1    0.207  "1101~ Subit~
#> 10 2012-01-01 1419  41128 1101075.Feijão - br~      NA     NA      "1101~ Subit~
#> # ... with 53,217 more rows
```

Calculando o IPCA-EX0:

``` r
# Núcleo IPCA-EX0
ipca_ex0 <- nucleos::core_adhoc(
  core   = "ex0", # pode ser também ex1, ex2, ex3
  data   = ipca_core,
  change = "pct_change",  # nome da coluna com variações mensais
  weight = "weight",      # nome da coluna dos pesos
  code   = "code",        # nome da coluna de identificação do código do elemento
  date   = "date"         # nome da coluna de datas
  )

# Resultado
ipca_ex0
#> # A tibble: 115 x 2
#>    date       ipca_ex0
#>    <date>        <dbl>
#>  1 2012-01-01     0.57
#>  2 2012-02-01     0.65
#>  3 2012-03-01     0.21
#>  4 2012-04-01     0.71
#>  5 2012-05-01     0.26
#>  6 2012-06-01    -0.1 
#>  7 2012-07-01     0.44
#>  8 2012-08-01     0.39
#>  9 2012-09-01     0.39
#> 10 2012-10-01     0.49
#> # ... with 105 more rows
```

Exemplos para os demais núcleos (consulte a documentação das funções
para detalhes):

``` r
# Núcleo IPCA-MA
ipca_ma <- ipca_core  %>%
  dplyr::filter(group == "Item") %>%
  nucleos::core_ma(., "pct_change", "weight", "date")

# Núcleo IPCA-MS
ipca_ms <- ipca_core  %>%
  dplyr::filter(group == "Item") %>%
  nucleos::core_ms(., "pct_change", "weight", "code", "date")

# Núcleo IPCA-DP
ipca_dp <- ipca_core  %>%
  nucleos::core_dp(., "pct_change", "weight", "code", "group", "date")
```
