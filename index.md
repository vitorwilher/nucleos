# nucleos

O `nucleos` calcula, de forma reprodutível, as **22 séries analíticas
derivadas do IPCA** publicadas pelo Banco Central do Brasil, seguindo a
metodologia consolidada na [Nota Técnica
57](https://www.bcb.gov.br/publicacoes/notastecnicas/NT_57_202512)
(dezembro de 2025): núcleos por exclusão (EX0–EX3), médias aparadas (MA
e MS), dupla ponderação (DP), percentil 55 (P55), índice de difusão e as
agregações por segmento (administrados, livres, serviços, industriais e
outras).

Cada série é verificada, em testes automatizados, contra a série oficial
do Sistema Gerenciador de Séries Temporais (SGS) do Banco Central,
reproduzindo até a segunda casa decimal no período posterior a 1999.

Faz parte dos **cursos da [Análise
Macro](https://analisemacro.com.br/)**.

## Instalação

``` r

if (!require("remotes")) install.packages("remotes")
remotes::install_github("vitorwilher/nucleos")
```

## Uso

``` r

library(nucleos)

# Coleta o IPCA do SIDRA/IBGE (costura as cinco estruturas desde 1991)
ipca <- get_ipca(inicio = "2015-01")

# As 17 agregações simples (EX0-EX3, EX-FE, segmentos) de uma vez
series <- agregar(ipca)

# Os núcleos de cálculo direto
ma  <- core_ma(ipca)    # médias aparadas sem suavização
ms  <- core_ms(ipca)    # médias aparadas com suavização
dp  <- core_dp(ipca)    # dupla ponderação
p55 <- core_p55(ipca)   # percentil 55
dif <- difusao(ipca)    # índice de difusão

# Conferência contra a série oficial do Banco Central (SGS)
oficial <- get_sgs(11426, inicio = "2015-01")   # núcleo MA oficial
```

O pacote inclui `ipca_exemplo`, um recorte de 2015–2026 para
experimentar sem depender da rede. Veja o tutorial em *Get started* para
uma introdução aos núcleos com gráficos.

## Séries e funções

| Função | Séries |
|:---|:---|
| [`agregar()`](https://vitorwilher.github.io/nucleos/reference/agregar.md) | EX0, EX1, EX2, EX3, EX-FE, EX3 Serviços/Industriais e agregações por segmento |
| [`core_ma()`](https://vitorwilher.github.io/nucleos/reference/core_ma.md), [`core_ms()`](https://vitorwilher.github.io/nucleos/reference/core_ms.md) | médias aparadas sem e com suavização |
| [`core_dp()`](https://vitorwilher.github.io/nucleos/reference/core_dp.md) | dupla ponderação |
| [`core_p55()`](https://vitorwilher.github.io/nucleos/reference/core_p55.md) | percentil 55 |
| [`difusao()`](https://vitorwilher.github.io/nucleos/reference/difusao.md) | índice de difusão |
| [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md), [`get_sgs()`](https://vitorwilher.github.io/nucleos/reference/get_sgs.md) | coleta do IPCA (SIDRA) e das séries oficiais (SGS) |

## Licença

Ver arquivo `LICENSE`.
