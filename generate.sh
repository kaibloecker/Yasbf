#!/bin/bash -e

# Check if sed is installed
if [ "$(command -v sed)" = "" ]; then
	echo "Y U NO INSTALL SED?!"
	exit
fi

# Check if markdown is installed
if [ "$(command -v markdown)" = "" ]; then
	echo "Y U NO INSTALL MARKDOWN?!"
	exit
fi

# Print welcome message
echo "--$(date +"%Y-%m-%d %T")--
Yasbf has been started."

# Read configuration from the config.cfg file
echo "Reading configuration file..."
source config.cfg

# Convert markdown files to html
for MD_FILE in posts/*.md
do
	HTML_FILE=`echo $MD_FILE | sed -e 's/.*\///' -e 's/\.md$//'`.html
	head -n 1 $MD_FILE | sed -e 's/^# //' > posts/$HTML_FILE
	head -n 3 $MD_FILE | tail -n 2 >> posts/$HTML_FILE
	sed -e '1,3d' $MD_FILE | markdown >> posts/$HTML_FILE
done

# Remove end slash from the url/link (if it has one)
if [ $(echo $url | sed "s/^.*\(.\)$/\1/") = "/" ]; then
	url=$(echo $url | sed 's/\(.*\)./\1/')
fi

# Create archive folder (if it doesn't exist)
if [ ! -d "archiv" ]; then
	mkdir archiv
fi

# Fill feed template with custom content
feedtemplate=$(sed -e "s/{title}/$title/g" -e "s/{todayrss}/$(date -R)/g" -e "s/{description}/$description/g" -e "s^{url}^$url^g" templates/feed.rss)
# Fill header template with custom content
headertemplate=$(sed -e "s/{title}/$title/g" -e "s/{author}/$author/g" -e "s/{description}/$description/g" -e "s^{url}^$url^g" templates/header.html)
# Fill footer template with custom content
footertemplate=$(sed -e "s/{year}/$(date +%Y)/g" -e "s/{author}/$author/g" templates/footer.html)

# Sort the files in the folder 'posts' by a custom date
cd posts
for file in *.html
do
	customdate="$(sed -n 2p $file)"
	customdate="20${customdate:6:2}${customdate:3:2}${customdate:0:2}.${customdate:9:2}${customdate:12:2}"
	if [ $(echo $customdate | sed 's/\.//') -le $(date +%Y%m%d%H%M) ]; then
		index="${index}${customdate},${file}\n"
	fi
done

# Generate ALL the posts
echo "Generating ALL the posts..."
for key in `echo -e ${index} | sort -r`
do
	# Some variables
	filename="$(echo "$key" | sed 's/.*,//')"
	postheadline="$(sed -n 1p $filename)"
	postdate="$(sed -n '2s/ .*//p' $filename)"
	archivefolder="$(echo $postdate | sed -e 's/\(..\)\.\(..\)\.\(..\)/20\3\/\2\/\1/')"
	postcontent="$(sed -n '4,$p' $filename)"
	postlink="$url/archiv/$archivefolder/$filename"
	if [ "$flattr_id" != "" ]; then
		flattr_postheadline="$(echo "$postheadline" | sed 's/ /%20/g')"
		flattr_postlink="$(echo "$postlink" | sed -e 's/:/%3A/g' -e 's/\//%2F/g')"
		flattr_link="https://flattr.com/submit/auto?user_id=$flattr_id&title=$flattr_postheadline&language=$flattr_lang&category=$flattr_category&url=$flattr_postlink"
		flattr="<a href=\"$flattr_link\" class=\"flattrbutton\"></a>"
	fi
	article="<h1><a href=\"$postlink\">$postheadline</a></h1> <h3 class=\"postdate\">$postdate</h3> $postcontent $flattr"

	# Generate the blog posts and the archive
	if [ ! -d "../archiv/$archivefolder" ]; then
		mkdir -p "../archiv/$archivefolder"
	fi
	echo "$headertemplate <article>$article</article> $footertemplate" > ../archiv/$archivefolder/$filename
	archive="$archive <li><span>$postdate</span> » <a href=\"$postlink\">$postheadline</a></li>"

	# Generate the index.html
	let indexcount=indexcount+1
	if [ $indexcount -eq 1 ]; then
		indexhtml="$indexhtml $article"
	elif [ $indexcount -le $posts_on_blog_index ]; then
		indexhtml="$indexhtml <hr /> $article"
	fi

	# Generate the rss feed
	let rsscount=rsscount+1
	if [ $rsscount -le $amount_of_rss_items ]; then
		rssdate="$(sed -n 2p $filename)"
		rssdate="$(date -Rd "20${rssdate:6:2}-${rssdate:3:2}-${rssdate:0:2} ${rssdate:9:2}:${rssdate:12:2}")"
		feed="$feed <item><title>$postheadline</title><pubDate>$rssdate</pubDate><description><![CDATA[$postcontent]]></description><link>$postlink</link><guid>$postlink</guid><atom:link rel=\"payment\" href=\"$flattr_link\" type=\"text/html\" /></item>"
	fi
done
cd ..

# Create index.html
echo "Creating blog index..."
indexhtml="$headertemplate <article>$indexhtml</article> $footertemplate"
echo $indexhtml > index.html

# Create feed.rss
echo "Creating rss feed..."
feed="$feedtemplate $feed </channel></rss>"
echo $feed > feed.rss

# Create archive.html
echo "Creating archive..."
archive="$headertemplate <div class=\"archive\"><h1>Blog Archive</h1><ul class=\"archive\">$archive</ul></div> $footertemplate"
echo $archive > archiv/index.html

# Goodbye message
echo "
100%[======================================]
Blog generation was successful."
