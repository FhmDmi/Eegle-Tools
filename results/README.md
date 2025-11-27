# Results

This section of the repository contains all the tools and files needed to observe and analyze results from the `WithinSessionEvaluation` folder in the same GitHub repository.

## Repository Structure

This section is organized into three main folders:

- `raw/` - Raw results (.txt)
- `MI/` - Motor Imagery analyses
- `P300/` - P300 analyses

Scripts and a general benchmark file are available directly in this section:

**Scripts:**

- `csvTable.jl` - Generates CSV tables from raw files
- `mdTable.jl` - Creates Markdown benchmarks per task
- `findThreshold.jl` - Analyzes performance thresholds (MI only)
- `findThreshold.jl` - Analyzes bad performers (MI only)


**`benchmark.md`:**

- General benchmark with complete explanation of analysis procedures and summary of averages per database according to models and tasks

---

## `raw/` Folder

Contains all raw results (`.txt` files) obtained via scripts from the `WithinSessionEvaluation` folder, organized in two subfolders: `MI/` and `P300/`.

For MI, results are further organized by task (e.g., right_hand_vs_feet).

### File Types (MI only)

For each MI task, the following files are generated:

| File | Type | Description |
|------|------|-------------|
| `names_$(DB.dbName)-$(DB.condition).txt` | `Vector{String}` | Names of analyzed subjects |
| `acc_$(clf)_$(DB.dbName)-$(DB.condition).txt` | `Vector{Float64}` | Accuracy for each subject |
| `performers_$(clf)_$(DB.dbName)-$(DB.condition).txt` | `Vector{Symbol}` | Categorized performance (`:g` = good, `:b` = bad, `:n` = neutral) |
| `pval_$(clf)_$(DB.dbName)-$(DB.condition).txt` | `Vector{Float64}` | P-values from statistical test |
| `z_$(clf)_$(DB.dbName)-$(DB.condition).txt` | `Vector{Float64}` | Z-scores for statistical significance |

> **Note:** These files are used by the `csvTable.jl` script to generate consolidated CSV tables.

### MI vs P300 Difference

**Only MI contains statistical test results** (p-values, z-scores, performers).

**Why doesn't P300 have statistical tests?**

Classes in P300 are imbalanced (5:1 non-target:target ratio). Bayles's test cannot work in this context because it requires:

- A `CVresult` structure obtained via the `crval` method
- A comparison of the distribution of average binary error losses
- A specified chance level to test whether performance is superior to chance

With imbalanced classes, the chance level is not 50% and Bayles's test (Bayles et al., 2020) cannot be reliably applied.

---

## `MI/` Folder (Motor Imagery)

Contains consolidated analyses for Motor Imagery paradigms in two subfolders: `CSV/` and `MD/`.

### `CSV/` Subfolder

Contains consolidated CSV tables per database and task.

**CSV Contents:**

- Accuracies per subject
- Performers (`:g`, `:b`, `:n`)
- P-values
- Z-scores
- Results for each evaluated model

### `MD/` Subfolder

Contains analysis files:

**`benchmark_[task].md`**

- **Associated script:** `mdTable.jl`
- **Content:** Averages per database according to tasks with all models

**`threshold_[task].txt`**

- **Associated script:** `findThreshold.jl`
- **Content:** Analysis of accuracies with p-value ∈ [0.05, 0.1]
- **Usage:** Determine the accuracy threshold for a subject to be considered a "bad performer"

**`bad_performers_[task].md`**

- **Associated script:** `findBadPerformers.jl`
- **Content:** List of bad performers per database and task with subject name, accuracy, and p-value
- **Usage:** Make a sumamry of "bad performers" for each task, database and models.

---

## `P300/` Folder

Contains consolidated analyses for P300 paradigms in two subfolders: `CSV/` and `MD/`.

### `CSV/` Subfolder

Contains consolidated CSV tables per database and task.

**CSV Contents:**

- Accuracies per subject
- Results for each evaluated model

> **Note:** Unlike MI, P300 CSVs do **not** contain performers, p-values, or z-scores.

### `MD/` Subfolder

Similar structure to MI, but without statistical metrics:

- `benchmark_[task].md`: Averages per database and task
- `benchmark.md`: General benchmark with analysis procedures

---

## Usage

1. **Generate raw results**: Run scripts from the `WithinSessionEvaluation` folder
2. **Consolidate to CSV**: Run `csvTable.jl`
3. **Create benchmarks**: Execute `mdTable.jl`
4. **Analyze thresholds**: Run `findThreshold.jl` (MI only)
5. **Analyze bad performers**: Run `findBadPerformers.jl` (MI only)


