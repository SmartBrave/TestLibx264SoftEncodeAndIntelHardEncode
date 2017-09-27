#!/bin/bash
#count=1
output=./output
ffmpeg_bin=/usr/local/ffmpeg/3.1.2/bin/ffmpeg
ffprobe_bin=/usr/local/ffmpeg/3.1.2/bin/ffprobe
#intel_sdk_bin=/opt/intel/mediasdk/samples/_bin/x64/sample_encode

function getVideoMeta(){
    $ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate,bit_rate,width,height,duration $1 2>/dev/null | sed -e 's/\"//g'
}

duration="-ss 00:00:00 -t 00:00:10"

function ffmpegSoftEncodingLibx264(){
    $ffmpeg_bin $1 $2 2>/dev/null
}
function ffmpegSoftEncodingLentenc(){
    $ffmpeg_bin $1 $2 2>/dev/null
}
function hardEncodingIntel264(){
    $ffmpeg_bin $1 $2 2>/dev/null
}
function hardEncodingIntel265(){
    $ffmpeg_bin $1 $2 2>/dev/null
}

mkdir $output 2>/dev/null
dir=./videos/data_0

for file in $dir/*.mp4
do
    #[[ ${#files[@]} -gt 1 ]] && break
    if [ -f $file ]
    then
	files[$cur]=$file
	(( cur++ ))
    else	
    	echo "$file is not exist!" >&2
    	continue
    fi
done

count=1
thread=8

#libx264
echo "">$output/psnr.libx264
mkdir -p $output/libx264
cur=0
cnt=0
rm -rf $output/*.mp4
for (( index=0;index<${#files[@]};index=index+count ))
do
        if [ $(echo "$index+$count"|bc) -lt ${#files[@]} ]
        then
            length=$count
        else
            length=$(echo "${#files[@]}-$index"|bc)
        fi
        inputopt=""
        outputopt=""
        for(( i=0;i<length;i++ ))
        do
            file=${files[i+index]}
            input_info=$( getVideoMeta $file )
		if [[ $? -ne 0  ]]
                then
                    echo "$ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate $file " >&2
                      continue
                fi
                source_bitrate=`echo $input_info | xargs -n1 | grep "bit_rate" | awk 'BEGIN{FS="="} {print $2}'`
          	inputopt=$inputopt" $duration -i $file"
          	outputopt=$outputopt" -c:v libx264 -maxrate $(echo "$source_bitrate*0.45"|bc) -threads $thread -map $i $output/libx264/$(echo $file | cut -d / -f 4)"
                (( cnt++ ))
        done
        spt=` { time ffmpegSoftEncodingLibx264 "$inputopt" "$outputopt"; } 2>&1 `
	psnr=`ffmpeg -i $file -i $output/libx264/$(echo $file | cut -d / -f 4) -filter_complex "psnr" -f null - 2>&1 | grep "PSNR" | cut -d " " -f 8`
	echo $file $output/$(echo $file | cut -d / -f 4) $psnr >> $output/psnr.libx264
done

#lenthevc
echo "">$output/psnr.lenthevc
mkdir -p $output/lenthevc
cur=0
cnt=0
rm -rf $output/*.mp4
for (( index=0;index<${#files[@]};index=index+count ))
do
	if [ $(echo "$index+$count"|bc) -lt ${#files[@]} ]
	then
	    length=$count
	else
	    length=$(echo "${#files[@]}-$index"|bc)
	fi
    	inputopt=""
    	outputopt=""
	for (( i=0;i<length;i++ ))
	do
       	     file=${files[i+index]}
    	    input_info=$( getVideoMeta $file )
                if [[ $? -ne 0  ]]
                then
                    echo "$ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate $file " >&2
                    continue
                fi
                source_bitrate=`echo $input_info | xargs -n1 | grep "bit_rate" | awk 'BEGIN{FS="="} {print $2}'`
        	    inputopt=$inputopt" $duration -i $file"
       	    outputopt=$outputopt" -c:v liblenthevc -maxrate $(echo "$source_bitrate*0.45"|bc) -threads $thread -map $i $output/lenthevc/$(echo $file | cut -d / -f 4)"
       	    (( cnt++ ))
    	done
	spt=` { time ffmpegSoftEncodingLentenc "$inputopt" "$outputopt"; } 2>&1 `
	psnr=`ffmpeg -i $file -i $output/lenthevc/$(echo $file | cut -d / -f 4) -filter_complex "psnr" -f null - 2>&1 | grep "PSNR" | cut -d " " -f 8`
	echo $file $output/$(echo $file | cut -d / -f 4) $psnr >> $output/psnr.lenthevc
done

#intel264
echo "">$output/psnr.intel264
mkdir -p $output/intel264
cur=0
cnt=0
rm -rf $output/*.mp4
for (( index=0;index<${#files[@]};index=index+count ))
do
	if [ $(echo "$index+$count"|bc) -lt ${#files[@]} ]
	then
	    length=$count
	else
	    length=$(echo "${#files[@]}-$index"|bc)
	fi
    	inputopt=""
    	outputopt=""
	for(( i=0;i<length;i++ ))
	do
	    file=${files[i+index]}
    	    input_info=$( getVideoMeta $file )
                if [[ $? -ne 0  ]]
                then
                    echo "$ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate $file " >&2
                    continue
                fi
                source_bitrate=`echo $input_info | xargs -n1 | grep "bit_rate" | awk 'BEGIN{FS="="} {print $2}'`
        	inputopt=$inputopt" $duration -i $file"
        	outputopt=$outputopt" -c:v h264_qsv -maxrate $(echo "$source_bitrate*0.45"|bc) -threads $thread -map $i $output/intel264/$(echo $file | cut -d / -f 4)"
	    (( cnt++ ))
	done
	spt=` { time hardEncodingIntel264 "$inputopt" "$outputopt"; } 2>&1 `
	psnr=`ffmpeg -i $file -i $output/intel264/$(echo $file | cut -d / -f 4) -filter_complex "psnr" -f null - 2>&1 | grep "PSNR" | cut -d " " -f 8`
	echo $file $output/$(echo $file | cut -d / -f 4) $psnr >> $output/psnr.intel264
done

##intel265
echo "">$output/psnr.intel265
mkdir -p $output/intel265
cur=0
cnt=0
rm -rf $output/*.mp4
for (( index=0;index<${#files[@]};index=index+count ))
do
	if [ $(echo "$index+$count"|bc) -lt ${#files[@]} ]
	then
	    length=$count
	else
	    length=$(echo "${#files[@]}-$index"|bc)
	fi
    	inputopt=""
    	outputopt=""
	for(( i=0;i<length;i++ ))
	do
	    file=${files[i+index]}
    	    input_info=$( getVideoMeta $file )
                if [[ $? -ne 0  ]]
                then
                    echo "$ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate $file " >&2
                    continue
                fi
                source_bitrate=`echo $input_info | xargs -n1 | grep "bit_rate" | awk 'BEGIN{FS="="} {print $2}'`
        	inputopt=$inputopt" $duration -i $file"
        	outputopt=$outputopt" -c:v hevc_qsv -load_plugin hevc_hw -maxrate $(echo "$source_bitrate*0.45"|bc) -threads $thread -map $i $output/intel265/$(echo $file | cut -d / -f 4)"
	    (( cnt++ ))
	done
	spt=` { time hardEncodingIntel265 "$inputopt" "$outputopt"; } 2>&1 `
	psnr=`ffmpeg -i $file -i $output/intel265/$(echo $file | cut -d / -f 4) -filter_complex "psnr" -f null - 2>&1 | grep "PSNR" | cut -d " " -f 8`
	echo $file $output/$(echo $file | cut -d / -f 4) $psnr >> $output/psnr.intel265
done
