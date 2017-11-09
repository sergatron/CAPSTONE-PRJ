library(ggplot2)
library(readr)
library(tidyr)
library(dplyr)
beer_reviews <- read_csv("beer_reviews_clean.csv")
beer_reviews = as_data_frame(beer_reviews)
glimpse(beer_reviews)
head(beer_reviews)


# *** Consider reducing the (104) beer styles to more general styles (Ale, Lager, Stout, Pilsner... )
# *** shape = 1 - hollow circle
# *** try filtering by profile name to see reviews of a single reviewer and then plot results

# ------ PLOTTING ------
# Exploratory Analysis
# reduce the amount of data points
reviews_10k = sample_n(beer_reviews, size = 10000)# head(beer_reviews, n = 10000)
glimpse(reviews_10k)

# --- Point Plot
# overall vs. beer ABV, colored by beer style
ggplot(reviews_10k, aes(x = overall, y = beer_abv, col = general_beer_style)) + 
  geom_point(alpha = 0.3) +
  geom_jitter()

# --- Point Plot
# OVR_rating vs. beer ABV, colored by beer style
ggplot(reviews_10k, aes(x = overall, y = general_beer_style, col = beer_abv)) + 
  geom_point(alpha = 0.1, shape = 21) +
  geom_jitter()

# --- Histogram Plot
# overall and beer style
ggplot(reviews_10k, aes(x = overall, fill = general_beer_style)) + 
  geom_histogram(binwidth = 10, position = 'dodge') 

# --- Bar Plot
# overall and beer style
ggplot(reviews_10k, aes(x = overall, fill = general_beer_style)) + 
  geom_bar(position = 'dodge') 



# ------ LOWER CASE ------
# change all text to lower case
beer_reviews %>%
  select(beer_name) %>%
  tolower() # *** NOTE: do not run. Takes tooooo long and crashes.

sample_N = sample_n(beer_reviews, size = 500)
lower_Case = 
  sample_N %>%
  select(beer_name, brewery_name, beer_style, profile_name) %>%
  tolower

class(lower_Case)
# ***NOTE: do not use DPLYR combined with tolower(). The data frame will be converted into character 
# Change each column to lower case individually 

sample_N$brewery_name
glimpse(lower_Case)



# ------ CHECK FOR MISSING VALUES IN EVERY COLUMN ------

# create a matrix of missing values for easier visualization
find_NA = function(column_name){
  beer_reviews %>% 
    filter(is.na(column_name)) %>%
    summarise(missing_values = n())
}

columns_name = list(
                beer_reviews$beer_beerid,
                beer_reviews$brewery_name,
                beer_reviews$brewery_id,
                beer_reviews$beer_abv,
                beer_reviews$review_profilename,
                beer_reviews$review_taste,
                beer_reviews$review_palate,
                beer_reviews$beer_style,
                beer_reviews$review_appearance,
                beer_reviews$review_aroma,
                beer_reviews$review_overall,
                beer_reviews$review_time,
                beer_reviews$beer_name
                )
class(columns_name)
missing_vals = sapply(columns_name, find_NA)
class(missing_vals)

# matrix of missing values
columns = c('beer id', 'brewery name', 'brewery id', 'beer ABV', 'profile name', 'review taste', 'review palate', 'beer style',
            'review appearance', 'review aroma', 'review overall', 'review time', 'beer name')
rows = c('missing values')
missing_matrix = matrix(missing_vals, byrow = TRUE, nrow = 1)
colnames(missing_matrix) = columns
rownames(missing_matrix) = rows
missing_matrix

# --- MISSING VALUES: beer_abv

# calculate the mean of ABV to use as replacement for NAs
mean_ABV = mean(beer_reviews$beer_abv, na.rm = TRUE)
class(mean_ABV)

# replace the missing values in ABV with the mean
beer_reviews = 
  beer_reviews %>%
  #select(beer_abv) %>%
  replace_na(list(beer_abv = mean_ABV))
