#!/usr/bin/env Rscript
# Publication-ready figures for the Sandton–Soweto interview dataset.
# Input:  /mnt/data/interview_dataset_sandton_soweto.csv
# Output: figure1_ideological_distribution.png
#         figure2_thematic_dimensions.png
#         figure3_theoretical_framework.png
# Counts and percentages describe the supplied coding only; they do not establish
# causal effects. Site is derived from Participant ID prefixes (S- / SW-).

options(stringsAsFactors = FALSE, scipen = 999)

required_packages <- c("tidyverse", "vcd")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]
if (length(missing_packages)) {
  stop(
    "Missing required R package(s): ", paste(missing_packages, collapse = ", "),
    ". Install with install.packages(c(",
    paste(sprintf("'%s'", missing_packages), collapse = ", "), ")).",
    call. = FALSE
  )
}
suppressPackageStartupMessages({
  library(tidyverse)
  library(vcd)
})

INPUT_FILE <- "/mnt/data/interview_dataset_sandton_soweto.csv"
OUTPUT_DIR <- dirname(INPUT_FILE)

# Restrained, color-blind-conscious journal palette.
PAL <- c(
  "Standard"  = "#356A8A",
  "Inclusion" = "#D17A32",
  "Neutral"   = "#8A8F98"
)
SITE_PAL <- c("Sandton" = "#356A8A", "Soweto" = "#D17A32")

journal_theme <- function(base_size = 12, base_family = "sans") {
  theme_classic(base_size = base_size, base_family = base_family) %+replace%
    theme(
      plot.title = element_text(face = "bold", size = rel(1.25), color = "#20252B"),
      plot.subtitle = element_text(size = rel(0.95), color = "#4F5963", margin = margin(b = 10)),
      plot.caption = element_text(size = rel(0.78), color = "#60666D", hjust = 0),
      axis.title = element_text(face = "bold", color = "#30363B"),
      axis.text = element_text(color = "#33383D"),
      axis.line = element_line(color = "#50565C", linewidth = 0.4),
      axis.ticks = element_line(color = "#50565C", linewidth = 0.35),
      legend.title = element_text(face = "bold"),
      legend.position = "bottom",
      panel.grid.major.y = element_line(color = "#E6E8EA", linewidth = 0.35),
      panel.grid.minor = element_blank(),
      plot.margin = margin(12, 15, 10, 12)
    )
}

save_figure <- function(plot, filename, width, height) {
  path <- file.path(OUTPUT_DIR, filename)
  tryCatch(
    ggsave(path, plot = plot, width = width, height = height, units = "in",
           dpi = 600, bg = "white", limitsize = TRUE),
    error = function(e) stop("Could not save '", path, "': ", conditionMessage(e), call. = FALSE)
  )
  if (!file.exists(path) || file.info(path)$size <= 0) {
    stop("Figure export failed or produced an empty file: ", path, call. = FALSE)
  }
  message("Saved: ", path)
  invisible(path)
}

