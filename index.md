<center><img src="{{ site.baseurl }}/figures/coding_logo.png" alt="Img"></center>

# Data Visualization: Creating Interactive Figures with plotly
------------------------

## Tutorial Aims

By the end of this tutorial, you'll be able to:

1. Understand what tools are available to creating interactive graphs in R. 
 
2. Learn how to convert static `ggplot2` figures into an interactive plot with `plotly`.

3. Explore different customisation options

4. Save and share your interactive graphs as standalone files.

## Tutorial Steps

#### <a href="#section1"> 1. Introduction</a>
##### <a href="#section1a">. a. Prerequisites</a>
##### <a href="#section1b">. a. Starting the tutorial</a>


#### <a href="#section2"> 2. Converting static ggplot2 into interactive plots</a>
##### <a href="#section2a">. a. Customizing Hover Tooltips</a>
##### <a href="#section2b">. b. Key Features of an Interactive plotly plot</a>
##### <a href="#section2c">. c. Exporting an Interactive Plot</a>


#### <a href="#section3"> 3. Interactive Spatial Visualisation</a>

#### <a href="#section4"> 4. Using Plotly Syntax</a>
##### <a href="#section4a">. a. Temporal Visualisations with Plotly</a>

#### <a href="section5"> 5. Bonus: Temporal Visualisations

#### <a href="#section6"> 6. Wrapping up</a>


---------------------------

You can get all of the resources for this tutorial from <a href="https://github.com/EdDataScienceEES/tutorial-oladw" target="_blank">this GitHub repository</a>. Clone and download the repo as a zip file, then unzip it.

<a name="section1"></a>

## 1. Introduction

When studying data science or even just looking through the news, have you ever wondered how they make those graphs that let you explore data points with a hover? The kinds of graphs you see on BBC News or Our World in Data? At first glance, they seem like they'd require some extensive code to create. What if I told you that, actually, its much simpler than it looks?
In this tutorial, we'll walk though the basics of creating such interactive figures in R, and add a little bit of *spice* to your visualizations. 

Now, don't get me wrong some of those interactive figures can be complex, but this tutorial aims to give you a quick rundown and show you how you can make one of your own!

Data visualization is a crucial component for communicating information quickly. By making these interactive, we allow the reader to explore this data on their own.

<a name="section1a"></a>

### Prerequisites

This tutorial is designed to suit any skill level from basic to intermediate R users. Before starting there are a couple of skills you should already have. You should be comfortable with operating R, including writing basic code, loading data, and working with data frames. In particular, you should already have some idea of how to create graphs using `ggplot2`. Additionally, having some familiarity in data wrangling with `dplyr` and `tidyr` is recommended. 

Don't worry if you're not an expert, we'll walk through each step - one by one.

If you'd like a quick refresher before starting, have a look through the these Coding Club tutorials before you begin

- 

- 

- 
<a name="section1b"></a>
### Starting the tutorial

#### Setting up your environment 

Before we begin learning how to make some funky graphs, make sure your environment is in working order. Open `RStudio`, and create a new script by selecting `File/New File/ R script` so you can follow along. You should also clone and download [this GitHub repository], where you'll find the necessary files needed to complete this tutorial. 


#### Installing and Loading Packages
Next, make sure you have the necessary packages installed and loaded in R. These include:
- `ggplot2`: To create static visualisations
- `plotly`: To make these visualisations interactive
- `dplyr`: To wrangle data to create data visualisations
- `htmlwidgets`: To save interactive visualisations


```r
# Purpose of the script
# Your name, data and email

# Load libraries ---- if you haven't installed them before run the code install.packages("package_name")
library(ggplot2)
library(plotly)
library(dplyr)
library(htmlwidgets)

```
Make sure to set your working directory in RStudio to the folder containing the files.

```r
# Set your working directory, replace "file-path" with your working directory

setwd("file-path")

```


#### Dataset
The time has come to load in the data! For this tutorial, we will be using a dataset from the __National Plant Monitoring Scheme (NPMS)__. Now, it is quite a large file so it might be a bit daunting at first, but don't worry! We'll focus on specific subsets to make it more manageable.

```r
# Read in data ----
npms_data <- read.csv("npmshabitatsamples_2015to2022.csv")

```
Lets have a quick look at what the dataset contains:

```r
#View the first few rows of the NPMS dataset
head(npms_data)

#Check the structure of the dataset
str(npms_data)
```

<a name="section2"></a>

## 2. Converting static `ggplot2` into interactive plots

I'm sure you've made countless ggplot2 graphs up until now. But, bare with me. In this part of the tutorial, we'll be creating a basic static `ggplot2` figure and converting it into an interactive graph using `plotly`. 

