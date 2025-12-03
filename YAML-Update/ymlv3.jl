# YAML Performance Updater for EEG Databases (v2 to v3)
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com
#
# CONTENTS:
# This script adds classification performance metrics to YAML metadata files
# (format version 0.0.2 to 0.0.3) for EEG databases.
#
# Processing steps:
# 1. Reads accuracy results from CSV files for each database
# 2. Extracts subject-specific performance metrics (MDM, ENLR, SVM)
# 3. Adds 'perf' section to YAML files with accuracy values
# 4. Updates format version from 0.0.2 to 0.0.3
#
# Performance structure:
# - MI paradigm: accuracies per task pair (left_hand-right_hand, right_hand-feet, feet-both_hands)
#                classifiers: MDM, ENLR, SVM (writes available tasks only)
# - P300 paradigm: global accuracies, classifiers: MDM, ENLR
# Output: Modified .yml files with performance metrics

using Eegle, YAML, DelimitedFiles

# Paths configuration
paradigm = "MI"  # or "P300"
csv_path = joinpath(pwd(), "results", paradigm, "CSV");
db_dir = joinpath(homedir(), "work", "OfficeWork", "BCI Databases", "NY", paradigm);
DBs = selectDB(db_dir, :MI);  # or :P300

# Tasks and classifiers
tasks = paradigm == "MI" ? ["left_hand-right_hand", "right_hand-feet", "feet-both_hands"] : ["P300"];
classifiers = paradigm == "MI" ? ["MDM", "ENLR", "SVM"] : ["MDM", "ENLR"];
acc_cols = paradigm == "MI" ? ["accMDM", "accENLR", "accSVM"] : ["accMDM", "accENLR"];

# Precompile regex pattern
version_pattern = r"formatversion:\s*0\.0\.2";

@inbounds for (db, DB) in enumerate(DBs)
    db_name = "$(DB.dbName)-$(DB.condition)"
    files = DBs[db].files
    
    # Load all CSV data for this database
    task_data = Dict(
        task => let csv_file = paradigm == "P300" ? "results_$(db_name).csv" : "results_$(db_name)_$(task).csv",
                    csv_fullpath = joinpath(csv_path, csv_file)
            isfile(csv_fullpath) ? (
                fc = readdlm(csv_fullpath, ',');
                col_indices = [findfirst(==(col), fc[1, :]) for col in acc_cols];
                (data=@view(fc[2:end, :]), acc_idx=col_indices)
            ) : nothing
        end
        for task in tasks if isfile(joinpath(csv_path, paradigm == "P300" ? "results_$(db_name).csv" : "results_$(db_name)_$(task).csv"))
    )
    
    # Process each YAML file
    @inbounds for filename in files
        yml_file = splitext(filename)[1] * ".yml"
        yml_text = read(yml_file, String)
        
        # Skip if already processed
        occursin("perf:", yml_text) && continue
        
        # Extract subject name and find in CSV
        subject_name = splitext(basename(yml_file))[1]
        subject_idx = let idx = nothing
            for task in tasks
                haskey(task_data, task) || continue
                idx = findfirst(==(subject_name), task_data[task].data[:, 1])
                idx !== nothing && break
            end
            idx
        end
        
        # Skip if not found
        if subject_idx === nothing
            @warn "Subject $subject_name not found in CSV for $(db_name)"
            continue
        end
        
        # Build perf section
        perf_text = paradigm == "MI" ?
            "perf:\n" * join([
                "  $(task):\n" * join([
                    "    $(clf): $(task_data[task].data[subject_idx, task_data[task].acc_idx[i]])\n"
                    for (i, clf) in enumerate(classifiers)
                ], "")
                for task in tasks if haskey(task_data, task)
            ], "") :
            "perf:\n" * join([
                "  $(clf): $(task_data["P300"].data[subject_idx, task_data["P300"].acc_idx[i]])\n"
                for (i, clf) in enumerate(classifiers)
            ], "")
        
        # Add perf section at the end and update version
        write(yml_file, replace(rstrip(yml_text) * "\n" * perf_text, version_pattern => "formatversion: 0.0.3"))
    end
end