#' Vetores de agregacao das series analiticas do IPCA
#'
#' Composicao das 17 series obtidas por agregacao simples de componentes do
#' IPCA, conforme a Secao 2.1.2 da Nota Tecnica 57 do Banco Central do Brasil.
#' Cada linha indica que um componente integra uma serie em um subperiodo.
#'
#' Os vetores seguem duas convencoes que os definem de forma unica: contem
#' apenas 0s e 1s (componentes sao somados, nunca subtraidos) e a inclusao
#' ocorre sempre no nivel hierarquico mais alto possivel. Assim, por exemplo,
#' a serie `Livres` inclui o grupo `1` inteiro, enquanto o `Nucleo EX0`, que
#' precisa excluir o subgrupo `11`, desce para o subgrupo `12`.
#'
#' @format Tibble com 3.832 linhas e 7 colunas:
#' \describe{
#'   \item{pof}{POF de referencia da estrutura do IPCA}
#'   \item{inicio}{primeiro mes de vigencia do vetor}
#'   \item{fim}{ultimo mes de vigencia; `NA` na estrutura vigente}
#'   \item{serie}{nome da serie analitica}
#'   \item{codigo}{codigo estrutural do componente no IPCA}
#'   \item{nivel}{nivel hierarquico: Geral, Grupo, Subgrupo, Item ou Subitem}
#'   \item{rotulo}{nome do componente}
#' }
#' @source Vetores_NT_57.xlsx, anexo da Nota Tecnica 57 do BCB (dezembro/2025).
#'   \url{https://www.bcb.gov.br/publicacoes/notastecnicas/NT_57_202512}
"ipca_vetores"

#' Estruturas do IPCA e tabelas correspondentes no SIDRA
#'
#' As cinco estruturas do IPCA vigentes desde janeiro de 1991, cada uma
#' definida por uma Pesquisa de Orcamentos Familiares (POF), com as tabelas do
#' SIDRA/IBGE que servem os dados de cada periodo (Tabela 1 da NT 57).
#'
#' Nas duas estruturas mais antigas, variacao mensal e peso mensal estao em
#' tabelas separadas do SIDRA; a partir de julho de 2006 as duas variaveis
#' convivem na mesma tabela.
#'
#' @format Tibble com 5 linhas e 5 colunas:
#' \describe{
#'   \item{pof}{POF de referencia}
#'   \item{inicio}{primeiro mes de vigencia}
#'   \item{fim}{ultimo mes de vigencia; `NA` na estrutura vigente}
#'   \item{tabela_variacao}{tabela do SIDRA com a variacao mensal (variavel 63)}
#'   \item{tabela_peso}{tabela do SIDRA com o peso mensal (variavel 66)}
#' }
#' @source Tabela 1 da Nota Tecnica 57 do BCB; identificacao das tabelas do
#'   SIDRA via API de metadados do IBGE.
"ipca_estruturas"

#' Itens com variacao suavizada no nucleo MS
#'
#' Codigos dos itens cuja variacao mensal e substituida pela variacao media
#' dos ultimos 12 meses no calculo do nucleo de medias aparadas com suavizacao
#' (Tabela 5 da NT 57).
#'
#' Sao nove itens nas tres estruturas mais recentes. Nas duas primeiras sao
#' oito, porque o item `8104.Cursos diversos` ainda nao existia. Entre
#' janeiro de 1991 e julho de 1999, os itens `7301.Educacao` e
#' `5201.Comunicacoes` substituem `8101.Cursos regulares` e `9101.Comunicacao`.
#'
#' @format Tibble com 43 linhas e 2 colunas:
#' \describe{
#'   \item{pof}{POF de referencia da estrutura do IPCA}
#'   \item{codigo}{codigo estrutural do item suavizado}
#' }
#' @source Tabela 5 da Nota Tecnica 57 do BCB (dezembro/2025).
"ipca_ms_itens"

#' Proxies de compatibilizacao entre estruturas do IPCA
#'
#' Os nucleos MS e DP dependem do historico recente de variacoes de precos --
#' 11 e 48 meses, respectivamente. Na transicao entre estruturas do IPCA, itens
#' sem correspondencia direta na estrutura anterior precisam de uma serie proxy,
#' definida como media ponderada de componentes da estrutura antiga com os
#' sinais indicados (Tabelas 2 a 4 para o DP e 6 a 8 para o MS).
#'
#' As proxies sao usadas exclusivamente nos meses iniciais de vigencia de cada
#' estrutura: os primeiros 48 meses no DP e os primeiros 11 no MS. A transicao
#' de julho/2006-dezembro/2011 para janeiro/2012-dezembro/2019 nao exigiu
#' compatibilizacao e por isso nao aparece aqui.
#'
#' @format Tibble com 50 linhas e 6 colunas:
#' \describe{
#'   \item{nucleo}{nucleo ao qual a proxy se aplica: `"DP"` ou `"MS"`}
#'   \item{pof_destino}{estrutura de destino, cujos meses iniciais usam a proxy}
#'   \item{item}{codigo do item na estrutura de destino}
#'   \item{rotulo}{nome do item na estrutura de destino}
#'   \item{sinal}{`+1` se o componente soma na proxy, `-1` se subtrai}
#'   \item{componente}{codigo do componente na estrutura anterior}
#' }
#' @source Tabelas 2 a 4 e 6 a 8 da Nota Tecnica 57 do BCB (dezembro/2025).
"ipca_proxies"

#' Codigos das series analiticas do IPCA no SGS
#'
#' Codigos das 22 series consolidadas pela Nota Tecnica 57 no Sistema
#' Gerenciador de Series Temporais do Banco Central, com a funcao do pacote que
#' reproduz cada uma. Usado pela suite de testes de conformidade.
#'
#' As series novas mantiveram os codigos que ja estavam em vigor. As anteriores
#' continuam no SGS sob os codigos de `sgs_anterior`, mas deixaram de ser
#' atualizadas. Alimentacao no domicilio, MA, P55 e difusao nao mudaram alem da
#' extensao do historico e por isso nao ganharam codigo para a versao anterior.
#'
#' @format Tibble com 22 linhas e 5 colunas:
#' \describe{
#'   \item{serie}{nome da serie}
#'   \item{sgs}{codigo da serie nova no SGS}
#'   \item{sgs_anterior}{codigo da serie anterior; `NA` quando nao existe}
#'   \item{funcao}{funcao do pacote que reproduz a serie}
#'   \item{inicio}{primeiro mes da serie nova}
#' }
#' @source Tabelas 9 e 11 da Nota Tecnica 57 do BCB (dezembro/2025).
"series_sgs"
