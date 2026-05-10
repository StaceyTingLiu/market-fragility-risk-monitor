
# Market Fragility Risk Monitor

AI-assisted market fragility and systemic risk monitoring framework using sector ETFs and cross-asset indicators.

## Short Description

This project implements a market fragility and systemic risk monitoring framework using sector ETF behavior, rolling correlation structure, PCA-based market concentration, residual stress indicators, and cross-asset stress signals.

The project is designed for financial risk monitoring and decision-support research rather than trading-alpha generation.

## Project Overview

This repository provides a reproducible pipeline for monitoring market fragility conditions using U.S. sector ETFs and cross-asset market indicators. The system downloads ETF market data, computes sector and cross-asset returns, builds interpretable fragility indicators, constructs a composite market fragility index, evaluates high-fragility signals against future drawdown-risk events, and generates visualization outputs.

The project supports research in leakage-safe AI/ML systems for financial risk forecasting, volatility monitoring, market fragility detection, and market-stress early warning.

## Motivation

Financial markets can become fragile when sector behavior becomes more dispersed, correlations shift, market movement becomes more concentrated, or residual sector stress rises. These conditions may signal changing market structure and elevated vulnerability to future stress events.

Many financial risk tools focus only on volatility or price drawdowns. This project instead monitors market structure through sector dispersion, rolling correlations, PCA concentration, residual stress, and volatility-linked cross-asset signals.

## Asset Universe

The system uses SPY as the broad U.S. equity-market benchmark and includes cross-asset and sector ETF predictors.

The asset universe includes:

- SPY
- QQQ
- IWM
- TLT
- GLD
- VXX
- XLC
- XLY
- XLP
- XLE
- XLF
- XLV
- XLI
- XLK
- XLB
- XLU
- XLRE

## Fragility Indicators

The framework constructs the following indicators:

- sector dispersion
- cross-sectional sector volatility
- rolling average sector correlation
- PCA first-component explained variance
- residual sector stress score
- VXX return signal
- cross-asset returns

These indicators are designed to capture different dimensions of market fragility, including dispersion, concentration, correlation, residual stress, and volatility-linked market pressure.

## Methodology

The project pipeline has six main steps:

1. Download ETF adjusted price data.
2. Compute daily sector ETF and cross-asset returns.
3. Build market fragility indicators.
4. Construct a composite market fragility index.
5. Evaluate high-fragility regimes against future 21-trading-day SPY drawdown stress events.
6. Generate market fragility figures, alert tables, and evaluation outputs.

## Leakage-Safe Design

The system uses rolling historical windows to construct market fragility indicators and normalize signals. The future stress-event label is used only for evaluation, not for constructing the fragility index.

This helps preserve the timing discipline of the monitoring framework. The project is designed as a realistic market-monitoring system rather than a hindsight-optimized trading strategy.

## Repository Structure

```text
market-fragility-risk-monitor/
|-- README.md
|-- run_pipeline.R
|-- requirements_R.txt
|-- data/
|   |-- raw/
|   `-- processed/
|-- scripts/
|   |-- 01_download_data.R
|   |-- 02_compute_sector_returns.R
|   |-- 03_build_fragility_indicators.R
|   |-- 04_construct_fragility_index.R
|   |-- 05_evaluate_stress_signals.R
|   `-- 06_generate_outputs.R
|-- outputs/
|   |-- figures/
|   |-- tables/
|   `-- alerts/
|-- report/
|   `-- technical_report.md