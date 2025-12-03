# Motor Imagery Classification Pipeline using Eegle
#
# MIT License
# Copyright (c) 2025,
# Fahim Doumi, CeSMA (University of Naples Federico II), Naples, Italy
# fahim.doumi.pro@gmail.com

# CONTENTS:
# This script performs cross-validation classification on Motor Imagery databases
# using the Eegle toolbox.
#
# Processes all selected MI databases and saves subject/session names, accuracies,
# p-values, z-scores, and performer categories (good/normal/bad).
#
# Performer categories: :g (p<0.005), :n (0.005≤p≤0.05), :b (p>0.05)
# Parameters: bandPass=(8, 32), nFolds=10, upperLimit=1.2, covtype=SCM
# Output: names_*.txt, acc_*.txt, pval_*.txt, z_*.txt, performers_*.txt per database

using Eegle, DelimitedFiles

# Select databases according to criterias 
MIDir = homedir()*"\\work\\OfficeWork\\BCI Databases\\NY\\MI" # path to MI databases
classes = ["left_hand", "right_hand"]; # Select the databases according to the specific MI class for evaluation and classification.
DBs = selectDB(MIDir, :MI; classes);

# get the names of the subjects/sessions per database 
for (db, DB) ∈ enumerate(DBs)
    println("Database: ", (DB.dbName, DB.condition))
    names = Vector{String}(undef, length(DB.files))
    for (f, file) ∈ enumerate(DB.files)
        names[f] = splitext(basename(file))[1]
    end
    writedlm("names_$(DB.dbName)-$(DB.condition).txt", names)
    println("")
end

clf = MDM # select classifier, only MDM, ENLR and SVM, for more option check Eegle.jl documentation
for (db, DB) ∈ enumerate(DBs)
    println("Database: ", (DB.dbName, DB.condition))
    acc = zeros(length(DB.files))
    pval = zeros(length(DB.files))
    z = zeros(length(DB.files))
    perf = Vector{Symbol}(undef, length(DB.files))
    for (f, file) ∈ enumerate(DB.files)
        nf = length(DB.files)
        println("file $f of $nf")
        res = Eegle.BCI.crval(file, clf(); bandPass=(8, 32), classes, nFolds=10, upperLimit=1.2, covtype=SCM, tikh=10e-4, seed = 109)
        acc[f] = round(res.avgAcc, digits=5)
        pval[f] = round(res.p , digits=5)
        z[f] = round(res.z , digits=2)
        perf[f] = res.p < 0.005 ? :g : (res.p > 0.05 ? :b : :n)
    end
    writedlm("acc_$(clf)_$(DB.dbName)-$(DB.condition).txt", acc)
    writedlm("pval_$(clf)_$(DB.dbName)-$(DB.condition).txt", pval)
    writedlm("z_$(clf)_$(DB.dbName)-$(DB.condition).txt", z)
    writedlm("performers_$(clf)_$(DB.dbName)-$(DB.condition).txt", repr.(perf))
    println("")
end
