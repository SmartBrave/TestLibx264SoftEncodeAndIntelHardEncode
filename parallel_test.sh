#!/bin/bash -x 
#count=1
output=./output
ffmpeg_bin=/usr/local/ffmpeg/3.1.2/bin/ffmpeg
ffprobe_bin=/usr/local/ffmpeg/3.1.2/bin/ffprobe
#intel_sdk_bin=/opt/intel/mediasdk/samples/_bin/x64/sample_encode

function getVideoMeta(){
    $ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate,bit_rate,width,height,duration $1 2>/dev/null | sed -e 's/\"//g'
}

function getCPUinfo(){
    #ps aux | grep 'sar 1' | cut -f 2
    sed -ie '/Linux/d' $1
    sed -ie '/CPU/d' $1
    sed -ie '/Average/d' $1
    sed -ie '/^$/d' $1
    awk 'BEGIN{sum=0;line=0;max=0;min=100;}{line++;used=100-$9;sum+=used;if(used>max)max=used;if(used<min)min=used}END{print "CPU :max:",max,"%\tmin:",min,"%\tave:",sum/line,"%";}' $1
}

function getMEMinfo(){
    sed -ie '/Linux/d' $1
    sed -ie '/memused/d' $1
    sed -ie '/Average/d' $1
    sed -ie '/^$/d' $1
    awk 'BEGIN{sum=0;line=0;max=0;min=100;}{line++;sum+=$5;if($5>max)max=$5;if($5<min)min=$5}END{print "MEM :max:",max,"%\tmin:",min,"%\tave:",sum/line,"%";}' $1
}

function getTIMEinfo(){
    awk 'BEGIN{real=0;user=0;sys=0;}{real+=$1;user+=$2;sys+=$3;}END{print "TIME:real:",real,"s\tuser:",user,"s\tsys:",sys,"s"}' $1
}

duration="-ss 00:00:00 -t 00:00:10"

function ffmpegSoftEncodingLibx264(){
    #$ffmpeg_bin -s $width*$height -i $1 -c:v libx264 -b:v $(echo "$source_bitrate*0.45"|bc) -r ${source_fps} -g ${source_fps} -c:a copy -y $2 2>/dev/null
    #$ffmpeg_bin $duration -i $1 -c:v libx264 -r ${source_fps} -g ${source_fps} -b:v $(echo "$source_bitrate*0.45"|bc) -maxrate $(echo "$source_bitrate*0.45"|bc) -c:a copy -y $2 2>/dev/null
    #$ffmpeg_bin $duration $1 -c:v libx264 -r ${source_fps} -g ${source_fps} -b:v $(echo "$source_bitrate*0.45"|bc) -maxrate $(echo "$source_bitrate*0.45"|bc) $2 2>/dev/null
    $ffmpeg_bin $1 $2 2>/dev/null
}
function ffmpegSoftEncodingLentenc(){
    #$ffmpeg_bin -s $width*$height -i $1 -c:v liblenthevc -b:v $(echo "$source_bitrate*0.45"|bc)K -r ${source_fps} -g ${source_fps} -c:a copy -y $2 2>/dev/null
    #$ffmpeg_bin $duration -i $1 -c:v liblenthevc -r ${source_fps} -g ${source_fps} -b:v $(echo "$source_bitrate*0.45"|bc) -maxrate $(echo "$source_bitrate*0.45"|bc) -c:a copy -y $2 2>/dev/null
    #$ffmpeg_bin $duration $1 -c:v liblenthevc -r ${source_fps} -g ${source_fps} -b:v $(echo "$source_bitrate*0.45"|bc) -maxrate $(echo "$source_bitrate*0.45"|bc) $2 2>/dev/null
    $ffmpeg_bin $1 $2 2>/dev/null
}
function hardEncodingIntel264(){
    #$intel_sdk_bin h264 -i $1 -b $(echo "$source_bitrate*0.45"|bc|cut -d . -f 1) -r ${source_fps} -g ${source_fps} -o $2 -w $width -h $height 1>/dev/null 2>&1
    #$ffmpeg_bin $duration -i $1 -c:v h264_qsv -r ${source_fps} -g ${source_fps} -b:v $(echo "$source_bitrate*0.45"|bc) -maxrate $(echo "$source_bitrate*0.45"|bc) -c:a copy -y $2 2>/dev/null
    #$ffmpeg_bin $duration $1 -c:v h264_qsv -r ${source_fps} -g ${source_fps} -b:v $(echo "$source_bitrate*0.45"|bc) -maxrate $(echo "$source_bitrate*0.45"|bc) $2 2>/dev/null
    $ffmpeg_bin $1 $2 2>/dev/null
}
function hardEncodingIntel265(){
    #$intel_sdk_bin h265 -i $1 -b $(echo "$source_bitrate*0.5"|bc|cut -d . -f 1) -r ${source_fps} -g ${source_fps} -o $2 -w $width -h $height 1>/dev/null 2>&1
    #$ffmpeg_bin $duration -i $1 -c:v hevc_qsv -load_plugin hevc_hw -r ${source_fps} -g ${source_fps} -b:v $(echo "$source_bitrate*0.45"|bc) -maxrate $(echo "$source_bitrate*0.45"|bc) -c:a copy -y $2 2>/dev/null
    #$ffmpeg_bin $duration $1 -c:v hevc_qsv -load_plugin hevc_hw -r ${source_fps} -g ${source_fps} -b:v $(echo "$source_bitrate*0.45"|bc) -maxrate $(echo "$source_bitrate*0.45"|bc) $2 2>/dev/null
    $ffmpeg_bin $1 $2 2>/dev/null
}

