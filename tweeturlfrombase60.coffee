sys = require('sys')
fs = require 'fs'
querystring = require 'querystring'
process.env.TZ = 'Pacific/Auckland'
path = require 'path'
jade = require 'jade'
http        = require 'http'
urls        = require 'url'

#thing = "{\n" + (("  \"" + i + "\": " + j) for i,j in space).join("\n") + "\n}\n"

conv = {
  "0": 0
  "1": 1
  "2": 2
  "3": 3
  "4": 4
  "5": 5
  "6": 6
  "7": 7
  "8": 8
  "9": 9
  "A": 10
  "B": 11
  "C": 12
  "D": 13
  "E": 14
  "F": 15
  "G": 16
  "H": 17
  "J": 18
  "K": 19
  "L": 20
  "M": 21
  "N": 22
  "P": 23
  "Q": 24
  "R": 25
  "S": 26
  "T": 27
  "U": 28
  "V": 29
  "W": 30
  "X": 31
  "Y": 32
  "Z": 33
  "_": 34
  "a": 35
  "b": 36
  "c": 37
  "d": 38
  "e": 39
  "f": 40
  "g": 41
  "h": 42
  "i": 43
  "j": 44
  "k": 45
  "m": 46
  "n": 47
  "o": 48
  "p": 49
  "q": 50
  "r": 51
  "s": 52
  "t": 53
  "u": 54
  "v": 55
  "w": 56
  "x": 57
  "y": 58
  "z": 59
}

frombase60 = (str) ->
  foo = 0
  for i, idx in str
    foo += (conv[i] * Math.pow(10, idx))
  return foo


days2date = (days) -> new Date(days * 86400 * 1000)

getLongSlug = (date, ord) ->
   fulldate = days2date(frombase60(date))
   "http://flaviusb.net/tweets/#{fulldate.getFullYear()}/#{fullDate.getMonth()}/#{fulldate.getDate}/#{frombase60(ord)}"

#leaps = (days) -> 
#days2year = (days) -> Math.floor(days / 365) + 1970 + leaps

fourohfour = (req, res, url) ->
  res.writeHeader 404, 'Content-Type': 'text/html'
  options = locals: { url: url }
  jade.renderFile __dirname + "/404.jade", options, (error, data) ->
    res.end data

threeohone = (req, res, url) ->
  res.writeHeader 301, 'Location': url , 'Content-Type': 'text/html'
  options = locals: { url: url }
  jade.renderFile __dirname + "/301.jade", options, (error, data) ->
    res.end data

choose_path = (req, res) ->
  url = urls.parse(req.url).pathname
  urlparts = url.split("/")
  if urlparts.length < 3
    fourohfour(req, res, url)
  else
    threeohone(req, res, getLongSlug(urlparts[1], urlparts[2]))

server = http.createServer (req, res) ->
  choose_path(req, res)

server.listen 8080

