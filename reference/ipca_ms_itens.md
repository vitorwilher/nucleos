# Itens com variacao suavizada no nucleo MS

Codigos dos itens cuja variacao mensal e substituida pela variacao media
dos ultimos 12 meses no calculo do nucleo de medias aparadas com
suavizacao (Tabela 5 da NT 57).

## Usage

``` r
ipca_ms_itens
```

## Format

Tibble com 43 linhas e 2 colunas:

- pof:

  POF de referencia da estrutura do IPCA

- codigo:

  codigo estrutural do item suavizado

## Source

Tabela 5 da Nota Tecnica 57 do BCB (dezembro/2025).

## Details

Sao nove itens nas tres estruturas mais recentes. Nas duas primeiras sao
oito, porque o item `8104.Cursos diversos` ainda nao existia. Entre
janeiro de 1991 e julho de 1999, os itens `7301.Educacao` e
`5201.Comunicacoes` substituem `8101.Cursos regulares` e
`9101.Comunicacao`.
