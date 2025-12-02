# Threshold Analysis Script for Marginal Performers
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com

# ? CONTENTS:
# This script identifies subjects with marginal statistical significance
# (0.05 < p-value < 0.1) to determine accuracy thresholds for bad performers.
#
# Computes statistics (mean, std, min, max, median) of accuracies for subjects
# in the marginal significance range, separated by classifier.
#
# Input: CSV files with results per database and task
# Output: Text file with threshold statistics per classifier

using DelimitedFiles, Statistics

# CSV files path
path = joinpath(pwd(), "MI", "CSV") 

# task to analyse 
task = "right_hand-feet"  # or "right_hand-feet" 

# filter files according to task
csv_files = filter(f -> startswith(f, "results_") && endswith(f, ".csv"), readdir(path));

db_files = [(replace(f, "results_" => "", "_$(task).csv" => ""), f) 
     for f in csv_files if occursin("_$(task).csv", f)];

# collect all data first
all_data = [(readdlm(joinpath(path, csv_file), ',')[1, :], 
             readdlm(joinpath(path, csv_file), ',')[2:end, :]) 
            for (db, csv_file) in db_files];

# create threshold_acc with comprehension
threshold_acc = Dict(
    clf => [data[i, findfirst(==("acc$(clf)"), header)] * 100
            for (header, data) in all_data
            for i in 1:size(data, 1)
            if (idx = findfirst(==("pval$(clf)"), header); 
                data[i, idx] isa Number && 0.05 < data[i, idx] < 0.1)]
    for clf in ["MDM", "ENLR", "SVM"]
);

# helper function for stats
format_stats(accs) = """N subjects: $(length(accs))
Mean accuracy: $(round(mean(accs), digits=2))%
Std : $(round(std(accs), digits=2))%
Min accuracy: $(round(minimum(accs), digits=2))%
Max accuracy: $(round(maximum(accs), digits=2))%
Median accuracy: $(round(median(accs), digits=2))%
"""

# save results
output_file = joinpath("MI", "MD", "threshold_analysis_$(task).txt")
open(output_file, "w") do io
    write(io, "Threshold Analysis for Task: $task\n")
    write(io, "Accuracies for subjects with pval between 0.05 and 0.1\n\n")
    
    for clf in ["MDM", "ENLR", "SVM"]
        write(io, "=== $(clf) ===\n")
        write(io, isempty(threshold_acc[clf]) ? 
              "No subjects found with pval between 0.05 and 0.1\n\n" : 
              format_stats(threshold_acc[clf]) * "\n")
    end
end


