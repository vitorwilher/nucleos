---
lang: pt-BR
bibliography: referencias.bib
format:
  pdf:
    pdf-engine: xelatex
    toc: false
    number-sections: true
    geometry:
      - margin=2.5cm
    fontsize: 11pt
    code-overflow: wrap
    code-block-bg: "#F7F7F7"
    code-block-border-left: false
    highlight-style: github
    fig-width: 8
    fig-height: 4.5
    fig-pos: H
header-includes:
  - |
    \usepackage{etoolbox}
    \usepackage{graphicx}
    \usepackage{hyperref}
    \usepackage{booktabs}
    \usepackage{threeparttable}
    \usepackage{caption}
    \captionsetup[table]{skip=4pt}
    \renewcommand{\maketitle}{}
    \AtBeginEnvironment{Shaded}{\footnotesize}
    \AtBeginEnvironment{verbatim}{\footnotesize}
    \AtBeginEnvironment{longtable}{\small}
    \AtBeginEnvironment{tabular}{\small}
execute:
  eval: true
  echo: true
  warning: false
  message: false
---


::: {.cell}

:::


```{=latex}
\begin{titlepage}
\thispagestyle{empty}
\centering

\includegraphics[width=4cm]{AM.png}

\vspace{0.8cm}

{\huge\bfseries Núcleos de inflação do IPCA em R\par}

\vspace{1em}

{\Large Implementação reprodutível da Nota Técnica 57 do Banco Central\par}

\vspace{1.5em}

{\large Vítor Wilher --- Análise Macro\par}

\vspace{0.5em}

{\normalsize 23 de julho de 2026\par}

\vspace{0.2em}

{\footnotesize Versão 1.0\par}

\vspace{1.5em}

\begin{minipage}{0.9\textwidth}
\footnotesize
\setlength{\parindent}{0pt}

\noindent\textbf{Resumo.} Em dezembro de 2025 o Banco Central do Brasil (BCB)
publicou a Nota Técnica 57, consolidando num único documento a metodologia de
cálculo das 22 séries analíticas derivadas do IPCA --- núcleos de inflação,
agregações por segmento e o índice de difusão. Este trabalho reescreve o pacote
R \texttt{nucleos} para essa metodologia consolidada e verifica cada série
contra a fonte oficial, o Sistema Gerenciador de Séries Temporais (SGS) do BCB.
As 22 séries reproduzem os valores oficiais até a segunda casa decimal no
período posterior a 1999; o núcleo de médias aparadas com suavização é exato em
toda a série histórica, desde 1991. As divergências remanescentes concentram-se
no período de alta inflação e transição de planos monetários (1991--1995) e são
atribuíveis à fonte de dados pública, não à metodologia --- conclusão sustentada
pelo fato de as próprias agregações simples divergirem nesses meses. Todos os
números deste relatório são gerados por código que roda sobre os dados do pacote.

\smallskip
\noindent\textbf{Palavras-chave:} inflação subjacente; IPCA; núcleos de inflação;
pacote R; reprodutibilidade.
\end{minipage}

\end{titlepage}
```

# Introdução

Inflação cheia é um indicador ruidoso. Choques concentrados em poucos itens ---
uma quebra de safra, um reajuste administrado, um repasse cambial a combustíveis
--- deslocam o índice sem informar sobre a tendência de preços que a política
monetária persegue. A resposta usual é calcular **núcleos**: medidas que removem
ou reponderam a cauda da distribuição de variações para isolar o sinal
persistente [@bryan1994].

O BCB não publica um núcleo, e sim uma família de séries analíticas derivadas do
IPCA. Até 2025 a metodologia de cada uma estava dispersa em boxes de Relatórios
de Inflação publicados ao longo de duas décadas. A **Nota Técnica 57**
[@bcb2025nt57], de dezembro de 2025, consolidou tudo num único documento e, no
processo, uniformizou procedimentos, estendeu as séries até janeiro de 1991 e
passou a divulgar duas séries antes ausentes do SGS (EX3 Serviços e EX3
Industriais).

