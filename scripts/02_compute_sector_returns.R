# 02_compute_sector_returns.R
# Compute daily returns for sector ETFs and cross-asset ETFs

library(dplyr)

prices <- read.csv("data/raw/etf_adjusted_prices.csv")
prices$date <- as.Date(prices$date)

# Compute log returns
returns <- prices
returns[-1] <- lapply(prices[-1], function(x) c(NA, diff(log(x))))

returns <- na.omit(returns)

# Define asset groups
sector_etfs <- c(
  "XLC", "XLY", "XLP", "XLE", "XLF", "XLV",
  "XLI", "XLK", "XLB", "XLU", "XLRE"
)

cross_asset_etfs <- c("SPY", "QQQ", "IWM", "TLT", "GLD", "VXX")

# Save full return dataset
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

write.csv(
  returns,
  "data/processed/all_etf_returns.csv",
  row.names = FALSE
)

# Save sector-only returns
sector_returns <- returns %>%
  select(date, all_of(sector_etfs))

write.csv(
  sector_returns,
  "data/processed/sector_returns.csv",
  row.names = FALSE
)

# Save cross-asset returns
cross_asset_returns <- returns %>%
  select(date, all_of(cross_asset_etfs))

write.csv(
  cross_asset_returns,
  "data/processed/cross_asset_returns.csv",
  row.names = FALSE
)

cat("ETF returns computed successfully.\n")
cat("Output files:\n")
cat("data/processed/all_etf_returns.csv\n")
cat("data/processed/sector_returns.csv\n")
cat("data/processed/cross_asset_returns.csv\n")
cat("Number of return observations:", nrow(returns), "\n")
cat("Number of sector ETFs:", length(sector_etfs), "\n")
cat("Number of cross-asset ETFs:", length(cross_asset_etfs), "\n")