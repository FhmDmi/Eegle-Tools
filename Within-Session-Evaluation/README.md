# Within-Session Evaluation

This directory contains scripts for performing within-session classification evaluation on the **FII BCI Corpus** databases using the [**Eegle.jl**](https://marco-congedo.github.io/Eegle.jl/dev/) package.

## Scripts

### `dbAccP300.jl`

Performs within-session classification on P300 databases.

**Outputs:**

- `names_*.txt` – Subject/session identifiers
- `acc_*.txt` – Classification accuracies

### `dbAccMI.jl`

Performs within-session classification on Motor Imagery (MI) databases.

**Outputs:**

- `names_*.txt` – Subject/session identifiers  
- `acc_*.txt` – Classification accuracies  
- `pval_*.txt` – P-values (statistical significance of performance)  
- `z_*.txt` – Z-scores  
- `performers_*.txt` – Performance categories (good / neither / bad)

## Usage

1. Set:
   - the database path,
   - the classifier,
   - and the desired options (e.g., subjects, sessions, features, etc.)
2. Run the corresponding script (`dbAccMI.jl` or `dbAccP300.jl`) in Julia.

All output files are then used by the [`results`](./results) tools within this directory for further analysis, benchmarking, and visualization.
