suppressPackageStartupMessages({
  library(gt)
  library(modelsummary)
})

# Transparent background lets the table inherit the page color so it reads
# well in both cosmo (light) and darkly (dark) site themes.
gt_pretty <- function(data, title = NULL, subtitle = NULL,
                      decimals = 3, ...) {
  tbl <- gt::gt(data, ...) |>
    gt::tab_options(
      table.background.color           = "transparent",
      table.border.top.style           = "hidden",
      table.border.bottom.style        = "hidden",
      heading.border.bottom.style      = "hidden",
      column_labels.border.top.style   = "solid",
      column_labels.border.bottom.style = "solid",
      column_labels.border.top.width   = gt::px(1),
      column_labels.border.bottom.width = gt::px(1),
      table_body.hlines.style          = "none",
      row.striping.include_table_body  = TRUE,
      row.striping.background_color    = "rgba(127,127,127,0.06)",
      table.font.size                  = "0.95em",
      data_row.padding                 = gt::px(4)
    ) |>
    gt::fmt_number(columns = tidyselect::where(is.numeric),
                   decimals = decimals,
                   drop_trailing_zeros = TRUE)
  if (!is.null(title) || !is.null(subtitle)) {
    tbl <- gt::tab_header(tbl, title = title, subtitle = subtitle)
  }
  tbl
}

ms_pretty <- function(models, title = NULL, notes = NULL,
                      coef_map = NULL, vcov = NULL,
                      gof_omit = "IC|Log|Adj|F|RMSE", ...) {
  modelsummary::modelsummary(
    models,
    output    = "gt",
    title     = title,
    notes     = notes,
    coef_map  = coef_map,
    vcov      = vcov,
    statistic = "({std.error})",
    stars     = TRUE,
    fmt       = 3,
    gof_omit  = gof_omit,
    ...
  ) |>
    gt::tab_options(
      table.background.color = "transparent",
      table.font.size        = "0.95em",
      data_row.padding       = gt::px(4),
      source_notes.font.size = "0.85em",
      source_notes.padding   = gt::px(6),
      footnotes.font.size    = "0.85em",
      footnotes.padding      = gt::px(6)
    )
}
