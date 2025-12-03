# Eegle-Tools

This repository contains scripts, utilities, and workflows for working with the [**Eegle.jl**](https://marco-congedo.github.io/Eegle.jl/dev/) package and the **FII BCI Corpus** for Motor Imagery (MI) and [P300](https://zenodo.org/records/17791298).

It provides reproducible tools for Brain-Computer Interface (BCI) research in both **Python** and **Julia**:

-   **Data Preparation:**
    -   Conversion of databases into the [NY format](https://marco-congedo.github.io/Eegle.jl/dev/documents/NY%20format/)
    -   Updating `.yml` metadata files
-   **EEG Processing & Analysis:**
    -   EEG preprocessing
    -   Feature extraction
    -   Machine learning experiments
    -   Results analysis and plot creation for visualization
-   **FII BCI Corpus Integration:**
    -   Python scripts for data reading, processing, and classification using the **FII BCI Corpus**

## Index

|            Name             |                     Content                      |
|:---------------------------:|:-------------------------------------------------:|
| [`Within-Session-Evaluation`](./Within-Session-Evaluation) | Within-session cross-validation pipelines and integrated result analysis tools for the **FII BCI Corpus** (MI and P300). |

---

## License

MIT License  
Copyright (c) 2025, Fahim Doumi  
CeSMA (University of Naples Federico II), Naples, Italy
