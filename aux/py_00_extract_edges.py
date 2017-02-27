# Prepare edge list with weights for each day (only RTs)

import os, json, sys, re, time
from datetime import datetime, timedelta

'''
Usage:
cd ~/Dropbox/research/Social\ Media\ and\ ICs
python code/py_00_extract_edges.py data/icourts-hashtag-tweets.json

'''

## note about files
## first variable is user id of who sends the retweet / mention
## second variable is screen_name for that user
## third variable is user id of who is retweeted / mentioned
## fourth variable is screen_name for that user

## for manual retweets, they will be captured as mentions

filename = sys.argv[1:]

rtregex = re.compile(r'RT @(\w*):')

date_old_rt = str(0)
date_old_m = str(0)

filehandle = open(filename, 'r')
for line in filehandle:
    # read line into json
    try:
        tweet = json.loads(line)
    except:
        continue
    try:
        text = tweet['text']
    except:
        continue
    # check if retweets
    rt = rtregex.search(text)
    if rt:
        date = datetime.strptime(tweet['created_at'],'%a %b %d %H:%M:%S +0000 %Y') \
            - timedelta(hours=5)
        date = date.strftime('%Y-%m-%d')
        if date != date_old_rt:
            print date
            frt = open('edges/retweet-edges-' + str(date) + '.csv', "a")
            date_old_rt = date
        # for automatic retweets
        if 'retweeted_status' in tweet:
            linewrite = tweet['user']['id_str'] + "," + tweet['user']['screen_name']
            linewrite = linewrite + "," + tweet['retweeted_status']['user']['id_str']
            linewrite = linewrite + "," + tweet['retweeted_status']['user']['screen_name'] + ",rt"
            print >> frt, linewrite
    if len(tweet['entities']['user_mentions'])>0:
        for user in tweet['entities']['user_mentions']:
            linewrite = tweet['user']['id_str'] + "," + tweet['user']['screen_name']
            linewrite = linewrite + "," + user['id_str']
            linewrite = linewrite + "," + user['screen_name'] + ",m"
            print >> frt, linewrite  





