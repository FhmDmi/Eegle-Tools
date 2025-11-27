# Eegle-Tools

This repository contains scripts, utilities, and workflows for working with the **Eegle.jl** package and the **BCI FII Corpus**. It provides reproducible tools for EEG preprocessing, feature extraction, machine learning experiments, and results analysis for Brain-Computer Interface (BCI) research.

## Repository Structure

### `Within-Session Evaluation/`

Contains classification scripts that evaluate BCI performance using within-session cross-validation.

**Purpose:** Generate raw classification results for Motor Imagery (MI) and P300 paradigms across multiple databases.

**Scripts:**

- `MI_classification.jl` - Classifies MI data and outputs accuracies, p-values, z-scores, and performer categories
- `P300_classification.jl` - Classifies P300 data and outputs accuracies

**Outputs:** Raw `.txt` files containing subject names and classification metrics per database.

For further information, see the README file in the directory.

---

### `results/`

Contains tools for processing, analyzing, and visualizing results from the Within-Session Evaluation.

**Purpose:** Transform raw results into structured tables, generate benchmarks, identify performance thresholds, and detect bad performers.

**Key Outputs:**

- `benchmark.md` - Complete analysis summary with database averages per model and task
- Per-task benchmark tables with mean ± std accuracies
- Bad performers reports for quality control

**Note:** MI includes statistical tests (p-values, z-scores) while P300 does not due to class imbalance preventing reliable significance testing.

For further information, see the README file in the directory.

---

## License


MIT License  
Copyright (c) 2025, Fahim Doumi  
CeSMA (University of Naples Federico II), Naples, Italy
