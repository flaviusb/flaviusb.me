sys = require('sys')
twitter = require('twitter')
fs = require 'fs'
fs.readFile 'conf.json', 'utf-8', (err, data) ->
  conf = JSON.parse data
  twit = new twitter({
      consumer_key: conf.c_k,
      consumer_secret: conf.c_s,
      access_token_key: conf.a_t_k,
      access_token_secret: conf.a_t_s
  })
  tweets = []
  writeOut = () ->
    fs.writeFile (__dirname + "/flaviusb2.json"), JSON.stringify(tweets), 'utf-8'
  gettweets = (page) ->
    twit.get '/statuses/user_timeline.json', {count: 200, page: page, screen_name: 'flaviusb'}, (data) ->
      tweets = tweets.concat(data)
  onTime = (page) ->
    gettweets page
    if page < 5
      setTimeout(onTime, 1750, page + 1)
    else
      setTimeout(writeOut, 3000)
  onTime 1
