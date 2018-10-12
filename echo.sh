#!/bin/bash

output=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*

for i in $output;do
bblIDs=$(echo ${i}|cut -d'/' -f9 |sed s@'/'@' '@g);
echo $bblIDs >>~/torun.txt
done
