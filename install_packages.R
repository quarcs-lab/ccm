# install_packages.R
# Bootstrap script: installs renv, initializes the project library,
# and snapshots a lockfile. Run once after cloning:
#
#   Rscript install_packages.R
#
# On subsequent sessions, `renv::restore()` is sufficient.

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv", repos = "https://cloud.r-project.org")
}

renv::init(bare = TRUE, restart = FALSE)

pkgs <- c(
  "tidyverse",
  "fixest",
  "modelsummary",
  "gt",
  "tidysynth",
  "Synth",
  "CausalImpact",
  "bsts",
  "segmented",
  "nlme",
  "rdrobust",
  "scpi",
  "scales",
  "knitr",
  "rmarkdown",
  "sandwich",
  "lmtest",
  "broom",
  "fpp3",
  "glue",
  "mice",
  "ranger",
  "gsynth",
  "panelView",
  # Part II — staggered DiD, matrix completion, IFE
  "did",
  "HonestDiD",
  "DRDID",
  "fect",
  "twfeweights",
  "BMisc",
  "pte",
  "patchwork",
  # Chapter 5 — augmented synthetic control (augsynth) + labeled Stata I/O
  "haven",
  "labelled",
  "LiblineaR",
  "FNN",
  "ggrepel"
)

renv::install(pkgs)

# GitHub-only: the augmented synthetic control package (not on CRAN). Its
# optional MCPanel backend (the progfunc = "mcp" matrix-completion option) is a
# Suggests dependency and is intentionally omitted — the book does not use it,
# and MCPanel does not compile cleanly on recent toolchains.
renv::install("ebenmichael/augsynth")

# GitHub-only: the synthetic difference-in-differences package (not on CRAN).
# Used by chapter 6 for panel.matrices(), synthdid_estimate(), sc_estimate(),
# did_estimate(), and the placebo / jackknife / bootstrap vcov methods.
renv::install("synth-inference/synthdid")

# r-universe-only: covariate-augmented SDID, exposes adjust.outcome.for.x() and
# the matching clustered-bootstrap SE xsdid_se_bootstrap(). Used by chapter 6.
install.packages(
  "xsynthdid",
  repos = c(skranz = "https://skranz.r-universe.dev",
            CRAN   = "https://cloud.r-project.org")
)

renv::snapshot(prompt = FALSE)

message("Done. renv.lock is now pinned. Commit it to git.")
