## Merge allometric relationships

## the purpose of this script is to put all allometric relationships in one dataframe so that they can be easily sourced and used in prepping the phyto & background data for modeling. 

## Inputs
    ## one model output object from each allometry_testing script. 
    ## input should be named like: "BRHO.allo.output"

## Relevant Outputs
    ## allo.df -> one df that will contain the species name, the model intercept, the slope, mean seeds, and mean viability 

allo_path = "allometry/clean_indiv_sp_data/"

# Read in Data ####
## read in allometric relationships
source(paste0(allo_path, "acam_allometry_testing.R"))
source(paste0(allo_path, "amme_allometry_testing.R"))
source(paste0(allo_path, "anar_allometry_testing.R"))
source(paste0(allo_path, "brho_allometry_testing.R"))
source(paste0(allo_path, "brni_allometry_testing.R"))
source(paste0(allo_path, "ceso_allometry_testing.R"))
source(paste0(allo_path, "clpu_allometry_testing.R"))
source(paste0(allo_path, "gitr_allometry_testing.R"))
source(paste0(allo_path, "leni_allometry_testing.R"))
source(paste0(allo_path, "lomu_allometry_testing.R"))
source(paste0(allo_path, "mael_allometry_testing.R"))
source(paste0(allo_path, "mica_allometry_testing.R"))
source(paste0(allo_path, "pler_allometry_testing.R"))
source(paste0(allo_path, "plno_allometry_testing.R"))
source(paste0(allo_path, "taca_allometry_testing.R"))
source(paste0(allo_path, "thir_allometry_testing.R"))
source(paste0(allo_path, "twil_allometry_testing.R"))

## merge all together
allo.df <- do.call("rbind", list(ACAM.allo.output, ANAR.allo.output, AMME.allo.output, BRHO.allo.output, BRNI.allo.output, CESO.allo.output, CLPU.allo.output, GITR.allo.output, LENI.allo.output, LOMU.allo.output, MAEL.allo.output, MICA.allo.output, PLER.allo.output, PLNO.allo.output, TACA.allo.output, THIR.allo.output, TWIL.allo.output))

allo.df.save = allo.df %>%
  rownames_to_column() %>%
  mutate(allo_type = ifelse(grepl("total",rowname), "total.biomass.g", rowname),
         allo_type = ifelse(allo_type %in% c("1", "11", "12"), NA, allo_type)) %>%
  select(-rowname)

write.csv(allo.df.save, "data/allometry_model_parameters_20250703.csv")

## clean up env
rm(list = c("ACAM.allo.output", "ANAR.allo.output", "AMME.allo.output", "BRHO.allo.output", "BRHO.tb.allo.output", "BRNI.allo.output", "CESO.allo.output", "CLPU.allo.output", "GITR.allo.output", "LENI.allo.output", "LOMU.allo.output", "MAEL.allo.output", "MICA.allo.output", "PLER.allo.output", "PLER.allo.output.CAREER", "PLNO.allo.output", "TACA.allo.output", "THIR.allo.output", "TWIL.allo.output", allo.df.save))
