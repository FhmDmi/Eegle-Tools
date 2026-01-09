# Converters

## Overview

This directory contains the conversion scripts used to build the **FII BCI Corpus**. These scripts are designed to standardize, annotate, and curate various Brain-Computer Interface (BCI) databases for research purposes. This project is part of a collaborative effort between the **University Federico II of Naples** and **University Grenoble Alpes**.

The conversion workflow is divided into two main stages:

1.  **RAW to CSV:** Converting raw data (from MOABB or original repositories) into a standardized CSV format.
2.  **CSV to NY:** Converting the standardized CSV files into the NY format (specifically designed for BCI data handling).

## Directory Structure

The folder is organized as follows:

* **`RAWtoCSV/`**: Contains scripts to convert raw data to CSV.
    * `MI/`: Motor Imagery datasets.
    * `P300/`: P300 datasets.
    * `ConvTools.py`: Helper functions for transformation and standardization.
* **`CSVtoNY/`**: Contains scripts to convert CSV data to NY format (mirrors the structure of `RAWtoCSV`).

---

## 1. RAW to CSV

The goal of this stage is to convert all datasets into a unified CSV format. Each database is processed using a specific Jupyter Notebook.

### The Standardized CSV Format

The output CSV files follow a strict structure:
* **Columns:** Time samples, EEG channels, and stimulation tags.
* **Rows:** Raw data samples.

### Conversion Strategy

For each database, the following workflow is applied:

1.  **Analysis:** Analyze the raw dataset structure (e.g., subject sessions).
2.  **Processing:** Apply necessary treatments to reach the standardized format.
3.  **Automation:** Once established on a test set, the process is looped over all subjects and sessions.
4.  **Condition Splitting:** If a database includes several experimental conditions, it is split into separate databases (one per condition).

### Common Treatments

While specific treatments are detailed in the **first cell of each notebook** when needed, the following curation steps are common to all databases:

* **Unit Conversion:** Data is converted to Volts (V) to facilitate compatibility (e.g., with MNE).
* **Downsampling:** Signals are downsampled to an integer below 256Hz (if original sampling rate is above this integer); anti-aliasing filters are applied to preserve the integrity of the data.
* **Channel Selection:** Removal of non-EEG channels (EOG, EMG, reference, ground).
* **Concatenation:** Runs from the same session with identical experimental conditions are concatenated.
* **Cleanup:** Removal of `NaN` and zero values at the beginning and end of recordings.
* **Class Re-labeling:** Triggers are mapped to a standardized scheme. Regarding stimulation tags, **only the first sample of an occurring event is labeled**:

| P300 | Motor Imagery (MI) | Label ID |
| :--- | :--- | :---: |
| Non-Target | Left Hand | `1` |
| Target | Right Hand | `2` |
| | Feet | `3` |
| | Rest | `4` |
| | Both Hands | `5` |
| | Tongue | `6` |

*Helper functions to facilitate these transformations are available in `RAWtoCSV/ConvTools.py`.*

> For further details on the treatment applied to each databases, please see [Treatment MI](https://marco-congedo.github.io/Eegle.jl/dev/documents/Treatment%20MI/) and [TreatmentP300](https://marco-congedo.github.io/Eegle.jl/dev/documents/Treatment%20P300/).

---

## 2. CSV to NY

The scripts in this folder convert the standardized CSV data into the **NY format**, which is optimized for storage and analysis in multiple programming languages.

Since standardization occurs during the *RAW to CSV* phase, the *CSV to NY* scripts are consistent across databases. Their primary role is to:

1.  Generate the YAML metadata file.
2.  Convert data to **Float32** and **Microvolts (µV)** (the standard for BCI analysis).
3.  Separate the EEG data from the stimulation tags.

---

## The NY Format Specification

The NY format is specifically conceived for efficient BCI data handling. It consists of two files sharing the same name but different extensions:

### 1. The `.npz` File

A standard NumPy compressed archive containing two arrays:

* **`X`**: The $N \times T$ EEG data matrix (Float32, µV), where $N$ is the number of samples and $T$ is the number of channels.
* **`stim`**: The stimulation vector containing the $T$ tags for the samples.

*Note: This format is natively supported in Python (NumPy) and readable in Julia via `NPZ.jl`.*

### 2. The `.yml` File

Contains the metadata offering a comprehensive description of the dataset's characteristics.

> For further details on the rationale and full documentation, please refer to the [**FII BCI Corpus Documentation**](https://marco-congedo.github.io/Eegle.jl/dev/documents/FII%20BCI%20Corpus%20Overview/).

## How to Contribute

We welcome contributions to expand the FII BCI Corpus! If you would like to propose or add a new database to the repository, please follow one of the steps below:

### 1. Open an Issue
You can open an issue directly on this GitHub repository. Please provide details about the database you wish to add, its source, and any relevant documentation.

### 2. Contact the Team
Alternatively, you can reach out directly to the project maintainers:

* **Fahim Doumi**: fahim _dot_ doumi _dot_ pro _at_ gmail _dot_ com
* **Marco Congedo**: marcocongedo _at_ gmail _dot_ com
* **Antonio Esposito**: anthony _dot_ esp _at_ live _dot_ it
