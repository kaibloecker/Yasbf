# Yasbf #

Yasbf is a basic blogging framework originally written by [Poapfel](https://github.com/Poapfel/Yasbf).

Just clone this repository onto your webserver. The master branch is always the most stable version.

For a sneak-peak of the layout, just run the generate.sh script. After that you should edit the config.cfg file, especially the url variable to get all the links working.

Write your posts in individual files in the posts directory.

* The first line will be your posts headline.
* The second line is for a date in the form DD.MM.YY HH:MM.
* The third line needs to be blank.
* Everything between the fourth line and the last will make up your blogpost.

For the text of your post you can use plain HTML (save the file as .html), or you use the Markdown markup language (in which case you save the file as .md). If you use Markdown you can start the first line with a '# ' (a hash followed by a blank), for example if you use an editor that shows Markdown markup.

Don't forget to run the generate.sh script after every change.

If you are using flattr, you can let Yasbf generate flattr-links for you automatically (on the website and in the feed). If you don't know about flattr, visit [flattr.com](https://flattr.com/) to learn more.

--------

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/thing/632852/kaibloeckerYasbf-on-GitHub) flattr me

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/thing/536465/Yasbf) flattr Poapfel
