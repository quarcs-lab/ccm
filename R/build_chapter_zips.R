# Pre-render hook (registered in _quarto.yml).
# Builds downloads/chapter-NN.zip for each content chapter so readers can
# download a self-contained Quarto bundle that renders standalone via
# `quarto render chapter.qmd` on any machine with R + Quarto.

chapters <- c(
  "01-introduction.qmd",
  "02-interrupted-time-series.qmd",
  "03-rd-in-time.qmd",
  "04-basic-diff-in-diff.qmd",
  "05-classical-synthetic-control.qmd",
  "06-structural-bayesian-ts.qmd",
  "07-bayesian-spatial-sc.qmd"
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
  pkg_list <- paste(sprintf('"%s"', sort(pkgs)), collapse = ", ")
  c(
    "```{r}",
    "#| label: install-packages",
    "#| message: false",
    "#| warning: false",
    paste0("pkgs <- c(", pkg_list, ")"),
    "to_install <- setdiff(pkgs, rownames(installed.packages()))",
    "if (length(to_install)) {",
    "  install.packages(to_install, repos = \"https://cloud.r-project.org\")",
    "}",
    "```"
  )
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

  # Chapter 7 ships the scspill helpers + .cpp kernels + spatial .rda so the
  # standalone bundle can reproduce the Bayesian Spatial SCM without network.
  if (chap == "07-bayesian-spatial-sc.qmd") {
    dir.create(file.path(stage, "R/scspill"), recursive = TRUE)
    scspill_files <- list.files("R/scspill", full.names = TRUE, all.files = TRUE, no.. = TRUE)
    file.copy(scspill_files, file.path(stage, "R/scspill"), overwrite = TRUE)
    file.copy("data/california_smoking.rda",
              file.path(stage, "data/california_smoking.rda"), overwrite = TRUE)
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
