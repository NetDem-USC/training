import os, json, sys, re

'''
Usage:

cd ~/Dropbox/research/Social\ Media\ and\ ICs
python code/py_02_extract_user_data.py data/user-data.csv data/icourts-hashtag-tweets.json


'''

outfile = sys.argv[1]
filename = sys.argv[2]

user_data = {}
user_list = {}

filehandle = open(filename, 'r')
for line in filehandle:
    try:
        tweet = json.loads(line)
        text = tweet['text']
    except:
        continue
    try:
        user_id = tweet['user']['id_str']
    except:
        continue
    user_list[user_id] = 1 + user_list.get(user_id,0)
    if tweet['user']['location'] is None:
        tweet['user']['location'] = ''
    if tweet['user']['description'] is None:
        tweet['user']['description'] = ''
    user_data[user_id] = "{0},{1},{2},{3},{4},{5},{6},{7},{8},{9}".format(
            tweet['created_at'][4:16] + ' ' + tweet['created_at'][26:30],
            tweet['user']['screen_name'],
            tweet['user']['id_str'],
            tweet['user']['friends_count'],
            tweet['user']['followers_count'],
            tweet['user']['lang'],
            tweet['user']['verified'],
            tweet['user']['location'].replace(",","").encode('utf-8'),
            tweet['user']['description'].replace(",","").encode('utf-8'),
            user_list[user_id])

outhandle = open(outfile, 'w')
file_key = "DateLastTweet,ScreenName,UserId,FriendsCount,FollowersCount,Language,Verified,Location,Description,Tweets"
outhandle.write("{0}\n".format(file_key))
for user, user_string in user_data.items():
    outhandle.write("{0}\n".format(user_string))

outhandle.close()





