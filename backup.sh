#!/bin/bash
barch_name=archive

dayToWriteWeek=Mon

declare -i max_arch_count=2

if [[ ! -n "$1" ]] || [[ ! -n "$2" ]]; then
    echo "error"
    exit 1
fi

if [[ ! -d "$1" ]]; then
	echo "Directory $1 does not exist"
	exit 2
elif [[ ! -d "$2" ]]; then
	echo "Directory $2 does not exist"
	exit 2
fi

src="$1"
dst="$2"
abs_path=$src/\

if [[ -n $( echo "$abs_path" | grep "~" ) ]]; then
    abs_path="$(cd "$(dirname $src)"; pwd)/$(basename $src)/"
fi

if [[ -n "$3" ]]; then
    barch_name="$3"
fi

touch $src/checksum.txt
echo "Files checksums" > $src/checksum.txt

find $src ! -name "checksum.txt" -type f -exec md5sum {} + | sed 's|'"$abs_path"'||g' >> $src/checksum.txt
farch_name=""
c_date=$(date +%F)
if [[ $(date | cut -d " " -f1) ==  $dayToWriteWeek ]]; then
    farch_name="week-${barch_name}-${c_date}.tar.gz"
else
    farch_name="${barch_name}-${c_date}.tar.gz"
fi


abs_dst="$(cd "$(dirname $dst)"; pwd)/$(basename $dst)"
cd "$(dirname $src)"
tar -czPf $abs_dst/$farch_name --exclude="backup" --exclude="restore" --exclude="backup_timer.timer" --exclude="task_to_backup.service" -C $(basename $src) $(ls "$(basename $src)")

declare -i arch_count=$(find $dst -type f  | grep ".tar.gz" | wc -l)

if [[ "$arch_count" -ge "$max_arch_count" ]]; then
    declare -i diff=$arch_count-$max_arch_count+1
    rm $(find $dst -type f -printf '%T+ %p\n' | grep ".tar.gz" | sort | head -n $diff | cut -d " " -f2)
fi

username=maninegor
ip=0.0.0.0.0
dest_path=~/backups

scp $farch_name $username@$ip:$dest_path
exit