class(beer_reviews)

# check for missing values again
find_NA(beer_reviews$beer_abv)

# --- Missing Values: Brewery Name

# --- Missing Values: profile name

# find max and min for beer ABV
# replace the missing values before finding MAX and MIN
max(beer_reviews$beer_abv)
min(beer_reviews$beer_abv)

# amount of beer with ABV over 20%
beer20 = 
  beer_reviews %>%
  select(beer_abv) %>%
  filter(beer_abv >= 20)
beer20

# ------ SUMMARY STATISTICS ------

# ------ BREWERY NAME ------
# NOTE: some brewery names have characters that can be removed 
glimpse(beer_reviews)
beer_reviews %>%
  group_by(brewery_name) %>%
  summarise(brewery_count = n()) %>%
  #arrange(desc(brewery_count)) %>%
  print(n = 20)

# distinct amount of breweries and the amount of times they appear in the data set
brewery_df = 
  beer_reviews %>%
  group_by(brewery_name) %>%
  summarise(brewery_count = n(), ovr_mean = mean(overall)) %>%
  arrange(desc(ovr_mean)) %>%
  filter(between(brewery_count, 10, 20)) %>%
  print(n = 20)
  
  
# rate the breweries
breweries_list = list(brewery_df$brewery_count)
stats_function = function(DF, VECT = NULL){
  # DF has to be a list
  sd_list   = lapply(DF, sd)
  var_list  = lapply(DF, var)
  mean_list = lapply(DF, mean)
  median_list = lapply(DF, median)
  max_list = lapply(DF, max)
  min_list = lapply(DF, min)
  yy = c(sd_list, var_list, mean_list, median_list, max_list, min_list)
  
  rows = c('standard deviation', 'variance', 'mean', 'median', 'max', 'min')
  columns = c('breweries')
  sd_matrix = matrix(yy, byrow = TRUE, nrow = length(rows), ncol = length(columns))
  colnames(sd_matrix) = columns
  rownames(sd_matrix) = rows
  sd_matrix
}
stats_function(breweries_list)








# ------ BEER NAMES ------
# find beers with least amount of reviews
beer_name_df = 
  beer_reviews %>%
  group_by(beer_name) %>%
  summarise(review_count = n(), 
            overall_sd = sd(overall),
            taste_sd = sd(taste)) %>%
  arrange(overall_sd) #%>%
  #filter(between())
beer_name_df
sd(beer_name_df$review_count)
median(beer_name_df$overall)
mean(beer_name_df$overall)
sd(beer_name_df$overall)

# max, min, and mean
max(beer_name_df$review_count) # = 3290
min(beer_name_df$review_count)# = 1 
mean(beer_name_df$review_count) # 27.93 reviews per beer
glimpse(beer_name_df)



# filter reviewed amount 
beer_review_amount_df = 
  beer_reviews %>%
  group_by(beer_name, general_beer_style) %>%
  summarise(reviewed_amount = n()) %>%
  arrange(desc(reviewed_amount)) %>%
  filter(reviewed_amount <= 250)

ggplot(beer_review_amount_df, aes(x = reviewed_amount, fill = general_beer_style)) + 
  geom_histogram(binwidth = 10, position = 'dodge')

glimpse(beer_name_filter)




# ------ BEER STYLES ------
# print out beer names and their styles
beer_reviews %>%
  group_by(beer_name, general_beer_style) %>%
  summarise(beer_name_cnt = n()) %>%
  arrange(desc(beer_name_cnt)) %>%
  #filter(between(n, 500, 900)) %>%
  print(n = 15)


# number of beer styles and the amount of times it was reviwed
beer_styles = 
  beer_reviews %>% 
  group_by(beer_style, overall, beer_abv) %>%
  summarise(reviewed_amount = n()) %>%
  arrange(desc(reviewed_amount)) %>%
  filter(between(reviewed_amount, 20, 3000))

