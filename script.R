rm(list=ls())
# Purpose of the script
# Your name, data and email

# Load libraries ---- if you haven't installed them before run the code install.packages("package_name")
library(ggplot2)
library(plotly)
library(dplyr)
library(htmlwidgets)

# Bar ----
npms_data <- read.csv("npmshabitatsamples_2015to2022.csv")
habitat_counts_2022 <- npms_data %>%
  filter(format(as.Date(date_start), "%Y") == "2022") %>%  # Keep only rows where the year is 2022
  group_by(NPMS_broad_habitat) %>%                        # Group by habitat type
  summarise(num_observations = n()) %>%                   # Count number of observations
  ungroup()
head(habitat_counts_2022)
  
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

ggsave("figures/static_bar_2022.png", plot = static_bar_2022)


interactive_bar_2022 <- ggplotly(static_bar_2022)

interactive_bar_2022
htmlwidgets::saveWidget(as_widget(interactive_bar_2022), "figures/Interactive_bar_2022.html")



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

htmlwidgets::saveWidget(as_widget(interactive_bar_2022_custom), "figures/Interactive_bar_2022_custom.html")




# Map ----
map_data <- npms_data %>%  
  filter(date_start >= "2022-01-01")         # Keep points collected on or after 2022-01-01
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

htmlwidgets::saveWidget(as_widget(interactive_map), "figures/interactive_map.html")

# Plotly ----
plotly_bar_2022 <- plot_ly(
  data = habitat_counts_2022, # Select data set
  x = ~NPMS_broad_habitat, # Habitat type as x-axis
  y = ~num_observations, # Number of observations as y-axis
  type = 'bar', # What kind of chart you want to make (e.g.: bar chart) 
  marker = list(color = 'pink'), # Customise bar colour
  text = ~paste("Broad Habitat Type:", NPMS_broad_habitat,  # Customise tooltip text
                "<br>No. of Observations:", num_observations),
  hoverinfo = 'text',  # Use custom tooltip text
  textposition = "none" #Prevents text from showing up on the bars
) %>%
  layout(xaxis = list(title = "Broad Habitat Type",
                      tickangle = 45),
         yaxis = list(title = "Number of Observations")
  )

plotly_bar_2022
htmlwidgets::saveWidget(as_widget(plotly_bar_2022), "figures/plotly_bar_2022.html")




# Dropdown ----
yearly_habitat_counts <- npms_data %>%
  mutate(year = as.numeric(format(as.Date(date_start), "%Y"))) %>% # Extract year from the date
  group_by(year, NPMS_broad_habitat) %>%                          # Group data by year and habitat
  summarise(num_observations = n(), .groups = "drop")             # Count observations for each group and ensure the grouping is dropped after summarising

plotly_bar_habitat <- plot_ly(
  data = yearly_habitat_counts,
  x = ~year,  # Broad habitat types = x-axis
  y = ~num_observations,       # Number of observations = y-axis
  type = 'bar',                # Set graph type: eg.bar chart, scatter, etc.
  color = ~as.factor(NPMS_broad_habitat), # Group data by year for coloring
  visible = FALSE,             # Set all graphs to be invisible by default
  name = ~NPMS_broad_habitat   # Label each trace by its year
)

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

htmlwidgets::saveWidget(as_widget(plotly_bar_habitat), "figures/observations_habitat_temporal.html")

