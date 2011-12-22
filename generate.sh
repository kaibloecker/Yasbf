#!/bin/bash

#########################
#                       #
#    Config - Start     #
#                       #
#########################

author="" #Insert your name here
name="" #Insert the name of your site here
description="" #Insert a description of your site here
twitter="" #Insert your twitter username here
github="" #Insert your github username here
link="" #Link to your Yasbf instance for example: http://example.com/Yasbf
echo "RTFM" & exit #RTFM protection just uncomment or remove this line if you have configured the lines above

#########################
#                       #
#     Config - End      #
#                       #
#########################

#Disclaimer: Everything below this line has to be rewritten, I will do this soon...

metafeed=$(awk '{sub(/\$name/,name);sub(/\$today/,today);sub(/\$description/,description);sub(/\$link/,link);}1' name="$name" today="$(date)" description="$description" link="$link" templates/feed.xml)

header=$(awk '{sub(/\$name/,name);sub(/\$github/,github);sub(/\$description/,description);sub(/\$twitter/,twitter);sub(/\$author/,author);sub(/\$linkcss/,linkcss);sub(/\$linkicon/,linkicon);sub(/\$linkarchives/,linkarchives);sub(/\$linkfeed/,linkfeed);}1' name="$name" github="$github" description="$description" twitter="$twitter" author="$author" linkcss="$link/style.css" linkicon="$link/images/favicon.png" linkarchives="$link/archives.html" linkfeed="$link/feed.xml" templates/header.html)

footer=$(awk '{sub(/\$author/,author);sub(/\$year/,year);}1' author="$author" year="$(date +%Y)" templates/footer.html)

if [ -d "archives" ]; then
	rm -r archives
	mkdir archives
else
	mkdir archives
fi

cd posts
index=""
for file in *
do
	customdate="$(sed -n 2p $file)"
	customdate="20${customdate:6:2}${customdate:0:2}${customdate:3:2}.${customdate:9:2}${customdate:12:2}"
	index="${index}${customdate},${file}\n"
done

for key in `echo -e ${index} | sort -r`
do
	filename="$(echo "$key" | sed 's/.*,//')"
	postdate="$(sed -n 2p $filename | cut -d " " -f1)"
	postlink="/archives/$postdate/$filename"
	headline="<h1><a href="\".$postlink\"">$(sed -n 1p $filename)</a></h1>"
	h3="<h3>$postdate</h3>"
	article="$headline $h3 $(sed -n '4,$p' $filename)"
	itemfeed="<item><title>$(sed -n 1p $filename)</title><pubDate>$postdate</pubDate><description>$(sed -n '4,$p' $filename)</description><link>$link$postlink</link></item>"
	if [ ! -d "../archives/$postdate" ]; then
		mkdir "../archives/$postdate"
	fi
	archivesraw="<li><a href="\".$postlink\"">$postdate - $(sed -n 1p $filename)</a></li>"
	echo "$header <article>$article</article> $footer" | tr '\r' ' ' >> "../archives/$postdate/$filename"
	echo $article | tr '\r' ' ' >> ../article.html
	echo $itemfeed | tr '\r' ' ' >> ../itemfeed.xml
	echo $archivesraw | tr '\r' ' ' >> ../archivesraw.html
done
cd ..

article=$(cat article.html)

indexhtml="$header <article>$article</article> $footer"

if [ -f "index.html" ];
then
	rm index.html
fi

echo $indexhtml | tr '\r' ' ' >> index.html

if [ -f "feed.xml" ];
then
	rm feed.xml
fi

itemfeed=$(cat itemfeed.xml)
feed="$metafeed $itemfeed </channel></rss>"

echo $feed | tr '\r' ' ' >> feed.xml

if [ -f "archives.html" ];
then
	rm archives.html
fi

archives="$header <article><ul id="archives">$(cat archivesraw.html)</ul></article> $footer"
echo $archives | tr '\r' ' ' >> archives.html

rm archivesraw.html
rm article.html
rm itemfeed.xml