glimpse(beer_styles)



# ------ *** REDUCE beer styles ------
# REDUCE the amount of styles into: lager, ale, IPA, stout, pilsner, porter

# TALLY each beer style and arrange in descending order
beer_reviews %>%
  group_by(beer_style, beer_name) %>%
  summarise(review_count = n()) %>%
  arrange(desc(review_count)) #%>%
  #filter(review_count >= 10000)


# create a list of beer styles to use within 'grep'
style_list =  
  c(beer_reviews %>%
  select(beer_style) %>%
  distinct())

style_list = unlist(style_list)
class(style_list)
glimpse(style_list)
head(style_list)

# beer name list
beer_name_list = 
  c(beer_reviews %>%
      select(beer_name) %>%
      distinct())
beer_name_list = unlist(beer_name_list)
glimpse(beer_name_list)

ale_count = matches(match = '.*ale.*', vars = beer_name_list)
ale_count = contains(match = 'ale', vars = beer_name_list)
glimpse(ale_count)
length(ale_count)




# ALE
# IPA will grouped with ALE since it is considered to be an ALE
# DPLYR method to match strings
?contains
ale_cnt = contains(match = 'ale', vars = style_list)
class(ale_cnt)
glimpse(ale_cnt)
eve = everything(vars = style_list)
class(eve)

bock_cnt = contains(match = 'bock', vars = style_list)
style_list[bock_cnt]
length(bock_cnt)


# base R, 'grep' method
style_list = c(beer_reviews %>% select(beer_style))
style_list = unlist(style_list)
ale = grep(pattern = '.*ale.*|^alt.*|.*winter.*|.*garde$|^k.*lsch.*', x = style_list) # setting value = TRUE will show the strings right away. Saves an extra step
class(ale)
glimpse(ale)
length(ale)

is.atomic(ale)
mean(ale)
sd(ale)

# LAGER
lager = grep(pattern = '.*lager.*|^schwarz.*|^m.*rzen.*|.*steam.*|.*zwickel.*', x = style_list)
lager_ = contains(match = '.*lager.*|^schwarz.*|^m.*rzen.*|.*steam.*|.*zwickel.*', vars = style_list)
lager_list = style_list[lager]
glimpse(lager_list)
length(lager)

sd(lager)

replace(style_list, lager, 'lager')


# IPA
ipa = grep(pattern = 'ipa', x = style_list, value = TRUE)
ipa_list = style_list[ipa]
glimpse(ipa_list)
length(ipa)

# STOUT
stout = grep(pattern = ' stout', x = style_list, value = TRUE)
stout_list = style_list[stout]
glimpse(stout_list)
length(stout_list)

# PILSNER or PILSENER
pils = grep(pattern = ' pilsner|pilsener', x = style_list, value = TRUE)
pils_list = style_list[pils]
length(pils)

# PORTER
porter = grep(pattern = ' porter', x = style_list, value = TRUE)
porter_list = style_list[porter]
length(porter)

# WHEAT BEER
wheat = grep(pattern = 'weizen|wit|weiss|gose', x = style_list, value = TRUE)
wheat_list = style_list[wheat]
length(wheat)

# BOCK
bock = grep(pattern = 'bock', x = style_list, value = TRUE)
bock_list = style_list[bock]
length(bock)

# LAMBIC
lambic = grep(pattern = '^lambic|faro|gueuze', x = style_list, value = TRUE)
lambic_list = style_list[lambic]
length(lambic)

# BARLEYWINE
barleywine = grep(pattern = ' barleywine', x = style_list, value = TRUE)

# SMOKED BEER
smoked = grep(pattern = '^smoked|^rauch', x = style_list, value = TRUE)
length(smoked)

# BITTER
bitter = grep(pattern = 'bitter', x = style_list, value = TRUE)

# RYE BEER
rye = grep(pattern = 'rye|roggen|kvass', x = style_list, value = TRUE)

