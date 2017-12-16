library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)

library(NbClust)
library(cluster)
library(flexclust)
library(factoextra) # clustering algorithms & visualization
beer_reviews = read_csv("beer_reviews_clean.csv")
beer_reviews = as_data_frame(beer_reviews)
glimpse(beer_reviews)
head(beer_reviews)

# --- NOTES:
# use scaling() and compute/mutate additional metrics for clustering 
# COMPUTE/INCLUDE: overall grade for each beer and brewery, standard deviation for agreement
# REMOVE: single reviews, obscure beer names with 1 review
# --- CONSIDER:
# give more weight to beers with lowest SD



# ---- FINAL DATA PREPARATIONS ----
# group by beer name, then tally amoutn of reviews for each
# COMPUTE/INCLUDE: overall grade for each beer and brewery, standard deviation for agreement
# REMOVE: single reviews, obscure beer names with 1 review
# select only the columns which need to be worked

# try different data sets for k-mean
# ---- DATA SET #1 k-means ----
beer_reviews_1 = 
  beer_reviews %>%
  group_by(beer_name) %>%
  #summarise(beer_review_count = n()) %>%
  mutate(ovr_grade = (taste + aroma + overall + appearance + palate)/5) %>%
  ungroup() %>%
  select(taste, aroma, appearance, overall, palate, beer_abv, ovr_grade,
  beer_name, beer_style, brewery_name) 

glimpse(beer_reviews_1)
# reduce the dataset to 10,000 points to make it easier to work with
set.seed(1)
beer_reviews_10k = sample_n(beer_reviews_1, size = 10000)
glimpse(beer_reviews_10k)

# ---- SCALE ---- 
beer_reviews_df = scale(beer_reviews_10k[1:7])
head(beer_reviews_df)
glimpse(beer_reviews_df)
distance = dist(beer_reviews_df)
# ---- Nbclust distribution ----
nc = NbClust(beer_reviews_df, min.nc = 2, max.nc = 15, method = "kmeans")
glimpse(nc)
barplot(table(nc$Best.n[1,]),
        xlab="Numer of Clusters", ylab="Number of Criteria",
        main="Number of Clusters Chosen by 26 Criteria")

# ---- (WSS) within-groups sums of squares ----
wssplot <- function(data, nc = 15, seed = 1){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
}
wssplot(beer_reviews_df)

# ---- k-means ----
# choose 3 clusters 
head(beer_reviews_df)
kmc_beer = kmeans(beer_reviews_df, centers = 3, iter.max = 100, nstart = 25)
kmc_beer
kmc_beer$centers # computed means for each cluster of each observation
beerClusters = kmc_beer$cluster # list of clusters
table(beerClusters)

# beer style table
# ?randIndex
glimpse(beer_reviews_10k)
table(beer_reviews_10k$beer_name, beerClusters)
beer_style.km = table(beer_reviews_10k$ovr_grade, beerClusters)
randIndex(beer_style.km)

# cluster plot
beer.pam = pam(beer_reviews_df, k = 3)
beer.pam
clusplot(beer.pam)

# plot clusters without scaling 
ggplot(beer_reviews_10k, aes(x = ovr_grade, y = beer_style, col = as.factor(kmc_beer$cluster))) + 
  geom_point() + 
  geom_jitter()



# ---- part 2 ----
# explore contents of the clusters and search through them
# contents of cluster 1 appear to have the highest overall grade
head(beer_reviews_20k)
kmc_beer$centers
beerClusters = kmc_beer$cluster
subset(beer_reviews_20k, beerClusters == 1)

# expand search with filter()
beer_reviews_20k_sub = 
  beer_reviews_20k %>%
  subset(beerClusters == 1) %>%
  filter(general_beer_style == 'ipa') 

stats_function_2(beer_reviews_20k_sub$ovr_grade, 'grade')


