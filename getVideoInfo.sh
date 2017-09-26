dir="output/test"

function getVideoMeta(){
    ffprobe -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate,bit_rate,width,height,duration $1 2>/dev/null | sed -e 's/\"//g'
}

str="0"
cnt=0
size=0

for file in $dir/*.mp4
do
    if [ -f $file ]
    then
        input_info=$( getVideoMeta $file )
        if [[ $? -ne 0  ]]
        then
            echo "$ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate $dir/$(echo $file|cut -d / -f 3|cut -d . -f 1).mp4 " >&2
            continue
        fi
        duration=`echo $input_info | xargs -n1 | grep "duration" | awk 'BEGIN{FS="="} {print $2}'`
	s=`ls -l $file | awk '{print $5}'`
	if [[ $duration = "" ]]
	then
		continue
	fi
	str=$str"+$duration"
	size=$size"+$s"
	(( cnt++ ))
    fi
done
echo $size|bc
echo $cnt
echo $str|bc
