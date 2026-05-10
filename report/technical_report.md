# Technical Report: Market Fragility Risk Monitor

## 1. Executive Summary

This project develops a market fragility and systemic risk monitoring framework using U.S. sector ETFs and cross-asset market indicators. The goal is to identify changes in market structure that may signal elevated vulnerability to future market stress.

The project constructs a composite market fragility index based on sector dispersion, cross-sectional sector volatility, rolling average sector correlation, PCA-based market concentration, residual sector stress, and volatility-linked cross-asset signals. The framework then evaluates whether high-fragility regimes are followed by future 21-trading-day SPY drawdown stress events.

This project is designed for financial risk monitoring and decision-support research. It is not intended to be a trading strategy or investment recommendation system. Its main value is to show how interpretable market-structure signals can be converted into a reproducible financial risk-monitoring pipeline.

The project supports a broader research direction in leakage-safe AI/ML systems for financial risk forecasting, volatility monitoring, market fragility detection, and market-stress early warning.

## 2. Problem Statement

Financial markets can become fragile before stress is fully visible in broad market indexes. Fragility may appear when sector behavior becomes more dispersed, correlations change, common market factors dominate sector movements, or residual sector stress increases.

Traditional risk-monitoring tools often focus on realized volatility, market returns, or drawdowns. These measures are useful, but they may not fully capture internal market-structure changes. For example, sector dispersion may increase before a broad market drawdown, or sector correlations may rise when diversification benefits decline during stress periods.

The key problem addressed by this project is how to monitor market fragility using interpretable, reproducible, and timing-disciplined indicators. Instead of relying only on broad market returns, the project examines sector-level behavior and cross-asset stress signals.

## 3. Objective

The objective of this project is to build a reproducible market fragility monitoring framework that transforms sector ETF and cross-asset data into practical systemic-risk indicators.

The project has five main goals:

1. Download and process ETF market data.
2. Construct daily sector and cross-asset return datasets.
3. Build interpretable market fragility indicators.
4. Combine those indicators into a composite market fragility index.
5. Evaluate whether high-fragility regimes align with future market drawdown stress.

The project is designed to demonstrate a practical implementation of AI-assisted financial risk monitoring and market-stress detection.

## 4. Data and Asset Universe

The project uses daily adjusted ETF price data downloaded from Yahoo Finance through the `quantmod` package in R.

The asset universe includes a broad equity-market benchmark, cross-asset indicators, and major U.S. sector ETFs.

### Broad Market Benchmark

- SPY: S&P 500 ETF

### Cross-Asset Indicators

- QQQ: Nasdaq-100 ETF
- IWM: Russell 2000 ETF
- TLT: Long-term U.S. Treasury ETF
- GLD: Gold ETF
- VXX: Volatility-linked ETF

### Sector ETFs

- XLC: Communication Services
- XLY: Consumer Discretionary
- XLP: Consumer Staples
- XLE: Energy
- XLF: Financials
- XLV: Health Care
- XLI: Industrials
- XLK: Technology
- XLB: Materials
- XLU: Utilities
- XLRE: Real Estate

This asset universe allows the framework to monitor broad equity-market behavior, sector-level market structure, volatility-linked pressure, bond-market movement, gold-market behavior, growth-stock sensitivity, and small-cap sensitivity.

## 5. Data Processing

The first script downloads adjusted ETF prices and saves the raw data to:

```text
data/raw/etf_adjusted_prices.csv
```

The second script computes daily log returns for all ETFs. It then separates the return data into three processed datasets:

```text
data/processed/all_etf_returns.csv
data/processed/sector_returns.csv
data/processed/cross_asset_returns.csv
```

Daily log returns are used because they are standard in financial time-series analysis and are suitable for measuring short-horizon return movements. The sector return dataset is used to construct market-structure indicators, while the cross-asset return dataset provides additional market-stress signals.

## 6. Fragility Indicator Construction

The project constructs several interpretable market fragility indicators.

### 6.1 Sector Dispersion

Sector dispersion measures the cross-sectional standard deviation of sector ETF returns on each date. Higher dispersion means sectors are behaving more differently from one another.

This may indicate market fragmentation, sector-specific stress, or uneven risk transmission across the market.

### 6.2 Cross-Sectional Sector Volatility

Cross-sectional sector volatility is calculated as the average rolling volatility across sector ETFs. It captures whether sector-level return instability is rising over a rolling historical window.

