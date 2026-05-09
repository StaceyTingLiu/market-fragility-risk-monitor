# 04_construct_fragility_index.R
# Construct market fragility index and classify fragility regimes

library(dplyr)
library(zoo)

indicators <- read.csv("data/processed/fragility_indicators.csv")
indicators$date <- as.Date(indicators$date)

# Indicators used to build the fragility index
indicator_cols <- c(
  "sector_dispersion",
  "cross_sectional_volatility",
  "rolling_avg_correlation",
  "pca_concentration",
  "residual_stress_score",
  "vxx_return"
)

# Rolling window for leakage-safe normalization
window <- 252

rolling_zscore <- function(x, window) {
  z <- rep(NA, length(x))
  
  for (i in window:length(x)) {
    past_values <- x[(i - window + 1):i]
    past_mean <- mean(past_values, na.rm = TRUE)
    past_sd <- sd(past_values, na.rm = TRUE)
    
    if (!is.na(past_sd) && past_sd > 0) {
      z[i] <- (x[i] - past_mean) / past_sd
    } else {
      z[i] <- NA
    }
  }
  
  return(z)
}

# Apply rolling z-score normalization
zscore_data <- indicators

for (col in indicator_cols) {
  zscore_data[[paste0(col, "_z")]] <- rolling_zscore(indicators[[col]], window)
}

z_cols <- paste0(indicator_cols, "_z")

# Construct average fragility score
zscore_data$fragility_score_raw <- rowMeans(
  zscore_data[, z_cols],
  na.rm = TRUE
)

# Rescale fragility score to 0-1 using expanding min/max after available history
valid_scores <- zscore_data$fragility_score_raw
min_score <- min(valid_scores, na.rm = TRUE)
max_score <- max(valid_scores, na.rm = TRUE)

zscore_data$fragility_index <- (
  zscore_data$fragility_score_raw - min_score
) / (max_score - min_score)

# Classify fragility regimes
zscore_data$fragility_regime <- cut(
  zscore_data$fragility_index,
  breaks = c(-Inf, 0.33, 0.66, Inf),
  labels = c("Low", "Medium", "High")
)

fragility_index <- zscore_data %>%
  na.omit()

dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

write.csv(
  fragility_index,
  "data/processed/fragility_index.csv",
  row.names = FALSE
)

cat("Market fragility index constructed successfully.\n")
cat("Output file: data/processed/fragility_index.csv\n")
cat("Number of observations:", nrow(fragility_index), "\n")
cat("Fragility regime counts:\n")
print(table(fragility_index$fragility_regime))