# SPICED/HERBED BEER
spiced = grep(pattern = 'herbed|braggot|chile', x = style_list, value = TRUE)

# TRAPPIST
trappist = grep(pattern = '^quad|^dub|^tri', x = style_list, value = TRUE)


# MISC
# subtract the known from style_list to get the remaining unknown beers
# use 'SETDIFF' to find the difference between 2 lists
x = style_list
styles_vect = c(porter, pils, stout, lager, ale, wheat, bock, lambic,
                smoked, barleywine, rye, bitter, spiced, ipa, trappist)
misc_styles = setdiff(x,styles_vect)
misc_styles
length(misc_styles)
class(misc_styles)

# check the math, there should be 104
length(misc_styles) + length(porter) + length(ale) + length(lager) + length(stout) + length(pils) + length(wheat)


# ------ NEW BEER STYLES COLUMN ------
# CONSIDER sorting by country of origin: BELGIUM, UK, US, GERMANY
# create new column for the reduced beer styles
# NEW COLUMN will contain styles: ale, lager, stout, pilsner, bock, tripel, wheat, lambic, porter

# create a list of beer styles to use within 'grep'
style_list = c(beer_reviews %>% select(beer_style))
style_list = unlist(style_list)

class(style_list)
glimpse(style_list)
head(style_list)


# ------- HOW TO REPLACE ENTIRE STRING WHEN A STRING MATCH OCCURS???
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
unique(style_list_mod)


length(style_list_mod)
glimpse(style_list_mod)

# create new column with the new styles using mutate()
beer_reviews = 
  beer_reviews %>%
  mutate(general_style = style_list_mod)

# summarize the new beer styles
# distinct amount of styles
beer_reviews %>%
  select(general_beer_style) %>%
  distinct()

beer_reviews_style =
  beer_reviews %>%
  group_by(general_beer_style) %>%
  summarise(style_count = n()) %>%
  arrange(desc(style_count)) %>%
  print(n = 25)

# ------ STANDARD DEVIATION ------
# ---- 2. Beer ABV Levels ----

# Beer ABV 
beer_reviews %>%
  select(beer_abv, general_beer_style) %>%
  print(n = 20)

abv_vector = beer_reviews$beer_abv
mean(abv_vector)   # 7.04
median(abv_vector) # 6.6
sd(abv_vector)     # 2.27
var(abv_vector)    # 5.16



one_sd_below = mean(abv_vector) - sd(abv_vector) # 4.77 -> 1 SD below mean
one_sd_above = mean(abv_vector) + sd(abv_vector) # 9.31 -> 1 SD above mean
mean(abv_vector) - 2*sd(abv_vector) 

?table
?cut
?cut_number
?cut_interval
?cut_width
# ---- * INTERVAL ----
interval = cut_interval(abv_vector, n = NULL, length = sd(abv_vector)*4, labels = c('low', 'below normal', 'normal',
                                                                                    'above normal', 'high'))
interval = cut_interval(abv_vector, n = NULL, length = sd(abv_vector))
table(interval)
interval2= cut_interval(as.integer(interval), length = sd(abv_vector)*2)
table(interval2)
class(interval)
length(interval2)

# Interval of ABV
# use cut() and a vector within the breaks
breaks_vect = c()
interval = cut(abv_vector, breaks = c(0, mean(abv_vector) - 2*sd(abv_vector), one_sd_below, mean(abv_vector), 
                                       one_sd_above, mean(abv_vector) + 2*one_sd_above, 60 ))
table(interval)


# NEW COLUMN: beer_abv_interval
beer_reviews %>%
  mutate(beer_abv_interval = interval2) %>%
  select(beer_abv_interval, beer_abv)
  filter(beer_abv >= 15) %>%
  arrange(desc(beer_abv))

glimpse(beer_reviews)

