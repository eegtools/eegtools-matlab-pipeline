filter=ae_vs_ao_nb_mu_beta1_beta2

mkdir temp_folder
for f in $filter*
do
	if [ -d $f ]; then
		cp $f/*/narrow_band.txt temp_folder/$f"_narrow_band.txt"
	fi
done


output_file=nb_results.dat
declare -i nfile=0
declare -i nline=0

for f in temp_folder/*
do
	echo "appending $f"
	nfile=$nfile+1
	nline=0
	while read line
	do
		nline=$nline+1
		if [ $nline -eq 1 -a $nfile -gt 1 ]; then
			#echo skipped":"$nline":"$nfile
			continue
		else
			#echo ":"$nline":"$nfile
			echo $line >> $output_file
		fi
	done < $f
done
