# install.packages('factoextra')
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

beer_reviews_20k = sample_n(beer_reviews, size = 20000)

# --- NOTES:
# use scaling() and compute/mutate additional metrics for clustering 
# COMPUTE/INCLUDE: overall grade for each beer and brewery, standard deviation for agreement
# REMOVE: single reviews, obscure beer names with 1 review
# --- CONSIDER:
# give more weight to beers with lowest SD



# ---- FINAL DATA PREPARATIONS ----
# group by beer name, then tally amoutn of reviews for each
# COMPUTE/INCLUDE: overall grade for each beer and standard deviation for agreement
# REMOVE: single reviews, obscure beer names with 1 review
# select only the columns which need to be worked


# try different data sets for k-mean
# ---- DATA SET #1: k-means ----
# group by beer name 
# calculate overall grade 
beer_reviews_1 = 
  beer_reviews %>%
  mutate(ovr_grade = (taste + aroma + overall + appearance + palate)/5) %>%
  add_count(beer_name) %>%
  add_count(brewery_name) 

glimpse(beer_reviews_1)
# rename the columns of beer_name tally and brewery_name tally
beer_reviews_1$beer_name_cnt = beer_reviews_1$n
beer_reviews_1$brewery_name_cnt = beer_reviews_1$nn

# select columns to work with
beer_reviews_1 = 
  beer_reviews_1 %>%
  select(taste, aroma, appearance, overall, palate, beer_abv, ovr_grade, beer_name_cnt, brewery_name_cnt, beer_id, brewery_id,
         beer_name, brewery_name, beer_abv_factor, beer_style)
glimpse(beer_reviews_1)


# reduce the dataset to 10,000 points to make it easier to work with
set.seed(1)
beer_reviews_10k = sample_n(beer_reviews_1, size = 10000)
glimpse(beer_reviews_10k)

# ---- SCALE ---- 
beer_reviews_df = scale(beer_reviews_10k[1:9])
# using all 1.5mil reviews 
beer_reviews_df = scale(beer_reviews_1[1:9])

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
    wss[i] <- sum(kmeans(data, centers=i, iter.max = 100)$withinss)}
  
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
}
wssplot(beer_reviews_df)
fviz_nbclust(beer_reviews_df, kmeans, method = "wss")

# ---- K-Means ----
# choose clusters 
head(beer_reviews_df)
?kmeans
kmc_beer = kmeans(beer_reviews_df, centers = 5, iter.max = 20, nstart = 25)
glimpse(kmc_beer)
kmc_beer$totss
kmc_beer$centers # computed means for each cluster of each observation
beerClusters = kmc_beer$cluster # list of clusters
table(beerClusters)

# ---- ERROR/AGREEMENT -----
# ?randIndex
?RRand
glimpse(beer_reviews_10k)
tbl.km = table(beer_reviews_10k$overall, beerClusters)
summary(tbl.km)
randIndex(tbl.km)
# comPart 
comPart(beer_reviews_10k$overall, beerClusters)
# RRand index from 0 to 1 
RRand(beer_reviews_10k$overall, beerClusters)

# cluster plot
?pam
kcca(beer_reviews_df, k = 3)
beer.pam = pam(beer_reviews_df, k = 3)
clusplot(beer.pam)



# error plot
# plot error on y-axis, and number of clusters on x-axis
k = tibble(k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15)
for (i in 1:15){
  k[i] = kmeans(beer_reviews_df, centers = i, iter.max = 100, nstart = 25)$cluster}