Let's say we want to create a simple bar chart showing the __number of surveyor observations__ of each __broad habitat type__ in __2022__.
To start, we'll filter the dataset to include only observations from 2022, using the `date_start` column and count how many observations of each habitat. You may have noticed that the values in the column are formatted as `year-month-day`, and is categorised in a Date format (take a look at the str(npms_data) output).

```r
# Filter data for 2022 and count observations by broad habitat type
habitat_counts_2022 <- npms_data %>%
  filter(format(as.Date(date_start), "%Y") == "2022") %>%  # Keep only rows where the year is 2022
  group_by(NPMS_broad_habitat) %>%         # Group by habitat type
  summarise(num_observations = n()) %>%    # Count number of observations
  ungroup()


```

Using this, lets make a simple bar chart with `ggplot2`.

```r
# Plotting number of surveyor observations of each broad habitat type in 2022
static_bar_2022 <- ggplot(habitat_counts_2022, aes(
  x = NPMS_broad_habitat,  # Order bars by count
  y = num_observations
)) +
    geom_col(fill = "pink", color = "black") +
    labs(
      title = "Number of Survey Observations by Broad Habitat Type (2022)",
      x = "Broad Habitat Type",
      y = "Number of Observations"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Print figure
print(static_bar_2022)

```

<center> <img src="{{ site.baseurl }}/figures/static_bar_2022.png" alt="Img" style="width: 800px;"/> </center>


Not bad. When you run the code, you'll se a simple bar chart that displays the number of survey observations for each broad habitat type in 2022. As you can see, there are a few habitat types that have significantly more observations than others.

But, what if we want to find out the exact observation count for each habitat? Or simply just want to add some interactivity to explore the data? Fret not! All it needs is one line of code.

```r
# Convert the static bar chart into an interactive plot
interactive_bar_2022 <- ggplotly(static_bar_2022)

# Display the interactive plot
interactive_bar_2022

```

<iframe src="Interactive_bar_2022.html" width="800" height="600"></iframe>


Now what can we see here? When hovering over each bar we get some information about each data point, including the broad habitat type and the number of observations.

Quite simple, no? There is only one issue. The hover information is, unfortunately, quite ugly. It's functional, but definitely not user friendly or appealing. If only there was some way to change it...

<a name="section2a"></a>
### Customizing Hover Tooltips

We can easily customize the hover tooltips to make them more appealing and informative. By adding a __text__ aesthetic to the original `ggplot2` code, we can specify what information we want to include.


```r
# Create a customized static bar chart with hover tooltips
static_bar_2022_custom <- ggplot(habitat_counts_2022, aes(
  x = NPMS_broad_habitat,  
  y = num_observations,
# Define custom hover text
  text = paste("Broad Habitat type:", NPMS_broad_habitat,  # Include the habitat type
               "<br>Number of Observations:", num_observations)	# Include the observation count with a line break
)) +
    geom_col(fill = "pink", color = "black") +
    labs(
      title = "Number of Survey Observations by Broad Habitat Type (2022)",
      x = "Broad Habitat Type",
      y = "Number of Observations"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))

#Convert the static bar chart into an interactive plot using plotly
interactive_bar_2022_custom <- ggplotly(static_bar_2022_custom, tooltip = "text") #Specify that tooltips should use the 'text' aesthetic

#View interactive plot
interactive_bar_2022_custom


```

<iframe src="Interactive_bar_2022_custom.html" width="800" height="600"></iframe>


Much better! Now our chart is both interactive and aesthetically pleasing. While this bar chart with interactivity does not necessarily tell us much more than the regular chart, the techniques you've learned can be applied to any other visualisation made with `ggplot2`! Think about all the endless possibilities.

You may have noticed we added a `<br>` into the text aesthetic. All this does is tells the programme to write the next part on a separate line.

Now that we've created an interactive plot, let's have a look at the unique features it provides and how it can be used to extract meaningful insights from your data points. Interactivity adds an additional _depth_ to charts that a static simply cannot compare with.

<a name="section2b"></a>
### Key Features of an Interactive `plotly` plot

If you look at the top of your interactive plot, there are a couple of icons that make the plot useful.

1. Hover Tooltips: When hovering over a specific datapoint you can get more insight about it in particular.

2. Zooming: If there are a couple of points close together, or a cluster of points, you can zoom into the plot by either pressing the `+` button on the tool bar at the top OR click and drag to zoom in on that point. To zoom out, press the `-` button on the toolbar or double click on the plot to reset.

3. Panning: Once zoomed in click the `pan` button on the toolbar and drag to move around the plot.

4. Download interactive plot as a static png: You can download the static version of the interactive plot by pressing the camera icon on the toolbar. Downloading the interactive version is a little bit more complicated.

<a name="section2c"></a>
### Exporting an Interactive Plot

For downloading the interactive plot we'll have to use the `htmlwidgets` package, which you should have loaded already. As the figure is interactive, you'll have to save it as a .html file otherwise it won't work. To save the figure all you have to enter into R is.

