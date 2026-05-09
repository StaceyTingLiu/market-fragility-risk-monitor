# run_pipeline.R
# Run full market fragility monitoring pipeline

source("scripts/01_download_data.R")
source("scripts/02_compute_sector_returns.R")
source("scripts/03_build_fragility_indicators.R")
source("scripts/04_construct_fragility_index.R")
source("scripts/05_evaluate_stress_signals.R")
source("scripts/06_generate_outputs.R")

cat("Full market fragility monitoring pipeline completed successfully.\n")