# normal ABV level will be considered being within 1 SD of the mean
interval_cut = cut_number(abv_vector, n = 2*sd(abv_vector), width = 1, length = sd(abv_vector)) # labels = c('low', 'below normal', 'normal', 'above normal', 'high')
table(interval_cut)
interval_cut_width = cut_width(abv_vector, width = 2*sd(abv_vector), center = mean(abv_vector), closed = c('left'))
table(interval_cut_width)


  

# ---- 1. Beer Styles Popularity ----
# Beer style SD
beer_reviews_style =
  beer_reviews %>%
  group_by(general_beer_style) %>%
  summarise(style_count = n()) %>%
  arrange(desc(style_count)) %>%
  print(n = 25)

beer_style_count = c(beer_reviews_style$style_count)
sd(beer_style_count)      # 123,448.7
var(beer_style_count)     # 15,239,576,394
mean(beer_style_count)    # 66,108.92
median(beer_style_count)  # 22,340.5

# most popular styles are outside the mean by at least 0.5 SD
mean(beer_style_count) - 0.5*sd(beer_style_count) # 4,384.58
mean(beer_style_count) + 0.5*sd(beer_style_count) # 127,833.3

# filter out the more popular styles
# filter(mean + 0.5*SD)
beer_reviews %>%
  group_by(general_beer_style) %>%
  summarise(style_count = n()) %>%
  arrange(desc(style_count)) %>%
  print(n = 25) %>%
  filter(style_count >= mean(beer_style_count) + 0.5*sd(beer_style_count))

# filter(mean - 0.5*SD) to find least popular
# 
beer_reviews %>%
  group_by(general_beer_style) %>%
  summarise(style_count = n()) %>%
  arrange(desc(style_count)) %>%
  print(n = 25) %>%
  filter(style_count <= mean(beer_style_count) - 0.5*sd(beer_style_count))





# ---- SUMMARISE the MEAN, SD, and VAR ----
# for every beer style and beer name, 
beer_reviews_dist = 
  beer_reviews %>%
  #select(beer_name, overall) %>%
  group_by(beer_name) %>%
  summarise(beer_name_count = n()) %>%
  arrange(desc(beer_name_count))

sd(beer_reviews_dist$beer_name_count)
mean(beer_reviews_dist$beer_name_count)
median(beer_reviews_dist$beer_name_count)
var(beer_reviews_dist$beer_name_count)

# tally each beer name and calculate SD for the 5 observations
beer_reviews_SD = 
  beer_reviews %>%
  group_by(beer_name, general_beer_style) %>%
  summarise(beer_name_count = n(),
            
            overall_sd    = sd(overall), 
            taste_sd      = sd(taste),
            aroma_sd      = sd(aroma), 
            appearance_sd = sd(appearance), 
            palate_sd     = sd(palate)) %>%
  
  filter(beer_name_count >= 5) %>%
  arrange(overall_sd) %>%
  #na.omit %>%
  print(n = 20)
glimpse(beer_reviews_SD)


# PLOT
# overall_mean vs. overall_sd
ggplot(beer_reviews_SD, aes(x = overall_sd, y = taste_sd, col = general_beer_style)) + 
  #geom_point() + 
  stat_smooth(method = 'loess', se = FALSE) +
  #geom_jitter() + 
  #scale_x_continuous(limits = c(0,2)) + 
  #scale_y_continuous(limits = c(0,2)) + 
  theme_classic()

# PLOT
# overall_sd vs beer_name_count
ggplot(beer_reviews_SD, aes(x = overall_sd, y = beer_name_count)) + 
  geom_point() + 
  #stat_smooth(method = 'loess', se = TRUE) +
  #geom_jitter() + 
  #scale_x_continuous(limits = c(0,2)) + 
  #scale_y_continuous(limits = c(0,2)) + 
  theme_classic()

# PLOT
# overall_sd histogram
ggplot(beer_reviews_SD, aes(x = overall_sd)) + 
  geom_histogram(binwidth = 0.01) + 
  theme_classic()


