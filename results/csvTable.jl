# Results Aggregation Script for BCI Analysis
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com

# ? CONTENTS:
# This script aggregates classification results from text files into CSV format
# for both Motor Imagery (MI) and P300 paradigms.
#
# MI tasks: Aggregates accuracy, performers, p-values, and z-scores for MDM, ENLR, SVM
# P300 tasks: Aggregates accuracy only for MDM and ENLR
#
# Input: Individual .txt files per metric (acc, perf, pval, z) and classifier
# Output: Consolidated CSV files per database with all metrics

using DelimitedFiles

# .txt path
MIpath = joinpath(pwd(), "raw", "MI", "right_hand-feet")
P300path = joinpath(pwd(), "raw", "P300")

# clfs list
clfs = ["MDM", "ENLR", "SVM"]

# helper function to process pval
process_pval(pvals) = [p < 0.0001 ? "<0.0001" : p for p in pvals]

############### MI ONLY !!!!!! ###############
names_files = filter(f -> startswith(f, "names_"), readdir(MIpath))

for names_file in names_files
    db = replace(names_file, "names_" => "", ".txt" => "")
    names = vec(readdlm(joinpath(MIpath, names_file), String))
    n_sessions = length(names)
    
    # header with comprehension
    header = vcat(["subject-session"], 
                  [metric * clf for clf in clfs for metric in ["acc", "perf", "pval", "z"]])
    
    # initiate data matrix
    data = Matrix{Any}(undef, n_sessions, length(header))
    data[:, 1] = names
    
    col_idx = 2
    for clf in clfs
        data[:, col_idx] = vec(readdlm(joinpath(MIpath, "acc_$(clf)_$(db).txt"), Float64))
        data[:, col_idx+1] = vec(readdlm(joinpath(MIpath, "performers_$(clf)_$(db).txt"), String))
        data[:, col_idx+2] = process_pval(vec(readdlm(joinpath(MIpath, "pval_$(clf)_$(db).txt"), Float64)))
        data[:, col_idx+3] = vec(readdlm(joinpath(MIpath, "z_$(clf)_$(db).txt"), Float64))
        col_idx += 4
    end
    
    # save CSV
    output_file = joinpath(pwd(), "MI", "CSV", "results_$(db)_$(basename(MIpath)).csv")
    open(output_file, "w") do io
        writedlm(io, [header], ',')
        writedlm(io, data, ',')
    end
    
    println("file created : $output_file")
end

# clfs list
clfs = ["MDM", "ENLR"]
############### P300 only !!!!!! ###############
names_files = filter(f -> startswith(f, "names_"), readdir(P300path))

for names_file in names_files
    db = replace(names_file, "names_" => "", ".txt" => "")
    names = vec(readdlm(joinpath(P300path, names_file), String))
    n_sessions = length(names)
    
    # header with comprehension
    header = vcat(["subject-session"], ["acc" * clf for clf in clfs])
    
    # initiate data matrix
    data = Matrix{Any}(undef, n_sessions, length(header))
    data[:, 1] = names
    
    for (idx, clf) in enumerate(clfs)
        data[:, idx+1] = vec(readdlm(joinpath(P300path, "acc_$(clf)_$(db).txt"), Float64))
    end
    
    # save CSV
    output_file = joinpath(pwd(), "P300", "CSV", "results_$(db).csv")
    open(output_file, "w") do io
        writedlm(io, [header], ',')
        writedlm(io, data, ',')
    end
    
    println("file created : $output_file")
end