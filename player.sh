#!/bin/bash

# return 1 if play is runing, otherwise return 0.
_isRuning(){
	ps -ef | grep $1 | grep -v grep
	if [ $? -ne 0 ]; then
		return 0
	else
		return 1
	fi
}

# update play list and init control file.
_list(){
	if [ ! -d ~/.player ]; then
		echo 'make directory ~/.player.'
		mkdir ~/.player
	fi
	echo 'create play list ...'
	find ~/Music -type f | grep -e mp3$ > ~/.player/music.lst
	echo 'init control file ...'
	wc -l ~/.player/music.lst | awk '{print $1i}' i='\t1' > ~/.player/control.cfg
}

# execute play command
_play(){
	# get music to play
	idx=$1
	file=`sed -n "${idx}p" ~/.player/music.lst`
	nohup /usr/bin/play "${file}" > /tmp/nohup.out 2>&1 &
	# update index in the control file
	sed -i -r "s/\t[0-9]+/\t${idx}/1" ~/.player/control.cfg
	echo "Playing index ${idx}, file is ${file} ..."
}

# start
_start(){
	echo 'start ... '
	# return if it is runing.
	_isRuning /usr/bin/play
	if [ $? -eq 1 ]; then
		echo "It is playing ..."
		return
	fi
	# update list and 
	_list
	_play 1
}

_move(){
	# get next music index
	read cnt idx < ~/.player/control.cfg
	idx=$((( $idx - 1 + $1 + $cnt ) % $cnt + 1 ))

	# kill current process and start another one.
	killall /usr/bin/play
	_play $idx
}

# next
_next(){
	if [ "$1" == "1" -o "$1" == "-1" ]; then
		_move $1
		return
	fi
	read cnt idx < ~/.player/control.cfg
	_move $(( $RANDOM % $cnt ))
}

checkitem="$0"
let procCnt=`ps -A --format='%p%P%C%x%a' --width 2048 -w --sort pid|grep "$checkitem"|grep -v grep|grep -v " -c sh "|grep -v "sh -c"|grep -v "$$" | grep -c sh|awk '{printf("%d",$1)}'`

if [ ${procCnt} -gt 0 ] ; then 
	# control
	if [ "$1" == "start" ]; then
		echo 'player is runing ...'
	elif [ "$1" == "next" ]; then
		_next 1
	elif [ "$1" == "prev" ]; then
		_next -1
	elif [ "$1" == "random" ]; then
		_next
	elif [ "$1" == "stop" ]; then
		kill -9 `ps -ef|grep -e /usr/bin/play -e "$checkitem"|grep -v grep|grep -v "sh -c"|awk '{print $2}'` > /tmp/nohup.out 
		echo "The player has been shutdown."
	else
		echo "unknown command : $1"
	fi
else
	# control
	if [ "$1" == "start" ]; then
		_start
		(while true
		do
			_isRuning /usr/bin/play
			if [ $? -eq 0 ]; then
				_next 1
			fi
			sleep 2s;
		done) > /tmp/nohup.out 2>&1 &
	elif [[ "next prev random stop" =~ "$1" ]]; then
		echo 'Player has not been started.'
	else
		echo "unknown command : $1"
	fi
fi
exit 0

