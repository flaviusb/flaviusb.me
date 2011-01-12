sys = require('sys')
twitter = require('twitter')
fs = require 'fs'
querystring = require 'querystring'
process.env.TZ = 'Pacific/Auckland'


str2hashtags = (str) ->
  ret = []
  strs = str.split(/[^A-Za-z0-9#]/)
  for i in strs
    if i[0] == '#'
      ret.push i[1..]
  ret

str2fancytext = (str) ->
  str.replace(/#[A-Za-z0-9]*/g, (tag) ->
    "<a href=\"http://flaviusb.net/tweets/hashtags/#{tag[1..]}\" rel=\"tag\">#{tag}</a>")


if not process.argv[2]?
  console.log "No post provided. Not posting anything."
  process.exit(1)

fs.readFile 'conf.json', 'utf-8', (err, data) ->
  if err?
    console.log err
    return
  conf = JSON.parse data
  twit = new twitter({
      consumer_key: conf.c_k,
      consumer_secret: conf.c_s,
      access_token_key: conf.a_t_k,
      access_token_secret: conf.a_t_s
  })
  fs.readFile 'flaviusb.json', 'utf-8', (err, data) ->
    if err?
      console.log err
      return
    tweets = JSON.parse data
    newtweet = {
      created_at: Date(Date.now).toLocaleString()
      text: process.argv[2]
      fancytext: str2fancytext process.argv[2]
      tags: str2hashtags process.argv[2]
    }
    tweets.unshift newtweet
    fs.writeFile (__dirname + "/flaviusb.json"), JSON.stringify(tweets), 'utf-8'
    twit.updateStatus newtweet.text, (err) ->
      if err?
        console.log err
      console.log 'foo'
