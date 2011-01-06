fs   = require 'fs'
path = require 'path'
jade = require 'jade'

process.env.TZ = 'Pacific/Auckland'


tag_docs = {}
tweet_index = []

stupid_count = 1

htdocsbase = {
  tweets: '/var/www/flaviusb.net/tweets/',
  redirs: '/home/flaviusb/code/flaviusb.me/'
}

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
  return md[if isleap(y) then 1 else 0][m]+d

date2days = (date) ->
  ymdptod date.getFullYear(), date.getMonth(), date.getDate()

lyrs = (y) -> Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400)

rellyrs = (y) -> lyrs(y) - lyrs(1970)

year2days = (yr) -> ((yr - 1970) * 365) + rellyrs(yr)


mkdirs = (dirname, callback) ->
  pathsCreated = []
  pathsFound = []
  makeNext = () ->
    #console.log pathsFound
    fn = pathsFound.pop()
    if not fn?
      if callback? then callback(null, pathsCreated)
    else
      fs.mkdir fn, 0777, (err, data) ->
        if not err?
          pathsCreated.push(fn)
          makeNext()
        else if callback?
          callback(err)
  findNext = (fn) ->
    fs.stat fn, (err, stats) ->
      if err?
        if err.errno is 2
          pathsFound.push(fn)
          findNext(path.dirname(fn))
        else if callback?
          callback err
      else if (stats.isDirectory())
        makeNext()
      else if callback?
        callback(new Error('Unable to create directory at '+fn))
  findNext(dirname)

getShortSlugInfix = (orig_date, ord) ->
  ((newbase60 (year2days(orig_date.getFullYear()) + date2days(orig_date))) + "/" + (newbase60 ord))

getLongSlugInfix = (orig_date, ord) ->
  "#{orig_date.getFullYear()}/#{orig_date.getMonth() + 1}/#{orig_date.getDate()}/#{ord}/"

writetweets = (redirfrom, redirend) ->
  return (error, jadedat) ->
      if (error)
        throw error
      #redirfrom = ("/t/" + getShortSlugInfix(orig_date, ord))
      redirbase = "http://flaviusb.net/tweets/"
      #redirend  = getLongSlugInfix(orig_date, ord)
      #console.log redirfrom
      #console.log redirend
      routes[redirfrom] = (redirbase + redirend)
      stupid_count -= 1
      #console.log jadedat
      mkdirs (htdocsbase.tweets + redirend), (err, done) ->
        if err? then console.log err
        if done?
          #console.log done
          fs.writeFile (htdocsbase.tweets + redirend + "index.html"), jadedat

writeHashTag = (tagname) ->
  console.log "Creating #{tagname}"
  return (error, jadeat) ->
    if error?
      throw error
    console.log "Writing #{tagname}, to #{htdocsbase.tweets}hashtags/#{tagname}.html"
    fs.writeFile "#{htdocsbase.tweets}hashtags/#{tagname}.html", jadeat
    console.log "Done with #{tagname}"

writeIndex =  (error, jadeat) ->
  if error?
    throw error
  console.log "Writing index of tweets"
  fs.writeFile "#{htdocsbase.tweets}index.html", jadeat
  console.log "Done with index"

writeHashIndex =  (error, jadeat) ->
  if error?
    throw error
  console.log "Writing index of hash tags"
  fs.writeFile "#{htdocsbase.tweets}/hashtags/index.html", jadeat
  console.log "Done with index of hash tags"


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

fs.readFile 'flaviusb.json', 'utf-8', (err, data) ->
  if err?
    throw err
  tweets = JSON.parse data
  # Sort by date
  tweets.sort (l, r) ->
    dl = new Date(l.created_at).valueOf()
    dr = new Date(r.created_at).valueOf()
    return dr - dl
  prev_tweet = null
  tweets2 = []
  for tweet in tweets
    tweet2 = {}
    tweet2.created_at = (new Date(tweet.created_at)).toLocaleString()
    tweet2.text       = tweet.text
    tweet2.tags       = str2hashtags tweet2.text
    tweet2.fancytext  = str2fancytext tweet2.text
    tweets2.push tweet2
  fs.writeFile (__dirname + "/flaviusb.json"), JSON.stringify(tweets2), 'utf-8'