This indicator reflects broad instability across sectors rather than stress concentrated in only one sector.

### 6.3 Rolling Average Sector Correlation

Rolling average sector correlation measures the average pairwise correlation among sector ETF returns over a rolling window.

A high average correlation may indicate that sector behavior is becoming more synchronized and dominated by common risk factors. This matters because diversification benefits often decline during stress periods.

### 6.4 PCA Market Concentration

The PCA concentration indicator measures the share of sector-return variance explained by the first principal component.

When the first principal component explains a large share of sector-return variation, sector behavior is more dominated by a common market component. This may indicate higher market concentration and reduced sector diversification.

### 6.5 Residual Sector Stress Score

The residual stress score removes the average sector movement from each sector return and measures the remaining cross-sectional residual dispersion.

This indicator captures sector-level dislocation after removing the common market movement. It is useful for identifying whether stress is concentrated in relative sector behavior rather than only in broad market direction.

### 6.6 VXX Return Signal

The VXX return signal is included as a volatility-linked cross-asset stress indicator. Large positive VXX movement may indicate rising market fear, volatility pressure, or broader market uncertainty.

## 7. Composite Market Fragility Index

The project combines multiple fragility indicators into a single composite market fragility index.

The construction process is:

1. Select key fragility indicators:
   - sector dispersion
   - cross-sectional sector volatility
   - rolling average sector correlation
   - PCA concentration
   - residual sector stress score
   - VXX return

2. Apply rolling z-score normalization to each indicator using historical information.

3. Average the standardized indicators to obtain a raw composite fragility score.

4. Rescale the raw score into a 0-to-1 fragility index.

5. Classify each date into one of three regimes:
   - Low fragility
   - Medium fragility
   - High fragility

The output is saved to:

```text
data/processed/fragility_index.csv
```

The composite index provides a compact summary of market fragility conditions while preserving interpretability through the underlying component indicators.

## 8. Leakage-Safe Design

The project emphasizes timing discipline and leakage-safe monitoring design.

The fragility indicators are constructed using current and historical market data. The future stress-event label is used only after the fragility index has already been constructed, and only for evaluation purposes.

This is important because a real monitoring system cannot use future drawdown information when generating current signals. If future information were used to construct or calibrate the fragility index, the evaluation would be unrealistic and affected by look-ahead bias.

The project separates:

- signal construction
- future stress-event labeling
- signal evaluation

This separation supports a more realistic financial risk-monitoring framework.

## 9. Future Stress-Event Evaluation

The project evaluates whether high-fragility regimes align with future SPY drawdown stress events.

The future stress-event target is defined as:

- benchmark: SPY
- horizon: 21 trading days
- stress threshold: future drawdown of at least 8%

For each date, the system calculates the worst future drawdown over the next 21 trading days. If the drawdown is less than or equal to -8%, the observation is labeled as a future stress event.

The high-fragility alert rule is:

```text
alert = 1 if fragility_regime == "High"
alert = 0 otherwise
```

The evaluation outputs are saved to:

```text
outputs/tables/fragility_signal_evaluation.csv
outputs/tables/fragility_signal_timeline.csv
outputs/alerts/high_fragility_alerts.csv
```

## 10. Evaluation Metrics

The project evaluates the high-fragility signal using several operational metrics.

### 10.1 Hit Rate

Hit rate measures the proportion of actual future stress events that were captured by high-fragility alerts.

A higher hit rate means the framework identified more future stress events.

### 10.2 Precision

Precision measures the proportion of high-fragility alerts that were followed by actual future stress events.

A higher precision means the alerts were more reliable.

### 10.3 False-Alarm Rate

False-alarm rate measures how often the system generated high-fragility alerts during non-stress periods.

A lower false-alarm rate is generally preferable, but there is usually a tradeoff between identifying more stress events and avoiding false alerts.

### 10.4 Confusion-Matrix Counts

The system also reports:

- true positives
- false positives
- false negatives
- true negatives

These values help evaluate the operational behavior of the monitoring framework.

## 11. Output Files

The project generates several categories of output files.

### 11.1 Processed Data

```text
data/processed/all_etf_returns.csv
data/processed/sector_returns.csv
data/processed/cross_asset_returns.csv
data/processed/fragility_indicators.csv
data/processed/fragility_index.csv
```

### 11.2 Evaluation Tables

```text
outputs/tables/fragility_signal_evaluation.csv
outputs/tables/fragility_signal_timeline.csv
```

### 11.3 Alert Records

