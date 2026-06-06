# R/simulate_tobacco_panel.R
# -----------------------------------------------------------------------------
# Generates the simulated tobacco-control panel used in Chapter 5 (Augmented
# Synthetic Control). It is deliberately engineered so that *classical*
# (simplex-constrained) synthetic control has POOR pre-treatment fit, while
# ridge augmentation repairs it:
#
#   * The outcomes follow a latent two-factor model. Donor states' factor
#     loadings sit inside the unit square; the four treated states' loadings are
#     pushed to ~1.45 on each factor, OUTSIDE the convex hull of the donor
#     loadings. No convex (simplex) combination of donors can reproduce the
#     treated factor path, so SCM leaves residual pre-period imbalance. Ridge
#     augmentation, being unconstrained and only L2-penalised, can extrapolate
#     beyond the hull and close the gap.
#   * Four treated states adopt an anti-smoking program at STAGGERED dates
#     (1986, 1989, 1992, 1995) -> exercises multisynth().
#   * THREE correlated outcomes are generated (cigarette sales, smoking-related
#     mortality, tobacco tax revenue) -> exercises augsynth_multiout().
#
# Run once from the repo root:
#   Rscript R/simulate_tobacco_panel.R
#
# Output: data/tobacco_sim.dta  (a LABELLED Stata file, variable + value labels)
# -----------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(haven)      # write_dta()
  library(labelled)   # set_variable_labels() / set_value_labels()
})

set.seed(42)

## --- dimensions -------------------------------------------------------------
n_donor <- 36L
n_treat <- 4L
n_state <- n_donor + n_treat
years   <- 1970:2000
Tn      <- length(years)

donor_names <- sprintf("Donor%02d", seq_len(n_donor))
treat_names <- c("Atlantica", "Borealis", "Cascadia", "Deltora")
states      <- c(donor_names, treat_names)

adopt_years <- c(1986L, 1989L, 1992L, 1995L)                 # staggered adoption
adoption_of <- setNames(c(rep(NA_integer_, n_donor), adopt_years), states)
ever_treated <- c(rep(0L, n_donor), rep(1L, n_treat))

## --- latent factor structure (the "bad-fit" engine) ------------------------
# Two time-varying common factors: a smooth stochastic trend and a faster
# oscillation. Two-way fixed effects cannot absorb the loading x factor term.
f1   <- as.numeric(scale(cumsum(rnorm(Tn, 0, 1))))          # smooth trend, ~N(0,1)
f2   <- sin(seq(0, 4 * pi, length.out = Tn))                # faster oscillation
Fmat <- cbind(f1, f2)                                       # Tn x 2

# Donor loadings inside [0,1]^2; treated loadings pushed OUTSIDE the hull.
Lam_donor <- matrix(runif(n_donor * 2, 0, 1), ncol = 2)
Lam_treat <- matrix(1.45, n_treat, 2) + matrix(rnorm(n_treat * 2, 0, 0.08), ncol = 2)
Lambda    <- rbind(Lam_donor, Lam_treat)                    # n_state x 2

## --- per-outcome building blocks -------------------------------------------
# Unit fixed effects (treated set higher to reinforce the off-hull level),
# secular trends, and factor loadings scaled per outcome.
mu_cig  <- rnorm(n_state, 130, 12) + ever_treated * 16
mu_mort <- rnorm(n_state,  95,  8) + ever_treated *  9
mu_tax  <- rnorm(n_state,  45,  6) + ever_treated *  4

fscale_cig  <-  9                                           # factor amplitude
fscale_mort <-  5
fscale_tax  <-  4

trend_cig  <- -0.8                                          # secular decline in smoking
trend_mort <- -0.5
trend_tax  <-  0.9                                          # secular rise in tax revenue

## --- correlated noise across the three outcomes ----------------------------
sd_cig <- 6; sd_mort <- 4; sd_tax <- 3
R <- matrix(c( 1.0,  0.4, -0.3,
               0.4,  1.0, -0.1,
              -0.3, -0.1,  1.0), 3, 3)
