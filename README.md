# funtions_for_dialogs

Small R functions for presenting survey results with ggplot2, written to be used in R-Instat's script window. They only need ggplot2, which R-Instat already has.

File	Function	What it does
legend_helper_function.R	legend_n()	Adds a compact legend with group sizes, e.g. ■ Women (n=273) ■ Men (n=122)
Loading the function
Run this once per R-Instat session, before using legend_n():

source("https://raw.githubusercontent.com/AmsaleEjigu/funtions_for_dialogs/main/legend_helper_function.R")
Or download the file and use the path on your computer, with forward slashes:

source("C:/Users/YourName/Documents/R scripts/legend_helper_function.R")
legend_n()
Add it to a ggplot with +, like a scale or theme. It sets the colours and the legend labels for the grouping variable.

survey <- data_book$get_data_frame(data_name = "survey")

last_graph <- ggplot2::ggplot(survey, ggplot2::aes(x = District, fill = Gender)) +
  ggplot2::geom_bar(position = "dodge") +
  ggplot2::labs(x = NULL, y = "Number of respondents") +
  legend_n(survey, Gender,
           colours = c(Female = "#1F4E79", Male = "#ED7D31"),
           rename  = c(Female = "Women", Male = "Men"))
Argument	Meaning
data	Data with one row per respondent (not stacked data), used for the counts
var	Grouping column, with or without quotes: Gender or "Gender"
answered	Optional columns that must be answered for a person to be counted, e.g. answered = "Q1", so n matches the graph
colours	Optional colours, named by group. Default: 6 fixed colours, or evenly spaced colours for more groups
rename	Optional display names, e.g. c(Female = "Women", Male = "Men")
order	Optional legend order. If left out, the legend follows the order of the bars
position	"top" (default), "bottom", "right" or "left"
aesthetic	"fill" for bars and areas, "colour" for points and lines
key_size, text_size	Size of the coloured keys (cm) and of the legend text
Notes:

Don't add another scale_fill_manual() to the same graph: legend_n() already sets the colours.
Remove rows with missing values in the grouping column from the plot data, or ggplot adds an "NA" item to the legend.
Showing the graph in R-Instat
After creating last_graph, store and display it as usual:

data_book$add_object(data_name = "survey", object_name = "last_graph",
                     object_type_label = "graph", object_format = "image",
                     object = instatExtras::check_graph(graph_object = last_graph))
data_book$get_object_data(data_name = "survey", object_name = "last_graph",
