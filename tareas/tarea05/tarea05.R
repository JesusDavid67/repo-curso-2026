#CORPUS----------------------------------------------------------
#El dataset junta artículos y reportes de la serie Mind the Gap de McKinsey, 
#que tratan principalmente sobre la brecha de género, la inclusión y el liderazgo 
#femenino en las empresas. Sí, los documentos son totalmente comparables. 
#Al ser todos publicados por la misma consultora, mantienen una extensión parecida, 
#la misma estructura y un tono corporativo bastante parejo, lo que hace que 
#la información sea homogénea y no meta ruido al momento de analizarlos.

#Lo más destacable es que maneja un vocabulario técnico muy específico del mundo 
#empresarial y de recursos humanos (con palabras clave como diversity, inclusion, 
#leadership, retention o gender gap). Además, como los textos vienen de una misma 
#línea editorial, el lenguaje es muy consistente y facilita mucho la etapa de 
#limpieza de datos en R. Por último, no son notas puramente descriptivas, sino que 
#combinan el diagnóstico de la brecha de género con propuestas estratégicas para 
#las organizaciones.

library(tidytext)
library(topicmodels)
library(ggraph)
library(igraph)

# Cargar el archivo CSV

df_mckinsey <- read_csv("tarea05/DATA-T9-mckinsey-mind-the-gap-articles-20251020 (1).csv")


# Creamos un identificador único por documento

df_clean <- df_mckinsey %>%
  mutate(doc_id = row_number())


# Tokenización inicial sin stop words

tokens <- df_clean %>%
  unnest_tokens(word, article_text) %>%
  anti_join(stop_words, by = "word") %>%
  filter(!str_detect(word, "^[0-9]+$"))

# Analisis de sentimientos
# Modelo Binario

sent_bing <- tokens %>%
  inner_join(get_sentiments("bing"), by = "word") %>%
  count(doc_id, title, sentiment) %>%
  pivot_wider(names_from = sentiment, values_from = n, values_fill = 0) %>%
  mutate(neto = positive - negative)

# Modelo con Graduaciones

sent_afinn <- tokens %>%
  inner_join(get_sentiments("afinn"), by = "word") %>%
  group_by(doc_id, title) %>%
  summarize(
    puntaje_promedio = mean(value),
    puntaje_total = sum(value),
    .groups = "drop"
  )

# Topicos
# Filtramos palabras

frecuencia_docs <- tokens %>%
  distinct(doc_id, word) %>%
  count(word, name = "n_docs") %>%
  mutate(porcentaje = n_docs / n_distinct(tokens$doc_id))
palabras_genericas <- frecuencia_docs %>%
  filter(porcentaje > 0.70) %>%
  pull(word)
tokens_topic <- tokens %>%
  filter(!word %in% palabras_genericas)
dtm <- tokens_topic %>%
  count(doc_id, word) %>%
  cast_dtm(doc_id, word, n)

# Topico para k=10

lda_10 <- LDA(dtm, k = 10, control = list(seed = 1234))
top_10 <- tidy(lda_10, matrix = "beta") %>%
  group_by(topic) %>%
  slice_max(beta, n = 8) %>%
  ungroup()

# Grafico para k=10

top_10 %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered() +
  labs(title = "Topic Modeling con k = 10 tópicos", x = "Beta", y = "Término") +
  theme_minimal()

# Topico para K=15

lda_15 <- LDA(dtm, k = 15, control = list(seed = 1234))
top_15 <- tidy(lda_15, matrix = "beta") %>%
  group_by(topic) %>%
  slice_max(beta, n = 8) %>%
  ungroup()

# Grafico para k=15

top_15 %>%
  mutate(term = reorder_within(term, beta, topic)) %>%
  ggplot(aes(beta, term, fill = factor(topic))) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~ topic, scales = "free") +
  scale_y_reordered() +
  labs(title = "Topic Modeling con k = 15 tópicos", x = "Beta", y = "Término") +
  theme_minimal()

# Avanzado bigrams
# Generación de bigramas y limpieza

bigramas <- df_clean %>%
  unnest_tokens(bigram, article_text, token = "ngrams", n = 2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(!word1 %in% stop_words$word, !word2 %in% stop_words$word) %>%
  filter(!is.na(word1), !is.na(word2))

# Red de bigramas más frecuentes

conteo_bigramas <- bigramas %>%
  count(word1, word2, sort = TRUE) %>%
  filter(n > 3) # Muestra solo relaciones repetidas más de 3 veces
graph_bigramas <- graph_from_data_frame(conteo_bigramas)
ggraph(graph_bigramas, layout = "fr") +
  geom_edge_link(aes(edge_alpha = n), show.legend = FALSE) +
  geom_node_point(color = "darkblue", size = 4) +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
  theme_void() +
  labs(title = "Red de Bigramas Frecuentes - McKinsey Mind the Gap")

# Bigramas con negaciones (ej: "not word", "no word")

negaciones <- c("not", "no", "never", "without")
bigramas_negados <- df_clean %>%
  unnest_tokens(bigram, article_text, token = "ngrams", n = 2) %>%
  separate(bigram, c("word1", "word2"), sep = " ") %>%
  filter(word1 %in% negaciones) %>%
  count(word1, word2, sort = TRUE)