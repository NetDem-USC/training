#==============================================================================
# 08-networks-research-example.r
# Purpose: network analysis of retweets mentioning hashtags related to 
# international courts
# Project: Social Media and International Courts (ISA 2017)
# Author: Pablo Barbera
#==============================================================================

setwd("~/git/training")
options(stringsAsFactors=F)
library(ggplot2)
library(scales)
library(ggthemes)
library(netdemR)

# reading tweets data (will not use it until later in the script)
tweets <- read.csv("data/icourts-hashtag-tweets.csv")
names(tweets)[2] <- "UserId"


# construct network of RTs: information flows
edges <- read.csv("data/edges-aggregated.csv", header=FALSE,
  col.names=c("source", "source_name", 
    "target", "target_name", "weight"), stringsAsFactors=TRUE)
# where does this file come from? see "aux" folder

summary(edges)

# users data
users <- read.csv("data/user-data.csv")
users <- users[order(users$Tweets, decreasing=TRUE),]
head(users)

# preparing user data: keeping only users in RTs and deleting duplicates
vert <- users[users$UserId %in% edges$source | users$UserId %in% edges$target,]
vert <- vert[!duplicated(vert$UserId),]
vert <- vert[c("UserId", "FollowersCount", "Language", "Tweets", "ScreenName")]
names(vert) <- c("id_str", "followers_count", "lang", "statuses_count", "screen_name")

# note: we found some new users (RTed) that were not in the user data file, so we
# queries the API for their user profile information
new.users <- edges$target[edges$target %in% vert$id_str == FALSE]
#new.users <- getUsersBatch(ids=new.users, oauth_folder="~/Dropbox/credentials/twitter")
#write.csv(new.users, file="data/new-users-dataset.csv", row.names=FALSE)
new.users <- read.csv("data/new-users-dataset.csv")

# now we paste both datasets together
new.users <- new.users[,c("id_str", "followers_count", "lang", "statuses_count", "screen_name")]
vert <- rbind(vert, new.users)

# cleaning edges: keeping only those where RTed is in user dataset
edges <- edges[edges$target %in% vert$id_str == TRUE,]

# creating network object
library(igraph)
g<-graph.data.frame(edges[,c(1,3,5)], directed=TRUE, vertices=vert)

# adding user names and screen_names to nodes
V(g)$id <- V(g)$name
V(g)$name <- V(g)$screen_name

# identify individuals with highest betweenness centrality
head(sort(degree(g), decreasing=TRUE), n=10)
head(sort(degree(g, mode="in"), decreasing=TRUE), n=10)
head(sort(degree(g, mode="out"), decreasing=TRUE), n=10)

# extract main components
cl <- components(g, mode="weak") 
cl$no
## N= 3,137
max(cl$csize)
## size of largest = N=57,469

comps <- decompose(g, min.vertices=2)
giant <- comps[[1]]
summary(giant)
# IGRAPH DNW- 57469 131366 -- 
# + attr: name (v/c), followers_count (v/n), lang (v/c),
# | statuses_count (v/n), screen_name (v/c), id (v/c), weight (e/n)

length(V(giant)) / length(V(g)) # 83% in giant component

# running community detection
gu <- simplify(as.undirected(giant, mode="collapse"))
fg <- cluster_fast_greedy(gu)
#infomap <- cluster_infomap(gu)
#blondel <- multilevel.community(gu)

#tail(sort(table(infomap$membership)), n=10)
tail(sort(table(fg$membership)), n=10)
#tail(sort(table(blondel$membership)), n=10)

V(gu)$community <- membership(fg)
#V(gu)$community[V(gu)$community %in% c(6,5,9,10,7) == FALSE] <- "Other"

# analysis of communities
analyze_community <- function(ids){
  require(quanteda)
  # how many users
  message(length(ids), " users in this community")
  message(round(length(ids)/length(V(gu)$id)*100), " % of all users")
  # most common hashtags / words
  # corpus <- corpus(tweets$text[tweets$UserId %in% ids])
  # dfm <- dfm(corpus, verbose=FALSE, ignoredFeatures=c(
  #   stopwords("english"), stopwords("spanish"), stopwords("french"), 
  #   "t.co", "https", "rt", "amp", "http", "t.c", "can", "v", "will", "via"))
  # topf <- topfeatures(dfm, 15)
  # print(paste(names(topf), collapse=", "))
  # most common language
  message("Most common language:")
  print(tail(round(prop.table(sort(table(tweets$lang[tweets$UserId %in% ids]))), 2)))
  # most central users
  message("Most central users:")
  indegree <- degree(gu, mode="in")[V(gu)$id %in% ids]
  print(paste(names(head(sort(indegree, decreasing=TRUE), n=10)), collapse=", "))

}

# from largest to smaller
ids <- V(gu)$id[V(gu)$community==7]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

ids <- V(gu)$id[V(gu)$community==10]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

ids <- V(gu)$id[V(gu)$community==9]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

# cricket?
ids <- V(gu)$id[V(gu)$community==5]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

ids <- V(gu)$id[V(gu)$community==6]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

ids <- V(gu)$id[V(gu)$community==2]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

ids <- V(gu)$id[V(gu)$community==8]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

ids <- V(gu)$id[V(gu)$community==3]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

ids <- V(gu)$id[V(gu)$community==1]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

ids <- V(gu)$id[V(gu)$community==15]
table(tweets$UserId %in% ids)
prop.table(table(tweets$UserId %in% ids))
analyze_community(ids)

# k-core decomposition
nodes <- data.frame(
  ID = V(giant)$name, Label=V(giant)$name, Followers = V(giant)$followers_count)
nodes$k <- coreness(giant)
nodes$Label[nodes$k==max(nodes$k)]

# wordcloud of description in core of network
require(quanteda)
corpus <- corpus(users$Description[users$ScreenName %in% nodes$Label[nodes$k>20]])
dfm <- dfm(corpus, ignoredFeatures=c(
  stopwords("english"), stopwords("spanish"), stopwords("french"), 
  "t.co", "https", "rt", "amp", "http", "t.c", "can"), ngrams=c(1,2))

pdf("plots/wordcloud-core.pdf", height=5, width=5)
par(mar=c(0,0,0,0))
plot(dfm, rot.per=0, scale=c(3.5, .75), max.words=100)
dev.off()








