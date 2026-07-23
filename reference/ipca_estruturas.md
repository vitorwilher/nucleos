# Estruturas do IPCA e tabelas correspondentes no SIDRA

As cinco estruturas do IPCA vigentes desde janeiro de 1991, cada uma
definida por uma Pesquisa de Orcamentos Familiares (POF), com as tabelas
do SIDRA/IBGE que servem os dados de cada periodo (Tabela 1 da NT 57).

## Usage

``` r
ipca_estruturas
```

## Format

Tibble com 5 linhas e 5 colunas:

- pof:

  POF de referencia

- inicio:

  primeiro mes de vigencia

- fim:

  ultimo mes de vigencia; `NA` na estrutura vigente

- tabela_variacao:

  tabela do SIDRA com a variacao mensal (variavel 63)

- tabela_peso:

  tabela do SIDRA com o peso mensal (variavel 66)

## Source

Tabela 1 da Nota Tecnica 57 do BCB; identificacao das tabelas do SIDRA
via API de metadados do IBGE.

## Details

Nas duas estruturas mais antigas, variacao mensal e peso mensal estao em
tabelas separadas do SIDRA; a partir de julho de 2006 as duas variaveis
convivem na mesma tabela.
