# Nucleo de medias aparadas com suavizacao (MS)

Segue exatamente as mesmas cinco etapas do nucleo MA. A diferenca esta
nas variacoes usadas: para itens com reajustes infrequentes, a variacao
do mes e substituida pela variacao media dos ultimos doze meses
(Subsecao 2.4 da Nota Tecnica 57 do BCB).

## Usage

``` r
core_ms(data)
```

## Arguments

- data:

  Tibble devolvido por
  [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md),
  com historico suficiente.

## Value

Tibble com as colunas `date` e `variacao`.

## Details

Os itens suavizados em cada estrutura do IPCA estao em
[ipca_ms_itens](https://vitorwilher.github.io/nucleos/reference/ipca_ms_itens.md).
Sao nove na estrutura vigente – combustiveis, energia eletrica,
transporte publico, servicos pessoais, fumo, cursos e comunicacao.

Como a suavizacao olha doze meses para tras, o nucleo so pode ser
calculado a partir do decimo segundo mes presente em `data`. Para obter
o MS de um mes especifico, colete pelo menos onze meses de historico
adicional.

Nos primeiros onze meses de vigencia de uma estrutura, a janela de
suavizacao alcanca a estrutura anterior. Itens sem correspondencia
direta usam as proxies de
[ipca_proxies](https://vitorwilher.github.io/nucleos/reference/ipca_proxies.md);
o calculo e feito estrutura a estrutura para nao misturar historicos de
codigos que mudaram de significado.

## See also

[`core_ma()`](https://vitorwilher.github.io/nucleos/reference/core_ma.md),
[ipca_ms_itens](https://vitorwilher.github.io/nucleos/reference/ipca_ms_itens.md),
[ipca_proxies](https://vitorwilher.github.io/nucleos/reference/ipca_proxies.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Para o MS de 2024 em diante, colete a partir de 2023
ipca <- get_ipca(inicio = "2023-01")
core_ms(ipca)
} # }
```
