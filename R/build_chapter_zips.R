# Pre-render hook (registered in _quarto.yml).
# Builds downloads/chapter-NN.zip for each content chapter so readers can
# download a self-contained Quarto bundle that renders standalone via
# `quarto render chapter.qmd` on any machine with R + Quarto.

chapters <- c(
  "01-introduction.qmd",
  "02-interrupted-time-series.qmd",
  "03-basic-diff-in-diff.qmd",
  "04-classical-synthetic-control.qmd",
  "05-augmented-synthetic-control.qmd",
  "06-synthetic-did.qmd",
  "07-structural-bayesian-ts.qmd",
  "08-synthetic-control-prediction-intervals.qmd",
  "09-bayesian-spatial-sc.qmd",
  "10-staggered-did.qmd",
  "11-matrix-completion-and-ife.qmd",
  "12-gsynth.qmd"
)

# Every chapter sources R/table_helpers.R and reads data/proposition99.rds.
# Scanning the helper too so packages it loads (gt, modelsummary) end up in
# the install cell — the chapter itself never library()s them.
helper_files <- "R/table_helpers.R"

detect_packages <- function(paths) {
  src <- unlist(lapply(paths, readLines, warn = FALSE), use.names = FALSE)
  pull <- function(re) {
    m <- regmatches(src, regexec(re, src))
    out <- vapply(m, function(x) if (length(x) > 1) x[2] else NA_character_, "")
    out[!is.na(out)]
  }
  pkgs <- unique(c(
    pull("library\\(([A-Za-z][A-Za-z0-9.]*)\\)"),
    pull("require\\(([A-Za-z][A-Za-z0-9.]*)\\)"),
    pull("([A-Za-z][A-Za-z0-9.]*)::")
  ))
  setdiff(pkgs, c("base", "stats", "utils", "methods", "graphics", "grDevices"))
}

build_install_chunk <- function(pkgs) {
  # GitHub-only packages (not on CRAN) are installed with remotes::install_github;
  # r-universe-only packages (xsynthdid) get their own install.packages() call;
  # everything else comes from CRAN. dependencies = NA skips Suggests.
  github <- c(augsynth = "ebenmichael/augsynth",
              synthdid = "synth-inference/synthdid")
  runiv  <- c(xsynthdid = "https://skranz.r-universe.dev")
  gh        <- github[names(github) %in% pkgs]
  ru        <- runiv[names(runiv) %in% pkgs]
  cran      <- sort(setdiff(pkgs, c(names(github), names(runiv))))
  cran_list <- paste(sprintf('"%s"', cran), collapse = ", ")
  lines <- c(
    "```{r}",
    "#| label: install-packages",
    "#| message: false",
    "#| warning: false",
    paste0("cran_pkgs <- c(", cran_list, ")"),
    "to_install <- setdiff(cran_pkgs, rownames(installed.packages()))",
    "if (length(to_install)) {",
    "  install.packages(to_install, repos = \"https://cloud.r-project.org\")",
    "}"
  )
  if (length(gh)) {
    lines <- c(lines,
      "if (!requireNamespace(\"remotes\", quietly = TRUE)) {",
      "  install.packages(\"remotes\", repos = \"https://cloud.r-project.org\")",
      "}")
    for (i in seq_along(gh)) {
      lines <- c(lines,
        sprintf(paste0("if (!requireNamespace(\"%s\", quietly = TRUE)) ",
                       "remotes::install_github(\"%s\", dependencies = NA, upgrade = \"never\")"),
                names(gh)[i], gh[[i]]))
    }
  }
  if (length(ru)) {
    for (i in seq_along(ru)) {
      lines <- c(lines,
        sprintf(paste0("if (!requireNamespace(\"%s\", quietly = TRUE)) ",
                       "install.packages(\"%s\", repos = c(\"%s\", \"https://cloud.r-project.org\"))"),
                names(ru)[i], names(ru)[i], unname(ru)[i]))
    }
  }
  c(lines, "```")
}

# Add bibliography + csl to the chapter YAML so citations resolve without a
# project-level _quarto.yml in the bundle.
add_yaml_keys <- function(lines) {
  yaml_close <- which(lines == "---")[2]
  c(
    lines[seq_len(yaml_close - 1)],
    "bibliography: references.bib",
    "csl: apa.csl",
    lines[seq.int(yaml_close, length(lines))]
  )
}

dir.create("downloads", showWarnings = FALSE)

