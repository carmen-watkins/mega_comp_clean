## GITR Allometric Relationship
## this script 
    ## 1. checks that phyto & allometry data cover approx the same range
          ## after this is checked & confirmed to be okay, comment out this part so that we do not load & reload the same phyto data multiple times in later scripts.
    ## 2. tests & plots various allometric relationships
    ## 3. saves the output from the final best model for use later in predicting seed output.

# set up env
library(tidyverse)
library(ggpubr)
theme_set(theme_classic())

# Read in Data ####
## Processing data
#source("data_cleaning/merge_processing_collections_data.R")

## Allometry data
# specify dropbox pathway 
if(file.exists("/Users/carme/Dropbox (University of Oregon)/Mega_Competition/Data/Allometry/Allometry_entered/")){
  # Carmen
  allo_lead <- "/Users/carme/Dropbox (University of Oregon)/Mega_Competition/Data/Allometry/Allometry_entered/"
  
} else {
  # Marina
  allo_lead <- "/Users/Marina/Documents/Dropbox/Mega_Competition/Data/Allometry/Allometry_entered/"
} 

date <- 20221019

gitr_flower_allo <- read.csv(paste0(allo_lead, "GITR-flowers_allometry-processing_", date, ".csv"))

drought <- c(1, 3, 4, 6, 12, 14) ## create treatment vector
gitr_seed_allo <- read.csv(paste0(allo_lead, "GITR-seeds_allometry-processing_", date, ".csv")) %>%
  select(1:6, 8) %>%
  mutate(treatment = ifelse(Block %in% drought, "D", "C")) %>%
  filter(!is.na(seed.num))

## create a function to calculate standard error
calcSE<-function(x){
  x2<-na.omit(x)
  sd(x2)/sqrt(length(x2))
}

# Flower Dat Range ####
#gitr_dat <- all_dat_final %>%
 # filter(phyto == "GITR")

#phyto<-ggplot(gitr_dat, aes(x=total.biomass.rounded.percap)) +
 # geom_histogram() +
 # facet_wrap(~treatment)

#allo<-ggplot(gitr_flower_allo, aes(x=total.biomass.g)) +
#  geom_histogram() +
 # facet_wrap(~treatment) +
 # coord_cartesian(xlim = c(0,4))

#ggarrange(phyto, allo, ncol = 1, nrow=2)

#ggsave("gitr_allometry_check.png", height = 4, width = 6)

# Seed Distrib ####
ggplot(gitr_seed_allo, aes(x=seed.per.pod)) +
  geom_histogram()

## separate by treatment
final1 <- ggplot(gitr_seed_allo, aes(x=seed.per.pod)) +
  geom_histogram()+
  facet_wrap(~treatment) +
  xlab("Seeds per Flower") +
  ylab("Count")

## look at sample num per treatment
nrow(gitr_seed_allo[gitr_seed_allo$treatment == "D",]) ## 19
nrow(gitr_seed_allo[gitr_seed_allo$treatment == "C",]) ## 32
## Q here ####
  ## somewhat uneven sample sizes. Does this matter here?

# Calc Seeds/Flower ####
## calc overall mean
gitr_mean_seeds <- mean(gitr_seed_allo$seed.per.pod, na.rm = T)
gitr_mean_seeds ## 10.55 

## calc mean by treatment
gitr_seed_means <- gitr_seed_allo %>%
  group_by(treatment) %>%
  summarise(mean_seeds = mean(seed.per.pod, na.rm = T), SE_seeds = calcSE(seed.per.pod))

## plot this
final2 <- ggplot(gitr_seed_means, aes(x=treatment, y = mean_seeds)) +
  geom_point(size = 3) +
  geom_errorbar(aes(ymin = mean_seeds - SE_seeds, ymax = mean_seeds + SE_seeds), width = 0.25) +
  ylab("Seeds per Flower") + xlab ("Precipitation Treatment")

## use an anova to test signif differences b/w categories
seedtrt <- aov(seed.per.pod~treatment, data = gitr_seed_allo)
## residual standard error: 4.15402 "Estimated effects may be unbalanced"
    ## don't know what this means.
summary(seedtrt)
TukeyHSD(seedtrt)

## Q here ####
    ## given signif differences b/w seeds per flower in drought vs. control, should we use separate numbers?

# TotBio - Flower Rel. ####
## Combine drought and controls together for biomass-flower relationship

## visualize ####
### linear ####
final3 <- ggplot(gitr_flower_allo, aes(x=total.biomass.g))+
  geom_histogram() +
  xlab("Aboveground Biomass (g)") +
  ylab("Count")
  
final4 <- ggplot(gitr_flower_allo, aes(x=total.biomass.g, y=flower.num)) +
  geom_point() +
  geom_smooth(method = "lm", alpha = 0.25, linewidth = 0.75) +
  xlab("Aboveground Biomass (g)") +
  ylab("Flower Number")

### Poly ####
#ggplot(gitr_flower_allo, aes(x=total.biomass.g, y=flower.num, color = treatment)) +
 # geom_point() +
  #geom_smooth(method = "lm", alpha = 0.25, size = 0.75, formula = y ~ poly(x, 2))

## model ####
### *Linear ####
gitr_fallo_lin <- lm(flower.num ~ total.biomass.g, data = gitr_flower_allo)
summary(gitr_fallo_lin)
## R2 = 0.9032

### Poly ####
#gitr_fallo_poly <- lm(flower.num ~ total.biomass.g + I(total.biomass.g^2), data = gitr_flower_allo)
#summary(gitr_fallo_poly)
## R2 = 0.926

# Methods Figure ####
plot <- ggarrange(final1, final2, final3, final4, labels = "AUTO", ncol = 2, nrow = 2)

annotate_figure(plot, top = text_grob("GITR", 
                                      color = "black", face = "bold", size = 14))

## ggsave("allometry/methods_figures/GITR.png", height = 5, width = 6.5)

# Save Output ####
## save the model outputs
GITR.allo.output <- data.frame(Species = "GITR", 
           intercept = 0, 
           intercept_pval = NA, 
           intercept_se = NA, 
           
           slope = gitr_fallo_lin$coefficients[2], 
           slope_pval = summary(gitr_fallo_lin)$coefficients[2,4], 
           slope_se = summary(gitr_fallo_lin)$coefficients[2,2], 

           seeds_C = gitr_seed_means[gitr_seed_means$treatment == "C",]$mean_seeds,
           seeds_C_se = gitr_seed_means[gitr_seed_means$treatment == "C",]$SE_seeds,
           seeds_D = gitr_seed_means[gitr_seed_means$treatment == "D",]$mean_seeds,
           seeds_D_se = gitr_seed_means[gitr_seed_means$treatment == "D",]$SE_seeds,
           
           viability_C = NA,
           viability_C_se = NA,
           viability_D = NA,
           viability_D_se = NA)

rm(list = c("allo_lead", "date", "drought", "gitr_fallo_lin", "gitr_flower_allo", "gitr_mean_seeds",  "gitr_seed_allo", "seedtrt", "gitr_seed_means", "final1", "final2", "final3", "final4", "plot"))