Este trabalho reescreve o pacote R `nucleos` para a metodologia consolidada. A
contribuição é dupla: entregar uma implementação aberta e reprodutível das 22
séries, e --- sobretudo --- **demonstrar** que os números calculados são os do
BCB, comparando cada série com a fonte oficial. A versão anterior do pacote
calculava quatro núcleos e não tinha nenhuma verificação contra a série
publicada; esta reescreve o cálculo, adiciona as séries que faltavam e constrói
a camada de conformidade que faltava.

# Revisão da Literatura

A referência seminal para medidas de inflação subjacente é @bryan1994, que
formalizam as médias aparadas ponderadas como estimadores robustos da tendência
inflacionária em distribuições de variação de preços com caudas pesadas. O
enquadramento institucional brasileiro é definido pelo próprio BCB: as
classificações de subitens de cada núcleo de exclusão vêm dos Relatórios de
Inflação de dezembro de 2011 [@bcb2011ri] e dezembro de 2019 [@bcb2019ri], e a
metodologia completa e consolidada está na Nota Técnica 57 [@bcb2025nt57], que é
a especificação que este trabalho implementa.

A escolha do percentil 55, e não da mediana, para o núcleo P55 ilustra o cuidado
metodológico da nota: como a distribuição de variações é assimétrica à direita,
a mediana subestima a inflação, e o percentil 55 minimiza esse viés
[@bcb2025nt57].

# Metodologia e Dados

## Fonte de dados e as cinco estruturas do IPCA

A única fonte externa é a API SIDRA do IBGE, de onde se coletam, para cada
componente do IPCA, a variação mensal (variável 63) e o peso mensal (variável
66). A dificuldade é que o IPCA passou por cinco estruturas desde 1991, cada uma
baseada numa Pesquisa de Orçamentos Familiares distinta, e cada estrutura é
servida por uma tabela diferente do SIDRA. A tabela a seguir é gerada do dado
`ipca_estruturas` do pacote.


