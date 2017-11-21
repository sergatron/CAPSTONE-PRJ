library(ggplot2)
library(readr)
library(tidyr)
library(dplyr)
library(tibble)
library(RColorBrewer)
library(ggthemes)
library(GGally)
beer_reviews <- read_csv("beer_reviews_clean.csv")
beer_reviews = as_data_frame(beer_reviews)
glimpse(beer_reviews)
head(beer_reviews)




# *** shape = 1 - hollow circle
# *** try filtering by profile name to see reviews of a single reviewer and then plot results
# CLEAN UP beer names and brewery columns for unsual characters, ",<ff>, <fe>, 

# ------ PLOTTING ------
# Exploratory Analysis
# reduce the amount of data points with the sample_n()
reviews_10k = sample_n(beer_reviews, size = 10000)
glimpse(reviews_10k)

# --- Point Plot
# overall vs. beer ABV, colored by beer style
ggplot(reviews_10k, aes(x = overall, y = beer_abv, col = general_beer_style)) + 
  geom_point(alpha = 0.3) +
  geom_jitter()

# filter out Lager in particular with its respective ABV, and ratings
# plot Lager overall ratings vs. the ABV

# --- Point Plot
# OVR_rating vs. beer ABV, colored by beer style
ggplot(reviews_10k, aes(x = overall, y = general_beer_style, col = beer_abv_factor)) + 
  geom_point(alpha = 0.1, shape = 21) +
  geom_jitter()

# ------ Histogram Plot -------
# Overall Rating Distribution
ggplot(reviews_10k, aes(x = overall)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = beer_abv_factor) +
  theme_blue

