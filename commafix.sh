#!/bin/bash
general=~/TS_matrices/TS_matrices/*ODI1mcon.csv
for i in $general;do
contents=$(cat $i)
echo $contents >>~/ODI1mcon.csv
done

