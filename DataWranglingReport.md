Capstone Project: Data Wrangling Report
================
Sergey Mouzykin
November 21, 2017

### Overview

This raw data will be cleaned and wrangled into a form which then can be analyzed. The following will be performed:

-   Column names will be renamed to be short, simple and descriptive
-   All columns with characters will be changed to lower case. This includes brewery name, beer name, beer style, and profile name
-   Any missing values found will be replaced accordingly
-   The amount of beer styles will be reduced from 104 to a more manageable size

### Lower Case

Change all columns with characters to lower case. This includes four columns, brewery name, beer name, profile name, and beer style.

### Rename Columns

Some columns need to be renamed in order to be more concise. The changes are summarized in the table below.

| Old Name            | New Name      |
|---------------------|---------------|
| review\_overall     | overall       |
| review\_aroma       | aroma         |
| review\_appearance  | appearance    |
| review\_palate      | palate        |
| review\_taste       | taste         |
| review\_profilename | profile\_name |
| brewery\_name       | *no change*   |
| brewery\_id         | *no change*   |
| beer\_style         | *no change*   |
| beer\_name          | *no change*   |
| beer\_abv           | *no change*   |
| beer\_id            | *no change*   |
| review\_time        | *no change*   |

### Finding Missing Values

Approach:

1.  Create a function for finding missing values
2.  Iterate this function over every column
3.  Create a matrix of missing values for easier visualization

``` r
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

    ##                beer id brewery name brewery id beer ABV profile name taste
    ## missing values 0       15           0          67785    348          0    
    ##                palate beer style appearance aroma overall review time
    ## missing values 0      0          0          0     0       0          
    ##                beer name
    ## missing values 0

Missing values are found in the following columns:

| Column       | Amount of missing values |
|--------------|--------------------------|
| brewery name | 15                       |
| beer ABV     | 67,785                   |
| profile name | 348                      |

The alcohol content is not always written on the container and relatively low ABV is not required to be printed on containers. This may explain the large amount of missing values in the beer\_abv column.

### Missing Values: beer ABV (alcohol by volume)

To deal with these missing values, the mean of the beer\_abv will be computed and used to replace the missing values. After replacing the missing values, the column will be checked again for any missing values in order to confirm the result.

``` r
mean_abv = mean(beer_reviews$beer_abv, na.rm = TRUE) # = 7.04
median_abv = median(beer_reviews$beer_abv, na.rm = TRUE) # 6.6

# replace the missing values in ABV with the mean
beer_reviews = 
  beer_reviews %>%
  replace_na(list(beer_abv = mean_abv))
# check for missing values again
find_NA(beer_reviews$beer_abv)
```

    ## # A tibble: 1 x 1
    ##   missing_values
    ##            <int>
    ## 1              0

### Missing Values: Brewery Name

At the moment, we can't make any accurate guesses as to what the names are of the breweries. Therefore their missing values will be replaced with the string '*unknown*'. After replacing the missing values, the column will be checked again for any missing values in order to confirm the result.

``` r
# view the matrix with missing values
missing_matrix
```

    ##                beer id brewery name brewery id beer ABV profile name taste
    ## missing values 0       15           0          67785    348          0    
    ##                palate beer style appearance aroma overall review time
    ## missing values 0      0          0          0     0       0          
    ##                beer name
    ## missing values 0

``` r
# replace the missing names with 'unknown'
beer_reviews = 
  beer_reviews %>%
  replace_na(list(brewery_name = 'unknown'))
# check for missing values again
find_NA(beer_reviews$brewery_name)
```

    ## # A tibble: 1 x 1
    ##   missing_values
    ##            <int>
    ## 1              0

### Missing Values: Profile Name

Profile names will be replaced with the string '*unknown*' since we can't make any accurate guesses of somebody's name in this instance.

``` r
# view the matrix with missing values
missing_matrix
```

    ##                beer id brewery name brewery id beer ABV profile name taste
    ## missing values 0       15           0          67785    348          0    
    ##                palate beer style appearance aroma overall review time
    ## missing values 0      0          0          0     0       0          
    ##                beer name
    ## missing values 0

``` r
# glance over the missing values
beer_reviews %>%
  select(profile_name) %>%
  filter(is.na(profile_name))
