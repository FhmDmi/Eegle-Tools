# Within-Session Evaluation

This directory contains scripts for performing within-session classification on BCI databases using the Eegle package for Julia.

## Scripts

### `dbAccP300.jl`
Performs classification on P300 databases.

**Outputs:**
- `names_*.txt`: Subject/session names
- `acc_*.txt`: Classification accuracies

### `dbAccMI.jl`
Performs classification on Motor Imagery databases.

**Outputs:**
- `names_*.txt`: Subject/session names
- `acc_*.txt`: Classification accuracies
- `pval_*.txt`: P-values
- `z_*.txt`: Z-scores
- `performers_*.txt`: Performance categories (good/normal/bad)

## Usage

Set the database path, classifier and options you want and then run the script.

All output files are used in the `results/` directory (located in this folder) for further analysis and benchmarking.