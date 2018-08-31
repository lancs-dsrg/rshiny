# rshiny: IMDB App
*The goal of this session is to practise making a RShiny App.*

**Detecting Changes in IMDB TV Ratings**

The app in its current form reads in a data file with historical user ratings for the "Top TV" shows on IMDB. It will then run a changepoint detection algorithm on the ratings, where the user can input the minimum segment length for the algorithm and the penalty, this is done using sliders. Once changes are detected, this will be put onto a plot of the data as vertical lines. In the sidebar, the episode number/s for the change/s will be printed.

Below gives you a list of tasks for the session.

## Task 1: Getting the data

The app currently reads in a data file with the TV ratings. As these ratings are scraped, they can't really be put onto GitHub for you all to use. Also, it means someone can only use the app if they have the data too. So, it is your task to make the scraping of the data live.

To help you, I have included the original script I used to scrape all of the data in the first place **getData.R**.

Some pointers: If you scrape all off of the data at once, your app may be slow. Therefore, I propse that first you scrape the names of the shows - so the user knows which shows it can pick - then once the person has inputted their choice of show, then scrape the historical user ratings for that show only.  

## Task 2: Input type

Change the minimum segment length input to be a text box.

## Task 3: Restricting inputs

The above change was a dangerous one!! The user could input any minimum segment length. We know it must be between 0 and the length of the data. Create a warning if the user inputs an invalid number. Hint: the functions **validate** and **need** may be useful.

## Task 4: A button to execute the changepoint algorithm

Currently, the changepoint algorithm will begin running whenever any of the following have been chaanged:
* The TV series name
* The minimum segment length
* The penalty choice

Please create a button such that the changepoint algorithm will only exectute when a user has pressed the button.

## Task 5: Reactive Values
Someone at IMDB has decided that they LOVE this app. What they really want, is to be able to have a list of TV series they think have really good changepoints, such that they can take a list of these shows to the PR team. 

Please create some functionality such that, if the user decides that a TV show has some really good changes in it, they can keep a record of it. Ideally, what they want to be able to do, is as they are checking each of the shows, they can mark it as one they want to keep a record of, and once they have finished with the app, they can save the names of the shows for later.

This could be done in a number of ways, but you will most likely need to use a **reactiveVal()**
