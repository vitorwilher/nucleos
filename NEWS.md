# nucleos 0.1.0

Reescrita completa do pacote para a metodologia consolidada da **Nota Tecnica 57
do Banco Central do Brasil** (dezembro de 2025), que unificou o calculo dos
nucleos de inflacao e demais series analiticas derivadas do IPCA.

## Series (22 no total)

* **Novas:** nucleo Percentil 55 (`core_p55()`), indice de difusao (`difusao()`)
  e as agregacoes por segmento -- administrados, livres, servicos, bens
  industriais, comercializaveis, duraveis/semiduraveis/nao duraveis, alem de
  EX-FE, EX3 Servicos e EX3 Industriais -- todas via `agregar()`.
* **Reescritas:** `core_ma()`, `core_ms()`, `core_dp()` e as agregacoes por
  exclusao (EX0-EX3), agora cobrindo as cinco estruturas do IPCA desde janeiro
  de 1991.

## Mudancas de metodologia

* `core_ma()` passa a aparar as duas caudas simetricamente: os itens que
  atravessam os percentis 20 e 80 entram com peso parcial, conforme a etapa (iv)
  da Subsecao 2.3 da nota. A versao anterior descartava por inteiro o item do
  percentil 80.
* `core_ms()` e `core_dp()` aplicam as proxies de transicao entre estruturas
  ([ipca_proxies], Tabelas 2 a 8 da nota) e sao calculados estrutura a
  estrutura, para nao misturar historicos de codigos que mudaram de significado.
* Tratamento especifico dos meses de agosto e setembro de 1991, nao divulgados
  isoladamente pelo IBGE (Subsecao 2.7).

## Interface

* `get_ipca()` costura automaticamente as cinco tabelas do SIDRA e devolve o
  codigo estrutural do IPCA. Aceita `inicio`/`fim` no formato `"AAAA-MM"` e
  pagina as consultas para respeitar o limite da API.
* `get_sgs()` baixa as series oficiais do SGS para conferencia.
* Novos dados: `ipca_vetores`, `ipca_estruturas`, `ipca_ms_itens`,
  `ipca_proxies` e `series_sgs`.
* Removidos: `core_adhoc()` (agora caso particular de `agregar()`),
  `group_desc()` (o nivel hierarquico ja vem de `get_ipca()`) e os dados
  `ipca_classes_2012`/`ipca_classes_2020`.

## Validacao

* Suite de testes de conformidade compara cada serie com a oficial do SGS. As
  22 series reproduzem o BCB ate a segunda casa decimal no periodo pos-1999.
* **Limitacao conhecida:** no periodo de alta inflacao e transicao de planos
  monetarios (1991-1995), a API publica do SIDRA nao reproduz exatamente as
  variacoes usadas pelo BCB, construidas de microdados do IBGE. Ver a secao
  "Reprodutibilidade do periodo pre-1996" em `?get_ipca`.

## Dependencias

* `Imports` reduzido de 14 para 8 pacotes. Removidos `sidrar`, `tibbletime`,
  `timetk`, `RcppRoll`, `lubridate`, `magrittr`, `purrr` e `stringr`.
* Requer R >= 4.1 (uso do pipe nativo `|>`).
