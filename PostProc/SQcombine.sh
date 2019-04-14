#!/bin/bash

#Combine Squareforms into csv

# Subject locations and loop
general=$(cat /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/reprod_list.txt)

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)

	#FA
	output=$(cat /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/*/tractography/${bblIDs}*sqfa.csv)	
	#regurg=$(echo ${bblIDs} ',' ${output})
	echo $output >> ~/facon_all.csv

	#ICVF
	output=$(cat /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/*/tractography/${bblIDs}*sqicvf.csv)
	#regurg=$(echo ${bblIDs} ',' ${output})
	echo $output >> ~/icvfcon_all.csv
	
	#RTOP
	output=$(cat /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/*/tractography/${bblIDs}*sqrtop.csv)
	#regurg=$(echo ${bblIDs} ',' ${output})
	echo $output >> ~/rtopcon_all.csv

done

