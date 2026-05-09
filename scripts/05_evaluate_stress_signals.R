# 05_evaluate_stress_signals.R
# Evaluate whether high fragility regimes align with future market stress

library(dplyr)

prices <- read.csv("data/raw/etf_adjusted_prices.csv")
fragility_index <- read.csv("data/processed/fragility_index.csv")

prices$date <- as.Date(prices$date)
fragility_index$date <- as.Date(fragility_index$date)

# -----------------------------
# 1. Define future stress event
# -----------------------------

horizon <- 21
drawdown_threshold <- -0.08

future_drawdown <- rep(NA, nrow(prices))

for (i in 1:(nrow(prices) - horizon)) {
  current_price <- prices$SPY[i]
  future_prices <- prices$SPY[(i + 1):(i + horizon)]
  min_future_price <- min(future_prices, na.rm = TRUE)
  
  future_drawdown[i] <- min_future_price / current_price - 1
}

stress_target <- data.frame(
  date = prices$date,
  future_drawdown_21 = future_drawdown,
  stress_event_21 = ifelse(future_drawdown <= drawdown_threshold, 1, 0)
)

# -----------------------------
# 2. Merge fragility index with future stress target
# -----------------------------

evaluation_data <- fragility_index %>%
  left_join(stress_target, by = "date") %>%
  na.omit()

# High-fragility alert rule
evaluation_data$high_fragility_alert <- ifelse(
  evaluation_data$fragility_regime == "High",
  1,
  0
)

# -----------------------------
# 3. Compute evaluation metrics
# -----------------------------

actual <- evaluation_data$stress_event_21
alert <- evaluation_data$high_fragility_alert

true_positive <- sum(alert == 1 & actual == 1)
false_positive <- sum(alert == 1 & actual == 0)
false_negative <- sum(alert == 0 & actual == 1)
true_negative <- sum(alert == 0 & actual == 0)

hit_rate <- ifelse(
  true_positive + false_negative == 0,
  NA,
  true_positive / (true_positive + false_negative)
)

precision <- ifelse(
  true_positive + false_positive == 0,
  NA,
  true_positive / (true_positive + false_positive)
)

false_alarm_rate <- ifelse(
  false_positive + true_negative == 0,
  NA,
  false_positive / (false_positive + true_negative)
)

evaluation_summary <- data.frame(
  signal = "High Fragility Regime",
  horizon_days = horizon,
  drawdown_threshold = drawdown_threshold,
  hit_rate = round(hit_rate, 4),
  precision = round(precision, 4),
  false_alarm_rate = round(false_alarm_rate, 4),
  total_alerts = sum(alert),
  true_positives = true_positive,
  false_positives = false_positive,
  false_negatives = false_negative,
  true_negatives = true_negative
)

# -----------------------------
# 4. Save outputs
# -----------------------------

dir.create("outputs/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("outputs/alerts", recursive = TRUE, showWarnings = FALSE)

write.csv(
  evaluation_summary,
  "outputs/tables/fragility_signal_evaluation.csv",
  row.names = FALSE
)

write.csv(
  evaluation_data,
  "outputs/tables/fragility_signal_timeline.csv",
  row.names = FALSE
)

high_fragility_alerts <- evaluation_data %>%
  filter(high_fragility_alert == 1) %>%
  select(
    date,
    fragility_index,
    fragility_regime,
    future_drawdown_21,
    stress_event_21
  )

write.csv(
  high_fragility_alerts,
  "outputs/alerts/high_fragility_alerts.csv",
  row.names = FALSE
)

# -----------------------------
# 5. Console message
# -----------------------------

cat("Fragility signal evaluation completed successfully.\n")
cat("Output files:\n")
cat("outputs/tables/fragility_signal_evaluation.csv\n")
cat("outputs/tables/fragility_signal_timeline.csv\n")
cat("outputs/alerts/high_fragility_alerts.csv\n")
cat("\nEvaluation summary:\n")
print(evaluation_summary)