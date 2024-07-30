if (!require("terra")) install.packages("terra")
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("ggpmisc")) install.packages("ggpmisc")
if (!require("extrafont")) install.packages("extrafont")

# linear models for all  populations
aberti_pops <- read_csv("data-raw/tables/abertiFstSPA.csv")
aberti_pops <- aberti_pops %>%
  select(population_1, population_2, fst, SPA)


lmDf <- aberti_pops %>%
  group_by(population_1) %>%
  group_split() %>%
  purrr::map(function(x){
    lm(data = x, fst ~ SPA)
  }) %>% purrr::map_df(broom::glance) %>%
  bind_cols(distinct(aberti_pops, population_1)) %>%
  select(population_1, everything()) %>%
  mutate_if(is.numeric, function(x) round(x, 3)) %>%
  write_csv(., "data-raw/tables/linearModelsCorrelationsFstSPA.csv")




# plot for barberi population only
fst_plot <- aberti_pops %>%
  filter(population_1 == "S. a. barberi") %>%
  ggplot( aes(x = SPA, y = fst)) +
  ggpmisc::stat_poly_eq(use_label(c("eq")),
               label.x = "left", label.y = "bottom",  size = 8 ) +
  stat_poly_eq(use_label(c("R2")),
               label.x = "right", label.y = "bottom",  size = 8) +
  geom_point(aes(SPA, fst),
             size = 5,
             alpha = 0.7, col = "blue") +
  geom_smooth(aes(SPA, fst),
              method = "lm",
              alpha = 0.2, col = "#EB5838", linewidth = 3) +
  labs(x = "SPA", y = "Fst") +
  theme_classic()

# optional for plotting
# loadfonts(device = "win")
# fst_plot <- fst_plot +
#   theme(text = element_text(size = 20, family = "Arial"))

reso <- 1200
length <- 3.25*reso/72



png("fst_vs_SPA.png",res=144,height=960,width=960)
fst_plot
dev.off()

# filtering imposed zero Fst and Chuscensis population

aberti_pops %>%
  filter(grepl("barberi", population_1)) %>%
  filter(!grepl("chuscensis", population_2)) %>%
  filter(!population_1 == population_2) %>%
  lm(fst~SPA, data = .) %>%
  broom::glance()


fst_plot_bis <- aberti_pops %>%
  filter(grepl("barberi", population_1)) %>%
  filter(!grepl("chuscensis", population_2)) %>%
  filter(!population_1 == population_2) %>%
  ggplot( aes(x = SPA, y = fst)) +
  ggpmisc::stat_poly_eq(use_label(c("eq")),
                        label.x = "left", label.y = "bottom",  size = 8 ) +
  stat_poly_eq(use_label(c("R2")),
               label.x = "right", label.y = "bottom",  size = 8) +
  geom_point(aes(SPA, fst),
             size = 5,
             alpha = 0.7, col = "blue") +
  geom_smooth(aes(SPA, fst),
              method = "lm",
              alpha = 0.2, col = "#EB5838", linewidth = 3) +
  labs(x = "SPA", y = "Fst") +
  theme_classic()
