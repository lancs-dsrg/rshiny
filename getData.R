library(rvest)
library(XML)
library(xml2)
library(plyr)
library(magrittr)
library(rsconnect)




#### Read in Data for the App
url   <- "http://www.imdb.com/chart/toptv/?ref_=nv_tvv_250_3"
topTV <- read_html(url)
series.nodes = html_nodes(topTV,'.titleColumn a')

# Names of Top TV
series.name = html_text(series.nodes)
data_sets <- series.name

# Links to the episodes
series.link = sapply(html_attrs(series.nodes),`[[`,'href')
series.link = paste0("http://www.imdb.com",gsub("(.*)/.*","\\1",series.link))

# Maximum number of seasons
getMaxSeasons <- function(series.link){
  page = read_html(series.link)
  season.nodes = html_nodes(page, ".seasons-and-year-nav a")
  maxS = as.numeric(html_text(season.nodes))
  maxS = max(maxS[which(maxS<100)])
  return(maxS)
}

# read season
readSeason <- function(series.link, season){
  page = read_html(paste0(series.link,"/episodes?season=", season))
  rating.nodes <- page %>% html_nodes(".ipl-rating-star__rating")%>% html_text()
  k = which(sapply(rating.nodes, FUN = nchar) == 3)
  rating.nodes = as.numeric(rating.nodes[k])
  result = cbind(rating = rating.nodes,season = rep(season, length(rating.nodes)))
  return(result)
}
# read entire series
readSeries <- function(series.link, series.name) {
  seasonMax = getMaxSeasons(series.link)
  result    = mapply(
    FUN = readSeason,
    season = 1:seasonMax,
    MoreArgs = list(series.link = series.link),
    SIMPLIFY = FALSE
  )
  result = do.call("rbind", result)
  return(cbind(series.name,result))
}

data = as.list(rep(NA, length(series.link)))
for (i in 239:length(series.link)){
  data[[i]] <- readSeries(series.link = series.link[i], series.name = series.name[i])
}
dataM <- as.data.frame(do.call(data,what = "rbind"))
dataM[,2]<- as.numeric(as.character(dataM[,2]))
