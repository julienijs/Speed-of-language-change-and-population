library(dplyr)
library(readxl)
library(tidyverse)
library(effects)
library(ggplot2)
library(tools)
library(broom)
library(car)
library(stylo)

#### read the data ####

# read the dataset with the population sizes:
Datasteden <- read.csv(file = "StedenBelgiëNederland19eEn20eEeuw.csv", 
                       header = TRUE)

# create histogram of the amount of cities per population size in Datasteden:
hist(Datasteden$BAIy1850, 
     xlab='Populatiegrootte', 
     ylab='Aantal steden',
     main='Histogram van de steden per populatiegrootte')

# same frequencies but log-transformed:
hist(log(Datasteden$BAIy1850),
     xlab='Populatiegrootte op de logaritmische schaal', 
     ylab='Aantal steden',
     main='Histogram van de steden per populatiegrootte (loggetransformeerd)')

Hortatief <- read_xlsx("The hortative alternation.xlsx", 
                         col_names = TRUE)

# add population counts:
Hortatief <- left_join(Hortatief, Datasteden, by = c("BIRTHPLACE" = "CITY"))

# throw away rows without birthplace:
Hortatief <- Hortatief %>% drop_na(BAIy1850) 
Hortatief$Change <- as.factor(Hortatief$Change) 
Hortatief <- droplevels(Hortatief[!Hortatief$Change=="NA",])

# add log transformed population counts to the data set:
symbox(Hortatief$BAIy1850)
Hortatief$logBAIy1850=log(Hortatief$BAIy1850)

#### Analysis per bin of cities: 3 bins ####

Hortatief$Change2 <- as.numeric(Hortatief$Change)-1 # rescale to numeric for ggplot

# create bins:
Hortatief <- Hortatief %>% mutate(logBAIy1850_bin_3 = cut_interval(Hortatief$logBAIy1850, 
                                                             n = 3))
Model_bins <- glm(Change ~ year*logBAIy1850_bin_3, 
                  data=Hortatief, family = binomial(link="logit"))
print(summary(Model_bins))
plot(allEffects(Model_bins))

print(ggplot(data = Hortatief, aes(x = year, y = Change2, color=logBAIy1850_bin_3)) +
        geom_smooth(method = "glm", 
                    method.args = list(family = binomial))+
        labs(x="Jaar", y="laat ons vs laten we") +
        guides(col=guide_legend(title="Populatiegrootte")) +
        scale_color_discrete(labels = c("Klein", "Middelgroot", "Groot")) +
        scale_x_continuous(limits = c(1850, 1990), 
                           breaks = seq(1850, 1990, by = 10)) +
        scale_y_continuous(limits = c(0,1), 
                           n.breaks = 10)+
        theme_bw())
