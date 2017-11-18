library(ggplot2)
library(readr)
library(tidyr)
library(dplyr)
beer_reviews <- read_csv("beer_reviews_original.csv")
beer_reviews = as_data_frame(beer_reviews)


# Your raw data needs to be cleaned and wrangled into a form you can analyze. Here are a few suggested steps:
# Clean up your column names to be simple, short and descriptive
# For each column:
#   Check for missing values and decide what you want to do about them.
#   Make sure the values in each column make sense. If you find values that don't, decide what you want to do about those.
#   Look for outliers (values that are too small or too large). Do they make sense? Do you want to keep them in the data set?
# Discuss with your mentor about other data wrangling steps you might need to perform for your specific problem and implement those.
# Save your cleaned up and transformed data set.


# ------ LOWER CASE ------
# change all text to lower case
# Columns to change: brewery name, beer name, profile name, beer style

# lower_case = 
#  beer_reviews %>%
#  select(beer_name) %>%
#  tolower

brewery_name  = tolower(beer_reviews$brewery_name)
beer_name     = tolower(beer_reviews$beer_name)
profile_name  = tolower(beer_reviews$review_profilename)
beer_style    = tolower(beer_reviews$beer_style)
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

beer_reviews = data_frame(brewery_name, beer_name, profile_name, beer_style, taste, palate, 
                          appearance, aroma, overall, brewery_id, beer_id, review_time, beer_abv)

glimpse(beer_reviews)

# ------ CHECK FOR MISSING VALUES IN EVERY COLUMN ------
# Approach:
# 1. create a function for finding missing values in every column
# 2. create a matrix of missing values for easier visualization


# create a function for finding missing values in every column
find_NA = function(column_name){
  m_val = beer_reviews %>% 
    filter(is.na(column_name)) %>%
    summarise(missing_values = n())
  
  
}

val = 
  beer_reviews %>% 
  filter(is.na(profile_name)) %>%
  summarise(missing_values = n())
class(val)
as.integer(val)
as.numeric(val)

find_NA_2 = function(col_name){
  m_val = beer_reviews %>% 
    filter(is.na(col_name)) %>%
    summarise(missing_values = n())
  #as.numeric(m_val)
  if(as.numeric(m_val) > 0){
    print(paste('Found', m_val, 'items, working ...'))
    
  }
  else if(as.numeric(m_val) == 0){
    print(paste('Found', m_val, 'missing items. All clear!'))
    
  }
}
find_NA_2(beer_reviews$brewery_name)

find_NA(beer_reviews$beer_abv)


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
find_NA(beer_reviews$profile_name)

missing_vals = sapply(columns_name, find_NA)

# matrix of missing values
columns = c('beer id', 'brewery name', 'brewery id', 'beer ABV', 'profile name', 'review taste', 'review palate', 'beer style',
            'review appearance', 'review aroma', 'review overall', 'review time', 'beer name')
rows = c('missing values')
missing_matrix = matrix(missing_vals, byrow = TRUE, nrow = 1)
colnames(missing_matrix) = columns
rownames(missing_matrix) = rows
missing_matrix

# missing values are found in columns: brewery name(15), beer ABV(67,785), and profile name (348)
# *** NOTE: for beer_ABV, the alcohol content is not always written on the container. Relatively low ABV is not required to be 
# printed on containers.
# 


# ------ MISSING VALUES: beer ABV (alcohol by volume) ------

# beer_abv missing values will be replaced with the mean()
# calculate the mean of ABV to use as replacement for NAs
mean_ABV = mean(beer_reviews$beer_abv, na.rm = TRUE)
mean_ABV # = 7.04
median_abv = median(beer_reviews$beer_abv, na.rm = TRUE)
median_abv # 6.6
class(mean_ABV)

# replace the missing values in ABV with the mean
beer_reviews = 
  beer_reviews %>%
  replace_na(list(beer_abv = mean_ABV))
class(beer_reviews)

# check for missing values again
find_NA(beer_reviews$beer_abv)

# find max and min for beer ABV
# replace the missing values before finding MAX and MIN
max(beer_reviews$beer_abv) # = 57.7 % 
min(beer_reviews$beer_abv) # = 0.01 % 


# ------ MISSING VALUES: Brewery Name ------
# view the matrix with missing values
missing_matrix

# look at the missing brewery names and their corresponding profile name and ABV
# from beer_reviews, select 3 columns, brewery name, profile name, and beer ABV
beer_reviews %>%
  select(brewery_name, profile_name, beer_abv) %>%
  filter(is.na(brewery_name))

# replace the missing names with 'unknown'
beer_reviews = 
  beer_reviews %>%
  replace_na(list(brewery_name = 'unknown'))

# check for missing values again
find_NA(beer_reviews$brewery_name)




# ------ MISSING VALUES: Profile Name ------

# view the matrix with missing values
missing_matrix

beer_reviews %>%
  select(brewery_name, profile_name, beer_abv) %>%
  filter(is.na(profile_name))

# replace the missing profile names with 'Unknown'
beer_reviews_clean = 
  beer_reviews %>%
  replace_na(list(profile_name = 'unknown'))

# check for missing values again
find_NA(beer_reviews_clean$profile_name)

# ------ ABV intervals ------
interval = cut(abv_vector, 
               breaks = c(0, two_sd_below, one_sd_below, one_sd_above, two_sd_above, 60),
               labels = c('low', 'below normal', 'normal', 'above normal', 'high'))
table(interval)

# ------ BEER STYLES ------
# reduce the 104 styles into: lager, ale, IPA, stout, pilsner, misc

# ------ NEW BEER-STYLE COLUMN ------
# CONSIDER sorting by country of origin: BELGIUM, UK, US, GERMANY
# create new column for the reduced beer styles
# NEW COLUMN: ale, lager, stout, pilsner, bock, tripel, wheat, lambic, porter
styles = select(beer_reviews, beer_style)
class(styles)
# create a list of beer styles to use within 'grep'
style_list =  
  c(beer_reviews %>%
      select(beer_style))

style_list = unlist(style_list)
class(style_list)
glimpse(style_list)
head(style_list)

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
length(unique(style_list_mod))


# create new column with the new styles using mutate()
beer_reviews = 
  beer_reviews %>%
  mutate(general_beer_style = style_list_mod)

glimpse(beer_reviews)

# summarize the new beer styles
# distinct amount of styles
beer_reviews %>%
  group_by(general_beer_style) %>%
  summarise(style_count = n()) %>%
  arrange(desc(style_count))

beer_reviews_clean = beer_reviews


glimpse(beer_reviews_clean)

# write the clean file 
write_csv(beer_reviews_clean, 'beer_reviews_clean.csv')