```r
htmlwidgets::saveWidget(as_widget(interactive_bar_2022_custom), "Interactive_bar_2022_custom.html")
```
After running this, you should see in the `File` terminal that you'll have two new files. One is the `Interactive_bar_2022_custom.html` (which you can just open and tah-dah! You have your interactive plot done!) and a new folder called `Interactive_bar_2022_custom_files`. This is not something to worry about. It is a necessary folder, however, to open the interactive graph.


<a name="section3"></a>
## 3. Interactive Spatial Visualisation

Okay, now that we know how plotly works (or at least the basics of it), lets try something else. The NPMS dataset is great because not only does it have a _lot_ of data, it has specific locations for each observation. So... lets try plotting it!

Similarly to the last plot, let's make a map for where these observations were made, and what habitat they observed (both broad habitat and surveyor habitat for some more detail). 

To start, we'll create a subset of the larger dataset (similarly to be the last example).

```r
map_data <- npms_data %>%  
  filter(date_start >= "2022-01-01")         # Keep points collected on or after 2022-01-01
```

Now that we have that, lets use this subset to create the map.


```r
# Creating a map
map <- ggplot(map_data, aes(x = LONGITUDE, y = LATITUDE, color = NPMS_broad_habitat,

                            text = paste(" Broad Habitat:", NPMS_broad_habitat,
                                         "<br> Surveyor Habitat:", surveyorHabitat,
                                         "<br> Latitude:", LATITUDE,
                                         "<br> Longitude:", LONGITUDE))) +
  borders("world", colour = "gray61", fill = "gray91") +
  coord_cartesian(xlim = c(-10.5, 2.5), ylim = c(48, 62)) +  # Longitude limits
  geom_point(size = 2, alpha = 0.7) +
  labs(title = "National Plant Monitoring Survey Map for 2022",
       x = "Longitude",
       y = "Latitude") +
  theme_minimal()

# Make map interactive
interactive_map <- ggplotly(map, tooltip = "text")  

#View interactive map
interactive_map

```
<iframe src="interactive_map.html" width="800" height="600"></iframe>


Looking cute! 

<a name="section4"></a>
## 4: Using Plotly Syntax

While we've been converting `ggplot2` visualisations into interactive plots, `plotly` also provides its own syntax for creating visualisations directly. This can help unlock some other features available in plotly, that can't be used otherwise; for example, creating graphs with a dropdown menu.

So far, we've converted a `ggplot2` chart into an interactive one with plotly, but it's also fairly simple to do the same in plotly directly - immediately making it interactive. Let's explore how to do this with the same bar chart we made at the beginning - the number of observations of each broad habitat type in 2022, made with `plotly` syntax.

Now, I'm not trying to convert you into a plotly user, whilst __it is__ useful, `ggplot2` simply is more wide spread, heavily customisable and has many extension packages to expand it's uses. _But_, if you're looking to build an interactive graph, with a large dataset, converting it with `ggplotly()` might cause your R session to crash. If you're primary objective is to make an interactive graph - plotly is the way to go.

Let's start with the same bar chart. We've already prepared the `habitat_counts_2022` subset, so we can lets dive right in to making the chart.

```r
# Create bar chart in plotly
plotly_bar_2022 <- plot_ly(
  data = habitat_counts_2022, # Select data set
  x = ~NPMS_broad_habitat, # Habitat type as x-axis
  y = ~num_observations, # Number of observations as y-axis
  type = 'bar', # What kind of chart you want to make (e.g.: bar chart) 
  marker = list(color = 'pink'), # Customise bar colour
  text = ~paste("Broad Habitat Type:", NPMS_broad_habitat,  # Customise tooltip text
                "<br>No. of Observations:", num_observations),
  hoverinfo = 'text',  # customise tooltip text
  textposition = "none" #Prevents text from showing up on the bars
) %>%
  layout(xaxis = list(title = "Broad Habitat Type", # x-axis title
                      tickangle = 45), # tilt labels
         yaxis = list(title = "Number of Observations") # y-axis title
  )

# View bar chart
plotly_bar_2022

```

<iframe src="plotly_bar_2022.html" width="800" height="600"></iframe>


Badabing, Badaboom. You've just created the same graph as before, but this time entirely in plotly. Notice the built in interactivity in this chart.

<a name="section5"></a>
## 5. Bonus: Temporal Visualisations with Plotly

Now, let's try something a bit more complicated. So far, we've looked at __regular data visualisation__, __spatial visualisation__, but what about __temporal visualisation__? 

For this example, lets say we want to show how the number of observations per habitat type changes over the years. We'll plot this a little differently, with year along the x-axis and __create a dropdown menu to filter by habitat type__.

