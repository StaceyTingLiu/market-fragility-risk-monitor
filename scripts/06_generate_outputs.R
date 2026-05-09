# 06_generate_outputs.R
# Generate figures for market fragility and systemic risk monitoring

library(dplyr)
library(ggplot2)
library(tidyr)
library(scales)

fragility_index <- read.csv("data/processed/fragility_index.csv")
evaluation_data <- read.csv("outputs/tables/fragility_signal_timeline.csv")

fragility_index$date <- as.Date(fragility_index$date)
evaluation_data$date <- as.Date(evaluation_data$date)

dir.create("outputs/figures", recursive = TRUE, showWarnings = FALSE)

# -----------------------------
# Helper: save readable white-background PNG
# -----------------------------
save_plot_png <- function(plot_obj, filename, width = 14, height = 7, res = 300) {
  if (capabilities("cairo")) {
    png(
      filename = filename,
      width = width,
      height = height,
      units = "in",
      res = res,
      bg = "white",
      type = "cairo"
    )
  } else {
    png(
      filename = filename,
      width = width,
      height = height,
      units = "in",
      res = res,
      bg = "white"
    )
  }
  
  print(plot_obj)
  dev.off()
}

# -----------------------------
# Common theme
# -----------------------------
my_theme <- theme_bw(base_size = 18) +
  theme(
    plot.title = element_text(size = 20, face = "bold", color = "black"),
    plot.subtitle = element_text(size = 15, color = "black"),
    axis.title = element_text(size = 16, face = "bold", color = "black"),
    axis.text = element_text(size = 14, color = "black"),
    legend.title = element_text(size = 15, face = "bold", color = "black"),
    legend.text = element_text(size = 14, color = "black"),
    legend.position = "right",
    panel.background = element_rect(fill = "white", color = "black"),
    plot.background = element_rect(fill = "white", color = "white"),
    legend.background = element_rect(fill = "white", color = "white"),
    legend.key = element_rect(fill = "white", color = "white"),
    panel.grid.major = element_line(color = "grey85", linewidth = 0.7),
    panel.grid.minor = element_line(color = "grey92", linewidth = 0.4)
  )

# -----------------------------
# Figure 1: Market Fragility Index Timeline
# -----------------------------
p1 <- ggplot(fragility_index, aes(x = date, y = fragility_index)) +
  geom_line(color = "steelblue4", linewidth = 1.0) +
  geom_hline(yintercept = 0.66, color = "firebrick", linetype = "dashed", linewidth = 0.9) +
  labs(
    title = "Market Fragility Index",
    subtitle = "Composite index based on sector dispersion, correlation, PCA concentration, residual stress, and VXX signal",
    x = "Date",
    y = "Fragility Index"
  ) +
  scale_y_continuous(limits = c(0, 1)) +
  my_theme

save_plot_png(
  p1,
  "outputs/figures/market_fragility_index_timeline.png"
)

# -----------------------------
# Figure 2: Fragility Regime Classification
# -----------------------------
fragility_index$fragility_regime <- factor(
  fragility_index$fragility_regime,
  levels = c("Low", "Medium", "High")
)

p2 <- ggplot(fragility_index, aes(x = date, y = fragility_index, color = fragility_regime)) +
  geom_point(size = 2.2, alpha = 0.85) +
  scale_color_manual(
    values = c(
      "Low" = "forestgreen",
      "Medium" = "darkorange",
      "High" = "red3"
    )
  ) +
  labs(
    title = "Market Fragility Regime Classification",
    subtitle = "Low / Medium / High market fragility regimes",
    x = "Date",
    y = "Fragility Index",
    color = "Fragility Regime"
  ) +
  scale_y_continuous(limits = c(0, 1)) +
  my_theme

save_plot_png(
  p2,
  "outputs/figures/fragility_regime_classification.png"
)

# -----------------------------
# Figure 3: Sector Dispersion Timeline
# -----------------------------
p3 <- ggplot(fragility_index, aes(x = date, y = sector_dispersion)) +
  geom_line(color = "darkcyan", linewidth = 1.0) +
  labs(
    title = "Sector Dispersion Timeline",
    subtitle = "Cross-sectional dispersion across U.S. sector ETF returns",
    x = "Date",
    y = "Sector Dispersion"
  ) +
  my_theme

