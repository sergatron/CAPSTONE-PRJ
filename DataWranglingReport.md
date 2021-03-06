---
title: 'Capstone Project: Data Wrangling Report'
author: "Sergey Mouzykin"
date: "November 21, 2017"
output: rmarkdown::github_document
 
---
### Overview 
This raw data will be cleaned and wrangled into a form which then can be analyzed. The following will be performed:

- Column names will be renamed to be short, simple and descriptive
- All columns with characters will be changed to lower case. This includes brewery name, beer name, beer style, and profile name
- Any missing values found will be replaced accordingly
- The amount of beer styles will be reduced from 104 to a more manageable size

```{r Library, message=FALSE, warning=FALSE, include=FALSE}
library(ggplot2)
library(readr)
library(tidyr)
library(dplyr)
library(ggthemes)
library(RColorBrewer)
```

```{r Data Frame, message=FALSE, warning=FALSE, include=FALSE}
beer_reviews <- read_csv("beer_reviews_original.csv")
beer_reviews = as_data_frame(beer_reviews)

```

### Lower Case
Change all columns with characters to lower case. This includes four columns, brewery name, beer name, profile name, and beer style. 

```{r Lower Case, message=FALSE, warning=FALSE, include=FALSE}
# ---- Lower Case ----
brewery_name  = tolower(beer_reviews$brewery_name)
beer_name     = tolower(beer_reviews$beer_name)
profile_name  = tolower(beer_reviews$review_profilename)
beer_style    = tolower(beer_reviews$beer_style)

```

### Rename Columns
Some columns need to be renamed in order to be more concise. The changes are summarized in the table below. 

|Old Name|New Name|
|----|----|
|review_overall| overall
|review_aroma| aroma
|review_appearance| appearance 
|review_palate| palate
|review_taste| taste
|review_profilename| profile_name
|brewery_name| *no change*
|brewery_id| *no change*
|beer_style| *no change*
|beer_name| *no change*
|beer_abv| *no change*
|beer_id| *no change*
|review_time| *no change*

```{r Lower Case and Rename, message=FALSE, warning=FALSE, include=FALSE}
# ---- Rename Columns ----
taste       = beer_reviews$review_taste
palate      = beer_reviews$review_palate
appearance  = beer_reviews$review_appearance
aroma       = beer_reviews$review_aroma
overall     = beer_reviews$review_overall
brewery_id  = beer_reviews$brewery_id
beer_id     = beer_reviews$beer_beerid
review_time = beer_reviews$review_time
beer_abv    = beer_reviews$beer_abv

# put together the data frame
beer_reviews = data_frame(brewery_name, beer_name, profile_name, beer_style, taste, palate, 
                          appearance, aroma, overall, brewery_id, beer_id, review_time, beer_abv)

```

### Finding Missing Values
Approach:

1. Create a function for finding missing values 
2. Iterate this function over every column 
3. Create a matrix of missing values for easier visualization

```{r Missing Values, echo=TRUE, message=FALSE, warning=FALSE}
find_NA = function(column_name){
  beer_reviews %>% 
    filter(is.na(column_name)) %>%
    summarise(missing_values = n())
}

columns_name = list(
  beer_reviews$beer_id,
  beer_reviews$brewery_name,
  beer_reviews$brewery_id,
  beer_reviews$beer_abv,
  beer_reviews$profile_name,
  beer_reviews$taste,
  beer_reviews$palate,
  beer_reviews$beer_style,
  beer_reviews$appearance,
  beer_reviews$aroma,
  beer_reviews$overall,
  beer_reviews$review_time,
  beer_reviews$beer_name
)
missing_vals = sapply(columns_name, find_NA)
# matrix of missing values
columns = c('beer id', 'brewery name', 'brewery id', 'beer ABV', 'profile name', 'taste', 'palate', 'beer style',
            'appearance', 'aroma', 'overall', 'review time', 'beer name')
rows = c('missing values')
missing_matrix = matrix(missing_vals, byrow = TRUE, nrow = 1)
colnames(missing_matrix) = columns
rownames(missing_matrix) = rows
missing_matrix
```
Missing values are found in the following columns: 

|Column|Amount of missing values|
|----|----|
|brewery name| 15
|beer ABV| 67,785
|profile name| 348 

The alcohol content is not always written on the container and relatively low ABV is not required to be printed on containers. This may explain the large amount of missing values in the beer_abv column. 

### Missing Values: beer ABV (alcohol by volume)
To deal with these missing values, the mean of the beer_abv will be computed and used to replace the missing values. After replacing the missing values, the column will be checked again for any missing values in order to confirm the result. 

