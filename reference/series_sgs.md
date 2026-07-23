# Codigos das series analiticas do IPCA no SGS

Codigos das 22 series consolidadas pela Nota Tecnica 57 no Sistema
Gerenciador de Series Temporais do Banco Central, com a funcao do pacote
que reproduz cada uma. Usado pela suite de testes de conformidade.

## Usage

``` r
series_sgs
```

## Format

Tibble com 22 linhas e 5 colunas:

- serie:

  nome da serie

- sgs:

  codigo da serie nova no SGS

- sgs_anterior:

  codigo da serie anterior; `NA` quando nao existe

- funcao:

  funcao do pacote que reproduz a serie

- inicio:

  primeiro mes da serie nova

## Source

Tabelas 9 e 11 da Nota Tecnica 57 do BCB (dezembro/2025).

## Details

As series novas mantiveram os codigos que ja estavam em vigor. As
anteriores continuam no SGS sob os codigos de `sgs_anterior`, mas
deixaram de ser atualizadas. Alimentacao no domicilio, MA, P55 e difusao
nao mudaram alem da extensao do historico e por isso nao ganharam codigo
para a versao anterior.
