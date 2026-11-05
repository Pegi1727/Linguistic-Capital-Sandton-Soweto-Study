#!/usr/bin/env Rscript
# Reproducible analysis: Linguistic Capital or Linguistic Barrier?
# Usage: Rscript sandton_soweto_analysis.R [input.csv] [output_directory]
# Required packages: tidyverse, vcd, irr
# Cohen's kappa is not inter-rater reliability here: only one final label exists per record.
suppressPackageStartupMessages({library(tidyverse); library(vcd); library(irr)})
args <- commandArgs(trailingOnly = TRUE)
script_dir <- dirname(normalizePath(sub("^--file=", "", commandArgs()[grep("^--file=", commandArgs())[1]]), mustWork=FALSE))
input <- if (length(args)>=1) args[1] else file.path(script_dir, "interview_dataset_sandton_soweto.csv")
outdir <- if (length(args)>=2) args[2] else file.path(script_dir, "analysis_outputs_r")
dir.create(outdir, showWarnings=FALSE, recursive=TRUE)

raw <- readr::read_csv(input, show_col_types=FALSE)
required <- c("Participant ID", "Raw Response Extract", "Code", "Category", "Final Label")
stopifnot(all(required %in% names(raw)))
dat <- raw %>% mutate(Location=if_else(str_starts(`Participant ID`, "SW-"), "Soweto", "Sandton"),
                      Location=factor(Location, levels=c("Sandton","Soweto")),
                      `Final Label`=factor(str_trim(`Final Label`), levels=c("Standard","Inclusion","Neutral")))
stopifnot(nrow(dat)==60, !anyDuplicated(dat$`Participant ID`), !any(is.na(dat$`Final Label`)))
ct <- table(dat$Location, dat$`Final Label`)
expected_table <- matrix(c(24,3,3,0,30,0), nrow=2, byrow=TRUE,
                         dimnames=list(Location=c("Sandton","Soweto"), Label=c("Standard","Inclusion","Neutral")))
stopifnot(identical(unname(ct), unname(expected_table)))
cat("Contingency table (Location x Final Label):\n"); print(ct)
pearson <- chisq.test(ct, correct=FALSE)
cat(sprintf("Pearson chi-square=%.3f, df=%d, p=%.12g\n", unname(pearson$statistic), unname(pearson$parameter), pearson$p.value))
cat("Expected counts:\n"); print(pearson$expected)
cat("vcd::assocstats (includes Cramer's V):\n"); print(vcd::assocstats(ct))
# 2x3 exact conditional test; this is the Fisher-Freeman-Halton extension.
cat("Fisher-Freeman-Halton exact test (2x3):\n")
print(fisher.test(ct, workspace=2e7))

metrics <- function(x) {
  p <- as.numeric(x[x>0])/sum(x)
  tibble(shannon_nats=-sum(p*log(p)), shannon_bits=-sum(p*log2(p)),
         simpson_diversity=1-sum(p^2), simpson_concentration=sum(p^2))
}
diversity <- dat %>% count(Location, `Final Label`) %>%
  tidyr::complete(Location, `Final Label`, fill=list(n=0)) %>%
  group_by(Location) %>% summarise(metrics(setNames(n, as.character(`Final Label`))), .groups="drop")
cat("Diversity indices:\n"); print(diversity)
# irr::kappa2 requires paired ratings. Self-pair validates the implementation only.
self_ratings <- tibble(r1=dat$`Final Label`, r2=dat$`Final Label`)
cat("irr::kappa2 self-agreement (NOT an inter-rater reliability estimate):\n")
print(irr::kappa2(self_ratings, weight="unweighted"))
set.seed(20250308)
perm_kappa <- replicate(2000, irr::kappa2(tibble(r1=dat$`Final Label`, r2=sample(dat$`Final Label`)), weight="unweighted")$value)
cat(sprintf("Permutation baseline (n=2000, seed=20250308): mean=%.3f; 2.5-97.5%%=[%.3f, %.3f]\n", mean(perm_kappa), quantile(perm_kappa,.025), quantile(perm_kappa,.975)))
cat("Caution: 4/6 expected Pearson counts are <5; prefer exact-test result for sparse table inference.\n")

