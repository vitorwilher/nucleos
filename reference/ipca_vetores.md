# Vetores de agregacao das series analiticas do IPCA

Composicao das 17 series obtidas por agregacao simples de componentes do
IPCA, conforme a Secao 2.1.2 da Nota Tecnica 57 do Banco Central do
Brasil. Cada linha indica que um componente integra uma serie em um
subperiodo.

## Usage

``` r
ipca_vetores
```

## Format

Tibble com 3.832 linhas e 7 colunas:

- pof:

  POF de referencia da estrutura do IPCA

- inicio:

  primeiro mes de vigencia do vetor

- fim:

  ultimo mes de vigencia; `NA` na estrutura vigente

- serie:

  nome da serie analitica

- codigo:

  codigo estrutural do componente no IPCA

- nivel:

  nivel hierarquico: Geral, Grupo, Subgrupo, Item ou Subitem

- rotulo:

  nome do componente

## Source

Vetores_NT_57.xlsx, anexo da Nota Tecnica 57 do BCB (dezembro/2025).
<https://www.bcb.gov.br/publicacoes/notastecnicas/NT_57_202512>

## Details

Os vetores seguem duas convencoes que os definem de forma unica: contem
apenas 0s e 1s (componentes sao somados, nunca subtraidos) e a inclusao
ocorre sempre no nivel hierarquico mais alto possivel. Assim, por
exemplo, a serie `Livres` inclui o grupo `1` inteiro, enquanto o
`Nucleo EX0`, que precisa excluir o subgrupo `11`, desce para o subgrupo
`12`.
