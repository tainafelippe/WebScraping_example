############################# DISCURSOS MIN ERNESTO ARAÚJO, SITE OFICIAL MRE #############################

# Pacotes necessários para rodar ese script
install.packages("rvest")
install.packages("tidyverse")
library(rvest)
library(tidyverse)

# Definindo o nome do data frame que receberá os dados 
df_araujo <- data.frame()

# Criando a função que vai puxar os discursos dos links
get_discs <- function(links) {
  pag <- read_html(links)
  disc <- pag %>% html_nodes("#parent-fieldname-text div") %>% 
    html_text()
}

# Criando o loop que permitirá obter informação de todas as páginas de resultados 
# Nesse caso, haviam 3 páginas com discursos do Min. Ernesto Araújo. Cada página 
# tinha 20 resultados. É preciso identificar qual o padrão desse link, o que muda 
# entre um link e outro de cada página. Nesse caso era o final, com o numero 0 
# para pagina 1, 20 para página 2 e 40 para página 3, dai as informacoes do meu 
# loop abaixo. 

for (i in seq(from = 0, to = 40, by = 20)) {
  # link que será usado para fazer o scrape, lembre-se de mudar para i o que muda entre os links. 
   urlloop <- paste0("https://www.gov.br/mre/pt-br/centrais-de-conteudo/publicacoes/discursos-artigos-e-entrevistas/ministro-das-relacoes-exteriores/discursos-mre/ernesto-araujo?b_start:int=", i)
  webpageloop <- read_html(urlloop)
  
  # O código abaixo funciona juntamente a ferramenta selector gadget, permitindo a 
  # obtenção das datas dos discursos, e dos links de cada discurso. 
  # O selector gadget lhe informará as informações entre "" no código abaixo para obtenção 
  # dos dados que você deseja obter (scrape).
  
  data <- html_nodes(webpageloop, ".hiddenStructure+ .summary-view-icon") %>% html_text() 
  link <- html_nodes(webpageloop, ".url") %>% html_attr("href") 

  # Mais informacoes sobre como usar o Selector Gadget no vídeo: 
  # https://www.youtube.com/watch?v=v8Yh_4oE-Fs&t=0s&ab_channel=Dataslice 
  
  # O objeto link acima contém todos os links de todos os discursos.
  #Com ele podemos puxar os discursos de cada link usando a função get_discs anteriormente criada. 
  
  discurso <- sapply(link, FUN = get_discs, USE.NAMES = FALSE)
  
  # Juntando as informacoes em um só data frame
  df <- data.frame(data, link, discurso)
    df_araujo <- bind_rows(df_araujo, df)  
    
  Sys.sleep(5) #Esse codigo permite que seja feita uma pausa entre os loops para não sobrecarregar o servidor
}

# Limpando a coluna data, pois ela veio com espacoes e caracterres indesejados 

View(df_araujo)

df_araujo$data <- str_extract(df_araujo$data , "\\d{2}/\\d{2}/\\d{4}")  # Extrair a data no formato DD/MM/AAAA 
df_araujo$data <- str_trim(df_araujo$data )  # Remoçao de espacos em branco indesejados

#### Abaixo algumas alterações e ajustes feitos para atender as minhas necessidades
# específicas, como excluir colunas que não preciso e inserir colunas que 
# irei utilizar. 

# A coluna links foi necessária somente para obter os discursos, não sendo mais necessária para 
# as proximas etapas da minha análise, portanto abaixo ela é deletada. 

df_araujo <- df_araujo[, -which(names(df_araujo) == "link")] 

# Inserindo as colunas faltantes desse data frame, para ficar igual ao data frame mãe 
# da minha pesquisa:    

df_araujo$id <- 2
df_araujo$nome <- "Ernesto Araújo"
df_araujo$partido <- NA
df_araujo$origem <- "mre"
df_araujo$fpa <- 0
df_araujo$instituicao <- "mre"
df_araujo$selecionado <- 0
df_araujo$posicao <- ""
df_araujo$tema <- ""

# Ajustando a ordem das colunas para que fique igual ao da minha base de dados mãe

ordemdf <- c("id", "nome", "partido", "data", "discurso", "origem", "fpa", "instituicao", "selecionado", "posicao", "tema")

df_araujo <- df_araujo[, ordemdf]

# Salvando a sua base em CSV

write.csv(df_araujo, file = "df_araujo.csv", row.names = FALSE)

# Salvando a sua base em Excel 

write_xlsx(df_araujo, path = "df_araujo.xlsx")

# Ajuste a sua base as suas necessidades e boas análises :)