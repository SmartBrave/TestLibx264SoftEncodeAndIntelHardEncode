#!/bin/bash

[[ $# -lt 1 ]] && echo "Usage: $0 file" && exit

result=$1


#sed -i 's/$/|/g' $result

sed -n '/x264/,+6p' $result >libx264
sed -n '/lentenc/,+6p' $result >lentenc
sed -n '/intel264/,+6p' $result >intel264
sed -n '/intel265/,+6p' $result >intel265

#task=1
for task in {1,4,8,16}
do
    table_header="<table><tr><th colspan="2">指标</th><th colspan="4">libx264</th><th colspan="4">Intel264</th></tr><tr><th colspan="2">threads</th><th>1</th><th>2</th><th>4</th><th>8</th><th>1</th><th>2</th><th>4</th><th>8</th></tr>"
    table_body=""
    table_footer="</table>"

    table_body=$table_body"<tr><th rowspan="4">CPU</th></tr><tr><th>max(%)</th>"
    #cpu max
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" libx264 >libx264.t$thread
	str=$( echo $( sed -n "/task:$task/,+1p" libx264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"| cut -d \" \" -f 4`</td>"
    done
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" intel264 >intel264.t$thread
	str=$( echo $( sed -n "/task:$task/,+1p" intel264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"| cut -d \" \" -f 4`</td>"
    done
    table_body=$table_body"</tr>"
    #cpu min
    table_body=$table_body"<tr><th>min(%)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+1p" libx264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 7`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+1p" intel264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 7`</td>"
    done
    table_body=$table_body"</tr>"
    #cpu ave
    table_body=$table_body"<tr><th>ave(%)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+1p" libx264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 10`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+1p" intel264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 10`</td>"
    done
    table_body=$table_body"</tr>"

    #mem
    table_body=$table_body"<tr><th rowspan="4">MEM</th></tr><tr><th>max(%)</th>"
    #mem max
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" libx264 >libx264.t$thread
	str=$( echo $( sed -n "/task:$task/,+2p" libx264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 14`</td>"
    done
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" intel264 >intel264.t$thread
	str=$( echo $( sed -n "/task:$task/,+2p" intel264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 14`</td>"
    done
    table_body=$table_body"</tr>"
    #mem min
    table_body=$table_body"<tr><th>min(%)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+2p" libx264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 17`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+2p" intel264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 17`</td>"
    done
    table_body=$table_body"</tr>"
    #mem ave
    table_body=$table_body"<tr><th>ave(%)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+2p" libx264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 20`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+2p" intel264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 20`</td>"
    done
    table_body=$table_body"</tr>"

    #time
    table_body=$table_body"<tr><th rowspan="4">TIME</th></tr><tr><th>real(s)</th>"
    #time real
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" libx264 >libx264.t$thread
	str=$( echo $( sed -n "/task:$task/,+3p" libx264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 23`</td>"
    done
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" intel264 >intel264.t$thread
	str=$( echo $( sed -n "/task:$task/,+3p" intel264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 23`</td>"
    done
    table_body=$table_body"</tr>"
    #time user
    table_body=$table_body"<tr><th>user(s)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+3p" libx264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 26`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+3p" intel264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 26`</td>"
    done
    table_body=$table_body"</tr>"
    #time sys
    table_body=$table_body"<tr><th>sys(s)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+3p" libx264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 29`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+3p" intel264.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 29`</td>"
    done
    echo "<h5>并发数:$task</h5>"
    echo $table_header$table_body$table_footer

    table_body=$table_body"</tr>"
    table_header="<table><tr><th colspan="2">指标</th><th colspan="4">视骏265</th><th colspan="4">Intel265</th></tr><tr><th colspan="2">threads</th><th>1</th><th>2</th><th>4</th><th>8</th><th>1</th><th>2</th><th>4</th><th>8</th></tr>"
    table_body=""
    table_footer="</table>"

    table_body=$table_body"<tr><th rowspan="4">CPU</th></tr><tr><th>max(%)</th>"
    #cpu max
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" lentenc >lentenc.t$thread
	str=$( echo $( sed -n "/task:$task/,+1p" lentenc.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"| cut -d \" \" -f 4`</td>"
    done
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" intel265 >intel265.t$thread
	str=$( echo $( sed -n "/task:$task/,+1p" intel265.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"| cut -d \" \" -f 4`</td>"
    done
    table_body=$table_body"</tr>"
    #cpu min
    table_body=$table_body"<tr><th>min(%)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+1p" lentenc.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 7`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+1p" intel265.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 7`</td>"
    done
    table_body=$table_body"</tr>"
    #cpu ave
    table_body=$table_body"<tr><th>ave(%)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+1p" lentenc.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 10`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+1p" intel265.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 10`</td>"
    done
    table_body=$table_body"</tr>"

    #mem
    table_body=$table_body"<tr><th rowspan="4">MEM</th></tr><tr><th>max(%)</th>"
    #mem max
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" lentenc >lentenc.t$thread
	str=$( echo $( sed -n "/task:$task/,+2p" lentenc.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 14`</td>"
    done
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" intel265 >intel265.t$thread
	str=$( echo $( sed -n "/task:$task/,+2p" intel265.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 14`</td>"
    done
    table_body=$table_body"</tr>"
    #mem min
    table_body=$table_body"<tr><th>min(%)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+2p" lentenc.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 17`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+2p" intel265.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 17`</td>"
    done
    table_body=$table_body"</tr>"
    #mem ave
    table_body=$table_body"<tr><th>ave(%)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+2p" lentenc.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 20`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+2p" intel265.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 20`</td>"
    done
    table_body=$table_body"</tr>"

    #time
    table_body=$table_body"<tr><th rowspan="4">TIME</th></tr><tr><th>real(s)</th>"
    #time real
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" lentenc >lentenc.t$thread
	str=$( echo $( sed -n "/task:$task/,+3p" lentenc.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 23`</td>"
    done
    for thread in {1,2,4,8}
    do
        sed -n "/threads:$thread/,+4p" intel265 >intel265.t$thread
	str=$( echo $( sed -n "/task:$task/,+3p" intel265.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 23`</td>"
    done
    table_body=$table_body"</tr>"
    #time user
    table_body=$table_body"<tr><th>user(s)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+3p" lentenc.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 26`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+3p" intel265.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 26`</td>"
    done
    table_body=$table_body"</tr>"
    #time sys
    table_body=$table_body"<tr><th>sys(s)</th>"
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+3p" lentenc.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 29`</td>"
    done
    for thread in {1,2,4,8}
    do
	str=$( echo $( sed -n "/task:$task/,+3p" intel265.t$thread) )
	table_body=$table_body"<td>`echo \"$str\"|cut -d \" \" -f 29`</td>"
    done
    table_body=$table_body"</tr>"

    echo $table_header$table_body$table_footer

    rm -rf libx264.t* lentenc.t* intel264.t* intel265.t*
done

rm -rf libx264 lentenc intel264 intel265
