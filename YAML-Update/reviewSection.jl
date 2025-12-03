# Generic YAML Section Updater for EEG Databases
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com

# CONTENTS:
# This script provides a generic method to update any section in YAML metadata files
# for EEG databases. The user can modify any field by defining the appropriate pattern.
#
# Processing steps:
# 1. Loads specific database (user-selected)
# 2. Iterates through all associated YAML files
# 3. Replaces user-defined section content using regex pattern
# 4. Writes modified files
#
# User-configurable parameters:
# - Database index: DBs[12] (can be changed to any database)
# - Pattern to match: any YAML section (here: sensortype as example)
# - Replacement text: any valid YAML content
#
# Example usage (current configuration):
# - Section: "sensortype"
# - Old: "sensortype: Active Dry electrodes"
# - New: "sensortype: Dry electrodes"
#
# Output: Modified .yml files with updated user-specified section

using Eegle, YAML

# Paths configuration
paradigm = "MI";  # or "P300"
db_dir = joinpath(homedir(), "work", "OfficeWork", "BCI Databases", "NY", paradigm);
DBs = selectDB(db_dir, :MI);  # or :P300

# Precompile regex pattern
sensortype_pattern = r"sensortype: Active Dry electrodes";

# Process each YAML file
@inbounds for filename in DBs[12].files
    yml_file = splitext(filename)[1] * ".yml"
    yml_text = read(yml_file, String)

    # Add perf section at the end and update version
    yml_text = replace(yml_text, sensortype_pattern => "sensortype: Dry electrodes")
    
    # Write modified file
    write(yml_file, yml_text)
end
