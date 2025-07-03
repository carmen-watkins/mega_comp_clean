## Model diagnostics

## this script checks rhat values, traceplots, and pairs plots. outputs print to pdfs. 

# Set Up ####
## load packages
library(rstan)
library(bayesplot)
library(tidyverse)

## set date of models
date <- 20240714

## create a species list
species.list <- c("ACAM", "ANAR", "AMME", "BRHO", "BRNI", "CESO", "GITR", "LENI", "LOMU", "MAEL", "MICA", "PLER", "PLNO", "TACA", "THIR", "TWIL")

## set location to save all diagnostics figures to
fig_loc = "modeling/2_run_diagnostics/diagnostics/"

## create df for rhat and neff values
stat_diagnostics = data.frame(model.name = NA, Rhat = NA, Neff = NA)

# Run Diagnostics ####
## run diagnostics loop
for(i in 1:length(species.list)){
  
  ## select species
  species = species.list[i]

  ## print model to keep track of progress during loop
  print(species)
  
  ## load model 
  load(paste0("modeling/1_run_models/posteriors/", species, "_posteriors_", date, ".rdata"))

  ## Rhat ####
  ## save Rhat & Neff vals
  Rhat = max(summary(PrelimFit)$summary[,"Rhat"],na.rm =T)
  Neff = min(summary(PrelimFit)$summary[,"n_eff"],na.rm = T)
  
  ## put in df
  tmp2 = data.frame(model.name = species, Rhat = Rhat, Neff = Neff)
  
  ## append to main df
  stat_diagnostics = rbind(stat_diagnostics, tmp2)

  ## Traceplots ####
  ### epsilon/sigma
  traceplot(PrelimFit, pars = c("epsilon[1]", "epsilon[2]", "epsilon[3]", "epsilon[4]", "epsilon[5]", "epsilon[6]", "epsilon[7]", "epsilon[8]", "epsilon[9]", "epsilon[10]", "epsilon[11]", "sigma"))

  ggsave(paste0(fig_loc, date, "/", species, "/", species, "_random_effects_traceplot_", date, ".png"), width = 8, height = 4)

  ### lambda_base
  traceplot(PrelimFit, pars = c("lambda_base", "lambda_dev", "disp_dev"))

ggsave(paste0(fig_loc, date, "/", species, "/", species, "_lambda_traceplot_", date, ".png"), width = 6, height = 3)

### alphas 
#### part 1
traceplot(PrelimFit, pars = c("alpha_acam_base", "alpha_acam_dev", "alpha_amme_base", "alpha_amme_dev", "alpha_anar_base", "alpha_anar_dev", "alpha_brho_base", "alpha_brho_dev", "alpha_brni_base", "alpha_brni_dev", "alpha_ceso_base", "alpha_ceso_dev"))

ggsave(paste0(fig_loc, date, "/", species, "/", species,  "_alphas1_traceplot_", date, ".png"), width = 8, height = 4)

#### part 2
traceplot(PrelimFit, pars = c("alpha_gitr_base", "alpha_gitr_dev", "alpha_leni_base", "alpha_leni_dev", "alpha_lomu_base", "alpha_lomu_dev", "alpha_mael_base", "alpha_mael_dev", "alpha_mica_base", "alpha_mica_dev", "alpha_pler_base", "alpha_pler_dev"))

ggsave(paste0(fig_loc, date, "/", species, "/", species, "_alphas2_traceplot_", date, ".png"), width = 8, height = 4)

#### part 3
traceplot(PrelimFit, pars = c("alpha_plno_base", "alpha_plno_dev", "alpha_taca_base", "alpha_taca_dev", "alpha_thir_base", "alpha_thir_dev", "alpha_twil_base", "alpha_twil_dev", "alpha_weeds_base", "alpha_weeds_dev"))

ggsave(paste0(fig_loc, date, "/", species, "/", species, "_alphas3_traceplot_", date, ".png"), width = 8, height = 4)

## Pairs plots ####
### epsilon/sigma/lambda
png(file = paste0(fig_loc, date, "/", species, "/", species, "_pairs_plot_epsilon_sigma_lambda.png"), width = 1800, height = 1800)

pairs(PrelimFit, pars = c("epsilon[1]", "epsilon[2]", "epsilon[3]", "epsilon[4]", "epsilon[5]", "epsilon[6]", "epsilon[7]", "epsilon[8]", "epsilon[9]", "epsilon[10]", "epsilon[11]", "sigma", "lambda_base", "lambda_dev"))

dev.off()

### alpha 1/lambda
png(file = paste0(fig_loc, date, "/", species, "/", species, "_pairs_plot_lambda_alphas1.png"), width = 1800, height = 1800)

pairs(PrelimFit, pars = c("lambda_base", "lambda_dev", "alpha_acam_base", "alpha_acam_dev", "alpha_amme_base", "alpha_amme_dev", "alpha_anar_base", "alpha_anar_dev", "alpha_brho_base", "alpha_brho_dev", "alpha_brni_base", "alpha_brni_dev", "alpha_ceso_base", "alpha_ceso_dev"))

dev.off()

### alpha 2/lambda
png(file = paste0(fig_loc, date, "/", species, "/", species, "_pairs_plot_lambda_alphas2.png"), width = 1800, height = 1800)

pairs(PrelimFit, pars = c("lambda_base", "lambda_dev", "alpha_gitr_base", "alpha_gitr_dev", "alpha_leni_base", "alpha_leni_dev", "alpha_lomu_base", "alpha_lomu_dev", "alpha_mael_base", "alpha_mael_dev", "alpha_mica_base", "alpha_mica_dev", "alpha_pler_base", "alpha_pler_dev"))

dev.off()

### alpha 3/lambda
png(file = paste0(fig_loc, date, "/", species, "/", species, "_pairs_plot_lambda_alphas3.png"), width = 1800, height = 1800)

pairs(PrelimFit, pars = c("lambda_base", "lambda_dev", "alpha_plno_base", "alpha_plno_dev", "alpha_taca_base", "alpha_taca_dev", "alpha_thir_base", "alpha_thir_dev", "alpha_twil_base", "alpha_twil_dev", "alpha_weeds_base", "alpha_weeds_dev"))

dev.off()


### alpha, epsilon, sigma
png(file = paste0(fig_loc, date, "/", species, "/", species, "_pairs_plot_epsilon_sigma_alpha1.png"), width = 1800, height = 1800)

pairs(PrelimFit, pars = c("epsilon[1]", "epsilon[2]", "epsilon[3]", "epsilon[4]", "epsilon[5]", "epsilon[6]", "sigma", "alpha_acam_base", "alpha_acam_dev", "alpha_amme_base", "alpha_amme_dev", "alpha_anar_base", "alpha_anar_dev", "alpha_brho_base", "alpha_brho_dev"))

dev.off()


png(file = paste0(fig_loc, date, "/", species, "/", species, "_pairs_plot_epsilon_sigma_2_alpha1.png"), width = 1800, height = 1800)

pairs(PrelimFit, pars = c("epsilon[7]", "epsilon[8]", "epsilon[9]", "epsilon[10]", "epsilon[11]", "sigma", "alpha_acam_base", "alpha_acam_dev", "alpha_amme_base", "alpha_amme_dev", "alpha_anar_base", "alpha_anar_dev", "alpha_brho_base", "alpha_brho_dev"))

dev.off()

}


## remove NA
stat_diagnostics = stat_diagnostics %>%
  filter(!is.na(model.name))

## save output
write.csv(stat_diagnostics, paste0(fig_loc, "rhat_neff_", date, ".csv"))


