

# Global file for the Tiny House Shiny Project
library(shiny, warn.conflicts = FALSE)
library(shinydashboard, warn.conflicts = FALSE)
library(shinycssloaders, warn.conflicts = FALSE)
library(shinyWidgets, warn.conflicts = FALSE)
library(dplyr, warn.conflicts = FALSE)
library(tidyr, warn.conflicts = FALSE)
library(tidyverse, warn.conflicts = FALSE)
library(tidytext, warn.conflicts = FALSE)
library(networkD3, warn.conflicts = FALSE)
library(tm, warn.conflicts = FALSE)
library(devtools, warn.conflicts = FALSE)
suppressPackageStartupMessages(library(googleVis, warn.conflicts = FALSE))
library(ggplot2, warn.conflicts = FALSE)
library(plotly, warn.conflicts = FALSE)
library(wordcloud, warn.conflicts = FALSE)

#### LOAD AND CHANGE COLUMN NAMES ####

#dataframe with all raw data
tiny_data = readxl::read_xlsx("./tiny_data.xlsx",col_names = TRUE)
#lowercase and get rid of spaces in column names
names(tiny_data) <- tolower(names(tiny_data))
colnames(tiny_data) = make.names(colnames(tiny_data))
tiny_data = tiny_data[!(is.na(tiny_data$participant.code)),]



####FOR OVERALL CHANGE STATS ####

ef_deltas = tiny_data %>%
  select(16:17, 139:153) %>%
  mutate(.,
         food = as.numeric(food...148) - as.numeric(food...141),
         shelter = as.numeric(shelter...149) - as.numeric(shelter...142),
         transportation = as.numeric(transportation...150) - as.numeric(transportation...143),
         goods = as.numeric(goods...151) - as.numeric(goods...144),
         services = as.numeric(services...152) - as.numeric(services...145)
  )

#by state
ef_by_state = ef_deltas %>%
  group_by(., current.state) %>%
  summarise(
    food_delta_mean = -mean(food),
    shelter_delta_mean = -mean(shelter),
    transportation_delta_mean = -mean(transportation),
    goods_delta_mean = -mean(goods),
    services_delta_mean = -mean(services),
    footprint_delta_mean = round(mean(as.numeric(footprint.delta)), 2),
    cnt_participants = n()
  )




#### FOR DEMOGRAPHICS ####

demo_columns = tiny_data %>%  select(6:25) 

demo_box_1 = demo_columns %>%
  mutate(
    "Age" = as.factor(age),
    "Ethnicity" = as.factor(ethnicity),
    "Employment" = as.factor(employment.status),
    "Income" = as.factor(personal.total.income)
  )


demo_box_2 = demo_box_1 %>% select(21:24)

#### MAPS DEMO LOCATION ####

#Current States
cstate = demo_box_1 %>%
  select(current.state) %>%
  group_by(current.state) %>%
  summarise(., count = n())


#Previous states
pstate = demo_box_1 %>%
  select(previous.state) %>%
  group_by(previous.state) %>%
  summarise(.,count = n())


#### JOBS ####

###Previous Jobs
set.seed(1234)

#replace N/A's
demo_box_1$previous.job.title.field..generalized. = str_replace_all(demo_box_1$previous.job.title.field..generalized., 'N/A', demo_box_1$employment.status)
#create corpus
job_corpus_previous <- Corpus(VectorSource(demo_box_1$previous.job.title.field..generalized.))
#replace special characters
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
job_corpus_previous <- tm_map(job_corpus_previous, toSpace, "[^a-zA-Z0-9 ]")
job_corpus_previous <- tm_map(job_corpus_previous, content_transformer(tolower))
job_corpus_previous <- tm_map(job_corpus_previous, removeWords, stopwords("english"))
job_corpus_previous <- tm_map(job_corpus_previous, stripWhitespace)
#job_corpus_previous <- tm_map(job_corpus_previous, stemDocument)
jcp_dtm <- TermDocumentMatrix(job_corpus_previous)
jcp_m <- as.matrix(jcp_dtm)
jcp_v <- sort(rowSums(jcp_m),decreasing=TRUE)
jcp_d <- data.frame(word = names(jcp_v), freq=jcp_v)




###Jobs after
demo_box_1$job.title.field..generalized. = str_replace_all(demo_box_1$job.title.field..generalized., 'N/A', demo_box_1$employment.status)
#create corpus
job_corpus_after <- Corpus(VectorSource(demo_box_1$job.title.field..generalized.))
#replace special characters
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
job_corpus_after <- tm_map(job_corpus_after, toSpace, "[^a-zA-Z0-9 ]")
job_corpus_after <- tm_map(job_corpus_after, content_transformer(tolower))
job_corpus_after <- tm_map(job_corpus_after, removeWords, stopwords("english"))
job_corpus_after <- tm_map(job_corpus_after, stripWhitespace)
#job_corpus_after <- tm_map(job_corpus_after, stemDocument)
jca_dtm <- TermDocumentMatrix(job_corpus_after)
jca_m <- as.matrix(jca_dtm)
jca_v <- sort(rowSums(jca_m),decreasing=TRUE)
jca_d <- data.frame(word = names(jca_v), freq=jca_v)



#### Why did they downsize? #### 
#create corpus
reason_corpus <- Corpus(VectorSource(demo_box_1$reasons.for.living.in.tiny.home..in.order.of.importance.))
#replace special characters
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x))
reason_corpus <- tm_map(reason_corpus, toSpace, "[^a-zA-Z0-9 ]")
reason_corpus <- tm_map(reason_corpus, content_transformer(tolower))
reason_corpus <- tm_map(reason_corpus, removeWords, stopwords("english"))
reason_corpus <- tm_map(reason_corpus, removeWords, c('home','house', 'wanted'))
reason_corpus <- tm_map(reason_corpus, stripWhitespace)
#reason_corpus <- tm_map(reason_corpus, stemDocument)
rc_dtm <- TermDocumentMatrix(reason_corpus)
rc_m <- as.matrix(rc_dtm)
rc_v <- sort(rowSums(rc_m),decreasing=TRUE)
rc_d <- data.frame(word = names(rc_v), freq=rc_v)




##### SANKEY DIAGRAM PREP ####

links_state = demo_box_1 %>%
  select(current.state, previous.state) %>%
  mutate(., current.state = paste(as.character(current.state), ' ')) %>%
  group_by(current.state, previous.state) %>%
  summarise(value = n())
nodes_state=data.frame(name=c(as.character(links_state$previous.state), as.character(links_state$current.state)) %>% unique())
links_state$IDsource=match(links_state$previous.state, nodes_state$name)-1 
links_state$IDtarget=match(links_state$current.state, nodes_state$name)-1


