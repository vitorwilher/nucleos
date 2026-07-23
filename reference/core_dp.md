# Nucleo de dupla ponderacao (DP)

Media ponderada das variacoes de precos dos itens do IPCA com pesos
ajustados que reduzem a influencia dos itens mais volateis (Subsecao 2.2
da Nota Tecnica 57 do BCB). O ajuste combina dois ponderadores: o peso
original do item no indice e o inverso da volatilidade de suas
variacoes.

## Usage

``` r
core_dp(data, janela = 48L)
```

## Arguments

- data:

  Tibble devolvido por
  [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md),
  com historico suficiente.

- janela:

  Numero de meses da janela de volatilidade. O padrao, `48`, e o valor
  adotado pelo BCB; alterar afasta o resultado da serie oficial.

## Value

Tibble com as colunas `date` e `variacao`.

## Details

O calculo tem tres etapas. Primeiro, para cada item, calcula-se o desvio
padrao da serie de diferencas entre sua variacao mensal e a do IPCA
cheio. Em seguida o peso original e dividido por esse desvio padrao. Por
fim os pesos ajustados sao normalizados e aplicados as variacoes do mes.

A janela de volatilidade cobre os **48 meses anteriores** ao mes de
referencia, sem inclui-lo: como diz a nota, o nucleo de um dado mes
depende das variacoes "do proprio mes e dos 48 meses anteriores" – a
variacao corrente entra no nucleo, e os 48 meses previos estimam a
volatilidade.

O desvio padrao usa o estimador nao viesado, com denominador 47 – e o
que a funcao [`stats::sd()`](https://rdrr.io/r/stats/sd.html) ja faz
para uma janela de 48 observacoes.

O nucleo so pode ser calculado a partir do quadragesimo nono mes
presente em `data`. Para obter o DP de um mes especifico, colete pelo
menos 48 meses de historico adicional.

Nos primeiros 48 meses de vigencia de uma estrutura, a janela de
volatilidade alcanca a estrutura anterior. Itens sem correspondencia
direta usam as proxies de
[ipca_proxies](https://vitorwilher.github.io/nucleos/reference/ipca_proxies.md);
o calculo e feito estrutura a estrutura para nao misturar historicos de
codigos que mudaram de significado.

## See also

[`core_ma()`](https://vitorwilher.github.io/nucleos/reference/core_ma.md),
[`core_ms()`](https://vitorwilher.github.io/nucleos/reference/core_ms.md),
[ipca_proxies](https://vitorwilher.github.io/nucleos/reference/ipca_proxies.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Para o DP de 2024 em diante, colete a partir de 2020
ipca <- get_ipca(inicio = "2020-01")
core_dp(ipca)
} # }
```