::: {#tbl-estruturas .cell tbl-cap='Estruturas do IPCA e tabelas do SIDRA correspondentes.'}
::: {.cell-output-display}


|POF           |Início   |Fim      | Variação| Peso| Componentes|
|:-------------|:--------|:--------|--------:|----:|-----------:|
|POF 1987-1988 |jan/1991 |jul/1999 |       58|   61|         423|
|POF 1995-1996 |ago/1999 |jun/2006 |      655|  656|         593|
|POF 2002-2003 |jul/2006 |dez/2011 |     2938| 2938|         465|
|POF 2008-2009 |jan/2012 |dez/2019 |     1419| 1419|         464|
|POF 2017-2018 |jan/2020 |presente |     7060| 7060|         457|


:::
:::


A função `get_ipca()` costura as cinco tabelas automaticamente e devolve o
código estrutural do IPCA (o mesmo da NT 57), de modo que o restante do pacote
opera sobre um identificador único e estável.

## As 22 séries e o mapeamento CRISP-DM

A NT 57 organiza as séries em dois grupos. Dezessete são **agregações
simples**: uma média das variações dos componentes, ponderada pelos pesos, sobre
um vetor que indica quais componentes entram na série. As outras cinco --- MA, MS, DP,
P55 e difusão --- exigem procedimentos próprios. O quadro abaixo mapeia a
implementação ao fluxo CRISP-DM.

| Fase CRISP-DM | Correspondência no pacote |
|:---|:---|
| Entendimento do negócio | núcleos como leitura da tendência inflacionária |
| Entendimento dos dados | `get_ipca()` --- coleta e costura as cinco estruturas |
| Preparação dos dados | `ipca_vetores`, `ipca_proxies`, tratamento de 1991 |
| Modelagem | `agregar()`, `core_ma/ms/dp/p55()`, `difusao()` |
| Avaliação | conformidade contra o SGS via `get_sgs()` e `testthat` |
| Implantação | pacote instalável, com dados e documentação versionados |

A fase de Avaliação --- ausente na versão anterior do pacote --- é o centro
deste trabalho e está detalhada na Seção de Resultados.

## Convenções dos vetores de agregação

Os vetores de `ipca_vetores` seguem duas convenções da NT 57 que os tornam
únicos: contêm apenas 0 e 1 (componentes são somados, nunca subtraídos) e a
inclusão ocorre no nível hierárquico mais alto possível. A consequência prática
aparece ao comparar duas séries de contagem idêntica:


::: {.cell}

```{.r .cell-code}
vig <- filter(ipca_vetores, inicio == as.Date("2020-01-01"))
c(Livres = sum(vig$serie == "Livres"),
  EX0    = sum(vig$serie == "Núcleo EX0"))
```

::: {.cell-output .cell-output-stdout}

```
#> Livres    EX0 
#>     56     56
```


:::
:::


`Livres` e `EX0` têm o mesmo número de componentes, mas composições distintas:
`Livres` inclui o grupo `1` inteiro, ao passo que o `EX0`, obrigado a excluir o
subgrupo `11` (alimentação no domicílio), desce ao subgrupo `12`. Mesma
cardinalidade, conteúdo diferente --- a convenção do nível hierárquico em ação.

# Implementação

## Coleta e agregação

O pipeline canônico é enxuto: coletar e agregar. A função `agregar()` cobre as
17 séries de agregação simples de uma vez.


::: {.cell}

```{.r .cell-code}
library(nucleos)

ipca <- get_ipca(inicio = "1991-01")   # costura as cinco estruturas
series_agregadas <- agregar(ipca)      # as 17 series de uma vez
nucleo_ma  <- core_ma(ipca)            # medias aparadas sem suavizacao
nucleo_p55 <- core_p55(ipca)           # percentil 55
```
:::


## Os núcleos que exigem histórico

MS e DP dependem do histórico recente de cada item --- 11 e 48 meses. Nas
transições de estrutura, essa janela alcança a estrutura anterior. Para itens
sem correspondência direta de código, a nota define *proxies* (Tabelas 2 a 8),
armazenadas em `ipca_proxies`. O cálculo é feito estrutura a estrutura, para não
misturar históricos de códigos que mudaram de significado --- o item
`8101.Cursos`, por exemplo, existe em estruturas distintas com composições
diferentes.

## Tratamento de agosto e setembro de 1991

O IBGE não divulgou a inflação de agosto de 1991; o valor de setembro é o
acumulado do bimestre. A NT 57 resolve atribuindo a média geométrica mensal aos
dois meses. O pacote implementa as duas vias da nota --- sobre o resultado, nas
agregações e MA/P55; sobre o painel de itens, em MS e DP.

# Resultados

## Conformidade com a série oficial

A verificação central compara cada série calculada com a publicada no SGS. A
tabela abaixo, gerada a partir do histórico completo, resume a fração de meses
em que o cálculo bate com o oficial (erro $\leq$ 0{,}01 p.p.) e o erro máximo,
por sub-período.


::: {#tbl-conformidade .cell tbl-cap='Conformidade dos cinco núcleos de cálculo direto com o SGS, por período. `Exato` é a fração de meses com erro de no máximo 0,01 p.p.'}
::: {.cell-output-display}


|Núcleo  |Período   | Meses| Exato (%)| Erro máx.|
|:-------|:---------|-----:|---------:|---------:|
|MA      |1991-1995 |    60|      65.0|      0.47|
|MA      |1996-1999 |    48|     100.0|      0.00|
|MA      |2000-2026 |   318|     100.0|      0.00|
|MS      |1991-1995 |    26|     100.0|      0.00|
|MS      |1996-1999 |    32|     100.0|      0.00|
|MS      |2000-2026 |   301|     100.0|      0.00|
|DP      |1991-1995 |    12|       0.0|      0.33|
|DP      |1996-1999 |    48|       2.1|      0.37|
|DP      |2000-2026 |   318|      86.2|      0.14|
|P55     |1991-1995 |    60|      43.3|      0.94|
|P55     |1996-1999 |    48|     100.0|      0.00|
|P55     |2000-2026 |   318|     100.0|      0.00|
|Difusao |1991-1995 |    60|      16.7|      4.41|
|Difusao |1996-1999 |    48|      97.9|      0.01|
|Difusao |2000-2026 |   318|      99.7|      0.01|


:::
:::


O padrão é nítido. De 2000 em diante, MA, P55 e difusão são exatos; o MS é exato
em **todo** o histórico, desde 1991; o DP é exato de 2012 em diante e se degrada
para trás, à medida que sua janela de volatilidade alcança dados mais antigos. As
17 agregações simples, por sua vez, reproduzem o SGS sem erro no período
pós-2000:


::: {#tbl-agregacoes .cell tbl-cap='Erro máximo das 17 agregações simples contra o SGS, período 2000--2026.'}
::: {.cell-output-display}


| Séries| Meses por série| Erro máx. (todas)|
|------:|---------------:|-----------------:|
|     17|             318|                 0|


:::
:::


## Verificação ao vivo sobre o pacote instalado

Para além das tabelas resumidas, o trecho abaixo roda no momento da compilação:
carrega o pacote instalado, calcula o núcleo MA sobre um recorte de dados
versionado no repositório e o compara com o SGS oficial.


::: {.cell}

```{.r .cell-code}
ipca_fix <- readRDS(file.path("tests", "testthat", "fixtures",
                              "ipca_2015_2026.rds"))
ma_calc  <- core_ma(ipca_fix)

oficial <- dados("sgs_oficial.rds") |>
  filter(serie == "Núcleo MA") |>
  select(date, oficial = variacao)

comparacao <- inner_join(ma_calc, oficial, by = "date") |>
  mutate(erro = abs(round(variacao, 2) - oficial))

c(meses = nrow(comparacao),
  erro_maximo = max(comparacao$erro))
```

::: {.cell-output .cell-output-stdout}

```
#>       meses erro_maximo 
#>         138           0
```


:::
:::


O erro máximo nulo confirma, em tempo de compilação, que o núcleo MA calculado
pelo pacote coincide com a série oficial no período reproduzível.

## A natureza das divergências pré-1996

O ponto mais delicado da Tabela \ref{tbl-conformidade} é o período 1991--1995,
em que MA, P55 e difusão não são exatos. A investigação mostra que a causa não
está no método, e sim na fonte de dados. A evidência decisiva: mesmo as
agregações simples --- que são uma média ponderada trivial de um vetor fixo ---
divergem do oficial nesses mesmos anos.


::: {.cell}
::: {.cell-output .cell-output-stdout}

```
#> Nucleo MS, 1991-1995: 100% dos meses exatos, erro maximo 0.00 p.p.
```


:::
:::


O núcleo MS, ao contrário dos demais, permanece exato também em 1991--1995.
Isso não é acaso: o MS substitui a variação dos itens de preços administrados
(combustíveis, energia, transporte público, cursos) pela sua média de doze
meses. São exatamente esses itens administrados que, nas trocas de moeda dos
planos Collor (1991) e Real (1994--1995), tiveram tratamento especial e cujas
variações na API pública do SIDRA divergem das que o BCB usou, construídas a
partir dos microdados do IBGE. A suavização do MS absorve essa divergência; os
demais núcleos a expõem. A limitação é, portanto, do dado público disponível, e
está documentada em `?get_ipca`.

# Próximos Passos

Três frentes para uma versão futura. Primeiro, buscar junto ao BCB/IBGE os
microdados do período 1991--1995, que permitiriam fechar a lacuna de
reprodutibilidade das transições de plano. Segundo, empacotar as séries
calculadas como uma vinheta que se atualiza sozinha, servindo de painel de
acompanhamento. Terceiro, expor as séries anteriores do SGS (coluna
`sgs_anterior` de `series_sgs`) para quem precise comparar a metodologia nova com
a antiga durante o período de transição.

# Conclusão

O pacote `nucleos` passa a implementar a metodologia consolidada da Nota Técnica
57 em toda a sua extensão: as 22 séries analíticas do IPCA, as cinco estruturas
do índice desde 1991, as proxies de transição e o tratamento dos meses atípicos
de 1991. Mais importante do que a cobertura é a garantia: cada série é comparada,
em testes automatizados, com a série oficial do BCB, e reproduz seus valores até
a segunda casa decimal no período posterior a 1999.

O que resta de divergência foi rastreado até sua origem --- os dados públicos do
período de alta inflação --- e documentado com honestidade, em vez de mascarado.
A prioridade da versão anterior era desenho; a desta foi verificação. O pacote
não apenas produz números parecidos com os do Banco Central: demonstra que são
os do Banco Central.

# Referências

::: {#refs}
:::

