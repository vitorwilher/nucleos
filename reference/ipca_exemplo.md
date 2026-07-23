# Recorte de exemplo do IPCA (2015-2026)

Saida de
[`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md)
para o periodo de janeiro de 2015 a junho de 2026 – toda a estrutura POF
2017-2018 e o fim da anterior. Serve ao tutorial do pacote e a
experimentacao sem depender da rede. O historico e suficiente para todos
os nucleos, inclusive o DP, que exige janela de 48 meses.

## Usage

``` r
ipca_exemplo
```

## Format

Tibble com uma linha por componente e mes:

- date:

  mes de referencia

- pof:

  POF de referencia da estrutura do IPCA

- codigo:

  codigo estrutural do componente no IPCA

- nivel:

  nivel hierarquico: Geral, Grupo, Subgrupo, Item ou Subitem

- rotulo:

  nome do componente

- variacao:

  variacao mensal de precos, em porcentagem

- peso:

  peso mensal no indice, em porcentagem

## Source

IPCA/SIDRA (IBGE), coletado via
[`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md).
