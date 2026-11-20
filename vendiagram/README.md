# Venn diagram of Yes/No questions

An R-Instat script that draws a Venn diagram of **2 or 3 Yes/No survey questions**,
showing how many respondents said Yes to each combination, with counts and
percentages. It uses the [ggvenn](https://cran.r-project.org/package=ggvenn) package.

Typical use: questions like "Did you change your crops / livestock / livelihoods?",
to see how many respondents made one, two or all three changes.

## Before you start

Install ggvenn once (in R-Instat's script window):

```r
install.packages("ggvenn")
```

## The script

File: `venn_diagram.R`

```r
survey <- data_book$get_data_frame(data_name = "survey")
cols <- c("Section.SectionCLL.change_1.Crops",
          "Section.SectionCLL.change_1.Livestock",
          "Section.SectionCLL.change_1.Livelihoods")
venn_data <- survey[stats::complete.cases(survey[cols]), cols]
venn_data <- as.data.frame(lapply(venn_data, function(x) as.character(x) %in% c("Yes", "TRUE", "1")))
names(venn_data) <- c("Crops", "Livestock", "Livelihood")

last_graph <- ggvenn::ggvenn(venn_data, show_percentage = TRUE,
                             fill_color = c("#E66101", "#2C7FB8", "#5E3C99"),
                             stroke_size = 0.8, set_name_size = 5, text_size = 4) +
  ggplot2::labs(title = " ", caption = paste0("n = ", nrow(venn_data), " "))

data_book$add_object(data_name = "survey", object_name = "last_graph", object_type_label = "graph", object_format = "image", object = instatExtras::check_graph(graph_object = last_graph))
data_book$get_object_data(data_name = "survey", object_name = "last_graph", as_file = TRUE)
rm(list = c("last_graph", "survey", "venn_data", "cols"))
```

## What each step does

| Step | What it does |
|---|---|
| `get_data_frame(...)` | Gets the data from R-Instat, one row per respondent |
| `cols <- c(...)` | The 2 or 3 Yes/No columns to compare |
| `complete.cases(...)` | Keeps only respondents who answered **all** the questions |
| `%in% c("Yes", "TRUE", "1")` | Turns each answer into TRUE (Yes) or FALSE (anything else) |
| `names(venn_data) <- ...` | The names shown on the circles |
| `ggvenn(...)` | Draws the diagram with counts and percentages |
| `labs(caption = ...)` | Shows n, the number of respondents in the diagram |
| `add_object` / `get_object_data` | Stores and shows the graph in R-Instat |
| `rm(...)` | Removes the temporary objects |

## Adapting it to your data

| Change | Where |
|---|---|
| Data frame name | `data_name = "survey"` (in all three places) |
| Questions | the column names in `cols`, exactly as `names(survey)` shows them |
| Circle names | `names(venn_data) <- c(...)`, one name per column, in the same order |
| How Yes is coded | `c("Yes", "TRUE", "1")`: add other spellings, e.g. `"yes"` or `"Selected"` |
| Colours | `fill_color`, one colour per circle |
| Title | `title = " "`, e.g. `title = "Changes made since the training"` |
| Text sizes | `set_name_size` (circle names), `text_size` (numbers) |
| Hide percentages | `show_percentage = FALSE` |

To find the exact column names:

```r
grep("Crops|Livestock|Livelihood", names(survey), value = TRUE)
```

## Reading the diagram

- Each region shows the number of respondents with exactly that combination of
  Yes answers, and its percentage.
- The centre is respondents who said Yes to all the questions.
- n in the caption is the number of respondents who answered all the questions.
  Respondents with a missing answer to any of them are left out.
- The circles are all the same size: only the numbers show how big each group is.

## Common errors

| Error | Cause and fix |
|---|---|
| `there is no package called 'ggvenn'` | ggvenn isn't installed. Run `install.packages("ggvenn")` |
| `undefined columns selected` | A name in `cols` doesn't match the data. Check with `names(survey)`; R-Instat often shows `/` in names as `.` |
| `unused argument (cols = ...)` | `cols` was written inside the square brackets. Create it on its own line first, as in the script |
| All regions show 0 | Yes is coded differently in your data. Check with `unique(survey[[cols[1]]])` and add that value to `c("Yes", "TRUE", "1")` |

## Notes

- Works best with 2 or 3 questions. For 4 or more, an UpSet plot is easier to read.
- This repository holds code only. Don't upload survey data.
