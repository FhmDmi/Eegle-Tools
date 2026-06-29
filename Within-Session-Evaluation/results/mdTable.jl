# Benchmark Table Generator for BCI Classification Results
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com

# ? CONTENTS:
# This script generates markdown benchmark tables summarizing classification
# performance across databases for a given task and paradigm.
#
# Outputs mean ± std accuracy (%) for each classifier per database
# MI paradigm: MDM, ENLR, SVM classifiers
# P300 paradigm: MDM, ENLR classifiers only
#
# Input: CSV files with aggregated results per database
# Output: Markdown table with performance summary

using DelimitedFiles, Statistics

# CSV files path
paradigm = "P300"; # replace MI by P300 for P300 tables
path = joinpath(pwd(), "Within-Session-Evaluation", "results", "Benchmark",paradigm, "CSV") # replace P300 instead of MI for P300 tables

# task to analyse 
task = "right_hand-feet";  # or "right_hand-feet" or "P300" ...

# filter files according to task
csv_files = filter(f -> startswith(f, "results_") && endswith(f, ".csv"), readdir(path))

# helper function
format_stat(acc) = "$(round(mean(acc), digits=2)) ± $(round(std(acc), digits=2))"

# only for MI
# generate and save markdown table
output_file = joinpath(pwd(), "Within-Session-Evaluation", "results", "Benchmark", paradigm, "MD", "benchmark_$(task).md")
filtered_files = filter(f -> occursin("_$(task).csv", f), csv_files)

open(output_file, "w") do io
    write(io, "## Task: $task\n\n")
    write(io, "| Database | MDM (%) | ENLR (%) | SVM (%) |\n")
    write(io, "|----------|---------|----------|----------|\n")
    
    for csv_file in filtered_files
        filepath = joinpath(path, csv_file)
        
        db = replace(csv_file, "results_" => "", "_$(task).csv" => "")
        
        file_content = readdlm(filepath, ',')

        header = file_content[1, :]
        data = file_content[2:end, :]

        # extract and calculate stats for each classifier
        stats = [format_stat(data[:, findfirst(==(col), header)] .* 100) 
                for col in ["accMDM", "accENLR", "accSVM"]]
        
        write(io, "| $db | $(stats[1]) | $(stats[2]) | $(stats[3]) |\n")
    end
end

println("file created : $output_file")


# ONLY P300 
# generate and save markdown table
output_file = joinpath(pwd(), "Within-Session-Evaluation", "results", "Benchmark", paradigm, "MD", "benchmark_P300.md")

open(output_file, "w") do io
    write(io, "## Task: P300\n\n")
    write(io, "| Database | MDM (%) | ENLR (%) |\n")
    write(io, "|----------|---------|----------|\n")
    
    for csv_file in csv_files
        filepath = joinpath(path, csv_file)
        
        db = replace(csv_file, "results_" => "", "_P300.csv" => "")
        
        file_content = readdlm(filepath, ',')
        
        header = file_content[1, :]
        data = file_content[2:end, :]
        
        stats = [format_stat(data[:, findfirst(==(col), header)] .* 100) 
                 for col in ["accMDM", "accENLR"]]
        
        write(io, "| $db | $(stats[1]) | $(stats[2]) |\n")
    end
end
