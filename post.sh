#/bin/bash

coffee -c post.coffee
node post.js "$1"
git commit flaviusb.json -m "Automated commit of generated tweet from flaviusb.me."
coffee gentweets.coffee
curl http://flaviusb.me/command/regenroutes