```{r ABV and mean, echo=TRUE, message=FALSE, warning=FALSE}

mean_abv = mean(beer_reviews$beer_abv, na.rm = TRUE) # = 7.04
median_abv = median(beer_reviews$beer_abv, na.rm = TRUE) # 6.6

# replace the missing values in ABV with the mean
beer_reviews = 
  beer_reviews %>%
  replace_na(list(beer_abv = mean_abv))
# check for missing values again
find_NA(beer_reviews$beer_abv)
```


### Missing Values: Brewery Name
At the moment, we can't make any accurate guesses as to what the names are of the breweries. Therefore their missing values will be replaced with the string '*unknown*'. After replacing the missing values, the column will be checked again for any missing values in order to confirm the result. 

```{r Brewery Name, echo=TRUE, message=FALSE, warning=FALSE}
# view the matrix with missing values
missing_matrix
# replace the missing names with 'unknown'
beer_reviews = 
  beer_reviews %>%
  replace_na(list(brewery_name = 'unknown'))
# check for missing values again
find_NA(beer_reviews$brewery_name)
```

### Missing Values: Profile Name
Profile names will be replaced with the string '*unknown*' since we can't make any accurate guesses of somebody's name in this instance.

```{r Profile Name, echo=TRUE, message=FALSE, warning=FALSE}
# view the matrix with missing values
missing_matrix

# glance over the missing values
beer_reviews %>%
  select(profile_name) %>%
  filter(is.na(profile_name))

# replace the missing profile names with 'Unknown'
beer_reviews = 
  beer_reviews %>%
  replace_na(list(profile_name = 'unknown'))

# check for missing values again
find_NA(beer_reviews$profile_name)

```


### Beer Styles
Currently, there are 104 unique beer styles included in this data set. However, some of these styles are highly specific due to their 
brewing process, ingredient ratios, yeast type, or a combination of other factors; but they can be grouped together since they are a variation of an ale or a lager. The goal is to classify them into more general terms, but without over simplifying, in order to produce plots that are easy to read and translate. A new column will be created to represent these styles. The approach will involve doing some research on the current beer styles included and deciding how to categorize them to yield a reduced list. The *gsub* function will be used to iterate over beer styles and categorize them accordingly. 

New Beer-Style column will consist of the following styles: 

|Beer Style| | | | |
|----|----|----|----|----|
| ale | lager | stout | lambic | spiced | 
| pilsner | porter | smoked | barleywine | ipa |
| wheat | bock | bitter | rye | trappist |


```{r Beer Styles, message=FALSE, warning=FALSE, include=FALSE}
# create a list of beer styles to use within 'gsub'
style_list =  c(beer_reviews %>% select(beer_style))

style_list = unlist(style_list)
ale         = gsub(pattern = '.*ale.*|^alt.*|.*winter.*|.*garde$|^k.*lsch.*',          replacement = 'ale',           x = style_list)
lager       = gsub(pattern = '.*lager.*|^schwarz.*|^m.*rzen.*|.*steam.*|.*zwickel.*',  replacement = 'lager',         x = ale)
stout       = gsub(pattern = '.*stout.*',                                              replacement = 'stout',         x = lager)
pils        = gsub(pattern = '.*pils.*',                                               replacement = 'pilsner',       x = stout)
porter      = gsub(pattern = '.*porter.*',                                             replacement = 'porter',        x = pils)
wheat       = gsub(pattern = '.*weizen.*|.*wit.*|.*weiss.*|.*gose.*',                  replacement = 'wheat',         x = porter)
bock        = gsub(pattern = '.*bock.*',                                               replacement = 'bock',          x = wheat)
lambic      = gsub(pattern = '^lambic.*|.*faro.*|.*gueuze.*',                          replacement = 'lambic',        x = bock)
smoked      = gsub(pattern = '^smoked.*|^rauch.*',                                     replacement = 'smoked',        x = lambic)
barleywine  = gsub(pattern = '.*barleywine.*',                                         replacement = 'barleywine',    x = smoked)
bitter      = gsub(pattern = '.*bitter.*',                                             replacement = 'bitter',        x = barleywine)
rye         = gsub(pattern = '.*rye.*|.*roggen.*|kvass',                               replacement = 'rye',           x = bitter)
spiced      = gsub(pattern = '.*herbed.*|.*braggot.*|^chile.*',                        replacement = 'spiced/herbed', x = rye)
trappist    = gsub(pattern = '^quad.*|^dub.*|^tri.*',                                  replacement = 'trappist',      x = spiced)
ipa         = gsub(pattern = '.*ipa.*',                                                replacement = 'ipa',           x = trappist)

style_list_mod = ipa
unique(style_list_mod) # print out the list of distinct beer styles 
length(unique(style_list_mod)) # number of distinct beer styles: 24
```