D     <- diag(c(sd_cig, sd_mort, sd_tax))
Sigma <- D %*% R %*% D

## --- dynamic treatment effects (event time e = year - adoption) ------------
te_cig  <- function(e) ifelse(e < 0, 0, -4.0 * pmin(e + 1, 6))   # negative ramp
te_mort <- function(e) ifelse(e < 0, 0, -1.5 * pmax(e - 2, 0))   # negative, lagged
te_tax  <- function(e) ifelse(e < 0, 0, 12.0 * pmin(e + 1, 6))   # positive ramp

## --- assemble the balanced panel -------------------------------------------
panel <- expand_grid(state = states, year = years) |>
  mutate(
    si      = match(state, states),
    ti      = match(year, years),
    adopt   = adoption_of[state],                          # NA for donors
    ever    = ever_treated[si],
    e       = if_else(is.na(adopt), -99L, as.integer(year - adopt)),
    yr0     = year - 1970,
    fac_sum = rowSums(Lambda[si, , drop = FALSE] * Fmat[ti, , drop = FALSE])
  )

noise <- MASS::mvrnorm(nrow(panel), mu = c(0, 0, 0), Sigma = Sigma)

tobacco_sim <- panel |>
  mutate(
    cigsale   = mu_cig[si]  + trend_cig  * yr0 + fscale_cig  * fac_sum +
                  if_else(ever == 1L, te_cig(e),  0) + noise[, 1],
    mortality = mu_mort[si] + trend_mort * yr0 + fscale_mort * fac_sum +
                  if_else(ever == 1L, te_mort(e), 0) + noise[, 2],
    taxrev    = mu_tax[si]  + trend_tax  * yr0 + fscale_tax  * fac_sum +
                  if_else(ever == 1L, te_tax(e),  0) + noise[, 3],
    treated   = ever,                                                  # static flag
    trt       = if_else(!is.na(adopt) & year >= adopt, 1L, 0L),        # time-varying
    adoption_year = if_else(is.na(adopt), 9999L, as.integer(adopt))    # Stata-safe sentinel
  ) |>
  arrange(state, year) |>
  mutate(year = as.integer(year)) |>
  dplyr::select(state, year, cigsale, mortality, taxrev,
                adoption_year, treated, trt)

## --- clear labels for the Stata file ---------------------------------------
tobacco_sim <- tobacco_sim |>
  set_variable_labels(
    state         = "State (unit identifier)",
    year          = "Calendar year",
    cigsale       = "Cigarette sales (packs per capita)",
    mortality     = "Smoking-related mortality (deaths per 100,000)",
    taxrev        = "Tobacco tax revenue (US$ per capita)",
    adoption_year = "First year anti-smoking program is active (9999 = never-treated)",
    treated       = "Ever adopts the anti-smoking program (0/1)",
    trt           = "Anti-smoking program active in this state-year (0/1)"
  ) |>
  set_value_labels(
    treated = c("Never-treated donor" = 0, "Treated state" = 1),
    trt     = c("Inactive" = 0, "Active" = 1)
  )

## --- write + summarise ------------------------------------------------------
dir.create("data", showWarnings = FALSE)
haven::write_dta(tobacco_sim, "data/tobacco_sim.dta", version = 14)

cat("Wrote data/tobacco_sim.dta\n")
cat(sprintf("  rows: %d  (states: %d x years: %d)\n",
            nrow(tobacco_sim), n_state, Tn))
cat("  adoption cohorts:\n")
print(tobacco_sim |>
        filter(treated == 1) |>
        distinct(state, adoption_year) |>
        arrange(adoption_year))
cat("  outcome ranges:\n")
print(tobacco_sim |>
        summarise(across(c(cigsale, mortality, taxrev),
                         list(min = ~min(.x), max = ~max(.x)))) |>
        as.data.frame())
