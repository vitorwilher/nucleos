# Proxies de compatibilizacao entre estruturas do IPCA

Os nucleos MS e DP dependem do historico recente de variacoes de precos
– 11 e 48 meses, respectivamente. Na transicao entre estruturas do IPCA,
itens sem correspondencia direta na estrutura anterior precisam de uma
serie proxy, definida como media ponderada de componentes da estrutura
antiga com os sinais indicados (Tabelas 2 a 4 para o DP e 6 a 8 para o
MS).

## Usage

``` r
ipca_proxies
```

## Format

Tibble com 50 linhas e 6 colunas:

- nucleo:

  nucleo ao qual a proxy se aplica: `"DP"` ou `"MS"`

- pof_destino:

  estrutura de destino, cujos meses iniciais usam a proxy

- item:

  codigo do item na estrutura de destino

- rotulo:

  nome do item na estrutura de destino

- sinal:

  `+1` se o componente soma na proxy, `-1` se subtrai

- componente:

  codigo do componente na estrutura anterior

## Source

Tabelas 2 a 4 e 6 a 8 da Nota Tecnica 57 do BCB (dezembro/2025).

## Details

As proxies sao usadas exclusivamente nos meses iniciais de vigencia de
cada estrutura: os primeiros 48 meses no DP e os primeiros 11 no MS. A
transicao de julho/2006-dezembro/2011 para janeiro/2012-dezembro/2019
nao exigiu compatibilizacao e por isso nao aparece aqui.
