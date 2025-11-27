# Bad Performers Identification Script
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com

# ? CONTENTS:
# This script identifies subjects with non-significant classification performance
# (p-value > 0.05) that should be excluded from further analyses.
#
# Generates a markdown report listing all bad performers per database and classifier,
# including their accuracy and p-value for transparency.
#
# Input: CSV files with results per database and task
# Output: Markdown file with detailed bad performers list per classifier

using DelimitedFiles, Statistics

# CSV files path
path = joinpath(pwd(), "MI", "CSV")

# task to analyse
task = "left_hand-right_hand"  # or "left_hand-right_hand"

# filter files according to task
csv_files = filter(f -> startswith(f, "results_") && endswith(f, ".csv"), readdir(path));

db_files = [(replace(f, "results_" => "", "_$(task).csv" => ""), f)
     for f in csv_files if occursin("_$(task).csv", f)];

# collect bad performers for each classifier
bad_performers = Dict{String, Dict{String, Vector{Tuple{Any, Float64, Any}}}}();
for clf in ["MDM", "ENLR", "SVM"]
    bad_performers[clf] = Dict{String, Vector{Tuple{Any, Float64, Any}}}()
    
    for (db, csv_file) in db_files
        file_content = readdlm(joinpath(path, csv_file), ',')
        header, data = file_content[1, :], file_content[2:end, :]
        
        idx_acc = findfirst(==("acc$(clf)"), header)
        idx_pval = findfirst(==("pval$(clf)"), header)
        
        bad_subjs = [(data[i, 1], data[i, idx_acc] * 100, data[i, idx_pval])
                     for i in 1:size(data, 1)
                     if data[i, idx_pval] isa Number && data[i, idx_pval] > 0.05]
        
        if !isempty(bad_subjs)
            bad_performers[clf][db] = bad_subjs
        end
    end
end;

# helper function to format table
format_table(subjects) = 
    "| Subject/Session | Accuracy (%) | p-value |\n" *
    "|-----------------|--------------|----------|\n" *
    join(["| $(s[1]) | $(round(s[2], digits=2)) | $(round(s[3], digits=4)) |" for s in subjects], "\n") * "\n\n"

# save results
output_file = joinpath("MI", "MD", "bad_performers_$(task).md")
open(output_file, "w") do io
    write(io, "# Bad Performers Analysis\n\nTask: $(task)\n\n")
    write(io, "Criterion: p-value > 0.05 (non-significant performance)\n\n")
    write(io, "These subjects should not be included in further analyses.\n\n")
    
    for clf in ["MDM", "ENLR", "SVM"]
        write(io, "## Classifier: $(clf)\n\n")
        
        if isempty(bad_performers[clf])
            write(io, "No bad performers found.\n\n")
        else
            total = sum(length(subjects) for (db, subjects) in bad_performers[clf])
            write(io, "Total: $(total) subject(s)\n\n")
            
            for (db, subjects) in sort(collect(bad_performers[clf]))
                write(io, "### Database: $(db) - Count: $(length(subjects))\n\n")
                write(io, format_table(subjects))
            end
        end
    end
end