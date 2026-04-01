# Test-of-Synchronization
This repository contains the official R implementation of **Algorithm 3** from:

> Bonnerjee, S., Karmakar, S., Cheng, M., and Wu, W. B. (2026+).  
> *Testing synchronization of change-points for multiple time series.*
> 
---

## Overview

This repository contains the R code used to implement and apply the bootstrap-based synchronization test proposed in the paper. The central question is whether change-points across the components of a multivariate time series occur **simultaneously** (synchronized) or at **different times** (asynchronized).

Given a multivariate time series **X**ᵢ = (X_{i,1}, ..., X_{i,d})ᵀ, the null hypothesis is:

**H₀ : τ₁ = τ₂ = ... = τ_d**

where τⱼ is the (rescaled) change-point location in the j-th coordinate series.

---

## Repository Structure
```
.
├── Algorithm_3.R               # Core implementation: SyncBootstage2()
├── Analysis_of_mississippi.R   # Real data application: Mississippi River floods (Section 6.2.1)
├── Analysis_of_mentalload.R    # Real data application: Pilot mental load (Section 6.2.2)
└── Data_For_Sec_6_1/
    ├── Vicksberg2324 - Sheet1.csv   # Daily water discharge at Vicksburg, MS
    └── Tennesi2324 - Sheet1.csv     # Daily water discharge at Memphis, TN
```

---

## Dependencies
```r
install.packages(c("MASS", "tidyverse", "readr", "kcpRS"))
```

| Package     | Purpose                                      |
|-------------|----------------------------------------------|
| `MASS`      | Multivariate normal sampling (`mvrnorm`)     |
| `tidyverse` | Data wrangling and `ggplot2` visualizations  |
| `readr`     | Reading CSV data files                       |
| `kcpRS`     | Provides the `MentalLoad` dataset            |

---

## Core Function: `SyncBootstage2`

Defined in `Algorithm_3.R`, this function implements the full two-stage bootstrap test of synchronization (Algorithm 3 in the paper).

### Usage
```r
source("Algorithm_3.R")

result <- SyncBootstage2(
  X,           # (n x d) numeric matrix of observations
  n,           # number of time points
  d,           # number of dimensions/components
  nboot = 5000,            # number of bootstrap samples (default: 5000)
  B_n = floor(n^(1/4))    # bandwidth for long-run covariance estimation (default: n^(1/4))
)
```

### Arguments

| Argument | Type    | Description                                                                 |
|----------|---------|-----------------------------------------------------------------------------|
| `X`      | matrix  | An n × d matrix; each column is one component time series                   |
| `n`      | integer | Number of observations per series                                           |
| `d`      | integer | Number of component series (dimensions)                                     |
| `nboot`  | integer | Bootstrap replicates for both Stage 1 (individual tests) and Stage 2        |
| `B_n`    | integer | HAC kernel bandwidth for estimating long-run covariance matrix Σ̂∞          |

### Return Value

A named list with the following elements:

| Element      | Description                                                              |
|--------------|--------------------------------------------------------------------------|
| `pval`       | Bootstrap p-value for H₀: τ₁ = ... = τ_d                               |
| `common_tau` | Estimated common change-point index (argmax of summed CUSUM)            |
| `indiv_tau`  | Vector of d individual CUSUM-based change-point estimates               |
| `T_n`        | Observed test statistic Tₙ (equation 2.3 in paper)                      |
| `boot`       | Vector of nboot bootstrap test statistic values                          |
| `Shat`       | Estimated long-run covariance matrix Σ̂∞ (equation 3.7 in paper)        |
| `pos_dim`    | Indices of dimensions identified as having a change-point (V̂₁)         |

### Minimal Example
```r
source("Algorithm_3.R")
set.seed(42)

n <- 300
d <- 4

# Simulate synchronized data under H0 (common change-point at 0.5)
X <- matrix(rnorm(n * d), nrow = n, ncol = d)
X[151:n, ] <- X[151:n, ] + 1  # common jump in all dimensions at t=150

result <- SyncBootstage2(X = X, n = n, d = d, nboot = 2000)

cat("p-value:", result$pval, "\n")
cat("Common change-point (index):", result$common_tau, "\n")
cat("Individual change-points:", result$indiv_tau, "\n")
cat("Dimensions with detected change-point:", result$pos_dim, "\n")
```

---

## Algorithm Details

The function implements a two-stage procedure:

**Stage 1 — Individual change-point detection (Algorithm 2)**  
For each dimension j, a CUSUM-based bootstrap test checks H₀ⱼ: δⱼ = 0 at level 5%. This partitions dimensions into V̂₀ (no change) and V̂₁ (significant change).

**Stage 2 — Synchronization test (Algorithm 3)**  
Bootstrap samples are drawn from N(0, Σ̂∞) and mean-corrected according to V̂₀/V̂₁. The empirical distribution of Tₙ under H₀ is approximated and a p-value is computed.

The **kernel function** used for HAC covariance estimation is:
```
K(u) = (1 - u²) · 1{|u| ≤ 1}
```

with bandwidth B_n = ⌊n^{1/4}⌋ (recommended by Theorem 2 and simulation studies in the paper).

---

## Real Data Applications

### Mississippi River Flood Onset (Section 6.2.1)
```r
source("Analysis_of_mississippi.R")
```

Applies the synchronization test to daily water discharge (ft³/sec) at **Memphis, TN** and **Vicksburg, MS** from September 1, 2023 to May 1, 2024 (n = 241, d = 2).

**Result:** p-value = 0.0264. H₀ is rejected at the 5% level — flood onset dates are statistically asynchronized, with Memphis leading Vicksburg by approximately **3 days**.

Data source: [USGS Water Data for the Nation](https://waterdata.usgs.gov)

### Pilot Mental Load (Section 6.2.2)
```r
source("Analysis_of_mentalload.R")
```

Applies the test to cardio-respiratory time series (HR, petCO₂, RR) from the `kcpRS` package (`MentalLoad` dataset, Grassmann et al., 2016).

Two segments are analyzed separately:

| Segment         | Time Points | p-value | Decision                        |
|-----------------|-------------|---------|----------------------------------|
| Resting → Vanilla Baseline | 1–500s   | 0.0362  | Reject H₀ (asynchronized)      |
| Multiple Tasks → Recovery  | 894–1393s | 0.1088  | Fail to reject H₀ (synchronized)|

---

## Citation

If you use this code, please cite:
```bibtex
@article{bonnerjee2025synchronization,
  title   = {Testing synchronization of change-points for multiple time series},
  author  = {Bonnerjee, Soham and Karmakar, Sayar and Cheng, Maggie and Wu, Wei Biao},
  journal = {Preprint},
  number  = {1},
  year    = {2026}
}
```

---

## Contact

For questions about the methodology, please refer to the paper or contact the author:

- Soham Bonnerjee — sohambonnerjee@uchicago.edu  
