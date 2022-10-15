#!/bin/bash
workdir=/root/webroot
url=$1
domain=`echo $url | cut -d '/' -f 3`

if [[ ${url} == http* ]];
	then
	docker build . -t httrack
    	mkdir -p "$workdir/$domain/httrack/"
	mkdir -p "$workdir/$domain/browsertrix-crawler/"
	docker run -d -p 9037:9037 -v "$workdir/$domain/browsertrix-crawler/:/crawls/collections/" -it webrecorder/browsertrix-crawler crawl --url $url --generateWACZ --workers 8 --text
	docker run -it --rm -v $workdir/$domain/httrack/:/data httrack bash -c "httrack --robots=0 $url"
	docker run -it --rm -v $workdir/$domain/httrack/:/data grep -Rl 'crossorigin="' . | xargs sed -i.bak -E -e 's/ integrity="[^"]+"//g' -e 's/ crossorigin="[^"]+"//g'
    else
    	echo "URL must start with http:// or https://"
        echo "Ex: ./archive.sh https://reclaimed.tech"
        exit
fi

