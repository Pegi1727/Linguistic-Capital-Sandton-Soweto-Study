# Linguistic Capital or Linguistic Barrier? A Comparative Analysis of Accent, Identity, and Socio-Economic Stratification in Sandton and Soweto

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23970129.svg)](https://doi.org/10.5281/zenodo.23970129)
[![License: CC BY 4.0](https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by/4.0/)

Official open-science repository for the comparative mixed-methods study investigating language ideologies, accent perceptions, and socio-economic stratification in post-apartheid South African schools (Sandton vs. Soweto).

---

## 1. Author & Metadata
* **Author:** Pegah Merrikhi (Independent Researcher, PhD in TESOL / Applied Linguistics)
* **Target Journal:** *Language Matters: Studies in the Languages of Southern Africa* (Routledge / Taylor & Francis)
* **Zenodo DOI:** [10.5281/zenodo.23970129](https://doi.org/10.5281/zenodo.23970129)
* **GitHub Repository:** [https://github.com/Pegi1727/Linguistic-Capital-Sandton-Soweto-Study](https://github.com/Pegi1727/Linguistic-Capital-Sandton-Soweto-Study)

---

## 2. Abstract
In post-apartheid South Africa, the operationalization of English as the primary Language of Learning and Teaching (LoLT) intersects acutely with persistent socio-economic stratification and linguistic gatekeeping. Drawing on Bourdieu’s sociological framework of linguistic capital and symbolic violence alongside contemporary translanguaging theory, this comparative study investigates how educator ideologies, accent perceptions, and material ecologies diverge across two historically disparate educational settings in Gauteng: an elite, high-resource independent school environment in Sandton ($n = 30$) and an under-resourced public township schooling context in Soweto ($n = 30$) ($N = 60$). Employing a mixed-methods thematic discourse analysis, findings reveal a stark ideological cleavage ($\chi^2(2) = 49.09, p < .001, \text{Cramér’s } V = .91$). In Sandton, an overwhelming consensus ($80.0\%$) adheres to Standard Language Ideology (SLI), weaponizing standardized accent as a mechanism of symbolic exclusion. Conversely, Soweto educators exhibit an absolute convergence ($100.0\%$) around inclusionary translanguaging, utilizing multilingual repertoires to mitigate structural disadvantage and affective anxiety. The study argues that rigid Standard Language Ideologies function as a structural barrier, reinforcing apartheid-era spatial and economic divides under the guise of linguistic meritocracy.

**Keywords:** Linguistic capital, Standard Language Ideology, translanguaging, accentism, Black South African English, socio-economic stratification, symbolic violence, South Africa.

---

## 3. Methodology & Statistical Formulas

### Research Design
* **Approach:** Convergent mixed-methods design integrating quantified ideological coding with Reflexive Thematic Analysis (Braun & Clarke, 2021).
* **Sample Size:** $N = 60$ in-service secondary educators ($n = 30$ elite Sandton school; $n = 30$ Soweto public township school).
* **Data Collection:** Semi-structured audio-recorded interviews (45–75 minutes) and non-participant classroom observations ($30$ sessions, 60 minutes each).

### Statistical Procedures & Formulas
1. **Pearson Chi-Square Test of Independence:**
   $$\chi^2 = \sum \frac{(O - E)^2}{E}$$
   *Yielded a highly significant association between research site and ideological label ($\chi^2(2) = 49.09, p < .001$).*

2. **Cramér’s V (Effect Size):**
   $$V = \sqrt{\frac{\chi^2}{N(\min(k-1, r-1))}}$$
   *Yielded an exceptionally strong effect size ($\text{Cramér’s } V = .91$).*

3. **Normalized Shannon Entropy ($H$):**
   $$H = -\sum_{i=1}^{k} p_i \log_k(p_i)$$
   *(Used to measure ideological dispersion across sites on a $0\text{–}1$ scale).*

4. **Simpson’s Index of Diversity ($1 - D$):**
   $$D = 1 - \sum \left(\frac{n_i(n_i-1)}{N(N-1)}\right)$$

---

## 4. Key Results & Summary Table

### Site by Final Label Cross-Tabulation ($N = 60$)
| Educational Site | Standard Language Ideology (SLI) | Inclusionary / Translanguaging | Neutral / Pragmatic | Total |
| :--- | :---: | :---: | :---: | :---: |
| **Sandton (High-Resource)** | $24\ (80.0\%)$ | $3\ (10.0\%)$ | $3\ (10.0\%)$ | **$30\ (100.0\%)$** |
| **Soweto (Under-Resourced)** | $0\ (0.0\%)$ | $30\ (100.0\%)$ | $0\ (0.0\%)$ | **$30\ (100.0\%)$** |
| **Aggregate ($N = 60$)** | $24\ (40.0\%)$ | $33\ (55.0\%)$ | $3\ (5.0\%)$ | **$60\ (100.0\%)$** |

---

## 5. Repository Structure & Figures

The repository organizes all supplementary files, figures, and data in the following layout:
```text
Linguistic-Capital-Sandton-Soweto-Study/
│
├── README.md
├── figures/
│   ├── figure1_ideological_distribution.png   # Distribution of Language Ideologies (Sandton vs. Soweto)
│   ├── figure2_thematic_dimensions.png        # Multidimensional Analytical Coding Matrix
│   ├── figure3_theoretical_framework.png      # Bourdieu's Capital & Translanguaging Intersection
│   └── graphic_abstract_sandton_soweto.png    # Visual Abstract of the Mixed-Methods Study
└── data/                                      # Coded transcripts & supplementary matrices
---------------------

APA Style:

Merrikhi, P. (2026). Linguistic Capital or Linguistic Barrier? A Comparative Analysis of Accent, Identity, and Socio-Economic Stratification in Sandton and Soweto [Data set and pre-print]. Zenodo. https://doi.org/10.5281/zenodo.23970129
----------------------------
BibTeX:

bibtex
@misc{merrikhi2026linguistic,
  author       = {Merrikhi, Pegah},
  title        = {Linguistic Capital or Linguistic Barrier? A Comparative Analysis of Accent, Identity, and Socio-Economic Stratification in Sandton and Soweto},
  year         = {2026},
  publisher    = {Zenodo},
  doi          = {10.5281/zenodo.23970129},
  url          = {https://doi.org/10.5281/zenodo.23970129}
}
Maintained by Pegah Merrikhi.