min(beer_reviews_SD$overall_sd)
max(beer_reviews_SD$overall_sd)
mean(beer_reviews_SD$overall_sd)
median(beer_reviews_SD$overall_sd)
sd(beer_reviews_SD$overall_sd)


# NOTE: 
# with only 1 or 2 reviews, disagreements vary greatly among the 5 observations
# 1. lower deviation implies agreement between different reviews
# 2. higher deviation implies disagreement between reviewers


# PLOT: deviation
# overall vs. aroma
ggplot(beer_reviews_SD, aes(x = overall_sd, y = aroma_sd)) + 
  geom_point() + 
  stat_smooth(method = 'loess', se = TRUE) +
  #geom_jitter() + 
  #scale_x_continuous(limits = c(0,2)) + 
  #scale_y_continuous(limits = c(0,2)) + 
  theme_classic()
# GRAPH NOTE:
# The outliers contained in the graph are due to low amount of reviews and the disagreements between reviewers


# FIND the least amount of disagreements by filtering the SD for each observation. Smaller deviation = less disagreement
# filter(sd between(0, 0.25), name_count >=5)
beer_reviews_sd_filter = 
  beer_reviews %>%
  group_by(beer_name, general_beer_style) %>%
  summarise(beer_name_count = n(), 
            overall_sd    = sd(overall), 
            taste_sd      = sd(taste), 
            aroma_sd      = sd(aroma), 
            appearance_sd = sd(appearance), 
            palate_sd     = sd(palate)) %>%
  filter(beer_name_count >= 5, 
         between(overall_sd, 0, 0.30), 
         between(taste_sd, 0, 0.30), 
         between(aroma_sd, 0, 0.30), 
         between(appearance_sd, 0, 0.30), 
         between(palate_sd, 0, 0.30)) %>%
  arrange(overall_sd, taste_sd, aroma_sd, appearance_sd, palate_sd) %>%
  print(n = 20)



# MATRIX for mean, sd, var
?matrix
observations_list = list(beer_reviews$overall, beer_reviews$aroma, 
                         beer_reviews$appearance,beer_reviews$palate,
                         beer_reviews$taste)
stats_function = function(DF, VECT = NULL){
  # DF can be a list of vectors
  sd_list   = lapply(DF, sd)
  var_list  = lapply(DF, var)
  mean_list = lapply(DF, mean)
  median_list = lapply(DF, median)
  max_list = lapply(DF, max)
  min_list = lapply(DF, min)
  yy = c(sd_list, var_list, mean_list, median_list, max_list, min_list)

  rows = c('standard deviation', 'variance', 'mean', 'median', 'max', 'min')
  columns = c('overall', 'aroma', 'appearance', 'palate', 'taste')
  sd_matrix = matrix(yy, byrow = TRUE, nrow = length(rows), ncol = length(columns))
  colnames(sd_matrix) = columns
  rownames(sd_matrix) = rows
  sd_matrix
}
stats_function(observations_list)





# ---- PLOT: reduced beer styles ----
# use gsub on beer_styles column and create a new column for a general beer style
beer_reviews_5k = sample_n(beer_reviews, 5000)
glimpse(beer_reviews)

# HISTOGRAM
ggplot(beer_reviews_5k, aes(x = beer_abv, fill = general_beer_style)) + 
  geom_histogram(binwidth = 10, position = 'dodge', alpha = 0.6) +
  scale_x_continuous(limits = c(1,20))

ggplot(beer_reviews_5k, aes(x = as.factor(overall), fill = general_beer_style)) + # ??????????????????
  geom_histogram(binwidth = 15, stat = 'count') +
  #scale_x_continuous(limits = c(1,20)) + 
  theme_classic()


ggplot(beer_reviews_5k, aes(x = general_beer_style, fill = overall)) + 
  geom_histogram(stat = 'count') +
  scale_x_discrete('Beer Style') + 
  theme_classic()


