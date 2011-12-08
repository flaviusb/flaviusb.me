At present, this is a small url redirect service for my personal use.
This is inspired by [Whistle](http://tantek.pbworks.com/w/page/21743973/Whistle) by Tantek.

Design

- single-letter content-type prefix, description, and ActivityStreams equivalent object-type if any
    - a - audio recording, speech, talk, session, sound 
    - b - blog post, article (structured, with headings), essay
          + http://activitystrea.ms/schema/1.0/article 
    - c - code, sample code, library, open source, code example
    - d - diff, edit, change
    - e - event - hCalendar
    - f - favorited - primarily just a URL, often to someone else's content. for more, see 'r' below 
    - g - geolocation, location, checkin, venue checkin, dodgeball, foursquare
    - h - hyperlink - e(x)ternal reference, link, etc. use of short URL to link to things that I expect to die or move, untrustworthy permalinks. 
    - i - identifier - on another system using subdirectory as system id space
          + i/i/ - ISBN (compressed via NewBase60)
          + i/a/ - ASIN (compressed via NewBase60)
    - j - reserved
    - k - reserved
    - l . (skipping due to resemblance to 1, per print-safety design principle, related: ShortURLPrintExample)
    - m - (message like email, permalink to external list archive, or private blog archive, or a sender-hosted message)
    - n - reserved
    - o - physical objects (e.g. stuff from Amazon, or URLs attached to actual specific physical objects) 
    - p - photo (re-using Flickr's design choice of flic.kr/p/ for photo short URLs)
    - q - reserved
    - r - review, recommendation, comment regarding/response/rebuttal - hReview/xfolk
    - s - slides, session presentation, S5 
    - t - text, (plain) text, tweet, thought, note, unstructured, untitled 
          + http://activitystrea.ms/schema/1.0/note 
          url of form /t/S+/n
          Where S+ is one or more sexagesimal digits in NewBase60, corresponding to the number of days since
          1970-01-01 (the epoch), and n is the ordinal of that post that day, in NewBase60.
    - u - (update, could be used for status updates of various types, profile updates)
    - v - video recording 
    - w - work, work in progress, wiki, project, draft, task list, to-do, do, gtd
    - x - XMDP Profile 
    - y - reserved
    - z - reserved 
    - ☸ - The wheel of Dharma; links to cheevos




Things needed for flaviusb.me:

node.js
npm
coffeescript
ssh
nginx
octopress?
