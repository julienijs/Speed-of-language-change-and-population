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
Datasteden <- read.csv(file = "StedenBelgiëNederland19eEn20eEeuw.csv", 
                       header = TRUE)

hist(Datasteden$BAIy1850, 
     xlab='Populatiegrootte', 
     ylab='Aantal steden',
     main='Histogram van de steden per populatiegrootte')
hist(log(Datasteden$BAIy1850),
     xlab='Populatiegrootte op de logaritmische schaal', 
     ylab='Aantal steden',
     main='Histogram van de steden per populatiegrootte (loggetransformeerd)')

Verandering <- read_xlsx("The hortative alternation.xlsx", 
                         col_names = TRUE)

# add population counts:
Merged <- left_join(Verandering, Datasteden, by = c("BIRTHPLACE" = "CITY"))

# throw away rows without birthplace:
Merged <- Merged %>% drop_na(BAIy1850) 
Merged$Change <- as.factor(Merged$Change) 
Merged <- droplevels(Merged[!Merged$Change=="NA",])

# add log transformed population counts to the data set:
symbox(Merged$BAIy1850)
Merged$logBAIy1850=log(Merged$BAIy1850)

#### glm model change vs year and population count ####
Model <- glm(Change ~ year + logBAIy1850, 
              data=Merged, family = binomial(link="logit"))
print(summary(Model))

plot(allEffects(Model))
  
Merged$Change2 <- as.numeric(Merged$Change)-1 # rescale to numeric for ggplot

# data visualisation:
print(ggplot(data = Merged, aes(x = year, y = Change2)) +
        geom_smooth(method = "glm", 
                    method.args = list(family = binomial), 
                    colour = "black")+
        labs(x="Jaar", y="laat ons vs laten we", title="De hortatiefalternantie") +
        scale_x_continuous(limits = c(1850, 1990), 
                           breaks = seq(1850, 1990, by = 10)) +
        scale_y_continuous(limits = c(0,1), 
                            n.breaks = 10)+
        theme_bw())
  
print(ggplot(data = Merged, aes(x = logBAIy1850, y = Change2)) +
        geom_smooth(method = "glm", 
                    method.args = list(family = binomial), 
                    colour = "black")+
        scale_y_continuous(limits = c(0,1), 
                            n.breaks = 10)+
        labs(x="Population", y="") +
        theme_bw())


#### Analysis per bin of cities: 3 bins ####

# create bins:
Merged <- Merged %>% mutate(BAIy1850_bin_3 = cut_interval(Merged$BAIy1850, 
                                                          n = 3)) # make bins of the population counts
Merged <- Merged %>% mutate(logBAIy1850_bin_3 = cut_interval(Merged$logBAIy1850, 
                                                             n = 3))

# histograms
hist(Merged$BAIy1850)
hist(Merged$logBAIy1850)

# calculate slopes per bin of cities:

my_lm <- function(df) {
  m <-(glm(Change ~ year, data = df, family = binomial(logit)))
  print(summary(m))
  summary_m <- summary(m)
  slopes <- summary_m$coefficients[2, 1]
  std_errors <- summary_m$coefficients[2, 2]
  slopes_df <- expand.grid(slopes, std_errors)
  df$Change2 <- as.numeric(df$Change)-1 # rescale to numeric for ggplot
  print(ggplot(data = df, aes(x = year, y = Change2)) +
          geom_smooth(method = "glm", 
                      method.args = list(family = binomial), 
                      colour = "black")+
          labs(x="Jaar", y="", title="De hortatiefalternantie") +
          scale_x_continuous(limits = c(1850, 1990), 
                             breaks = seq(1850, 1990, by = 10)) +
          scale_y_continuous(limits = c(0,1), 
                             n.breaks = 10)+
          theme_bw())
  return(slopes_df)
}
slopes_bin3 <- by(Merged, Merged$logBAIy1850_bin_3, my_lm)

df_bin3 <- do.call(rbind, slopes_bin3)

# plotting:

ymin <- df_bin3$Var1-(1.95*df_bin3$Var2)
ymax <- (1.95*df_bin3$Var2)+df_bin3$Var1

p <- ggplot(df_bin3, aes(c("[0.693,2.27]", "[2.27,3.84]", "[3.84,5.42]"), Var1, 
            ymin = Var1-(1.95*Var2), ymax = (1.95*Var2)+Var1))+
  geom_point()+
  geom_errorbar()+
  labs(x="Groepering per populatiegrootte van de steden", 
       y="Richtingscoëfficiënten", 
       title="De hortatiefalternantie")
p