run_figures <- function() {
  if (!file.exists(INPUT_FILE)) stop("Input CSV not found: ", INPUT_FILE, call. = FALSE)
  dir.create(OUTPUT_DIR, recursive = TRUE, showWarnings = FALSE)

  dat <- readr::read_csv(INPUT_FILE, show_col_types = FALSE,
                         progress = FALSE, name_repair = "minimal")
  required_columns <- c("Participant ID", "Category", "Final Label")
  absent <- setdiff(required_columns, names(dat))
  if (length(absent)) {
    stop("Input CSV is missing required column(s): ", paste(absent, collapse = ", "), call. = FALSE)
  }
  if (nrow(dat) == 0) stop("Input CSV contains no records.", call. = FALSE)

  dat <- dat %>%
    mutate(
      participant_id = as.character(`Participant ID`),
      category = stringr::str_squish(as.character(Category)),
      label = stringr::str_squish(as.character(`Final Label`)),
      site = case_when(
        str_detect(participant_id, "^SW-") ~ "Soweto",
        str_detect(participant_id, "^S-") ~ "Sandton",
        TRUE ~ NA_character_
      )
    )
  if (anyNA(dat$site)) {
    bad_ids <- dat$participant_id[is.na(dat$site)]
    stop("Could not assign site from Participant ID for: ", paste(bad_ids, collapse = ", "), call. = FALSE)
  }
  if (anyNA(dat$label) || any(dat$label == "") || anyNA(dat$category) || any(dat$category == "")) {
    stop("Category and Final Label must be present for every record.", call. = FALSE)
  }
  unexpected <- setdiff(unique(dat$label), names(PAL))
  if (length(unexpected)) {
    stop("Unexpected Final Label value(s): ", paste(unexpected, collapse = ", "),
         ". Add corresponding palette colors before plotting.", call. = FALSE)
  }
  site_levels <- c("Sandton", "Soweto")
  label_levels <- c("Standard", "Inclusion", "Neutral")
  dat <- dat %>% mutate(site = factor(site, levels = site_levels),
                        label = factor(label, levels = label_levels))

  # Use vcd's association summary as a descriptive audit; do not imply causality.
  tab <- table(dat$site, dat$label)
  if (nrow(tab) > 1 && ncol(tab) > 1) {
    assoc <- vcd::assocstats(tab)
    cramers_v <- unname(assoc$cramer)
    message(sprintf("Descriptive site-by-label Cramer's V = %.3f (n = %d).", cramers_v, nrow(dat)))
  }

  # Figure 1 — overall ideological distribution (n and share of all records).
  dist <- dat %>% count(label, .drop = FALSE, name = "n") %>%
    mutate(percent = 100 * n / sum(n), label_text = sprintf("%d  (%.1f%%)", n, percent))
  p1 <- ggplot(dist, aes(x = label, y = n, fill = label)) +
    geom_col(width = 0.68, color = "white", linewidth = 0.45) +
    geom_text(aes(label = label_text), vjust = -0.45, size = 3.8, color = "#252A2E") +
    scale_fill_manual(values = PAL, drop = FALSE) +
    scale_y_continuous(expand = expansion(mult = c(0, 0.16)), breaks = scales::pretty_breaks()) +
    labs(title = "Ideological Distribution", subtitle = "Coded interview responses across both study sites",
         x = NULL, y = "Participants (n)",
         caption = "Percentages use all records as the denominator; categories follow the supplied Final Label coding.") +
    journal_theme() + theme(legend.position = "none")
  save_figure(p1, "figure1_ideological_distribution.png", 7.2, 5.0)

  # Figure 2 — site-specific thematic dimensions, as percent within each site.
  by_site <- dat %>% count(site, label, .drop = FALSE, name = "n") %>%
    group_by(site) %>% mutate(site_n = sum(n), percent = 100 * n / site_n,
                              label_text = if_else(n > 0, sprintf("%d  (%.1f%%)", n, percent), "")) %>%
    ungroup()
  p2 <- ggplot(by_site, aes(x = label, y = percent, fill = site)) +
    geom_col(position = position_dodge(width = 0.78), width = 0.68,
             color = "white", linewidth = 0.35) +
    geom_text(aes(label = label_text), position = position_dodge(width = 0.78),
              vjust = -0.38, size = 3.2, color = "#252A2E") +
    scale_fill_manual(values = SITE_PAL, drop = FALSE) +
    scale_y_continuous(limits = c(0, 115), breaks = seq(0, 100, 20),
                       labels = function(x) paste0(x, "%"), expand = expansion(mult = c(0, 0))) +
    labs(title = "Thematic Dimensions across Sandton and Soweto",
         subtitle = "Distribution of supplied ideological labels within each site",
         x = NULL, y = "Within-site share of participants", fill = "Site",
         caption = "Site is inferred from participant ID prefix (S- = Sandton; SW- = Soweto). Percentages are descriptive.") +
    journal_theme() + theme(panel.grid.major.y = element_line(color = "#E6E8EA", linewidth = 0.35))
  save_figure(p2, "figure2_thematic_dimensions.png", 8.2, 5.5)

  # Figure 3 — conceptual/comparative map of observed site profiles.
  # Arrows are descriptive links between site samples and their observed coding profile,
  # not estimates of causal influence. Theoretical interpretation should be developed
  # in the manuscript and is intentionally not asserted by the diagram.
  profile <- by_site %>%
    mutate(label_chr = as.character(label)) %>%
    select(site, label_chr, n, percent) %>%
    pivot_wider(names_from = label_chr, values_from = c(n, percent), values_fill = 0)
  getv <- function(site_name, col) {
    z <- profile %>% filter(as.character(site) == site_name) %>% pull(all_of(col))
    if (length(z) == 0) 0 else as.numeric(z[[1]])
  }
  node_text <- function(site_name) {
    total <- sum(dat$site == site_name)
    sprintf("%s\n(n = %d)", site_name, total)
  }
  profile_text <- function(site_name) {
    sprintf("Observed coding profile\nStandard: %d (%.1f%%)\nInclusion: %d (%.1f%%)\nNeutral: %d (%.1f%%)",
            getv(site_name, "n_Standard"), getv(site_name, "percent_Standard"),
            getv(site_name, "n_Inclusion"), getv(site_name, "percent_Inclusion"),
            getv(site_name, "n_Neutral"), getv(site_name, "percent_Neutral"))
  }
  nodes <- tibble(
    x = c(1.1, 1.1, 3.0, 3.0), y = c(2.25, 0.75, 2.25, 0.75),
    text = c(node_text("Sandton"), node_text("Soweto"), profile_text("Sandton"), profile_text("Soweto")),
    kind = c("Sandton", "Soweto", "profile", "profile")
  )
  arrows <- tibble(x = c(1.5, 1.5), y = c(2.25, 0.75), xend = c(2.35, 2.35), yend = c(2.25, 0.75),
                   site = factor(c("Sandton", "Soweto"), levels = site_levels))
  p3 <- ggplot() +
    geom_segment(data = arrows, aes(x = x, y = y, xend = xend, yend = yend, color = site),
                 arrow = grid::arrow(length = grid::unit(0.16, "inches"), type = "closed"),
                 linewidth = 0.8, show.legend = FALSE) +
    geom_label(data = nodes %>% filter(kind != "profile"), aes(x = x, y = y, label = text, fill = kind),
               color = "white", fontface = "bold", size = 4.4, label.size = 0,
               label.padding = grid::unit(0.22, "inches"), lineheight = 1.05) +
    geom_label(data = nodes %>% filter(kind == "profile"), aes(x = x, y = y, label = text),
               fill = "#F2F4F5", color = "#252A2E", fontface = "plain", size = 3.7,
               label.size = 0.35, label.r = grid::unit(0.08, "inches"),
               label.padding = grid::unit(0.22, "inches"), lineheight = 1.15) +
    scale_fill_manual(values = SITE_PAL) + scale_color_manual(values = SITE_PAL) +
    coord_cartesian(xlim = c(0.45, 3.75), ylim = c(0.12, 2.9), clip = "off") +
    annotate("text", x = 2.0, y = 2.72, label = "Descriptive comparison of coded interview responses",
             size = 4.1, fontface = "bold", color = "#30363B") +
    labs(title = "Theoretical Framework: Site and Observed Thematic Profiles",
         subtitle = "A descriptive map of the sample grouping and supplied coding pattern",
         caption = "Arrows indicate sample-to-profile organization only—not causation. Site labels derive from participant IDs; percentages are within site.") +
    journal_theme() + theme(axis.title = element_blank(), axis.text = element_blank(),
                            axis.ticks = element_blank(), axis.line = element_blank(),
                            panel.grid = element_blank(), legend.position = "none",
                            plot.margin = margin(15, 18, 12, 18))
  save_figure(p3, "figure3_theoretical_framework.png", 10.2, 5.8)

  message("Completed all three publication-resolution figures.")
  invisible(list(figure1 = p1, figure2 = p2, figure3 = p3, data = dat))
}

tryCatch(
  run_figures(),
  error = function(e) {
    message("ERROR: ", conditionMessage(e))
    quit(status = 1)
  }
)
