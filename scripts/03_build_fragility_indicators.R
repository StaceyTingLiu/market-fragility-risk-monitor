# 03_build_fragility_indicators.R
# Build market fragility indicators from sector ETFs and cross-asset signals

library(dplyr)
library(zoo)

sector_returns <- read.csv("data/processed/sector_returns.csv")
cross_asset_returns <- read.csv("data/processed/cross_asset_returns.csv")

sector_returns$date <- as.Date(sector_returns$date)
cross_asset_returns$date <- as.Date(cross_asset_returns$date)

sector_etfs <- setdiff(names(sector_returns), "date")

# Rolling window for fragility indicators
window <- 63

# Helper function: average pairwise correlation
average_pairwise_correlation <- function(x) {
  corr_mat <- cor(x, use = "pairwise.complete.obs")
  upper_vals <- corr_mat[upper.tri(corr_mat)]
  mean(upper_vals, na.rm = TRUE)
}

# Helper function: first principal component explained variance
pca_first_component_share <- function(x) {
  x <- scale(x)
  pca_obj <- prcomp(x, center = FALSE, scale. = FALSE)
  variance_share <- pca_obj$sdev^2 / sum(pca_obj$sdev^2)
  variance_share[1]
}

# Create empty vectors
n <- nrow(sector_returns)

sector_dispersion <- rep(NA, n)
cross_sectional_volatility <- rep(NA, n)
rolling_avg_correlation <- rep(NA, n)
pca_concentration <- rep(NA, n)
residual_stress_score <- rep(NA, n)

sector_matrix <- as.matrix(sector_returns[, sector_etfs])

for (i in window:n) {
  
  rolling_sector_data <- sector_matrix[(i - window + 1):i, ]
  
  # Indicator 1: sector dispersion on current date
  sector_dispersion[i] <- sd(sector_matrix[i, ], na.rm = TRUE)
  
  # Indicator 2: average cross-sectional sector volatility over rolling window
  sector_vols <- apply(rolling_sector_data, 2, sd, na.rm = TRUE)
  cross_sectional_volatility[i] <- mean(sector_vols, na.rm = TRUE)
  
  # Indicator 3: rolling average pairwise correlation
  rolling_avg_correlation[i] <- average_pairwise_correlation(rolling_sector_data)
  
  # Indicator 4: PCA first component explained variance
  pca_concentration[i] <- pca_first_component_share(rolling_sector_data)
  
  # Indicator 5: residual stress score
  # Idea: remove the average sector movement and measure remaining dispersion
  current_sector_returns <- sector_matrix[i, ]
  common_component <- mean(current_sector_returns, na.rm = TRUE)
  residual_returns <- current_sector_returns - common_component
  residual_stress_score[i] <- sd(residual_returns, na.rm = TRUE)
}

# Merge with cross-asset signals
fragility_indicators <- data.frame(
  date = sector_returns$date,
  sector_dispersion = sector_dispersion,
  cross_sectional_volatility = cross_sectional_volatility,
  rolling_avg_correlation = rolling_avg_correlation,
  pca_concentration = pca_concentration,
  residual_stress_score = residual_stress_score
) %>%
  left_join(cross_asset_returns, by = "date") %>%
  na.omit()

# Rename cross-asset returns for clarity
fragility_indicators <- fragility_indicators %>%
  rename(
    spy_return = SPY,
    qqq_return = QQQ,
    iwm_return = IWM,
    tlt_return = TLT,
    gld_return = GLD,
    vxx_return = VXX
  )

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

write.csv(
  fragility_indicators,
  "data/processed/fragility_indicators.csv",
  row.names = FALSE
)

cat("Market fragility indicators built successfully.\n")
cat("Output file: data/processed/fragility_indicators.csv\n")
cat("Number of observations:", nrow(fragility_indicators), "\n")
cat("Indicators included:\n")
cat("- sector_dispersion\n")
cat("- cross_sectional_volatility\n")
cat("- rolling_avg_correlation\n")
cat("- pca_concentration\n")
cat("- residual_stress_score\n")
cat("- cross-asset returns\n")