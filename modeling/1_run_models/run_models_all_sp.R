
## Run Models All Species

## this script runs the stan model for each species in a loop

# Set up ####
## read in cleaned & formatted model data
model.dat = read.csv("data/model_dat_unfilt.csv")

## set date
date = 20240714

## load packages
library(tidyverse)
library(bayesplot)
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

library(here)

# Run model loop ####
## create a vector of species to loop through
species = c("ACAM", "ANAR", "AMME", "BRHO", "BRNI", "CESO", "GITR", "LENI", "LOMU", "MAEL", "MICA", "PLER", "PLNO", "TACA", "THIR", "TWIL")

## create empty list to hold model outputs
model.output = list()
warnings = list()

## run loop
for(i in species){

  ## subset model data for one species
  dat = subset(model.dat, phyto == i)
  
## create vectors of the various data inputs
  Fecundity = as.integer(round(dat$phyto.seed.out)) ## seeds out
  N_blocks = as.integer(length(unique(dat$block))) ## number of blocks
  Blocks_OLD = as.integer(dat$block) ## vector of block vals
  Blocks = rep(NA, length(Blocks_OLD)) ## Make Blocks sequential

  for (i in 1:length(Blocks_OLD)) {
  
  if(Blocks_OLD[i] == 1) { 
    Blocks[i] = 1 } else if(Blocks_OLD[i] == 3) {
      Blocks[i] = 2} else if(Blocks_OLD[i] == 4){ 
        Blocks[i] = 3} else if(Blocks_OLD[i] == 6){
          Blocks[i] = 4} else if(Blocks_OLD[i] == 12) { 
            Blocks[i] = 5} else if(Blocks_OLD[i] == 14) {
              Blocks[i] = 6} else if(Blocks_OLD[i] == 5) {
                Blocks[i] = 7} else if (Blocks_OLD[i] == 7) {
                  Blocks[i] = 8} else if (Blocks_OLD[i] == 8) {
                    Blocks[i] = 9}  else if (Blocks_OLD[i] == 15){
                      Blocks[i] = 10} else if (Blocks_OLD[i] == 16){
                        Blocks[i] = 11
                      }
}

  N = as.integer(length(Fecundity)) ## number of observations
  N_i = as.integer(dat$phyto.n.indiv) ## stem # of focal species
  trt = as.integer(dat$trt) ## treatment (binary)

## stems data
  acam = as.integer(dat$ACAM)
  amme = as.integer(dat$AMME)
  anar = as.integer(dat$ANAR)
  brho = as.integer(dat$BRHO)
  brni = as.integer(dat$BRNI)
  ceso = as.integer(dat$CESO)
  gitr = as.integer(dat$GITR)
  leni = as.integer(dat$LENI)
  lomu = as.integer(dat$LOMU)
  mael = as.integer(dat$MAEL)
  mica = as.integer(dat$MICA)
  pler = as.integer(dat$PLER)
  plno = as.integer(dat$PLNO)
  taca = as.integer(dat$TACA)
  thir = as.integer(dat$THIR)
  twil = as.integer(dat$TWIL)
  weeds = as.integer(dat$weeds)

## make a vector of data inputs to model
  data_vec = c("N", "Fecundity", "N_i", "N_blocks", "Blocks", "trt", "acam", "amme", "anar", "brho","brni", "ceso", "gitr", "leni", "lomu", "mael", "mica", "pler", "plno", "taca","thir","twil", "weeds")

  print(i)

## create initials for epsilon and sigma
  initials = list(epsilon=rep(1,N_blocks), sigma = 1)
  initials1 = list(initials, initials, initials)

# Model ####
  model.output[[paste0("ricker_",i)]] = stan(file = 'modeling/1_run_models/ricker_model_stan.stan', 
                  data = data_vec, init = initials1, iter = 5000, chains = 3, thin = 2, 
                  control = list(adapt_delta = 0.9, max_treedepth = 15)) 

  PrelimFit = model.output[[paste0("ricker_",i)]] 

## save model output
  save(PrelimFit, file = paste0("modeling/1_run_models/posteriors/", i, "_posteriors_", date, ".rdata"))

}
