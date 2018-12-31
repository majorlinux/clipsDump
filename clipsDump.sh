#!/bin/bash

while read STRING
do
	clientid=$STRING
done < clientID.txt

while read STRING2
do
	broadcasterid=$STRING2
done < broadcasterid.tx

url="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at=2018-01-01T00:00:00Z&ended_at=2018-12-31T00:00:00Z' | jq -r '.data[] | .url')" > /dev/null

youtube-dl -o  "/mnt/e/Videos/Twitch Clips/clipsOfTheYear/%(title)s.%(ext)s" $url

page="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at=2018-01-01T00:00:00Z&ended_at=2018-12-31T00:00:00Z' | jq -r '.pagination.cursor')"

while [ $page != 'null' ]; do
	url="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at=2018-01-01T00:00:00Z&ended_at=2018-12-31T00:00:00Z&after='$page'' | jq -r '.data[] | .url')" > /dev/null

	youtube-dl -o  "/mnt/e/Videos/Twitch Clips/clipsOfTheYear/%(title)s.%(ext)s" $url

	page="$(curl -s -H 'Client-ID:'$clientid'' -X GET 'https://api.twitch.tv/helix/clips?broadcaster_id='$broadcasterid'&first=100&started_at=2018-01-01T00:00:00Z&ended_at=2018-12-31T00:00:00Z&after='$page'' | jq -r '.pagination.cursor')"

done