ggplot(reviews_10k, aes(x = taste)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge') +
  theme_classic()

ggplot(reviews_10k, aes(x = aroma)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge') +
  theme_classic()

ggplot(reviews_10k, aes(x = appearance)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge') +
  theme_classic()

ggplot(reviews_10k, aes(x = palate)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge') +
  theme_classic()

# ------ Bar Plot ------
# overall rating distribution
ggplot(reviews_10k, aes(x = overall, fill = general_beer_style)) + 
  geom_bar(position = 'dodge') 



# ------ LOWER CASE ------
# change all text to lower case
#beer_reviews %>%
#  select(beer_name) %>%
#  tolower() # *** NOTE: do not run. Takes tooooo long and crashes.

#sample_N = sample_n(beer_reviews, size = 500)
#lower_Case = 
#  sample_N %>%
#  select(beer_name, brewery_name, beer_style, profile_name) %>%
#  tolower

class(lower_Case)
# ***NOTE: do not use DPLYR combined with tolower(). The data frame will be converted into character 
# Change each column to lower case individually 



# ------ CHECK FOR MISSING VALUES IN EVERY COLUMN ------

# create a matrix of missing values for easier visualization
find_NA = function(column_name){
  beer_reviews %>% 
    filter(is.na(column_name)) %>%
    summarise(missing_values = n())
}
find_NA(brewery_name)

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


# ------ SUMMARY STATISTICS ------

# ------ BREWERY NAME ------
# NOTE: some brewery names have characters that can be removed such as: "", \\, <>
beer_reviews %>%
  group_by(brewery_name) %>%
  summarise(brewery_count = n()) %>%
  arrange(desc(brewery_count)) %>%
  print(n = 20)

# CLEAN UP: Brewery Name column
# mutate
brewery_name_list = beer_reviews$brewery_name
brew_name_ind_vect = grep('<ff>|<fe>|"|u008', brewery_name_list, value = TRUE)
length(brew_name_ind_vect)
brew_sub = gsub('<ff>|<fe>|"|u008', '', brewery_name_list)
length(brew_sub)
brew_check = grep('<ff>|<fe>|"|u008', brew_sub)
length(brew_check)
# in the data frame, insert the new clean column
glimpse(beer_reviews)

beer_reviews$brew_sub = beer_reviews$brewery_name
glimpse(brew_sub)
length(grep('<ff>|<fe>|"|u008', beer_reviews$brewery_name))

clean_brew = function(column_name){
  column_name
  brew_name_ind_vect = grep('<ff>|<fe>|"|u008', column_name)
  
  if(length(brew_name_ind_vect) > 0){
    print(paste('Found', length(brew_name_ind_vect), 'items. Working...'))
    brew_sub = gsub('<ff>|<fe>|"|u008', '', brewery_name_list)
    print('Done!')
    
  } else if(length(brew_name_ind_vect) < 1) {
    print('All clear!')
  }
}
clean_brew(brewery_name)


# CLEAN UP: Beer Name column
# use grep() and length() to find the beer names in question
beer_name_list = beer_reviews$beer_name
beer_name_ind_vec = grep('<ff>|<fe>|"|u008', beer_name_list)
length(beer_name_ind_vec)
beer_name_ind_vec[1:50]
# use gsub() to search for the characters and replace them with nothing/emptry string
re_beer_name = gsub('<ff>|<fe>|"|u008', '', beer_name_list)
length(re_beer_name)
re_beer_name[1:50]

?replace
# use the grep() index vector to use within replace() 
beer_name_ind_vec = grep('<ff>|<fe>|"|u008', beer_name_list)
length(beer_name_ind_vec)
re = replace(beer_name_list, beer_name_ind_vec, re_beer_name)
length(re)
glimpse(re)
# replace the existing column with the cleaned version
re = beer_reviews$beer_name

# check the cleaned column. Will be zero if successfull
beer_name_ind_vec = grep('<ff>|<fe>|"|u008', re)
length(beer_name_ind_vec)

# replace the 
beer_reviews = 
  beer_reviews %>%
  replace(list = beer_name_vect, values = re_beer_name)
  
glimpse(beer_reviews)
beer_reviews %>%
  select(beer_name) %>%
  matches('<ff>|<fe>|"|u008', vars = beer_name)
  print(n = 50)






# distinct amount of breweries and the amount of times they appear in the data set
# 

brewery_df =
  beer_reviews %>%
  group_by(brewery_name, beer_name) %>%
  summarise(review_count = n()) %>%
  arrange(desc(review_count)) %>%
  #filter(between(review_count, 1, 2)) %>%
  print(n = 20)  

# rate the breweries
# try tibble() to construct a table instead of the matrix
breweries_list = list(brewery_df$brewery_count)
stats_function = function(DF, col_name){
  # DF has to be a list
  DF = list(DF)
  sd_list   = lapply(DF, sd)
  var_list  = lapply(DF, var)
  mean_list = lapply(DF, mean)
  median_list = lapply(DF, median)
  max_list = lapply(DF, max)
  min_list = lapply(DF, min)
  yy = c(sd_list, var_list, mean_list, median_list, max_list, min_list)
  rows = c('standard deviation', 'variance', 'mean', 'median', 'max', 'min')
  columns = c(col1 = col_name)
  sd_matrix = matrix(yy, byrow = TRUE, nrow = length(rows), ncol = length(columns))
  colnames(sd_matrix) = columns
  rownames(sd_matrix) = rows
  sd_matrix
}
stats_function(brewery_df$review_count, 'brewery stats')
stats_function_2(brewery_df$review_count, 'brewery stats')







# ------ BEER NAMES ------
# find characters to remove from beer_names: \,"<ff> <fe>
# find beers with least amount of reviews
beer_name_df = 
  beer_reviews %>%
  group_by(beer_name, general_beer_style) %>%
  summarise(review_count = n()) %>%
  print(n = 20)
beer_name_df

stats_function_2(beer_name_df$review_count, 'Reviews Count')


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
  geom_histogram(binwidth = 30, position = 'dodge')

glimpse(beer_name_filter)




# ------ BEER STYLES ------

beer_reviews %>%
  group_by(beer_style) %>%
  summarise(review_count = n()) %>%
  arrange(desc(review_count)) %>%
  print(n = 104)

# print out beer names and their styles
beer_reviews %>%
  group_by(beer_name, general_beer_style) %>%
  summarise(beer_name_cnt = n()) %>%
  arrange(desc(beer_name_cnt)) %>%
  #filter(between(n, 500, 900)) %>%
  print(n = 15)


# calculate mean for each beer style
beer_styles = 
  beer_reviews %>% 
  group_by(beer_style, overall) %>%
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
ipa = grep(pattern = '.*ipa.*', x = style_list)
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


stats_function_2 = function(DF, col_name, summary = FALSE){
  # DF has to be a list
  if (summary == TRUE){
    summary(DF)
  }
  else if(summary == FALSE){
  DF = list(DF)  
  sd_list     = lapply(DF, sd)
  var_list    = lapply(DF, var)
  mean_list   = lapply(DF, mean)
  median_list = lapply(DF, median)
  max_list    = lapply(DF, max)
  min_list    = lapply(DF, min)
  yy          = c(sd_list, var_list, mean_list, median_list, max_list, min_list)
  rows        = c('standard deviation', 'variance', 'mean', 'median', 'max', 'min')
  columns     = c(col1 = col_name)
  sd_matrix   = matrix(yy, byrow = TRUE, nrow = length(rows), ncol = length(columns))
  colnames(sd_matrix) = columns
  rownames(sd_matrix) = rows
  sd_matrix
  }
  
}
stats_function_2(abv_vector, 'Beer ABV Summary')
summary(abv_vector)

# ---- ABV INTERVAL ----
?tibble
abv_vector = beer_reviews$beer_abv
mean(abv_vector)   # 7.04
median(abv_vector) # 6.6
sd(abv_vector)     # 2.27
var(abv_vector)    # 5.16
length(abv_vector)

stats_function_2(beer_reviews$beer_abv, 'Beer ABV')

one_sd_below = mean(abv_vector) - sd(abv_vector) # 4.77 -> 1 SD below mean
one_sd_above = mean(abv_vector) + sd(abv_vector) # 9.31 -> 1 SD above mean
two_sd_below = mean(abv_vector) - 2*sd(abv_vector) 
two_sd_above = mean(abv_vector) + 2*sd(abv_vector)

?table
?cut
?cut_number
?cut_interval
?cut_width

# Interval of ABV
# use cut() and a vector within the breaks
# normal ABV level will be considered being within 1 SD of the mean
breaks_vect = c(0, two_sd_below, one_sd_below, one_sd_above, two_sd_above, 60)
interval = cut(abv_vector, 
               breaks = breaks_vect)
               #labels = c('low', 'below normal', 'normal', 'above normal', 'high'))
table(interval)
# sum the amounts within two standard deviations and divide by total amount of rows
# this will contain about 95% of all the data points in the beer's abv column
(140735 + 1193157 + 200598) / length(abv_vector)


glimpse(beer_reviews)
# NEW COLUMN: beer_abv_interval
beer_reviews %>%
  mutate(beer_abv_interval = interval2) %>%
  select(beer_abv_interval, beer_abv)
  filter(beer_abv >= 15) %>%
  arrange(desc(beer_abv))
glimpse(beer_reviews)



  

# ---- Beer Styles Popularity ----
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




# ---- BEER NAME: Summary Stats ----

# for every beer style and beer name, summarize SD, VAR, MEAN, MEDIAN, MAX, MIN
stats_function_2(beer_reviews$overall, 'Overall Rating Summary')
stats_function_2(beer_reviews$taste, 'Taste Rating Summary')
stats_function_2(beer_reviews$aroma, 'Aroma Rating Summary')
stats_function_2(beer_reviews$appearance, 'Appearance Rating Summary')
stats_function_2(beer_reviews$palate, 'Palate Rating Summary')

beer_reviews_dist = 
  beer_reviews %>%
  #select(beer_name, overall) %>%
  group_by(beer_name, overall, taste, aroma, appearance, palate) %>%
  summarise(beer_name_count = n(), 
            overall_mean = mean(overall), overall_sd = sd(overall)) %>%
  arrange(overall) %>%
  filter(overall == 0) %>%
  print(n = 10)


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
  
  #filter(beer_name_count >= 5) %>%
  arrange(overall_sd) %>%
  na.omit %>%
  print(n = 20)
glimpse(beer_reviews_SD)

beer_reviews_SD %>% 
  filter(is.na(beer_name_count)) %>%
  summarise(missing_values = n())

stats_function_2(beer_reviews_SD$beer_name_count, 'Beer Review Count')


# ---- GENERAL BEER STYLE: Summary Stats ----

# tally each General_beer style and find SD
beer_reviews_style_sd = 
  beer_reviews %>%
  group_by(general_beer_style) %>%
  summarise(style_count = n(),
            
            overall_sd    = sd(overall), 
            overall_mean  = mean(overall),
            taste_sd      = sd(taste),
            aroma_sd      = sd(aroma), 
            appearance_sd = sd(appearance), 
            palate_sd     = sd(palate)) %>%
  
  #filter(beer_name_count >= 5) %>%
  arrange(overall_mean) %>%
  na.omit %>%
  print(n = 25)

stats_function_2(beer_reviews_style_sd$style_count, 'Beer Style')
stats_function_2(beer_reviews_style_sd$overall_sd, 'Beer Style')
stats_function_2(beer_reviews_style_sd$aroma_sd, 'Beer Style')
stats_function_2(beer_reviews_style_sd$taste_sd, 'Beer Style')
stats_function_2(beer_reviews_style_sd$appearance_sd, 'Beer Style')
stats_function_2(beer_reviews_style_sd$palate_sd, 'Beer Style')


# ---- BEER STYLE: Summary Stats ----

# tally each beer_style and find SD
beer_reviews_style_sd2 = 
  beer_reviews %>%
  group_by(beer_style) %>%
  summarise(style_count = n(),
            
            overall_sd    = sd(overall), 
            overall_mean  = mean(overall),
            taste_sd      = sd(taste),
            aroma_sd      = sd(aroma), 
            appearance_sd = sd(appearance), 
            palate_sd     = sd(palate)) %>%
  
  #filter(beer_name_count >= 5) %>%
  arrange(desc(overall_mean)) %>%
  na.omit %>%
  print(n = 50)


# missing values are created because there are too few amount of reviews and therefore the SD cannot be calculated
# missing values need to be omitted as a result
stats_function_2(beer_reviews_SD$overall_sd, 'Overall SD')
stats_function_2(beer_reviews_style_sd2$overall_mean, 'Overall Mean')
stats_function_2(beer_reviews_SD$taste_sd, 'Taste SD')
stats_function_2(beer_reviews_SD$aroma_sd, 'Aroma SD')
stats_function_2(beer_reviews_SD$appearance_sd, 'Appearance SD')
stats_function_2(beer_reviews_SD$palate_sd, 'Palate SD')


# PLOT
# overall_mean vs. overall_sd
ggplot(beer_reviews_SD, aes(x = overall_sd, y = beer_name_count, col = general_beer_style)) + 
  geom_point() + 
  #stat_smooth(method = 'loess', se = FALSE) +
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
  geom_histogram(binwidth = 0.1, col = 'black') + 
  scale_x_continuous('Overall Deviation', breaks = seq(0, 3.0, by = 0.2)) +
  theme_classic()

ggplot(beer_reviews_SD, aes(x = taste_sd)) + 
  geom_histogram(binwidth = 0.1, col = 'black') + 
  scale_x_continuous('Taste Deviation', breaks = seq(0, 3.0, by = 0.2))
  theme_classic()

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



# ---- PLOTS: themes ----
# use gsub on beer_styles column and create a new column for a general beer style
beer_reviews_5k = sample_n(beer_reviews, 5000)
glimpse(beer_reviews)
theme
theme_pink <- theme(panel.background = element_blank(),
                    legend.key = element_blank(),
                    legend.background = element_blank(),
                    strip.background = element_blank(),
                    plot.background = element_rect(fill = 'pink', color = "black", size = 3),
                    panel.grid = element_blank(),
                    axis.line = element_line(color = "black"),
                    axis.ticks = element_line(color = "black"),
                    strip.text = element_text(size = 16, color = 'red'),
                    axis.title.y = element_text(color = 'red', hjust = 0.5, face = "italic"),
                    axis.title.x = element_text(color = 'red', hjust = 0.5, face = "italic"),
                    plot.title = element_text(color = 'red', hjust = '0.5'),
                    
                    axis.text = element_text(color = "black"),
                    legend.position = "none")
?theme
reds = brewer.pal(9, 'Reds')
blues = brewer.pal(9, 'Blues')
theme_blue = theme(panel.background = element_blank(),
                  legend.key = element_rect(fill = 'gray', color = "#3182BD", size = 1),
                  legend.background = element_rect(fill = 'gray', color = "#3182BD", size = 1),
                  legend.position = 'right',
                  legend.direction = 'vertical',
                  strip.background = element_blank(),
                  plot.background = element_rect(fill = 'gray', color = "#3182BD", size = 2),
                  panel.grid = element_line(linetype = 8),
                  axis.line = element_line(color = "#08519C"),
                  axis.ticks = element_line(color = "#08519C"),
                  axis.ticks.x = element_line(color = "black", size = 1),
                  axis.ticks.y = element_line(color = "black", size = 1),
                  strip.text = element_text(size = 16, color = 'red'),
                  axis.title.y = element_text(color = 'black', hjust = 0.5, face = "italic"),
                  axis.title.x = element_text(color = 'black', hjust = 0.5, face = "italic"),
                  plot.title = element_text(color = 'black', hjust = '0.5'),
                  axis.text = element_text(color = "black"))


# ------ PLOTTING ------

# PLOT: Beer ABV distribution
beer_reviews_10k = sample_n(beer_reviews, size = 10000)

ggplot(beer_reviews_10k, aes(x = beer_abv)) + 
  geom_histogram(binwidth = 0.5, position = 'dodge', fill = '#3182BD', col = 'black') + 
  scale_x_continuous('Alcohol by Volume (%)', breaks = seq(0, 60, by = 2)) +
  scale_y_continuous('Beer Count') +
  ggtitle('Beer ABV Distribution') +
  theme_blue

# PLOT: ABV and Style
ggplot(beer_reviews_10k, aes(x = beer_abv, y = general_beer_style)) + 
  geom_point() + 
  geom_jitter()

# HISTOGRAM
ggplot(beer_reviews_10k, aes(x = beer_abv, fill = general_beer_style)) + 
  geom_histogram(binwidth = 10, position = 'dodge', alpha = 0.4) 
  #scale_x_continuous( breaks = seq(0, 60, by = 2)) +
  #theme_blue

ggplot(beer_reviews_5k, aes(x = as.factor(overall), fill = general_beer_style)) + # ??????????????????
  geom_histogram(binwidth = 15, stat = 'count') +
  #scale_x_continuous(limits = c(1,20)) + 
  theme_classic()

# ABV factor and beer style
ggplot(beer_reviews_5k, aes(x = beer_abv_factor, fill = general_beer_style)) + 
  geom_histogram(stat = 'count', position = 'dodge') +
  scale_x_discrete('Beer ABV') + 
  theme_blue





# BAR GRAPH
# beer style vs overall
ggplot(beer_reviews_5k, aes(x = general_beer_style, y = overall, fill = general_beer_style)) + 
  geom_bar(stat = 'identity') +
  scale_x_discrete('Beer Style',  expand = c(0.1, 0)) 
  #scale_y_discrete('Overall Rating', breaks = seq(0, 5, by = 1)) +
  #theme_classic()

# reduce the amount of data points with the sample_n()
reviews_10k = sample_n(beer_reviews, size = 10000)
glimpse(reviews_10k)

# --- Point Plot
# overall vs. beer ABV, colored by beer style
ggplot(reviews_10k, aes(x = overall, y = beer_abv, col = general_beer_style)) + 
  geom_point(alpha = 0.3) +
  geom_jitter() +
  theme_blue

# filter out Lager in particular with its respective ABV, and ratings
# plot Lager overall ratings vs. the ABV

# --- Point Plot
# Overall vs. Style, colored by beer style
ggplot(reviews_10k, aes(x = overall, y = general_beer_style, col = beer_abv_factor)) + 
  geom_point(alpha = 0.1, shape = 21) +
  geom_jitter() + 
  theme_blue
# Overall and Beer ABV distribution
ggplot(reviews_10k, aes(x = overall, fill = beer_abv_factor)) + 
  geom_histogram(binwidth = 0.25) +
  theme_blue
# Overall and Beer Styles
ggplot(reviews_10k, aes(x = overall, fill = general_beer_style)) + 
  geom_histogram(binwidth = 0.25) +
  theme_blue

ggplot(reviews_10k, aes(x = beer_abv, y = general_beer_style, col = as.factor(overall))) + 
  geom_point(alpha = 0.1, shape = 21) +
  geom_jitter() + 
  theme_blue



# ------ Histogram Plot -------
# Overall Rating Distribution
ggplot(reviews_10k, aes(x = overall)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue

ggplot(reviews_10k, aes(x = taste)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue

ggplot(reviews_10k, aes(x = aroma)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue

ggplot(reviews_10k, aes(x = appearance)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue

ggplot(reviews_10k, aes(x = palate)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue

# ------ Bar Plot ------
# overall rating distribution
ggplot(reviews_10k, aes(x = overall, fill = general_beer_style)) + 
  geom_bar(position = 'dodge') +
  theme_blue


# POINT PLOTS
# overall vs. ABV
ggplot(beer_reviews_5k, aes(x = overall, y = beer_abv, col = general_beer_style)) + 
  #geom_point(alpha = 0.3) +
  stat_smooth(method = 'loess', se = FALSE) +
  #geom_jitter() +
  theme_blue
  
# overall vs. beer style
ggplot(beer_reviews_5k, aes(x = overall, y = general_beer_style, col = beer_abv_factor)) + 
  geom_point(alpha = 0.3) +
  #stat_smooth(method = 'loess', se = FALSE) +
  geom_jitter() 
  #theme_blue
  
ggplot(beer_reviews_5k, aes(x = overall, y = general_beer_style, col = beer_abv_factor)) + 
  geom_point(shape = 21, alpha = 0.6) + 
  geom_jitter()  +
  #stat_smooth(method = 'loess', se = FALSE)
  theme_blue

# palate vs overall
ggplot(beer_reviews_5k, aes(x = palate, y = overall)) + 
  geom_point(alpha = 0.3) +
  stat_smooth(method = 'loess', se = TRUE) + 
  geom_jitter() +
  theme_classic()
  
  
  

    
  

# LOOK UP
?setdiff
?extract



# ------ PROFILE NAMES: Summary Stats ------
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
  summarise(review_amount = n(),
            profile_mean = mean(overall)) %>%
  arrange(desc(review_amount)) %>%
  
  print(n = 20)
profile_names # 33,388 total profile names
glimpse(profile_names)

stats_function_2(profile_names$review_amount, 'Profile Name')
stats_function_2(profile_names$profile_mean, 'Profile Name')



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

ggplot(beer_reviews_10k, aes(x = review_time, fill = overall)) + 
  geom_histogram()

# number of beers with the greatest amount of reviews and their respective beer styles
review_time = 
  beer_reviews %>%
  select(review_time, beer_name) %>%
  arrange(desc(review_time))

beer_reviews %>%
  group_by(review_time) %>%
  distinct()

glimpse(review_time)
min(review_time$review_time) # MIN: 840,672,001
max(review_time$review_time) # MAX: 1,326,285,348
stats_function(review_time$review_time)

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

beer_reviews %>%
  group_by(review_time) %>%
  n_distinct()



