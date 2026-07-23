# Package index

## Coleta de dados

Baixar o IPCA do SIDRA e as séries oficiais do SGS.

- [`get_ipca()`](https://vitorwilher.github.io/nucleos/reference/get_ipca.md)
  : Coleta as series do IPCA no SIDRA/IBGE
- [`get_sgs()`](https://vitorwilher.github.io/nucleos/reference/get_sgs.md)
  : Coleta uma serie analitica do IPCA no SGS do Banco Central

## Agregações e núcleos de exclusão

Séries obtidas por agregação simples de componentes do IPCA.

- [`agregar()`](https://vitorwilher.github.io/nucleos/reference/agregar.md)
  : Calcula as series obtidas por agregacao simples do IPCA

## Núcleos de cálculo direto

Médias aparadas, dupla ponderação, percentil 55 e difusão.

- [`core_ma()`](https://vitorwilher.github.io/nucleos/reference/core_ma.md)
  : Nucleo de medias aparadas sem suavizacao (MA)
- [`core_ms()`](https://vitorwilher.github.io/nucleos/reference/core_ms.md)
  : Nucleo de medias aparadas com suavizacao (MS)
- [`core_dp()`](https://vitorwilher.github.io/nucleos/reference/core_dp.md)
  : Nucleo de dupla ponderacao (DP)
- [`core_p55()`](https://vitorwilher.github.io/nucleos/reference/core_p55.md)
  : Nucleo percentil 55 (P55)
- [`difusao()`](https://vitorwilher.github.io/nucleos/reference/difusao.md)
  : Indice de difusao do IPCA

## Dados

Vetores de agregação, estruturas, proxies e recorte de exemplo.

- [`ipca_exemplo`](https://vitorwilher.github.io/nucleos/reference/ipca_exemplo.md)
  : Recorte de exemplo do IPCA (2015-2026)
- [`ipca_vetores`](https://vitorwilher.github.io/nucleos/reference/ipca_vetores.md)
  : Vetores de agregacao das series analiticas do IPCA
- [`ipca_estruturas`](https://vitorwilher.github.io/nucleos/reference/ipca_estruturas.md)
  : Estruturas do IPCA e tabelas correspondentes no SIDRA
- [`ipca_ms_itens`](https://vitorwilher.github.io/nucleos/reference/ipca_ms_itens.md)
  : Itens com variacao suavizada no nucleo MS
- [`ipca_proxies`](https://vitorwilher.github.io/nucleos/reference/ipca_proxies.md)
  : Proxies de compatibilizacao entre estruturas do IPCA
- [`series_sgs`](https://vitorwilher.github.io/nucleos/reference/series_sgs.md)
  : Codigos das series analiticas do IPCA no SGS