# BAR GRAPH
# beer style vs overall
ggplot(beer_reviews_5k, aes(x = general_beer_style, y = overall, fill = general_beer_style)) + 
  geom_bar(stat = 'identity') +
  scale_x_discrete('Beer Style',  expand = c(0, 0)) + 
  theme_classic()


# POINT 
# overall vs. ABV
ggplot(beer_reviews_5k, aes(x = overall, y = beer_abv, col = general_beer_style)) + 
  #geom_point(alpha = 0.3) +
  stat_smooth(method = 'loess', se = FALSE) +
  #geom_jitter() +
  theme_classic()
  
# overall vs. beer style
ggplot(beer_reviews_5k, aes(x = overall, y = general_beer_style)) + 
  geom_point(alpha = 0.3) +
  #stat_smooth(method = 'loess', se = FALSE) +
  geom_jitter() +
  theme_classic()
  
ggplot(beer_reviews_5k, aes(x = overall, y = general_beer_style, col = beer_abv)) + 
  geom_point(shape = 21, alpha = 0.6) + 
  geom_jitter()  
  #stat_smooth(method = 'loess', se = FALSE)
  
# palate vs overall
ggplot(beer_reviews_5k, aes(x = palate, y = overall, col = beer_abv)) + 
  geom_point(alpha = 0.3) +
  stat_smooth(method = 'loess', se = FALSE) + 
  geom_jitter() +
  theme_classic()
  
  
  

    
  

# LOOK UP
?setdiff
?extract



# create a new metric by calculating mean of all observations
# number of overall = 5
beer_reviews %>%
  select(overall) %>%
  filter(overall >= 5) 

# overall ratings between 4 and 5 
beer_reviews %>%
  filter(between(review_overall, 4, 5))






# ------ PROFILE NAMES ------
# number of profile names
beer_reviews %>% 
  select(profile_name) %>% 
  distinct()

# amount of reviews by each person
beer_reviews %>% 
  group_by(profile_name) %>% 
  tally(sort = TRUE)

# find total amount of profile names
profile_names = 
  beer_reviews %>% 
  group_by(profile_name) %>%
  summarise(review_amount = n()) %>%
  arrange(desc(review_amount)) #%>%
  #filter(between(review_amount, 100,5900)) # amount of people with reviews in range: 100 <= review_amount < 5900
profile_names # 33,388 total profile names
glimpse(profile_names)

max(profile_names$review_amount) # 5817
min(profile_names$review_amount) # 1
sum(profile_names$review_amount) # 1,586,614
mean(profile_names$review_amount) # 47.52 reviews per person
glimpse(profile_names)

# find lowest activity by filtering review amount 
beer_reviews %>% 
  group_by(profile_name) %>%
  summarise(review_amount = n()) %>%
  arrange(desc(review_amount)) %>%
  filter(between(review_amount, 1, 5))
# 19,821 names submitted 5 or less reviews





# ------ REVIEW TIMES SUMMARY ------
# find: max and min review time/amount
# find: largest amount of review times for beer style

# number of beers with the greatest amount of reviews and their respective beer styles
review_time = 
  beer_reviews %>%
  select(review_time) %>%
  arrange(desc(review_time))

glimpse(review_time)
min(review_time$review_time) # MIN: the beer with the least reviews = 840,672,001
max(review_time$review_time) # MAX: the beer with the most reviews = 1,326,285,348


# ------ REVIEW TIME ??? ------
# MAX: the beer with the most reviews = 1,326,285,348
max(beer_reviews$review_time)
# MIN: the beer with the least reviews = 840,672,001
min(beer_reviews$review_time)
beer_reviews %>%
  select(review_time, beer_style) %>%
  filter(review_time <= 1000000000) %>%
  summarise(Num_of_beers = n())

beer_reviews %>%
  group_by(review_time) %>%
  summarise(n = n()) %>%
  arrange(desc(n))