```text
outputs/alerts/high_fragility_alerts.csv
```

### 11.4 Figures

```text
outputs/figures/market_fragility_index_timeline.png
outputs/figures/fragility_regime_classification.png
outputs/figures/sector_dispersion_timeline.png
outputs/figures/rolling_correlation_timeline.png
outputs/figures/pca_concentration_timeline.png
outputs/figures/fragility_stress_event_overlay.png
outputs/figures/fragility_indicator_heatmap.png
```

## 12. Visualization Outputs

The project generates several figures to make the monitoring system interpretable.

### 12.1 Market Fragility Index Timeline

This figure shows how the composite fragility index evolves over time. It provides a high-level view of changing market fragility conditions.

### 12.2 Fragility Regime Classification

This figure classifies each date into low, medium, or high fragility regimes. It helps users see when the market enters more fragile conditions.

### 12.3 Sector Dispersion Timeline

This figure shows the cross-sectional dispersion of sector ETF returns. It helps identify periods when sectors behave more differently from one another.

### 12.4 Rolling Average Sector Correlation

This figure tracks the average pairwise correlation among sector ETFs. It helps evaluate whether sector behavior is becoming more synchronized.

### 12.5 PCA Concentration Timeline

This figure shows the share of sector-return variance explained by the first principal component. It helps identify whether market movement is becoming dominated by a common factor.

### 12.6 Fragility Index and Future Stress Events

This figure overlays future stress-event dates on the fragility index timeline. It helps visually evaluate whether stress events occur around elevated fragility conditions.

### 12.7 Fragility Indicator Heatmap

This heatmap shows rolling standardized fragility indicators over time. It provides a component-level view of how the composite fragility index is formed.

## 13. Practical Use Case

This project can support financial risk monitoring and decision-support research.

Potential use cases include:

- monitoring market fragility conditions
- identifying shifts in sector behavior
- supporting systemic-risk analysis
- creating market-stress dashboards
- comparing different fragility indicators
- supporting drawdown-risk early-warning research
- developing AI-assisted financial risk-monitoring systems

The system is designed to help analysts understand changing market conditions rather than to provide direct investment recommendations.

## 14. Relationship to Broader Research Direction

This project supports a broader research direction in leakage-safe AI/ML for financial risk forecasting, volatility monitoring, market fragility detection, and market-stress early warning.

It complements other projects in the same research portfolio:

1. A financial risk warning system focused on drawdown-risk early warning.
2. A volatility forecasting benchmark system focused on future realized volatility prediction.
3. This market fragility risk monitor focused on systemic risk and market-structure fragility.

Together, these projects demonstrate a coherent research and implementation direction in AI-based financial risk monitoring.

## 15. Limitations

This project has several limitations.

First, the current version uses ETF market data only. It does not include macroeconomic variables, credit spreads, liquidity indicators, options-implied volatility surfaces, earnings information, or intraday data.

Second, the composite fragility index uses selected indicators and simple averaging. Alternative weighting schemes may produce different results.

Third, the high-fragility regime threshold is fixed. Future versions may use adaptive thresholds or cost-sensitive alert rules.

Fourth, the evaluation target is based on a future 21-trading-day SPY drawdown of at least 8%. Different horizons or drawdown thresholds may change the results.

Fifth, the project is designed for research and decision-support demonstration. It does not provide investment advice and does not guarantee accurate prediction of future market stress.

## 16. Future Work

Future versions may extend the framework in several ways:

- add macroeconomic indicators
- include credit-market and liquidity indicators
- include options-implied volatility data
- test alternative fragility index weighting methods
- evaluate multiple forecast horizons
- test alternative drawdown thresholds
- add model-based stress classification
- add interpretability analysis
- build an interactive Shiny dashboard
- conduct broader robustness checks across historical regimes

## 17. Conclusion

This project implements a reproducible market fragility and systemic risk monitoring framework using sector ETFs and cross-asset indicators.

The system constructs interpretable fragility indicators, combines them into a composite market fragility index, classifies market fragility regimes, evaluates high-fragility signals against future drawdown stress events, and generates visual outputs for interpretation.

The main contribution of the project is not a trading strategy, but a practical and reproducible monitoring framework for market fragility and financial risk decision support. By emphasizing timing discipline, interpretability, and market-structure indicators, the project supports a broader research agenda in leakage-safe AI/ML systems for financial risk forecasting, volatility monitoring, market fragility detection, and market-stress early warning.