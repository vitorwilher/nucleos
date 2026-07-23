# Coleta as series do IPCA no SIDRA/IBGE

Baixa variacao mensal e peso mensal de todos os componentes do IPCA –
indice geral, grupos, subgrupos, itens e subitens – para o periodo
pedido, costurando automaticamente as cinco estruturas do indice
vigentes desde janeiro de 1991 (Tabela 1 da Nota Tecnica 57 do BCB).

## Usage

``` r
get_ipca(inicio = "1991-01", fim = NULL, quiet = FALSE)
```

## Arguments

- inicio:

  Primeiro mes, no formato `"AAAA-MM"`. O padrao, `"1991-01"`, e o
  inicio das series consolidadas pela NT 57.

- fim:

  Ultimo mes, no formato `"AAAA-MM"`. Se `NULL` (padrao), coleta ate o
  ultimo mes disponivel.

- quiet:

  Logico. Se `FALSE` (padrao), informa o progresso da coleta.

## Value

Tibble com uma linha por componente e mes, com as colunas `date`, `pof`,
`codigo`, `nivel`, `rotulo`, `variacao` e `peso`.

## Details

Cada estrutura do IPCA e servida por uma tabela diferente do SIDRA,
listadas em
[ipca_estruturas](https://vitorwilher.github.io/nucleos/reference/ipca_estruturas.md).
Nas duas estruturas mais antigas, variacao e peso estao em tabelas
separadas; a partir de julho de 2006 convivem na mesma tabela. A funcao
trata as duas formas e devolve sempre o mesmo formato.

O codigo devolvido na coluna `codigo` e o codigo estrutural do IPCA – o
mesmo usado pela NT 57 e por
[ipca_vetores](https://vitorwilher.github.io/nucleos/reference/ipca_vetores.md)
– extraido do descritor do SIDRA. O indice geral recebe o codigo `"0"`.

## Reprodutibilidade do periodo pre-1996

As series calculadas a partir destes dados reproduzem exatamente as
series oficiais do BCB (ate a segunda casa decimal) a partir de 1996
para os nucleos de calculo direto e de agosto de 1999 para todas as
series. No periodo de alta inflacao e de transicao entre planos
monetarios (Collor, 1991; Real, 1994-1995), as variacoes publicadas na
API publica do SIDRA divergem das que o BCB utilizou – construidas a
partir de microdados do IBGE –, sobretudo para itens de precos
administrados. Nesses meses, mesmo as agregacoes simples nao sao
perfeitamente reproduziveis a partir dos dados publicos. O nucleo MS,
por suavizar justamente os itens administrados, permanece exato tambem
nesse periodo.

## See also

[ipca_estruturas](https://vitorwilher.github.io/nucleos/reference/ipca_estruturas.md),
[ipca_vetores](https://vitorwilher.github.io/nucleos/reference/ipca_vetores.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Estrutura vigente
ipca <- get_ipca(inicio = "2020-01")

# Serie completa consolidada pela NT 57 (coleta demorada)
ipca_completo <- get_ipca()
} # }
```
