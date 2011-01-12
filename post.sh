#/bin/bash

coffee -c postandgen.coffee
node postandgen.js "$1"
git commit flaviusb.json -m "Automated commit of generated tweet from flaviusb.me."
#coffee gentweets.coffee
curl http://flaviusb.me/command/regenroutes
