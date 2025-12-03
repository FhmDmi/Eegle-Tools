# YAML Tools

This directory contains utility scripts to update and enrich YAML metadata files for EEG databases in [NY format](https://marco-congedo.github.io/Eegle.jl/dev/documents/NY%20format/) used with [**Eegle.jl**](https://marco-congedo.github.io/Eegle.jl/dev/).

These scripts help you:

- Standardize metadata fields (e.g. sensor types)
- Migrate YAML format versions (`0.0.1` → `0.0.2` → `0.0.3`)
- Attach classification performance to each subject directly in the `.yml` files

---

## Scripts

### `reviewSection.jl`

Generic tool to batch-update any YAML section using a regex pattern.

- Select a database with `selectDB`
- Define the target pattern (e.g. `sensortype: Active Dry electrodes`)
- Define the replacement (e.g. `sensortype: Dry electrodes`)
- Applies the change to all corresponding `.yml` files in the selected database

**Use it for:** small corrections and metadata normalization across many files.

---

### `ymlv2.jl`

Converts YAML files from **format `0.0.1` to `0.0.2`**.

Main actions:

- Cleans comment blocks after the `stim` section  
- For P300 databases:
  - Normalizes label names to lowercase (`NonTarget` → `nontarget`, `Target` → `target`)
- Adds a `trials_per_class` field with trial counts per class
- Updates `formatversion` from `0.0.1` to `0.0.2`

**Input:** list of database paths  
`DBs = ["path/to/db1", ...]`  

This script does **not** use [`Eegle.Database.selectDB`](https://marco-congedo.github.io/Eegle.jl/dev/Database/#Eegle.Database.selectDB) because it is not compatible anymore with `.yml` V1, so you must specify the full paths manually and then read the data with [`Eegle.InOut.readNY`](https://marco-congedo.github.io/Eegle.jl/dev/InOut/#Eegle.InOut.readNY).

**Output:** original `.yml` files overwritten in the new format.

---

### `ymlv3.jl`

Upgrades YAML files from **format `0.0.2` to `0.0.3`** by adding performance metrics.

Main actions:

- Reads accuracies from CSV files in `results/<paradigm>/CSV`
- Matches subjects between CSV and YAML
- Adds a `perf` section to each YAML file
- Updates `formatversion` from `0.0.2` to `0.0.3`

**Perf structure:**

- **MI:**
  - Tasks: e.g. `left_hand-right_hand`, `right_hand-feet`, `feet-both_hands`
  - Classifiers: `MDM`, `ENLR`, `SVM`
- **P300:**
  - Global accuracies with classifiers `MDM`, `ENLR`

Files already containing `perf:` are skipped.
