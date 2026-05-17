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
  "scales",
  "knitr",
  "rmarkdown"
)

renv::install(pkgs)
renv::snapshot(prompt = FALSE)

message("Done. renv.lock is now pinned. Commit it to git.")