save_plot_png(
  p3,
  "outputs/figures/sector_dispersion_timeline.png"
)

# -----------------------------
# Figure 4: Rolling Average Sector Correlation
# -----------------------------
p4 <- ggplot(fragility_index, aes(x = date, y = rolling_avg_correlation)) +
  geom_line(color = "purple4", linewidth = 1.0) +
  labs(
    title = "Rolling Average Sector Correlation",
    subtitle = "Average pairwise correlation across U.S. sector ETFs",
    x = "Date",
    y = "Average Correlation"
  ) +
  my_theme

save_plot_png(
  p4,
  "outputs/figures/rolling_correlation_timeline.png"
)

# -----------------------------
# Figure 5: PCA Concentration Timeline
# -----------------------------
p5 <- ggplot(fragility_index, aes(x = date, y = pca_concentration)) +
  geom_line(color = "darkorange3", linewidth = 1.0) +
  labs(
    title = "PCA Market Concentration Timeline",
    subtitle = "Share of sector-return variance explained by the first principal component",
    x = "Date",
    y = "First PC Variance Share"
  ) +
  my_theme

save_plot_png(
  p5,
  "outputs/figures/pca_concentration_timeline.png"
)

# -----------------------------
# Figure 6: Fragility Index with Future Stress Events
# -----------------------------
stress_points <- evaluation_data %>%
  filter(stress_event_21 == 1)

p6 <- ggplot(evaluation_data, aes(x = date, y = fragility_index)) +
  geom_line(color = "steelblue4", linewidth = 1.0) +
  geom_point(
    data = stress_points,
    aes(x = date, y = fragility_index),
    color = "red3",
    size = 2.8,
    alpha = 0.9
  ) +
  labs(
    title = "Fragility Index and Future Market Stress Events",
    subtitle = "Red dots mark dates followed by a 21-day SPY drawdown stress event",
    x = "Date",
    y = "Fragility Index"
  ) +
  scale_y_continuous(limits = c(0, 1)) +
  my_theme

save_plot_png(
  p6,
  "outputs/figures/fragility_stress_event_overlay.png"
)

# -----------------------------
# Figure 7: Indicator Heatmap
# -----------------------------
heatmap_data <- fragility_index %>%
  select(
    date,
    sector_dispersion_z,
    cross_sectional_volatility_z,
    rolling_avg_correlation_z,
    pca_concentration_z,
    residual_stress_score_z,
    vxx_return_z
  ) %>%
  pivot_longer(
    cols = -date,
    names_to = "indicator",
    values_to = "z_score"
  )

p7 <- ggplot(heatmap_data, aes(x = date, y = indicator, fill = z_score)) +
  geom_tile() +
  scale_fill_gradient2(
    low = "steelblue4",
    mid = "white",
    high = "firebrick",
    midpoint = 0,
    limits = c(-3, 3),
    oob = squish
  ) +
  labs(
    title = "Market Fragility Indicator Heatmap",
    subtitle = "Rolling standardized fragility indicators",
    x = "Date",
    y = "Indicator",
    fill = "Z-score"
  ) +
  my_theme +
  theme(
    axis.text.y = element_text(size = 12),
    legend.position = "right"
  )

save_plot_png(
  p7,
  "outputs/figures/fragility_indicator_heatmap.png",
  width = 14,
  height = 8,
  res = 300
)

cat("Figure generation completed successfully.\n")
cat("Created figures:\n")
cat("outputs/figures/market_fragility_index_timeline.png\n")
cat("outputs/figures/fragility_regime_classification.png\n")
cat("outputs/figures/sector_dispersion_timeline.png\n")
cat("outputs/figures/rolling_correlation_timeline.png\n")
cat("outputs/figures/pca_concentration_timeline.png\n")
cat("outputs/figures/fragility_stress_event_overlay.png\n")
cat("outputs/figures/fragility_indicator_heatmap.png\n")