## BRHO Allometric Relationship
## this script 
    ## 1. checks that phyto & allometry data cover approx the same range
          ## after this is checked & confirmed to be okay, comment out this part so that we do not load & reload the same phyto data multiple times in later scripts.
    ## 2. tests & plots various allometric relationships
    ## 3. saves the output from the final best model for use later in predicting seed output.

# set up env
library(tidyverse)
library(ggpubr)
theme_set(theme_classic())

## create a function to calculate standard error
calcSE<-function(x){
  x2<-na.omit(x)
  sd(x2)/sqrt(length(x2))
}

# Read in Data ####
## Processing data
#source("data_cleaning/merge_processing_collections_data.R")

# specify dropbox pathway 
if(file.exists("/Users/carme/Dropbox (University of Oregon)/Mega_Competition/Data/Allometry/Allometry_entered/")){
  # Carmen
  allo_lead <- "/Users/carme/Dropbox (University of Oregon)/Mega_Competition/Data/Allometry/Allometry_entered/"
  
} else {
  # Marina
  allo_lead <- "/Users/Marina/Documents/Dropbox/Mega_Competition/Data/Allometry/Allometry_entered/"
} 

date <- 20221019

## Allometry data
brho_allo <- read.csv(paste0(allo_lead, "BRHO_allometry-processing_", date, ".csv")) %>%
  mutate(inflor.g = inflorescence.weight.g, seed.num = seeds.num) %>% ## standardize column names
  mutate(treatment = ifelse(treatment == "ambient", "C", "D")) ## standardize treatment values

# Dat Range ####
#brho_dat <- all_dat_final %>%
 # filter(phyto == "BRHO")

#phyto <- ggplot(brho_dat, aes(x=inflor.g.rounded.percap)) +
 # geom_histogram() +
#  facet_wrap(~treatment)+
 # coord_cartesian(xlim = c(0,2))

#allo <- ggplot(brho_allo, aes(x=inflor.g)) +
 # geom_histogram() +
  #facet_wrap(~treatment) +
  #coord_cartesian(xlim = c(0,2))

#ggarrange(phyto, allo, ncol = 1, nrow=2)

#ggsave("allometry/preliminary_figs/allometric_relationship_fits/brho_allometry_check.png", height = 4, width = 6)

## To-Do ####
  ## Looks like BRHO control could use a few more samples in the lower range.

# Inflor-Seed Rel. ####
## Visualize ####
ggplot(brho_allo, aes(x=inflor.g, y=seed.num, color = treatment)) +
  geom_point() +
  geom_smooth(method = "lm")
## the error bars on the lines overlap for most of it - so probably not separate relationships here

final1 <- ggplot(brho_allo, aes(x=inflor.g)) +
  geom_histogram() +
  xlab("Inflorescence Biomass (g)") +
  ylab("Count")
  
final2 <- ggplot(brho_allo, aes(x=inflor.g, y=seed.num)) +
  geom_point() +
  geom_smooth(method = "lm", alpha = 0.25, linewidth = 0.75, formula = y ~ x) +
  xlab("Inflorescence Biomass (g)") + ylab("Seed Number")

#ggplot(brho_allo, aes(x=inflor.g, y=seed.num)) +
 # geom_point() +
  #geom_smooth(method = "lm", formula = y ~ poly(x,2))

#ggplot(brho_allo, aes(x=inflor.g, y=seed.num)) +
 # geom_point() +
  #geom_smooth(method = "lm", formula = y ~ x)

#ggplot(brho_allo, aes(x=inflor.g, y=seed.num)) +
 # geom_point() +
  #geom_smooth(method = "lm", formula = y ~ log(x))

ggplot(brho_allo, aes(x=total.biomass.g, y=seed.num)) +
  geom_point() +
  geom_smooth(method = "lm")

ggplot(brho_allo, aes(x=inflor.g, y=seed.num)) +
  geom_point() +
  geom_smooth(method = "lm")


## Model ####
brho_fallo_rel <- lm(seed.num~inflor.g, data = brho_allo)
summary(brho_fallo_rel)
## slope = 951.7297
# y = 0.7543 + 951.7297x

brho_tb_allo_rel <- lm(seed.num~total.biomass.g, data = brho_allo)
summary(brho_tb_allo_rel)

# inflorseeds2 <- lm(seed.num ~ inflor.g + I(inflor.g^2), data = brho_allo)
# summary(inflorseeds2)

# Methods Figure ####
plot <- ggarrange(final1, final2, labels = "AUTO", ncol = 2, nrow = 1)

annotate_figure(plot, top = text_grob("BRHO", 
                                      color = "black", face = "bold", size = 14))

## ggsave("allometry/methods_figures/BRHO.png", height = 3, width = 6.5)


# Save Output ####
## save the model outputs
BRHO.allo.output <- data.frame(Species = "BRHO", 
           intercept = 0, 
           intercept_pval = NA, 
           intercept_se = NA, 
           
           slope = brho_fallo_rel$coefficients[2], 
           slope_pval = summary(brho_fallo_rel)$coefficients[2,4], 
           slope_se = summary(brho_fallo_rel)$coefficients[2,2], 
       
           seeds_C = NA,
           seeds_C_se = NA,
           seeds_D = NA,
           seeds_D_se = NA, 
           
           viability_C = NA,
           viability_C_se = NA,
           viability_D = NA,
           viability_D_se = NA)

BRHO.tb.allo.output <- data.frame(Species = "BRHO", 
                               intercept = 0, 
                               intercept_pval = NA, 
                               intercept_se = NA, 
                               
                               slope = brho_tb_allo_rel$coefficients[2], 
                               slope_pval = summary(brho_tb_allo_rel)$coefficients[2,4], 
                               slope_se = summary(brho_tb_allo_rel)$coefficients[2,2], 
                               
                               seeds_C = NA,
                               seeds_C_se = NA,
                               seeds_D = NA,
                               seeds_D_se = NA, 
                               
                               viability_C = NA,
                               viability_C_se = NA,
                               viability_D = NA,
                               viability_D_se = NA)

# Clean Env ####
rm(allo_lead, brho_allo, date, brho_fallo_rel, final1, final2, plot, brho_tb_allo_rel)
