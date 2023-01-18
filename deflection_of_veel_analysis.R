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

# read the data of the deflection of veel: 
Verandering <- read_xlsx("The deflection of veel.xlsx", 
                         col_names = TRUE)

# add population counts:
Merged <- left_join(Verandering, Datasteden, by = c("BIRTHPLACE" = "CITY"))

# throw away rows without birthplace:
Merged <- Merged %>% drop_na(BAIy1850) 
Merged$Change <- as.factor(Merged$Change) # recode variable Change to a factor
Merged <- droplevels(Merged[!Merged$Change=="NA",]) # drop NA values

# add log transformed population counts to the data set:
symbox(Merged$BAIy1850)
Merged$logBAIy1850=log(Merged$BAIy1850)

#### glm model change vs year and population count ####
Model <- glm(Change ~ year + logBAIy1850, 
              data=Merged, family = binomial(link="logit"))
print(summary(Model))

plot(allEffects(Model))
  
Merged$Change2 <- as.numeric(Merged$Change)-1 # rescale to numeric for ggplot

# data visualisation: the deflection of veel over time
print(ggplot(data = Merged, aes(x = year, y = Change2)) +
        geom_smooth(method = "glm", 
                    method.args = list(family = binomial), 
                    colour = "black")+
        labs(x="Jaar", y="vele vs veel", title="The deflection of veel") +
        scale_x_continuous(limits = c(1850, 1990), 
                           breaks = seq(1850, 1990, by = 10)) +
        scale_y_continuous(limits = c(0,1), 
                            n.breaks = 10)+
        theme_bw())

#### Analysis per bin of cities: 3 bins ####

# create 3 bins based on population counts:
# not log-transformed:
Merged <- Merged %>% mutate(BAIy1850_bin_3 = cut_interval(Merged$BAIy1850, 
                                                          n = 3)) 
# log-transformed:
Merged <- Merged %>% mutate(logBAIy1850_bin_3 = cut_interval(Merged$logBAIy1850, 
                                                             n = 3))

# histograms of the amount of cities per population size in the deflection of veel dataset:
hist(Merged$BAIy1850) # not log-transformed: huge gap in the distribution
hist(Merged$logBAIy1850) # log-transformed:  nicer distribution

# calculate slopes per bin of cities:

# function calculates slopes and standard errors and plots 
my_lm <- function(df) {
  m <-(glm(Change ~ year, data = df, family = binomial(logit))) # make logistic regression model
  print(summary(m)) # check model
  summary_m <- summary(m) # store the summary of the model
  slopes <- summary_m$coefficients[2, 1] # get the slope
  std_errors <- summary_m$coefficients[2, 2] # get the standard error
  slopes_df <- expand.grid(slopes, std_errors) # store slope and st error in dataframe
  df$Change2 <- as.numeric(df$Change)-1 # rescale to numeric for ggplot
  # make plot:
  print(ggplot(data = df, aes(x = year, y = Change2)) +
          geom_smooth(method = "glm", 
                      method.args = list(family = binomial), 
                      colour = "black")+
          labs(x="Jaar", y="", title="The deflection of veel") +
          scale_x_continuous(limits = c(1850, 1990), 
                             breaks = seq(1850, 1990, by = 10)) +
          scale_y_continuous(limits = c(0,1), 
                             n.breaks = 10)+
          theme_bw())
  return(slopes_df)
}

# calculate slope and standard deviation and plot slope per bin of cities (log-transformed):
slopes_bin3 <- by(Merged, Merged$logBAIy1850_bin_3, my_lm) 

df_bin3 <- do.call(rbind, slopes_bin3) # make dataframe with slopes and standard deviations

# plotting:

# calculate 1.95 confidence interval based on standard error:
ymin <- df_bin3$Var1-(1.95*df_bin3$Var2)
ymax <- (1.95*df_bin3$Var2)+df_bin3$Var1

print(ggplot(df_bin3, aes(c("[0.693,2.27]", "[2.27,3.84]", "[3.84,5.42]"), Var1, 
            ymin = Var1-(1.95*Var2), ymax = (1.95*Var2)+Var1))+
  geom_point()+
  geom_errorbar()+
  labs(x="Groepering per populatiegrootte van de steden", 
       y="Richtingscoëfficiënten", 
       title="The deflection of veel"))
