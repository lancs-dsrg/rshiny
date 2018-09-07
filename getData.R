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