glimpse(k)
k
length(k[1:10000,1])
k[1:10000,1]
length(k$k2)
length(beer_reviews_10k$overall)
table(beer_reviews_10k$overall, k$k2)
r = c()
for(i in 2:15){
  r[i] = randIndex(table(beer_reviews_10k$overall, k[i]))
}
#r1 = randIndex(table(beer_reviews_10k$overall, k$k1))
r2 = randIndex(table(beer_reviews_10k$overall, k$k2))
r3 = randIndex(table(beer_reviews_10k$overall, k$k3))
r4 = randIndex(table(beer_reviews_10k$overall, k$k4))
r5 = randIndex(table(beer_reviews_10k$overall, k$k5))
r6 = randIndex(table(beer_reviews_10k$overall, k$k6))
r7 = randIndex(table(beer_reviews_10k$overall, k$k7))
r8 = randIndex(table(beer_reviews_10k$overall, k$k8))
r9 = randIndex(table(beer_reviews_10k$overall, k$k9))
r10 = randIndex(table(beer_reviews_10k$overall, k$k10))
r11 = randIndex(table(beer_reviews_10k$overall, k$k11))
r12 = randIndex(table(beer_reviews_10k$overall, k$k12))
r13 = randIndex(table(beer_reviews_10k$overall, k$k13))
r14 = randIndex(table(beer_reviews_10k$overall, k$k14))
r15 = randIndex(table(beer_reviews_10k$overall, k$k15))
r13 = randIndex(table(beer_reviews_10k$overall, k$k13))
r14 = randIndex(table(beer_reviews_10k$overall, k$k14))
r15 = randIndex(table(beer_reviews_10k$overall, k$k15))
r_v = c(r2,r3, r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15)
nc = 2:15

plot(nc, r_v)
##################
truth    <- c(1,1,2,2,2,1,3,3,3)
estimate <- c(1,2,2,2,2,1,2,3,3)
table(truth, estimate)
randIndex(truth,estimate)
install.packages('EMCluster')
library(EMCluster, quietly = TRUE)
true.id <- c(1, 1, 1, 2, 2, 2, 3, 3, 3)
pred.id <- c(1, 1, 1, 2, 2, 5, 3, 3, 3)
label   <- c(0, 0, 0, 0, 1, 0, 2, 0, 0)
table(true.id, pred.id)
RRand(true.id, pred.id)
RRand(true.id, pred.id, lab = label)
#################


# summarize resulting clusters
beer_reviews_10k %>%
  mutate(cluster = kmc_beer$cluster) %>%
  group_by(cluster) %>%
  summarise_all('mean')


# ---- DATA SET #1: part 2 ----
# explore contents of the clusters and search through them
head(beer_reviews_20k)
kmc_beer$centers # contents of cluster 1 appear to have the highest overall grade
beerClusters = kmc_beer$cluster
subset(beer_reviews_20k, beerClusters == 1)

# expand search with filter()
beer_reviews_20k_sub = 
  beer_reviews_20k %>%
  subset(beerClusters == 1) %>%
  filter(general_beer_style == 'lager', beer_abv_factor == 'normal') %>%
  arrange(desc(ovr_grade))

stats_function_2(beer_reviews_20k_sub$beer_abv, 'grade stats')
# the overall grade actually ranges from 1.7 to 5 






# ---- DATA SET #2: part 1, k-means ----
# group by beer name
# calculate mean, standard deviation, overall grade for each beer, and tally amount of reviews 
beer_reviews_SD = 
  beer_reviews %>%
  group_by(beer_name, brewery_name) %>%
  summarise(
         beer_name_count  = n(),
         ovr_grade        = mean(taste + aroma + overall + appearance + palate),
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
  
  filter(beer_name_count >= 2) %>%
  arrange(desc(overall_sd))

glimpse(beer_reviews_SD)
head(beer_reviews_SD)
stats_function_2(beer_reviews_SD$beer_review_count, 'Beer Review Amount')


# reduce the dataset to 10,000 points to make it easier to work with
set.seed(1)
beer_reviews_10k = sample_n(beer_reviews_SD, size = 10000)
glimpse(beer_reviews_10k)

# ---- SCALE ---- 
beer_reviews_df = scale(beer_reviews_10k)
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

beer_grade.km = table(beer_reviews_10k$ovr_grade, beerClusters)
randIndex(beer_grade.km)

# cluster plot
beer.pam = pam(beer_reviews_df, k = 4)
beer.pam
clusplot(beer.pam)




# ---- DATA SET #2:  part 2 ----
# explore contents of the clusters and search through them
head(beer_reviews_20k)
kmc_beer$centers # contents of cluster 1 appear to have the highest ratings 
beerClusters = kmc_beer$cluster
subset(beer_reviews_20k, beerClusters == 1)

# expand search with filter()
beer_reviews_20k_sub = 
  beer_reviews_20k %>%
  subset(beerClusters == 1) #%>%
  #filter(general_beer_style == 'lager', beer_abv_factor == 'normal') %>%
  #arrange(desc(ovr_grade))

stats_function_2(beer_reviews_20k_sub$ovr_grade, 'grade stats')
# the overall grade actually ranges from 1 to 5 









