# Bridge between did::AGGTEobj (dynamic event study) and HonestDiD's
# sensitivity-analysis functions. Adapted from Pedro Sant'Anna's
# `honest_did` helper at https://github.com/pedrohcgs/CS_RR.
#
# Usage:
#   attgt <- did::att_gt(...)
#   es    <- did::aggte(attgt, type = "dynamic")
#   hd    <- honest_did(es, e = 0, type = "relative_magnitude",
#                       Mbarvec = seq(0, 2, by = 0.5))

honest_did <- function(...) UseMethod("honest_did")

honest_did.AGGTEobj <- function(es,
                                e = 0,
                                type = c("smoothness", "relative_magnitude"),
                                method = NULL,
                                bound = "deviation from parallel trends",
                                Mvec = NULL,
                                Mbarvec = NULL,
                                monotonicityDirection = NULL,
                                biasDirection = NULL,
                                alpha = 0.05,
                                parallel = FALSE,
                                gridPoints = 10^3,
                                grid.ub = NA,
                                grid.lb = NA,
                                ...) {
  type <- match.arg(type)

  if (es$type != "dynamic") {
    stop("`es` must be a `dynamic` AGGTEobj from did::aggte().")
  }

  # Influence-function-based variance estimator (n^-2 sum of outer products).
  # Use unit count (rows of the influence-function matrix) — NOT panel-row count.
  # A previous version used `length(data[[idname]])` which counts N*T and shrinks
  # the variance by a factor of T^2.
  n <- nrow(es$inf.function$dynamic.inf.func.e)
  V <- t(es$inf.function$dynamic.inf.func.e) %*%
       es$inf.function$dynamic.inf.func.e / n / n

  # Drop the omitted reference period (event time = -1 with universal base).
  eventTimes <- es$egt
  beta       <- es$att.egt
  refperiod  <- -1
  if (refperiod %in% eventTimes) {
    keep       <- eventTimes != refperiod
    beta       <- beta[keep]
    V          <- V[keep, keep, drop = FALSE]
    eventTimes <- eventTimes[keep]
  }

  numPrePeriods  <- sum(eventTimes < 0)
  numPostPeriods <- sum(eventTimes >= 0)

  base_args <- list(
    betahat       = beta,
    sigma         = V,
    numPrePeriods = numPrePeriods,
    numPostPeriods = numPostPeriods,
    alpha         = alpha
  )

  if (type == "smoothness") {
    args <- c(base_args, list(
      Mvec                  = Mvec,
      method                = method,
      bound                 = bound,
      monotonicityDirection = monotonicityDirection,
      biasDirection         = biasDirection,
      parallel              = parallel,
      gridPoints            = gridPoints,
      grid.ub               = grid.ub,
      grid.lb               = grid.lb
    ))
    do.call(HonestDiD::createSensitivityResults, args)
  } else {
    args <- c(base_args, list(
      Mbarvec               = Mbarvec,
      method                = method,
      monotonicityDirection = monotonicityDirection,
      biasDirection         = biasDirection,
      parallel              = parallel,
      gridPoints            = gridPoints,
      grid.ub               = grid.ub,
      grid.lb               = grid.lb
    ))
    do.call(HonestDiD::createSensitivityResults_relativeMagnitudes, args)
  }
}