journal_theme <- theme_classic(base_size=12, base_family="sans") +
  theme(plot.title=element_text(face="bold", size=13), legend.position="top",
        axis.title=element_text(face="plain"), panel.grid=element_blank())
cols <- c(Standard="#355C7D", Inclusion="#2A9D8F", Neutral="#E9C46A")
# Figure 1: ideology distribution
g1 <- ggplot(dat, aes(x=Location, fill=`Final Label`)) +
  geom_bar(position=position_dodge(width=.82), width=.72, color="white") +
  geom_text(stat="count", aes(label=after_stat(count)), position=position_dodge(width=.82), vjust=-.35, size=3.5) +
  scale_fill_manual(values=cols, drop=FALSE) + labs(title="Figure 1. Ideological distribution by study site", x=NULL, y="Participants (n)", fill="Final label") + journal_theme
# Figure 2: supplied coded thematic categories
theme_dat <- dat %>% count(Location, Category)
g2 <- ggplot(theme_dat, aes(x=Category, y=n, fill=Location)) +
  geom_col(position=position_dodge(width=.82), width=.72, color="white") +
  geom_text(aes(label=n), position=position_dodge(width=.82), vjust=-.35, size=3.2) +
  scale_fill_manual(values=c(Sandton="#355C7D", Soweto="#D1495B")) +
  labs(title="Figure 2. Thematic dimensions by study site", x=NULL, y="Participants (n)", fill=NULL) +
  journal_theme + theme(axis.text.x=element_text(angle=15, hjust=1))
# Figure 3: conceptual, non-causal schematic
nodes <- tibble(x=c(1.5,5,8.5), y=2, label=c("Socio-economic context\nSandton / Soweto", "Accent, identity &\nlinguistic resources", "Ideological positioning\nStandard / Inclusion / Neutral"))
g3 <- ggplot() +
  geom_rect(data=nodes, aes(xmin=x-1.35,xmax=x+1.35,ymin=y-.65,ymax=y+.65), fill=c("#E7EEF5","#E5F3F0","#FFF1D6"), color="#34495E", linewidth=.7) +
  geom_text(data=nodes, aes(x=x,y=y,label=label), size=3.7) +
  geom_segment(aes(x=2.9,xend=3.6,y=2,yend=2), arrow=arrow(length=unit(.16,"inches")), linewidth=.7) +
  geom_segment(aes(x=6.4,xend=7.1,y=2,yend=2), arrow=arrow(length=unit(.16,"inches")), linewidth=.7) +
  annotate("text",x=5,y=.8,label="Interpretive framework; arrows do not imply causal identification.",size=3.2,color="#555555") +
  coord_cartesian(xlim=c(0,10),ylim=c(.4,3.4),clip="off") +
  labs(title="Figure 3. Conceptual framework for comparative interpretation") + journal_theme + theme(axis.title=element_blank(),axis.text=element_blank(),axis.ticks=element_blank(),axis.line=element_blank(),panel.border=element_blank(),plot.title=element_text(hjust=.5))
for (i in 1:3) {
  g <- get(paste0("g",i))
  ggsave(file.path(outdir,paste0("figure",i,"_",c("ideological_distribution","thematic_dimensions","theoretical_framework")[i],".png")),g,width=ifelse(i==2,8.2,7.2),height=4.8,dpi=350,bg="white")
  ggsave(file.path(outdir,paste0("figure",i,"_",c("ideological_distribution","thematic_dimensions","theoretical_framework")[i],".pdf")),g,width=ifelse(i==2,8.2,7.2),height=4.8,device=cairo_pdf,bg="white")
}
readr::write_csv(diversity,file.path(outdir,"diversity_indices.csv"))
cat("Figures and diversity table saved to:", normalizePath(outdir), "\n")
