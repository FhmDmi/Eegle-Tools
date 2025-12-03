# P300 Classification Pipeline using Eegle
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com

# CONTENTS:
# This script performs cross-validation classification on P300 databases
# using the Eegle toolbox.
#
# Processes all selected P300 databases and saves subject/session names
# and classification accuracies for each classifier.
#
# Parameters: bandPass=(1, 24), nFolds=10, upperLimit=1.2
# Output: names_*.txt and acc_*.txt files per database

using Eegle, DelimitedFiles

# Select databases according to criterias 
P300Dir = homedir()*"\\work\\OfficeWork\\BCI Databases\\NY\\P300" # path to P300 databases
DBs = selectDB(P300Dir, :P300);

# get the names of the subjects/sessions per database and save them
for (db, DB) ∈ enumerate(DBs)
    println("Database: ", (DB.dbName, DB.condition))
    names = Vector{String}(undef, length(DB.files))
    for (f, file) ∈ enumerate(DB.files)
        names[f] = splitext(basename(file))[1]
    end
    writedlm("names_$(DB.dbName)-$(DB.condition).txt", names)
    println("")
end

clf = MDM # select classifier, only MDM and ENLR are currently supported for P300, for more option check Eegle.jl documentation
for (db, DB) ∈ enumerate(DBs)
    println("Database: ", (DB.dbName, DB.condition))
    acc = zeros(length(DB.files))
    for (f, file) ∈ enumerate(DB.files)
        nf = length(DB.files)
        println("file $f of $nf")
        res = Eegle.BCI.crval(file, clf(); bandPass=(1, 24), nFolds=10, upperLimit=1.2, seed = 109)
        acc[f] = round(res.avgAcc, digits=5)
    end
    writedlm("acc_$(clf)_$(DB.dbName)-$(DB.condition).txt", acc)
    println("")
end