Firstly, we'll prepare the dataset by summarising the number of observations per habitat type in each year.

```r
yearly_habitat_counts <- npms_data %>%
  mutate(year = as.numeric(format(as.Date(date_start), "%Y"))) %>% # Extract year from the date
  group_by(year, NPMS_broad_habitat) %>%                          # Group data by year and habitat
  summarise(num_observations = n(), .groups = "drop")             # Count observations for each group and ensure the grouping is dropped after summarising

```
Now let's use plotly to create the bar chart with a dropdown menu. Before we begin, I should explain a bit as to how plotly's syntax actually works. Unlike in `ggplot2`, we use plotly to define different 'traces' (otherwise known as data layers - which you might be familiar with in ggplot2). 

In this example, each 'trace' will represent __a different habitat type__. Using the dropdown menu, we'll allow the user to toggle between them. By default, we want all the traces to be invisible, except for the habitat we have selected in the dropdown menu.

```r
plotly_bar_habitat <- plot_ly(
  data = yearly_habitat_counts,
  x = ~year,  # Broad habitat types = x-axis
  y = ~num_observations,       # Number of observations = y-axis
  type = 'bar',                # Set graph type: eg.bar chart, scatter, etc.
  color = ~as.factor(NPMS_broad_habitat), # Group data by year for coloring
  visible = FALSE,             # Set all graphs to be invisible by default
  name = ~NPMS_broad_habitat   # Label each trace by its year
)
```
Now that we've created the foundation for our bar chart, its time to bring it to life with some interactivity. Our goal is to create a chart where you can explore the data for each habitat separately.

We'll do this by adding the dropdown menu to make it easy to select the habitat you're interested in and see the relevant data. Now, brace yourself, it is a long code but it'll be the pretty much the same anytime you want too create a dropdown so feel free to refer back to this anytime.

```r
## Add a dropdown menu for habitat selection
plotly_bar_habitat <- plotly_bar_habitat %>%
  # Add interactive dropdown menu
  layout(updatemenus = list(
      # Create buttons for each habitat
      list(buttons = lapply(unique(yearly_habitat_counts$NPMS_broad_habitat), function(habitat) { 
          list(
	    # Update the chart after selecting new habitat
            method = "update", 
	    # Show selected habitat trace when selecting habitat in dropdown
            args = list(
              list(visible = yearly_habitat_counts$NPMS_broad_habitat == habitat)
            ),
            label = habitat) # Dropdown menu label
        }),
# Dropdown customisation
        direction = "down",       # Dropdown opens downward
        showactive = TRUE,        # Highlight currently selected
        x = 0.95,                 # Move dropdown to the far right
        y = 1.15,                 # Position above the chart
        xanchor = "right",        # Anchor dropdown to the right
        yanchor = "top"           # Anchor dropdown to the top
      )
    ),
    xaxis = list(title = "Year"),          # X-axis label
    yaxis = list(title = "Number of Observations") # Y-axis label
  )

# View figure
plotly_bar_habitat

```
<iframe src="observations_habitat_temporal.html" width="800" height="600"></iframe>

Phenomenal work! You've just created a visualisation that allows the user to explore how the number of observation changes over time for each habitat type (and there's that added hover tool function as a bonus). Now let's just save it for good measure.

```
htmlwidgets::saveWidget(as_widget(plotly_bar_habitat), "observations_habitat_temporal.html")
```

-------
<a name="section6"></a>
## 5. Wrapping up

Congratulations! You've successfully jumped into the wide world of data visualisation! Here's a little summary of what you managed to complete today:
1. Converted static visualisations into interactive figures: You learned how to convert static `ggplot2` figures into interactive plots using `plotly`. 
2. Customisations: You customised interactive features such as the tooltips and hover information to increase user functionality. 
3. Plotly Visualisations: You explored how to build visualisations directly in plotly.
4. Dropdown Menus: You explored how to create a figure with a dropdown menu to switch between graphs.
5. Saving: You saved your interactive charts as HTML files that can be shared or embedded into web pages. 
Such figures allow audiences to explore data dynamically, uncover anomalies or trends and engage in a meaningful way.

By the end of this tutorial, you've (hopefully) built an understanding on how to create interactive visualisations and their usefulness in presenting information. Keep experimenting, and trying out new ways to present information. You know how that one saying goes, a picture paints a thousand words.


We can also provide some useful links, include a contact form and a way to send feedback.

For more on `ggplot2`, read the official <a href="https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf" target="_blank">ggplot2 cheatsheet</a>.

Everything below this is footer material - text and links that appears at the end of all of your tutorials.

<hr>
<hr>

#### Check out our <a href="https://ourcodingclub.github.io/links/" target="_blank">Useful links</a> page where you can find loads of guides and cheatsheets.

#### If you have any questions about completing this tutorial, please contact us on ourcodingclub@gmail.com

