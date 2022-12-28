#!/bin/bash

archive="$1"
mode="$2"

if [[ ! -n "$archive" ]]; then
	echo "Specify the path to the archive as first argument"
	echo "Example: ./restore.sh archive.tar.gz check"
	exit 1
fi

if [[ $mode == "check" ]]; then
	tmp_folder=tmp-archive
	tmp_path=./$tmp_folder
	checksum_src=checksum.txt
	checksum_local=checksum_final.txt

	if [[ ! -d "$tmp_path" ]]; then
		mkdir $tmp_folder
	fi
	tar -xzf "$archive" -C $tmp_path
	find $tmp_path ! -name $checksum_src ! -name $checksum_local -type f -exec md5sum {} + > $tmp_path/$checksum_local

	declare -i i=0
	while read line; do
		if [[ $i != 0 ]]; then
			filename=$(echo "$line" | cut -d " " -f3)
			file_checksum=$(echo "$line" | cut -d " " -f1)
			checksum=$(md5sum "$tmp_path/$filename" | cut -d " " -f1)
			if [[ $checksum == $file_checksum  ]]; then
				echo "$( echo "$filename" | sed 's|'"$tmp_path"'/||g' ) OK"
			else
				echo "$( echo "$filename" | sed 's|'"$tmp_path"'/||g'  ) ERROR"
			fi
		fi
		i=$i+1
	done <$tmp_path/$checksum_src
	rm -rf $tmp_path
elif [[ $mode == "extract" ]]; then
	path=$(pwd)
	if [[ -n "$3" ]]; then
		path="$3"
		if [[ ! -d "$path" ]]; then
			mkdir "$path"
		fi
	fi
	tar -xzf "$archive" -C $path
	rm $path/checksum.txt
else
	echo "Unrecognized option as second argument"
	echo "Allowed options are: 'check' and 'extract'"
	echo "Example: ./restore.sh archive.tar.gz check"
	exit 2
fi
