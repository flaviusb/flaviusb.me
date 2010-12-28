fs = require 'fs'
jade = require 'jade'

newbase60 = (num) ->
  ret = ""
  if num is 0 or not num?
    return "0"
  space = "0123456789ABCDEFGHJKLMNPQRSTUVWXYZ_abcdefghijkmnopqrstuvwxyz"
  num = Math.abs(Math.floor(num))
  mod = num % 60
  div = Math.floor(num / 60)
  ret = space[mod] + ret
  while not (div is 0)
    mod = div % 60
    div = Math.floor(div / 60)
    ret = space[mod] + ret
  return ret

isleap = (y) ->
  return (y % 4 == 0 && (y % 100 != 0 || y % 400 == 0))

ymdptod = (y,m,d) ->
  md = [[0,31,59,90,120,151,181,212,243,273,304,334],[0,31,60,91,121,152,182,213,244,274,305,335]]
  return md[if isleap(y) then 1 else 0][m-1]+d

date2days = (date) ->
  ymdptod date.getFullYear(), date.getMonth(), date.getDate()

dateprint = (ord, orig_date) ->
  return (error, jadedat) ->
      if (error)
        throw error
      console.log ((newbase60 date2days(orig_date)) + "/" + (newbase60 ord))
      console.log "http://flaviusb.net/tweets/#{orig_date.getYear()}/#{orig_date.getMonth()}/#{orig_date.getDay()}/#{ord}/"
      console.log jadedat

str2hashtags = (str) ->
  ret = []
  strs = str.split(/[^A-Za-z0-9#]/)
  for i in strs
    if i[0] == '#'
      ret.push i[1..]
  ret

fs.readFile 'flaviusb.json', 'utf-8', (err, data) ->
  if (err)
    throw err
  tweets = JSON.parse data
  prev_date = new Date("1970-01-01")
  prev_ord = 0
  for tweet in tweets
    orig_date = new Date(tweet.created_at)
    if date2days(prev_date) == date2days(orig_date)
      prev_ord += 1
    else
      prev_ord = 0
    tweet.created_at = (new Date(tweet.created_at)).toLocaleString()
    tweet.tags = str2hashtags tweet.text
    jade.renderFile __dirname + "/tweet.jade", { locals: tweet }, dateprint(prev_ord, orig_date)
    prev_date = orig_date