mkdir $output 2>/dev/null
dir=./videos/data_0
#rm -rf $output/*.yuv
#rm -rf $output/*.264
#rm -rf $output/*.265
echo "">$output/videoinfo
cpuinfo=$output/cpuinfo
meminfo=$output/meminfo
timeinfo=$output/timeinfo

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

for count in {4,8,16} #task
#for count in {1,2,4,8,16} #task
do
    #x264
    #for thread in {1,2,4,8} #thread
    #do
    #    cur=0
    #    cnt=0
    #    sar 1 > $cpuinfo.par$count.x264.t$thread &
    #    sar -r 1 > $meminfo.par$count.x264.t$thread &
    #    echo "">$timeinfo.par$count.x264.t$thread
    #    rm -rf $output/*.mp4
    #    for (( index=0;index<${#files[@]};index=index+count ))
    #    do
    #    	if [ $(echo "$index+$count"|bc) -lt ${#files[@]} ]
    #    	then
    #    	    length=$count
    #    	else
    #    	    length=$(echo "${#files[@]}-$index"|bc)
    #    	fi
    #		inputopt=""
    #		outputopt=""
    #    	for(( i=0;i<length;i++ ))
    #    	do
    #    	    file=${files[i+index]}
    #        	    input_info=$( getVideoMeta $file )
    #	            if [[ $? -ne 0  ]]
    #	            then
    #	                echo "$ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate $file " >&2
    #	                continue
    #	            fi
    #	            source_bitrate=`echo $input_info | xargs -n1 | grep "bit_rate" | awk 'BEGIN{FS="="} {print $2}'`
    #	    	    inputopt=$inputopt" $duration -i $file"
    #	    	    outputopt=$outputopt" -c:v libx264 -maxrate $(echo "$source_bitrate*0.45"|bc) -threads $thread -map $i $output/$(echo $file | cut -d / -f 4)"
    #    	    (( cnt++ ))
    #    	done
    #    	spt=` { time ffmpegSoftEncodingLibx264 "$inputopt" "$outputopt"; } 2>&1 `
    #    	r=`echo "$spt"| grep "real" | cut -f 2`
    #    	u=`echo "$spt"| grep "user" | cut -f 2`
    #    	s=`echo "$spt"| grep "sys" | cut -f 2`
    #    	
    #    	a=$(echo "$(echo $r | cut -d m -f 1)*60"|bc)
    #    	b=$(echo "$(echo $r | cut -d m -f 2 | cut -d s -f 1)"|bc)
    #    	x264real=$(echo "$a + $b"|bc)
    #    	
    #    	a=$(echo "$(echo $u | cut -d m -f 1)*60"|bc)
    #    	b=$(echo "$(echo $u | cut -d m -f 2 | cut -d s -f 1)"|bc)
    #    	x264user=$(echo "$a + $b"|bc)
    #    	
    #    	a=$(echo "$(echo $s | cut -d m -f 1)*60"|bc)
    #    	b=$(echo "$(echo $s | cut -d m -f 2 | cut -d s -f 1)"|bc)
    #    	x264sys=$(echo "$a + $b"|bc)
    #    
    #    	echo $x264real $x264user $x264sys >> $timeinfo.par$count.x264.t$thread
    #    	#rm -rf $output/$(echo $file|cut -d / -f 3 | cut -d . -f 1).264
    #    done
    #    echo "-------------x264-------------"
    #    echo "count of videos:$cnt"
    #    echo "threads:$thread"
    #    echo "task:$count"
    #    getCPUinfo $cpuinfo.par$count.x264.t$thread
    #    getMEMinfo $meminfo.par$count.x264.t$thread
    #    getTIMEinfo $timeinfo.par$count.x264.t$thread
    #done

    ##lentenc
    for thread in {1,2,4,8}
    do
        cur=0
        cnt=0
        sar 1 > $cpuinfo.par$count.lentenc.t$thread &
        sar -r 1 > $meminfo.par$count.lentenc.t$thread &
        echo "">$timeinfo.par$count.lentenc.t$thread
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
    	   	    outputopt=$outputopt" -c:v liblenthevc -maxrate $(echo "$source_bitrate*0.45"|bc) -threads $thread -map $i $output/$(echo $file | cut -d / -f 4)"
    	   	    (( cnt++ ))
    		done
        	spt=` { time ffmpegSoftEncodingLentenc "$inputopt" "$outputopt"; } 2>&1 `
        	r=`echo "$spt"| grep "real" | cut -f 2`
        	u=`echo "$spt"| grep "user" | cut -f 2`
        	s=`echo "$spt"| grep "sys" | cut -f 2`
        	
        	a=$(echo "$(echo $r | cut -d m -f 1)*60"|bc)
        	b=$(echo "$(echo $r | cut -d m -f 2 | cut -d s -f 1)"|bc)
        	lentencreal=$(echo "$a + $b"|bc)
        	
        	a=$(echo "$(echo $u | cut -d m -f 1)*60"|bc)
        	b=$(echo "$(echo $u | cut -d m -f 2 | cut -d s -f 1)"|bc)
        	lentencuser=$(echo "$a + $b"|bc)
        	
        	a=$(echo "$(echo $s | cut -d m -f 1)*60"|bc)
        	b=$(echo "$(echo $s | cut -d m -f 2 | cut -d s -f 1)"|bc)
        	lentencsys=$(echo "$a + $b"|bc)
        
        	echo $lentencreal $lentencuser $lentencsys >> $timeinfo.par$count.lentenc.t$thread
        	#rm -rf $output/$(echo $file|cut -d / -f 3 | cut -d . -f 1).265
        done
        echo "------------lentenc------------"
        echo "count of videos:$cnt"
        echo "threads:$thread"
        echo "task:$count"
        getCPUinfo $cpuinfo.par$count.lentenc.t$thread
        getMEMinfo $meminfo.par$count.lentenc.t$thread
        getTIMEinfo $timeinfo.par$count.lentenc.t$thread
    done
    
    ##intel264
    #for thread in {1,2,4,8}
    #do
    #    cur=0
    #    cnt=0
    #    sar 1 > $cpuinfo.par$count.intel264.t$thread &
    #    sar -r 1 > $meminfo.par$count.intel264.t$thread &
    #    echo "">$timeinfo.par$count.intel264.t$thread
    #    rm -rf $output/*.mp4
    #    for (( index=0;index<${#files[@]};index=index+count ))
    #    do
    #    	if [ $(echo "$index+$count"|bc) -lt ${#files[@]} ]
    #    	then
    #    	    length=$count
    #    	else
    #    	    length=$(echo "${#files[@]}-$index"|bc)
    #    	fi
    #		inputopt=""
    #		outputopt=""
    #    	for(( i=0;i<length;i++ ))
    #    	do
    #    	    file=${files[i+index]}
    #        	    input_info=$( getVideoMeta $file )
    #	            if [[ $? -ne 0  ]]
    #	            then
    #	                echo "$ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate $file " >&2
    #	                continue
    #	            fi
    #	            source_bitrate=`echo $input_info | xargs -n1 | grep "bit_rate" | awk 'BEGIN{FS="="} {print $2}'`
    #	    	    inputopt=$inputopt" $duration -i $file"
    #	    	    outputopt=$outputopt" -c:v h264_qsv -maxrate $(echo "$source_bitrate*0.45"|bc) -threads $thread -map $i $output/$(echo $file | cut -d / -f 4)"
    #    	    (( cnt++ ))
    #    	done
    #    	spt=` { time hardEncodingIntel264 "$inputopt" "$outputopt"; } 2>&1 `
    #    	r=`echo "$spt"| grep "real" | cut -f 2`
    #    	u=`echo "$spt"| grep "user" | cut -f 2`
    #    	s=`echo "$spt"| grep "sys" | cut -f 2`
    #    	
    #    	a=$(echo "$(echo $r | cut -d m -f 1)*60"|bc)
    #    	b=$(echo "$(echo $r | cut -d m -f 2 | cut -d s -f 1)"|bc)
    #    	intelreal264=$(echo "$a + $b"|bc)
    #    	
    #    	a=$(echo "$(echo $u | cut -d m -f 1)*60"|bc)
    #    	b=$(echo "$(echo $u | cut -d m -f 2 | cut -d s -f 1)"|bc)
    #    	inteluser264=$(echo "$a + $b"|bc)
    #    	
    #    	a=$(echo "$(echo $s | cut -d m -f 1)*60"|bc)
    #    	b=$(echo "$(echo $s | cut -d m -f 2 | cut -d s -f 1)"|bc)
    #    	intelsys264=$(echo "$a + $b"|bc)
    #    
    #    	echo $intelreal264 $inteluser264 $intelsys264 >> $timeinfo.par$count.intel264.t$thread
    #    	#rm -rf $output/$(echo $file|cut -d / -f 3|cut -d . -f 1).264
    #    done
    #    
    #    echo "------------intel264-------------"
    #    echo "count of videos:$cnt"
    #    echo "threads:$thread"
    #    echo "task:$count"
    #    getCPUinfo $cpuinfo.par$count.intel264.t$thread
    #    getMEMinfo $meminfo.par$count.intel264.t$thread
    #    getTIMEinfo $timeinfo.par$count.intel264.t$thread
    #done
    #
    #
    ###intel265
    #for thread in {1,2,4,8}
    #do
    #    cur=0
    #    cnt=0
    #    sar 1 > $cpuinfo.par$count.intel265.t$thread &
    #    sar -r 1 > $meminfo.par$count.intel265.t$thread &
    #    echo "">$timeinfo.par$count.intel265.t$thread
    #    rm -rf $output/*.mp4
    #    for (( index=0;index<${#files[@]};index=index+count ))
    #    do
    #    	if [ $(echo "$index+$count"|bc) -lt ${#files[@]} ]
    #    	then
    #    	    length=$count
    #    	else
    #    	    length=$(echo "${#files[@]}-$index"|bc)
    #    	fi
    #		inputopt=""
    #		outputopt=""
    #    	for(( i=0;i<length;i++ ))
    #    	do
    #    	    file=${files[i+index]}
    #        	    input_info=$( getVideoMeta $file )
    #	            if [[ $? -ne 0  ]]
    #	            then
    #	                echo "$ffprobe_bin -v error -of flat=s=_ -select_streams v:0 -show_entries stream=r_frame_rate $file " >&2
    #	                continue
    #	            fi
    #	            source_bitrate=`echo $input_info | xargs -n1 | grep "bit_rate" | awk 'BEGIN{FS="="} {print $2}'`
    #	    	    inputopt=$inputopt" $duration -i $file"
    #	    	    outputopt=$outputopt" -c:v hevc_qsv -load_plugin hevc_hw -maxrate $(echo "$source_bitrate*0.45"|bc) -threads $thread -map $i $output/$(echo $file | cut -d / -f 4)"
    #    	    (( cnt++ ))
    #    	done
    #    	spt=` { time hardEncodingIntel265 "$inputopt" "$outputopt"; } 2>&1 `
    #    	r=`echo "$spt"| grep "real" | cut -f 2`
    #    	u=`echo "$spt"| grep "user" | cut -f 2`
    #    	s=`echo "$spt"| grep "sys" | cut -f 2`
    #    	
    #    	a=$(echo "$(echo $r | cut -d m -f 1)*60"|bc)
    #    	b=$(echo "$(echo $r | cut -d m -f 2 | cut -d s -f 1)"|bc)
    #    	intelreal265=$(echo "$a + $b"|bc)
    #    	
    #    	a=$(echo "$(echo $u | cut -d m -f 1)*60"|bc)
    #    	b=$(echo "$(echo $u | cut -d m -f 2 | cut -d s -f 1)"|bc)
    #    	inteluser265=$(echo "$a + $b"|bc)
    #    	
    #    	a=$(echo "$(echo $s | cut -d m -f 1)*60"|bc)
    #    	b=$(echo "$(echo $s | cut -d m -f 2 | cut -d s -f 1)"|bc)
    #    	intelsys265=$(echo "$a + $b"|bc)
    #    
    #    	echo $intelreal265 $inteluser265 $intelsys265 >> $timeinfo.par$count.intel265.t$thread
    #    	#rm -rf $output/$(echo $file|cut -d / -f 3|cut -d . -f 1).265
    #    done
    #    echo "------------intel265-------------"
    #    echo "count of videos:$cnt"
    #    echo "threads:$thread"
    #    echo "task:$count"
    #    getCPUinfo $cpuinfo.par$count.intel265.t$thread
    #    getMEMinfo $meminfo.par$count.intel265.t$thread
    #    getTIMEinfo $timeinfo.par$count.intel265.t$thread
    #done
    
    kill -9 `ps aux | grep sar | awk '{print $2}'` 1>/dev/null 2>&1
done