```{r Mutate and Summarize, echo=TRUE, message=FALSE, warning=FALSE}
# create new column with the new styles using mutate()
beer_reviews = 
  beer_reviews %>%
  mutate(general_beer_style = style_list_mod)

glimpse(beer_reviews)

# summarize the new beer styles by calling distinct()
beer_reviews %>%
  group_by(general_beer_style) %>%
  summarise(style_count = n()) %>%
  arrange(desc(style_count))

```

### Plot: Beer ABV
Plotting the beer's ABV as a histogram will reveal it's distribution and help us spot any outliers that may be present before diving into deeper analysis.  

```{r Plot: Beer ABV, echo=TRUE, message=FALSE, warning=FALSE}
#glimpse(beer_reviews)
blues = brewer.pal(6, 'Blues')
ggplot(beer_reviews, aes(x = beer_abv)) + 
  geom_histogram(binwidth = 0.5, position = 'identity', fill = '#3182BD', col = 'black') + 
  scale_x_continuous('Alcohol by Volume (%)', breaks = seq(0, 60, by = 5)) +
  scale_y_continuous('Beer Count') +
  ggtitle('Beer ABV Distribution') +
  theme_classic()

```

This plot shows us that the ABV is actually a right-skewed distribution due to some beers having a a very high alcohol by volume content. The minimum and maximum of ABV content are 0.01% and 57.7%, respectively. The mean lies at 7.04, the median at 6.6, and the standard deviation is 2.27. We can also infer that the distribution is right-skewed due to the median being lower than the mean. Although the values range from 0.01 to 57.7, in theory, about 95% of these values should lie within two standard deviations from the mean.

|Stat|Value|
|----|----|
|Standard Deviation| 2.27
|Variance| 5.16
|Mean| 7.04 
|Median| 6.6
|Max| 57.7
|Min| 0.01 

```{r Max and Min for beer ABV, echo=TRUE, message=FALSE, warning=FALSE}
# find max and min for beer ABV
# replace the missing values before finding MAX and MIN
max(beer_reviews$beer_abv) # 57.7 % 
min(beer_reviews$beer_abv) # 0.01 % 
```

### Interval: Beer ABV
In order to better visualize the alcohol level content, the ABV can be distributed into five factored levels using the calculated mean and standard deviation. These five levels will be labeled as, 'low', 'below normal', 'normal', 'above normal', and 'high'. The computed standard deviation will be used to create the breaks for the labels. 

```{r, message=FALSE, warning=FALSE, include=FALSE}

abv_vector = beer_reviews$beer_abv
mean_abv   = mean(abv_vector)   # 7.04
median_abv = median(abv_vector) # 6.6
sd(abv_vector)     # 2.27
var(abv_vector)    # 5.16
length(abv_vector)

# calculate the deviation breaks
one_sd_below = mean(abv_vector) - sd(abv_vector) # 4.77 -> 1 SD below mean
one_sd_above = mean(abv_vector) + sd(abv_vector) # 9.31 -> 1 SD above mean
two_sd_below = mean(abv_vector) - 2*sd(abv_vector) # 2.50 -> 2 SD below mean
two_sd_above = mean(abv_vector) + 2*sd(abv_vector) # 11.59 -> 2 SD above mean

# Interval of ABV
# use cut() and a vector for the breaks
# normal ABV level will be considered being within 1 SD of the mean
breaks_vect = c(0, two_sd_below, one_sd_below, one_sd_above, two_sd_above, 60)
interval_abv = cut(abv_vector, 
               breaks = breaks_vect, 
               labels = c('low', 'below normal', 'normal', 'above normal', 'high'))
table(interval_abv)
length(interval_abv)

# sum the amounts within two standard deviations and divide by total amount of rows
# this will contain about 95% of all the data points in the beer's abv column
(140735 + 1193157 + 200598) / length(abv_vector) * 100 # 0.9671

```

```{r Mutate Beer ABV Interval, echo=TRUE, message=FALSE, warning=FALSE}
# NEW COLUMN: beer_abv_factor
beer_reviews = 
  beer_reviews %>%
  mutate(beer_abv_factor = interval_abv)

glimpse(beer_reviews)
```



### Write the cleaned data to a new file
The clean file is now ready to be written.
```{r Write Cleaned Data, message=FALSE, warning=FALSE, include=FALSE}
beer_reviews_clean = beer_reviews
glimpse(beer_reviews_clean)

# write the clean file 
write_csv(beer_reviews_clean, 'beer_reviews_clean.csv')
```