for (chap in chapters) {
  stage <- tempfile("ccm-chap-")
  dir.create(file.path(stage, "R"),    recursive = TRUE)
  dir.create(file.path(stage, "data"), recursive = TRUE)

  file.copy("R/table_helpers.R",      file.path(stage, "R/table_helpers.R"),     overwrite = TRUE)
  file.copy("data/proposition99.rds", file.path(stage, "data/proposition99.rds"), overwrite = TRUE)
  file.copy("references.bib",         file.path(stage, "references.bib"),         overwrite = TRUE)
  file.copy("apa.csl",                file.path(stage, "apa.csl"),                overwrite = TRUE)

  # Chapter 5 ships the purpose-built simulated tobacco panel (a labelled Stata
  # file) so a reader can render the augmented synthetic control chapter
  # standalone without the rest of the book.
  if (chap == "05-augmented-synthetic-control.qmd") {
    file.copy("data/tobacco_sim.dta",
              file.path(stage, "data/tobacco_sim.dta"), overwrite = TRUE)
  }

  # Chapter 6 (synthetic difference-in-differences) shares the Proposition 99
  # panel with chs 1-4 but also reuses chapter 5's simulated tobacco panel for
  # the staggered-adoption demo.
  if (chap == "06-synthetic-did.qmd") {
    file.copy("data/tobacco_sim.dta",
              file.path(stage, "data/tobacco_sim.dta"), overwrite = TRUE)
  }

  # Chapter 9 (was 8) ships the scspill helpers + .cpp kernels + spatial .rda
  # so the standalone bundle can reproduce the Bayesian Spatial SCM without
  # network.
  if (chap == "09-bayesian-spatial-sc.qmd") {
    dir.create(file.path(stage, "R/scspill"), recursive = TRUE)
    scspill_files <- list.files("R/scspill", full.names = TRUE, all.files = TRUE, no.. = TRUE)
    file.copy(scspill_files, file.path(stage, "R/scspill"), overwrite = TRUE)
    file.copy("data/california_smoking.rda",
              file.path(stage, "data/california_smoking.rda"), overwrite = TRUE)
  }

  # Chapter 10 (was 9) ships the CS minimum-wage county panel and the
  # honest_did bridge that connects did::AGGTEobj to HonestDiD.
  if (chap == "10-staggered-did.qmd") {
    file.copy("data/cs_minwage.rds",
              file.path(stage, "data/cs_minwage.rds"), overwrite = TRUE)
    file.copy("R/honest_did.R",
              file.path(stage, "R/honest_did.R"), overwrite = TRUE)
  }

  # Chapter 11 (was 10) ships the CS minimum-wage county panel so a reader
  # can render the IFE/MC chapter standalone without the rest of the book.
  if (chap == "11-matrix-completion-and-ife.qmd") {
    file.copy("data/cs_minwage.rds",
              file.path(stage, "data/cs_minwage.rds"), overwrite = TRUE)
  }

  # Chapter 12 (was 11) ships the same CS minimum-wage county panel so a
  # reader can render the gsynth chapter standalone without the rest of the
  # book.
  if (chap == "12-gsynth.qmd") {
    file.copy("data/cs_minwage.rds",
              file.path(stage, "data/cs_minwage.rds"), overwrite = TRUE)
  }

  pkgs <- detect_packages(c(chap, helper_files))
  body <- readLines(chap, warn = FALSE)
  # Strip the in-site download button — it would render as a broken link
  # inside the standalone bundle.
  body <- body[!grepl("\\(downloads/chapter-[0-9]+\\.zip\\)", body)]
  body <- add_yaml_keys(body)
  yaml_close <- which(body == "---")[2]

  out <- c(
    body[seq_len(yaml_close)],
    "",
    "## Install required packages {.unnumbered}",
    "",
    build_install_chunk(pkgs),
    "",
    body[seq.int(yaml_close + 1, length(body))]
  )
  writeLines(out, file.path(stage, basename(chap)))

  num <- sub("^([0-9]+)-.*$", "\\1", chap)
  zip_rel <- file.path("downloads", sprintf("chapter-%s.zip", num))
  zip_abs <- file.path(normalizePath("downloads", mustWork = TRUE),
                       sprintf("chapter-%s.zip", num))
  if (file.exists(zip_abs)) file.remove(zip_abs)

  old <- setwd(stage)
  tryCatch(
    utils::zip(zip_abs, files = list.files(".", recursive = TRUE)),
    finally = setwd(old)
  )

  message("built ", zip_rel)
}

invisible(NULL)
