input=$1; shift
output=$1; shift
orig=$1; shift
new=$1; shift

for f in *.vmrk; 
do 
	echo $f; 
	name=${f:0:2};
	sed -e "s@$name"_"$orig".eeg"@$name"_"$new".eeg"@g" $input > $output; 
done

