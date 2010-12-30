fs = require 'fs'
jade = require 'jade'

routes = []

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
  return md[if isleap(y) then 1 else 0][m-1]+d

date2days = (date) ->
  ymdptod date.getFullYear(), date.getMonth(), date.getDate()

lyrs = (y) -> Math.floor(y / 4) - Math.floor(y / 100) + Math.floor(y / 400)

rellyrs = (y) -> lyrs(y) - lyrs(1970)

year2days = (yr) -> ((yr - 1970) * 365) + rellyrs(yr)


mkdirs = (dirname, callback) ->
  pathsCreated = []
  pathsFound = []
  makeNext = () ->
    fn = pathsFound.pop()
    if not fn?
      if callback? then callback(null, pathsCreated)
    else
    fs.mkdir fn, (err) ->
      if not err?
        pathsCreated.push(fn)
        makeNext()
      else if callback?
        callback(err)
  findNext = (fn) ->
    fs.stat fn, (err, stats) ->
      if err?
        if (err.errno is process.ENOENT)
          pathsFound.push(fn)
          findNext(path.dirname(fn))
        else if callback?
          callback err
      else if (stats.isDirectory())
        makeNext()
      else if callback?
        callback(new Error('Unable to create directory at '+fn))
  findNext(dirname)

writetweets = (ord, orig_date) ->
  return (error, jadedat) ->
      if (error)
        throw error
      redirfrom = ((newbase60 (year2days(orig_date.getFullYear()) + date2days(orig_date))) + "/" + (newbase60 ord))
      redirbase = "http://flaviusb.net/tweets/"
      redirend  = "#{orig_date.getFullYear()}/#{orig_date.getMonth() + 1}/#{orig_date.getDate()}/#{ord}/"
      console.log redirfrom
      console.log redirend
      routes.push [redirfrom, (redirbase + redirend)]
      console.log jadedat
      mkdirs (htdocsbase.tweets + redirend), (err) ->
        console.log err
      fs.writeFile (htdocsbase.tweets + redirend + "index.html") jadedat
      

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
  tweets.sort (l, r) ->
    dl = new Date(l.created_at).valueOf()
    dr = new Date(r.created_at).valueOf()
    return dl - dr
  for tweet in tweets
    orig_date = new Date(tweet.created_at)
    if date2days(prev_date) == date2days(orig_date)
      prev_ord += 1
    else
      prev_ord = 0
    tweet.created_at = (new Date(tweet.created_at)).toLocaleString()
    tweet.tags = str2hashtags tweet.text
    jade.renderFile __dirname + "/tweet.jade", { locals: tweet }, writetweets(prev_ord, orig_date)
    prev_date = orig_date
