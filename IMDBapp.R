################################# PREAMBLE ###################################
# Load in data
library(rvest)
library(XML)
library(xml2)
library(plyr)
library(magrittr)
library(rsconnect)

source("getData.R")

#### Read in Data for the App
url   <- "http://www.imdb.com/chart/toptv/?ref_=nv_tvv_250_3"
topTV <- read_html(url)
series.nodes = html_nodes(topTV,'.titleColumn a')

# names of choices of TV shows
series.names = html_text(series.nodes)

# Links to the episodes
series.link = sapply(html_attrs(series.nodes),`[[`,'href')
series.link = paste0("http://www.imdb.com",gsub("(.*)/.*","\\1",series.link))

##############################################################################

# Define UI
ui = fluidPage(pageWithSidebar(
  headerPanel("IMBD User Ratings"),
  
  sidebarPanel(
    selectInput(
      inputId = "series",
      label = "Choose a TV Series",
      choices = series.names,
      multiple = FALSE
    ),
    uiOutput("minseglen"),
    uiOutput("pen"),
    textOutput("cploc")
  ),
  mainPanel(plotOutput("data_plot"))
))

# Define server function
server <- function(input, output) {
  # Get data
  data <- reactive({
    dataM <- readSeries(series.link = series.link[which(series.names==input$series)], series.name = input$series)
    dataM <- as.data.frame(dataM)
    dataM[,2]<- as.numeric(as.character(dataM[,2]))
    return(dataM)
  })
  
  # Minseglen slider bounds
  output$minseglen = renderUI({
    sliderInput(
      "minseglen",
      "Minimum Segment Length",
      min = 2,
      max = floor(dim(data())[1] / 2),
      value = 2,
      step = 1
    )
  })
  
  # Get cps
  cps <- reactive({
    changepoint::cpt.mean(
      data = data()$rating,
      penalty = "CROPS",
      pen.value = c(0.1, 1000),
      method = "PELT",
      minseglen = input$minseglen,
      class = F
    )
  })
  
  #Penalty slider bounds
  output$pen = renderUI({
    sliderInput(
      "pen",
      "Penalty",
      min = 0.1,
      max = ceiling(tail(cps()$cpt.out[1, ], 1)),
      value = tail(cps()$cpt.out[1, ], 1),
      round = T
    )
  })
  
  selected_cps <- reactive({
    cps()$changepoints[[max(which(cps()$cpt.out[1, ] <= input$pen))]]
  })
  
  output$cploc <- renderText({
    paste0("Episodes: ", paste0(selected_cps(), collapse = ","))
  })
  
  output$data_plot <- renderPlot({
    par(mar = c(5.1, 4.1, 0, 1))
    if (length(selected_cps()) > 0) {
      ggplot2::ggplot() + ggplot2::geom_line(data = cbind(episode = 1:dim(data())[1], data()),
                                             ggplot2::aes(x = episode, y = rating)) +
        ggplot2::geom_rect(
          data = cbind(episode = 1:dim(data())[1], data()),
          ggplot2::aes(
            ymin = 0,
            ymax = 10,
            xmin = episode - 0.5,
            xmax = episode +
              0.5
          ),
          fill = data()$season,
          alpha = 0.3
        ) +
        ggplot2::xlab("Episode Number") + ggplot2::ylab("IMBD User Rating") + ggplot2::geom_vline(
          xintercept =
            selected_cps(),
          colour = "red",
          linetype = "dashed",
          size = 1
        ) +
        ggplot2::theme(plot.margin = grid::unit(c(0, 0, 0, 0), "mm"))
    } else{
      ggplot2::ggplot() + ggplot2::geom_line(data = cbind(episode = 1:dim(data())[1], data()),
                                             ggplot2::aes(x = episode, y = rating)) +
        ggplot2::geom_rect(
          data = cbind(episode = 1:dim(data())[1], data()),
          ggplot2::aes(
            ymin = 0,
            ymax = 10,
            xmin = episode - 0.5,
            xmax = episode +
              0.5
          ),
          fill = data()$season,
          alpha = 0.3
        ) +
        ggplot2::xlab("Episode Number") + ggplot2::ylab("IMBD User Rating") +
        ggplot2::theme(plot.margin = grid::unit(c(0, 0, 0, 0), "mm"))
    }
  })
}


# This is a function to stop the (local) server when the client is closed ( I only had this because I had students deploying the app from a USB)
shinyServer(function(input, output, session) {
  session$onSessionEnded(function() {
    stopApp()
  })
})


# Create shiny object
shinyApp(ui = ui, server = server)
