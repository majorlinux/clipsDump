#!/bin/bash

while getopts "ab:c:e:ls:f:" OPTION
do
	case "$OPTION" in
		c)
		while read STRING
		do
			clientid=$STRING
		done < $OPTARG
		;;
		s)
		startDate=$OPTARG
		endDate=2999-12-31T23:59:59Z
		;;
		e)
		startDate=1970-01-01T00:00:00Z
		endDate=$OPTARG
		;;
		b)
		streamer=$OPTARG
		;;
		a)
		startDate="all"
		;;
		l)
		list=true
		;;
		f)
		save=true
		location=$OPTARG
	esac
done

if [ -z "$clientid" ]
then
	printf 'Please submit your Twitch API client ID: '
	read -r clientid
fi

#while read STRING
#do
#	clientid=$STRING
#done < clientID.txt
#fi

#while read STRING2
#do
#	broadcasterid=$STRING2
#done < broadcasterid.txt

if [ -z "$streamer" ]
then
	printf 'Whose Twitch clips would you like to download? '
	read -r streamer
fi

broadcasterid="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/users?login='$streamer'' | jq -r '.data[] | .id')" > /dev/null



if [ -z $startDate ]
then
	printf 'Please enter the Twitch clip dump starting date in UTC (Format: 2019-01-30T22:19:54Z or "all" for all clips): '
	read -r startDate
fi

if [ "$startDate" == "all" ]
then
	echo $startDate
	if [ "$list" == "true" ]
	then
		curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100' | jq -r '.data[] | .url'
	elif [ $save == "true" ]
	then
		curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100' | jq -r '.data[] | .url' | tee $location > /dev/null
	else
		url="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100' | jq -r '.data[] | .url')"

		youtube-dl -o  "./%(title)s.%(ext)s" $url
	fi

	page="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100' | jq -r '.pagination.cursor')"

	while [ $page != 'null' ]; do
		if [ "$list" == "true" ]
		then
			curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&after='$page'' | jq -r '.data[] | .url'
		elif [ $save == "true" ]
		then
			curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&after='$page'' | jq -r '.data[] | .url' | tee -a $location > /dev/null
		else
			url="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&after='$page'' | jq -r '.data[] | .url')"

			youtube-dl -o  "./%(title)s.%(ext)s" $url
		fi

		page="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&after='$page'' | jq -r '.pagination.cursor')"
	done

else
	if [ -z $endDate ]
	then
		printf 'Please enter the Twitch clip dump ending date in UTC (Format: 2019-01-30T22:19:54Z): '
		read -r endDate
	fi

	if [ "$list" == "true" ]
	then
		curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at='$startDate'&ended_at='$endDate'' | jq -r '.data[] | .url'
	elif [ "$save" == "true" ]
	then
		curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at='$startDate'&ended_at='$endDate'' | jq -r '.data[] | .url' | tee $location > /dev/null
	else
		url="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at='$startDate'&ended_at='$endDate'' | jq -r '.data[] | .url')" > /dev/null

		youtube-dl -o  "./%(title)s.%(ext)s" $url
	fi

	page="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at='$startDate'&ended_at='$endDate'' | jq -r '.pagination.cursor')"

	while [ $page != 'null' ]
	do
		if [ $list == "true" ]
		then
			curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at='$startDate'&ended_at='$endDate'&after='$page'' | jq -r '.data[] | .url'
		elif [ $save == "true" ]
		then
			curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at='$startDate'&ended_at='$endDate'&after='$page'' | jq -r '.data[] | .url' | tee -a $location > /dev/null
		else
			url="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at='$startDate'&ended_at='$endDate'&after='$page'' | jq -r '.data[] | .url')" > /dev/null

			youtube-dl -o  "./%(title)s.%(ext)s" $url
		fi

		page="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at='$startDate'&ended_at='$endDate'&after='$page'' | jq -r '.pagination.cursor')"
	done
fi