```

    ## # A tibble: 348 x 1
    ##    profile_name
    ##           <chr>
    ##  1         <NA>
    ##  2         <NA>
    ##  3         <NA>
    ##  4         <NA>
    ##  5         <NA>
    ##  6         <NA>
    ##  7         <NA>
    ##  8         <NA>
    ##  9         <NA>
    ## 10         <NA>
    ## # ... with 338 more rows

``` r
# replace the missing profile names with 'Unknown'
beer_reviews = 
  beer_reviews %>%
  replace_na(list(profile_name = 'unknown'))

# check for missing values again
find_NA(beer_reviews$profile_name)
```

    ## # A tibble: 1 x 1
    ##   missing_values
    ##            <int>
    ## 1              0

### Beer Styles

Currently, there are 104 unique beer styles included in this data set. However, some of these styles are highly specific due to their brewing process, ingredient ratios, yeast type, or a combination of other factors; but they can be grouped together since they are a variation of an ale or a lager. The goal is to classify them into more general terms, but without over simplifying, in order to produce plots that are easy to read and translate. A new column will be created to represent these styles. The approach will involve doing some research on the current beer styles included and deciding how to categorize them to yield a reduced list. The *gsub* function will be used to iterate over beer styles and categorize them accordingly.

New Beer-Style column will consist of the following styles:

| Beer Style |        |        |            |          |
|------------|--------|--------|------------|----------|
| ale        | lager  | stout  | lambic     | spiced   |
| pilsner    | porter | smoked | barleywine | ipa      |
| wheat      | bock   | bitter | rye        | trappist |

``` r
# create new column with the new styles using mutate()
beer_reviews = 
  beer_reviews %>%
  mutate(general_beer_style = style_list_mod)

glimpse(beer_reviews)
```

    ## Observations: 1,586,614
    ## Variables: 14
    ## $ brewery_name       <chr> "vecchio birraio", "vecchio birraio", "vecc...
    ## $ beer_name          <chr> "sausa weizen", "red moon", "black horse bl...
    ## $ profile_name       <chr> "stcules", "stcules", "stcules", "stcules",...
    ## $ beer_style         <chr> "hefeweizen", "english strong ale", "foreig...
    ## $ taste              <dbl> 1.5, 3.0, 3.0, 3.0, 4.5, 3.5, 4.0, 3.5, 4.0...
    ## $ palate             <dbl> 1.5, 3.0, 3.0, 2.5, 4.0, 3.0, 4.0, 2.0, 3.5...
    ## $ appearance         <dbl> 2.5, 3.0, 3.0, 3.5, 4.0, 3.5, 3.5, 3.5, 3.5...
    ## $ aroma              <dbl> 2.0, 2.5, 2.5, 3.0, 4.5, 3.5, 3.5, 2.5, 3.0...
    ## $ overall            <dbl> 1.5, 3.0, 3.0, 3.0, 4.0, 3.0, 3.5, 3.0, 4.0...
    ## $ brewery_id         <int> 10325, 10325, 10325, 10325, 1075, 1075, 107...
    ## $ beer_id            <int> 47986, 48213, 48215, 47969, 64883, 52159, 5...
    ## $ review_time        <int> 1234817823, 1235915097, 1235916604, 1234725...
    ## $ beer_abv           <dbl> 5.0, 6.2, 6.5, 5.0, 7.7, 4.7, 4.7, 4.7, 4.7...
    ## $ general_beer_style <chr> "wheat", "ale", "stout", "pilsner", "ipa", ...

``` r
# summarize the new beer styles by calling distinct()
beer_reviews %>%
  group_by(general_beer_style) %>%
  summarise(style_count = n()) %>%
  arrange(desc(style_count))
