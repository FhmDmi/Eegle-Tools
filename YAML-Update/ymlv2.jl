# YAML Format Converter for EEG Databases (v1 to v2)
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com

# CONTENTS:
# This script converts YAML metadata files from format version 0.0.1 to 0.0.2
# for EEG databases using the Eegle toolbox.
#
# Processing steps (in order):
# 1. Removes comment section after stimulation metadata
# 2. Converts P300 labels to lowercase (NonTarget -> nontarget, Target -> target)
# 3. Adds trials_per_class field with trial counts for each class
# 4. Updates format version from 0.0.1 to 0.0.2
#
# Note: Lowercase conversion applies only to P300 paradigm databases
# Output: Modified .yml files in place (overwrites original files)

using Eegle, YAML

DBs  = ["D:\\BCI Databases\\test yaml\\v1\\P300\\bi2012-O"] # list of path where databases are stored

for db_path in DBs
    files = loadNYdb(db_path)
   
    for filename in files
        base_path = splitext(filename)[1]
        yml_file = base_path * ".yml"
       
        # Read YAML file
        yml_text = read(yml_file, String)
        yml_data = YAML.load_file(yml_file)
       
        # Check if P300 paradigm
        is_p300 = yml_data["id"]["paradigm"] == "P300"
       
        # 1. Remove comments after stim section
        lines = split(yml_text, '\n')
        stim_end_idx = nothing
        in_stim_section = false
       
        for (j, line) in enumerate(lines)
            stripped_line = strip(line)
            if startswith(stripped_line, "stim:")
                in_stim_section = true
            elseif in_stim_section && !isempty(stripped_line) && !startswith(line, " ")
                stim_end_idx = j - 1
                break
            elseif in_stim_section && !isempty(stripped_line)
                stim_end_idx = j
            end
        end
       
        yml_text = stim_end_idx !== nothing ? join(lines[1:stim_end_idx], '\n') * "\n" : yml_text
       
        # 2. Lowercase for P300 only (in stim section)
        if is_p300
            yml_text = replace(yml_text, "NonTarget:" => "nontarget:")
            yml_text = replace(yml_text, "Target:" => "target:")
        end
       
        # 3. Add trials_per_class
        if !occursin("trials_per_class:", yml_text)
            o = readNY(filename; upperLimit=0)
            current_labels = yml_data["stim"]["labels"]
            sorted_labels = sort(collect(current_labels), by = x -> x[2])
           
            trials_per_class = Dict{String, Int}()
            for (class_name, class_value) in sorted_labels
                # Convert to lowercase for P300
                search_name = is_p300 ? lowercase(class_name) : class_name
                if search_name in o.clabels
                    idx = findfirst(x -> x == search_name, o.clabels)
                    trials_per_class[search_name] = length(o.mark[idx])
                end
            end
           
            # Reorganize labels
            labels_pattern = r"  labels:\s*\n((?:\s{4,}\w+:\s*\d+\s*\n)+)"
            labels_match = match(labels_pattern, yml_text)
            if labels_match !== nothing
                new_labels_section = "  labels:\n"
                for (class_name, class_value) in sorted_labels
                    # Use lowercase for P300
                    final_name = is_p300 ? lowercase(class_name) : class_name
                    new_labels_section *= "    $final_name: $class_value\n"
                end
                yml_text = replace(yml_text, labels_match.match => new_labels_section)
            end
           
            # Add trials_per_class
            nclasses_pattern = r"(\s+nclasses:\s*\d+\s*\n)"
            nclasses_match = match(nclasses_pattern, yml_text)
            if nclasses_match !== nothing
                trials_text = "  trials_per_class:\n"
                for (class_name, count) in trials_per_class
                    trials_text *= "    $class_name: $count\n"
                end
                yml_text = replace(yml_text, nclasses_match.match => nclasses_match.match * trials_text)
            end
        end
       
        # 4. Update format version
        yml_text = replace(yml_text, r"formatversion:\s*0\.0\.1" => "formatversion: 0.0.2")
       
        # Write modified file
        write(yml_file, yml_text)
    end
end