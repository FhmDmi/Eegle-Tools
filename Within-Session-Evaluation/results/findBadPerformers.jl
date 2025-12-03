# Bad Performers Identification Script
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com
#
# ? CONTENTS:
# This script identifies subjects with accuracy < 0.58 across both MDM and ENLR models
# that should be excluded from further analyses.
#
# Generates a markdown report listing all bad performers per database,
# including their accuracy for each classifier for transparency.
#
# Input: CSV files with results per database and task
# Output: Markdown file with detailed bad performers list

using DelimitedFiles, Statistics

# Configuration
paradigm = "MI";  # "MI" or "P300"
task = "feet-both_hands"; # or "right_hand-feet" or "left_hand-right_hand" ...
threshold = 0.58;
path = joinpath(pwd(), "results", paradigm, "CSV");
classifiers = ["MDM", "ENLR"];

# Filter database files
db_files = [
    (replace(f, "results_" => "", "_$(task).csv" => ""), f)
    for f in readdir(path)
    if startswith(f, "results_") && occursin("_$(task).csv", f)
];

# Identify bad performers
bad_performers = Dict(
    db => [
        (subj_id, accs)
        for (subj_id, accs) in begin
            content = readdlm(joinpath(path, file), ',')
            header, data = content[1, :], content[2:end, :]
            acc_indices = Dict(clf => findfirst(==("acc$(clf)"), header) for clf in classifiers)
           
            Dict(
                @inbounds(data[i, 1]) => Dict(
                    clf => @inbounds(data[i, idx])
                    for (clf, idx) in acc_indices
                    if @inbounds(data[i, idx]) isa Number
                )
                for i in 1:size(data, 1)
            )
        end
        if length(accs) == length(classifiers) && all(acc < threshold for acc in values(accs))
    ]
    for (db, file) in db_files
) |> d -> filter(p -> !isempty(p.second), d);

# Save results
output_file = joinpath(pwd(), "results", task_type, "MD", "bad_performers_$(task).md")
open(output_file, "w") do io
    write(io, "# Bad Performers Analysis\n\nTask: $(task)\n\n")
    write(io, "Task Type: $(task_type)\n\n")
    write(io, "Criterion: Accuracy < $(threshold) in ALL $(length(classifiers)) models ($(join(classifiers, ", ")))\n\n")
    write(io, "These subjects should not be included in further analyses.\n\n")
   
    isempty(bad_performers) ? write(io, "No bad performers found.\n\n") : begin
        total = sum(length(subjects) for (_, subjects) in bad_performers)
        write(io, "Total: $(total) subject(s)\n\n")
       
        for db in sort(collect(keys(bad_performers)))
            subjects = sort(bad_performers[db], by = s -> s[1])
            write(io, "## Database: $(db) - Count: $(length(subjects))\n\n")
            write(io, "| Subject/Session |" * join([" $(clf) Acc (%) |" for clf in classifiers]) * "\n")
            write(io, "|" * repeat("-----------------|", length(classifiers) + 1) * "\n")
            write(io, join([
                "| $(s[1]) |" * join([" $(round(s[2][clf] * 100, digits=2)) |" for clf in classifiers])
                for s in subjects
            ], "\n") * "\n\n")
        end
    end
end