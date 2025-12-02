# Eegle-Tools

This repository contains scripts, utilities, and workflows for working with the **Eegle.jl** package and the **BCI FII Corpus**. It provides reproducible tools for EEG preprocessing, feature extraction, machine learning experiments, and results analysis for Brain-Computer Interface (BCI) research.

## Repository Structure

### `Within-Session Evaluation/`

Contains classification scripts that evaluate BCI performance using within-session cross-validation.

**Purpose:** Generate raw classification results for Motor Imagery (MI) and P300 paradigms across multiple databases.

**Outputs:** Raw `.txt` files containing subject names and classification metrics per database.

For further information, see the README file in the directory.

**Outputs:** Raw `.txt` files containing subject names and classification metrics per database. These outputs are used by tools in `Within-Session Evaluation/results/` for further analysis.

**Results and Analysis:** All analysis tools and results are now located in `Within-Session Evaluation/results/`. This includes:

- Processing scripts to transform raw results into structured tables
- Benchmarks and performance analysis
- Threshold analysis and bad performer detection (MI only)
- Complete documentation in `Within-Session Evaluation/results/README.md`

---

## License


MIT License  
Copyright (c) 2025, Fahim Doumi  
CeSMA (University of Naples Federico II), Naples, Italy