# ---- DATA SET #2 k-means ----
beer_reviews_SD = 
  beer_reviews %>%
  group_by(beer_name) %>%
  summarise(beer_review_count = n(), 
         ovr_grade        = mean(taste + aroma + overall + appearance + palate),
         beer_abv_mean    = mean(beer_abv),   
         overall_mean     = mean(overall), 
         taste_mean       = mean(taste),
         aroma_mean       = mean(aroma), 
         appearance_mean  = mean(appearance), 
         palate_mean      = mean(palate),
         
         overall_sd       = sd(overall), 
         taste_sd         = sd(taste),
         aroma_sd         = sd(aroma), 
         appearance_sd    = sd(appearance), 
         palate_sd        = sd(palate)) %>%
  
  filter(beer_review_count >= 3) %>%
  arrange(desc(overall_sd)) #%>%
  #ungroup() %>%
  #group_by(brewery_name) %>%
  #mutate(brewery_review_count= n()) %>%
  #ungroup() %>%
  #select(taste, aroma, appearance, overall, palate, beer_abv, beer_review_count,
         #overall_sd, taste_sd, aroma_sd, appearance_sd, palate_sd,
         #overall_mean, taste_mean, aroma_mean, appearance_mean, palate_mean,
        # beer_name, beer_style, brewery_name) 


glimpse(beer_reviews_SD)
stats_function_2(beer_reviews_SD$beer_review_count, 'Beer Review Amount')
stats_function_2(beer_reviews_SD$ovr_grade, 'Grade')


# reduce the dataset to 10,000 points to make it easier to work with
set.seed(1)
beer_reviews_10k = sample_n(beer_reviews_SD, size = 10000)
glimpse(beer_reviews_10k)

# ---- SCALE ---- 
beer_reviews_df = scale(beer_reviews_10k[-1])
glimpse(beer_reviews_df)
distance2 = dist(beer_reviews_df)
# ---- Nbclust distribution ----
nc = NbClust(beer_reviews_df, min.nc = 2, max.nc = 15, method = "kmeans")
glimpse(nc)
barplot(table(nc$Best.n[1,]),
        xlab="Numer of Clusters", ylab="Number of Criteria",
        main="Number of Clusters Chosen by 26 Criteria")

# ---- (WSS) within-groups sums of squares ----

wssplot <- function(data, nc = 15, seed = 1){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i)$withinss)}
  
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
}
wssplot(beer_reviews_df)

# ---- k-means ----
# choose 4 clusters 
head(beer_reviews_df)
kmc_beer = kmeans(beer_reviews_df, centers = 4, iter.max = 100, nstart = 25)
kmc_beer
kmc_beer$centers # computed means for each cluster of each observation
beerClusters = kmc_beer$cluster # list of clusters
table(beerClusters)

# beer style table
# ?randIndex
glimpse(beer_reviews_10k)
table(beer_reviews_10k$beer_name, beerClusters)
beer_style.km = table(beer_reviews_10k$beer_name, beerClusters)
randIndex(beer_style.km)

beer_grade.km = table(beer_reviews_10k$ovr_grade, beerClusters)
randIndex(beer_grade.km)

# cluster plot
beer.pam = pam(beer_reviews_df, k = 3)
beer.pam
clusplot(beer.pam)

# plot clusters without scaling 
ggplot(beer_reviews_10k, aes(x = aroma_sd, y = beer_style, col = as.factor(kmc_beer$cluster))) + 
  geom_point() + 
  geom_jitter()



# ---- part 2 ----
# explore contents of the clusters and search through them
# contents of cluster 2 have the highest ratings 
head(beer_reviews_20k)
kmc_beer$centers
beerClusters = kmc_beer$cluster
subset(beer_reviews_20k, beerClusters == 1)

# expand search with filter()
beer_reviews_20k %>%
  subset(beerClusters == 1) %>%
  filter(general_beer_style == 'ipa') 

stats_function_2(ovr_grade, 'grade')








