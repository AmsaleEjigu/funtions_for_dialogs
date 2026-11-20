# legend_n(): a compact legend with group sizes. Add it to any ggplot with +
#
#   ■ Women (n=273)  ■ Men (n=122)
#
# data         : the data the counts come from, ONE ROW PER RESPONDENT
#                (use the unstacked data, or each person is counted once per question)
# var          : the grouping column, with or without quotes: Gender or "Gender".
# answered     : optional columns that must be answered (not missing) for a
#                respondent to be counted, so n matches the people in the graph
# colours      : named colours, e.g. c(Female = "#1F4E79", Male = "#ED7D31").
#                If left out, a set of 6 colours is used, or evenly spaced
#                colours when there are more than 6 groups. Your own colours
#                must cover every group, or you get an error saying which.
# rename       : optional new names, e.g. c(Female = "Women", Male = "Men")
# order        : optional order of the groups in the legend (original values).
#                If left out, the legend follows the order of the groups in
#                the graph's data, so it matches the order of the bars.
# position     : "top", "bottom", "right" or "left". Top and bottom put the
#                items in one row; right and left stack them in a column.
# aesthetic    : "fill" for bars/areas, "colour" for points/lines, or both
# key_size     : size of the coloured squares, in cm
# text_size    : size of the legend text

legend_n <- function(data, var, answered = NULL,
                     colours = NULL, rename = NULL, order = NULL,
                     position = c("bottom","top", "right", "left"),
                     aesthetic = "fill", key_size = 0.3, text_size = 10) {
  position <- match.arg(position)
  in_row <- position %in% c("top", "bottom")

  # var can be written with or without quotes: Gender, "Gender", or a
  # variable holding the name (e.g. group_col <- "Gender")
  if (missing(var))
    stop("Give the grouping column, e.g. legend_n(survey, Gender)", call. = FALSE)
  var_expr <- substitute(var)
  if (is.name(var_expr) && as.character(var_expr) %in% names(data)) {
    var <- as.character(var_expr)
  } else {
    var <- tryCatch(var, error = function(e)
      stop("Column not found in the data: ", deparse(var_expr), call. = FALSE))
    if (!is.character(var) || length(var) != 1)
      stop("var should be one column name, e.g. Gender or \"Gender\"", call. = FALSE)
  }

  if (!is.null(answered)) {
    missing_cols <- setdiff(answered, names(data))
    if (length(missing_cols) > 0)
      stop("Column(s) not found in the data: ", paste(missing_cols, collapse = ", "))
    data <- data[stats::complete.cases(data[answered]), , drop = FALSE]
  }

  legend_theme <- list(
    ggplot2::theme(legend.position  = position,
                   legend.direction = if (in_row) "horizontal" else "vertical",
                   legend.justification = "center",
                   legend.title     = ggplot2::element_blank(),
                   legend.text      = ggplot2::element_text(size = text_size, colour = "grey20"),
                   legend.key.size  = ggplot2::unit(key_size, "cm"),
                   legend.background = ggplot2::element_blank(),
                   legend.key       = ggplot2::element_blank()),
    # Space between legend items (this setting exists from ggplot2 3.5.0)
    if (utils::packageVersion("ggplot2") >= "3.5.0") {
      if (in_row) ggplot2::theme(legend.key.spacing.x = ggplot2::unit(0.4, "cm"))
      else        ggplot2::theme(legend.key.spacing.y = ggplot2::unit(0.2, "cm"))
    }
  )

  # ---- Grouping column: one item per group ----
  if (!var %in% names(data)) stop("Column not found in the data: ", var)

  x <- data[[var]]
  x <- x[!is.na(x)]
  groups <- if (!is.null(order)) order
            else if (is.factor(x)) levels(droplevels(x))
            else sort(unique(as.character(x)))
  n <- sapply(groups, function(g) sum(as.character(x) == g))

  shown <- groups
  if (!is.null(rename)) {
    hit <- groups %in% names(rename)
    shown[hit] <- rename[groups[hit]]
  }
  # Labels are matched to groups by name, so they stay right in any order
  legend_labels <- stats::setNames(paste0(shown, " (n=", n, ")"), groups)

  k <- length(groups)
  if (is.null(colours)) {
    # Up to 6 groups: a fixed set. More groups: evenly spaced colours from
    # the "Dark 3" palette, so every group gets its own colour.
    base <- c( "#ED7D31", "#1F4E79","#7F7F7F", "#FFC000", "#5B9BD5", "#70AD47")
    colours <- if (k <= length(base)) base[seq_len(k)]
               else grDevices::hcl.colors(k, palette = "Dark 3")
    colours <- stats::setNames(colours, groups)
    if (k > 8)
      warning(k, " groups in '", var, "': colours will be hard to tell apart. ",
              "Consider combining groups or using facets.", call. = FALSE)
  } else if (is.null(names(colours))) {
    if (length(colours) < k)
      stop(k, " groups in '", var, "' but only ", length(colours),
           " colours given.", call. = FALSE)
    colours <- stats::setNames(colours[seq_len(k)], groups)
  } else {
    no_colour <- setdiff(groups, names(colours))
    if (length(no_colour) > 0)
      stop("No colour given for: ", paste(no_colour, collapse = ", "), call. = FALSE)
  }

  # Without 'order', the legend follows the order the groups have in the
  # graph's own data, so it matches the bars. With 'order', that order is used.
  scale_args <- list(aesthetics = aesthetic, values = colours,
                     labels = legend_labels, name = NULL)
  if (!is.null(order)) scale_args$breaks <- order

  c(list(do.call(ggplot2::scale_discrete_manual, scale_args)),
    legend_theme)
}