```

    ## # A tibble: 24 x 2
    ##    general_beer_style style_count
    ##                 <chr>       <int>
    ##  1                ale      577361
    ##  2                ipa      216034
    ##  3              stout      182268
    ##  4              lager      132481
    ##  5              wheat       80947
    ##  6             porter       73249
    ##  7           trappist       68397
    ##  8               bock       46501
    ##  9         barleywine       40459
    ## 10            pilsner       40330
    ## # ... with 14 more rows

### Plot: Beer ABV

Plotting the beer's ABV as a histogram will reveal it's distribution and help us spot any outliers that may be present before diving into deeper analysis.

``` r
#glimpse(beer_reviews)
blues = brewer.pal(6, 'Blues')
ggplot(beer_reviews, aes(x = beer_abv)) + 
  geom_histogram(binwidth = 0.5, position = 'identity', fill = '#3182BD') + 
  scale_x_continuous('Alcohol by Volume (%)', breaks = seq(0, 60, by = 5)) +
  scale_y_continuous('Beer Count') +
  ggtitle('Beer ABV Distribution') +
  theme_classic()
```

![](DataWranglingReport_files/figure-markdown_github-ascii_identifiers/Plot:%20Beer%20ABV-1.png)

This plot shows us that the ABV is actually a right-skewed distribution due to some beers having a a very high alcohol by volume content. The minimum and maximum of ABV content are 0.01% and 57.7%, respectively. The mean lies at 7.04, the median at 6.6, and the standard deviation is 2.27. We can also infer that the distribution is right-skewed due to the median being lower than the mean. Although the values range from 0.01 to 57.7, in theory, about 95% of these values should lie within two standard deviations from the mean.

| Stat               | Value |
|--------------------|-------|
| Standard Deviation | 2.27  |
| Variance           | 5.16  |
| Mean               | 7.04  |
| Median             | 6.6   |
| Max                | 57.7  |
| Min                | 0.01  |

``` r
# find max and min for beer ABV
# replace the missing values before finding MAX and MIN
max(beer_reviews$beer_abv) # 57.7 % 
```

    ## [1] 57.7

``` r
min(beer_reviews$beer_abv) # 0.01 % 
```

    ## [1] 0.01

### Interval: Beer ABV

In order to better visualize the alcohol level content, the ABV can be distributed into five factored levels using the calculated mean and standard deviation. These five levels will be labeled as, 'low', 'below normal', 'normal', 'above normal', and 'high'. The computed standard deviation will be used to create the breaks for the labels.

``` r
# NEW COLUMN: beer_abv_factor
beer_reviews = 
  beer_reviews %>%
  mutate(beer_abv_factor = interval_abv)

glimpse(beer_reviews)
```

    ## Observations: 1,586,614
    ## Variables: 15
    ## $ brewery_name       <chr> "vecchio birraio", "vecchio birraio", "vecc...
    ## $ beer_name          <chr> "sausa weizen", "red moon", "black horse bl...
    ## $ profile_name       <chr> "stcules", "stcules", "stcules", "stcules",...
    ## $ beer_style         <chr> "hefeweizen", "english strong ale", "foreig...
    ## $ taste              <dbl> 1.5, 3.0, 3.0, 3.0, 4.5, 3.5, 4.0, 3.5, 4.0...
    ## $ palate             <dbl> 1.5, 3.0, 3.0, 2.5, 4.0, 3.0, 4.0, 2.0, 3.5...
    ## $ appearance         <dbl> 2.5, 3.0, 3.0, 3.5, 4.0, 3.5, 3.5, 3.5, 3.5...
    ## $ aroma              <dbl> 2.0, 2.5, 2.5, 3.0, 4.5, 3.5, 3.5, 2.5, 3.0...
    ## $ overall            <dbl> 1.5, 3.0, 3.0, 3.0, 4.0, 3.0, 3.5, 3.0, 4.0...
    ## $ brewery_id         <int> 10325, 10325, 10325, 10325, 1075, 1075, 107...
    ## $ beer_id            <int> 47986, 48213, 48215, 47969, 64883, 52159, 5...
    ## $ review_time        <int> 1234817823, 1235915097, 1235916604, 1234725...
    ## $ beer_abv           <dbl> 5.0, 6.2, 6.5, 5.0, 7.7, 4.7, 4.7, 4.7, 4.7...
    ## $ general_beer_style <chr> "wheat", "ale", "stout", "pilsner", "ipa", ...
    ## $ beer_abv_factor    <fctr> normal, normal, normal, normal, normal, be...

### Write the cleaned data to a new file

The clean file is now ready to be written.
