# install.packages('factoextra')
library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)

# library(EMCluster)
# detach('package:EMCluster')
detach('package:MASS') # MASS comes with a select() function and therefore conflicts with DPLYR::select
search()

library(NbClust)
library(cluster)
library(flexclust)
library(factoextra) # clustering algorithms & visualization
beer_reviews = read_csv("beer_reviews_clean.csv")
beer_reviews = as_data_frame(beer_reviews)
glimpse(beer_reviews)


beer_reviews = 
  beer_reviews %>%
  mutate(ovr_grade = (taste + aroma + overall + appearance + palate)/5) 

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
# add counts of beer name and brewery name
beer_reviews_1 = 
  beer_reviews %>%
  add_count(beer_name) %>%
  add_count(brewery_name) %>%
  add_count(profile_name)


# glimpse(beer_reviews_1)
# rename the columns of beer_name tally and brewery_name tally
beer_reviews_1$beer_name_cnt = beer_reviews_1$n
beer_reviews_1$brewery_name_cnt = beer_reviews_1$nn
beer_reviews_1$profile_name_cnt = beer_reviews_1$nnn

# select columns to work with
beer_reviews_1 = 
  beer_reviews_1 %>%
  filter(beer_name_cnt > 350 & brewery_name_cnt > 10000 & profile_name_cnt > 500) %>%
  select(taste, aroma, appearance, overall, palate,beer_abv, ovr_grade, beer_name_cnt, brewery_name_cnt, profile_name_cnt,  beer_id, brewery_id, 
         beer_name, brewery_name, beer_abv_factor, beer_style)
  
glimpse(beer_reviews_1)

# using filter, attempt to remove some of the outliers
stats_function_2(beer_reviews_1$beer_name_cnt, 'beer') 
stats_function_2(beer_reviews_1$brewery_name_cnt, 'brewery')
stats_function_2(beer_reviews_1$profile_name_cnt, 'profile name')
stats_function_2(beer_reviews_1$beer_abv, 'abv')
# look for median and mean converging, outliers have a great effect on mean not on median

# reduce the dataset to 10,000 points to make it easier to work with
set.seed(1)
beer_reviews_10k = sample_n(beer_reviews_1, size = 10000)
# glimpse(beer_reviews_10k)

# ---- SCALE ---- 
beer_reviews_df = scale(beer_reviews_10k[1:7])
# *** NOTE: 1:7 and 4 clusters have highest Accuracy so far, 0.30
# WITH: filter(beer_name_cnt > 350 & brewery_name_cnt > 10000 & profile_name_cnt > 500)
beer_reviews_df = scale(beer_reviews_1[1:7])
distance = dist(beer_reviews_df)
glimpse(distance)
?dist

# ---- Nbclust distribution ----
#nc = NbClust(beer_reviews_df, min.nc = 2, max.nc = 15, method = "kmeans")
#glimpse(nc)
#barplot(table(nc$Best.n[1,]),
#        xlab="Numer of Clusters", ylab="Number of Criteria",
#        main="Number of Clusters Chosen by 26 Criteria")

# ---- (WSS) within-groups sums of squares ----
wssplot <- function(data, nc = 15, seed = 1){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i, iter.max = 100)$withinss)}
  
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
}
# find optimum amount of clusters
wssplot(beer_reviews_df)
fviz_nbclust(beer_reviews_df, kmeans, method = 'wss')
fviz_nbclust(beer_reviews_df, kmeans, method = 'silhouette')


# ---- K-Means ----
# choose clusters 
head(beer_reviews_df)
?kmeans
kmc_beer = kmeans(beer_reviews_df, centers = 4, iter.max = 20, nstart = 25)
glimpse(kmc_beer)
centers = kmc_beer$centers # computed means for each cluster of each observation
withinss = kmc_beer$withinss 
withinss/kmc_beer$tot.withinss
beerClusters = kmc_beer$cluster # list of clusters
length(beerClusters)

# ---- ERROR/AGREEMENT -----
# ?randIndex
# ?RRand # EMCluster package
table(beer_reviews_10k$ovr_grade, beerClusters)
table(beer_reviews_10k$overall, beerClusters)

randIndex(table(beer_reviews_1$overall, beerClusters))
randIndex(table(beer_reviews_1$taste, beerClusters))

randIndex(table(beer_reviews_10k$overall, beerClusters))
randIndex(table(beer_reviews_10k$taste, beerClusters))
randIndex(table(beer_reviews_10k$aroma, beerClusters))
randIndex(table(beer_reviews_10k$appearance, beerClusters))
randIndex(table(beer_reviews_10k$palate, beerClusters))
randIndex(table(beer_reviews_10k$ovr_grade, beerClusters))



# comPart 
comPart(beer_reviews_10k$appearance, beerClusters)
comPart(beer_reviews_10k$ovr_grade, beerClusters)
comPart(beer_reviews_10k$beer_abv, beerClusters)
# RRand index from 0 to 1 
RRand(beer_reviews_10k$brewery_id, beerClusters)


# reduce the dataset to 10,000 points to make it easier to work with and plot faster
set.seed(1)
beer_reviews_10k = sample_n(beer_reviews_1, size = 10000)
# glimpse(beer_reviews_10k)
# ---- SCALE ---- 
beer_reviews_df2 = scale(beer_reviews_10k[1:7])
glimpse(beer_reviews_df2)
# create a vector for storing Rand values
# compute Rand value for each cluster
r = c()
for(i in k[,1:15]){
  r[i] = randIndex(table(beer_reviews_10k$overall, k[,i]))
}

# ----- PLOT Rrand ----
# plot error on y-axis, and number of clusters on x-axis
# build a cluster tibble for k-means 
k = data_frame(k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15)
for (i in 1:15){
  k[i] = kmeans(beer_reviews_df2, centers = i, iter.max = 50, nstart = 25)$cluster}

r1 = randIndex(table(beer_reviews_10k$taste, k$k1))
r2 = randIndex(table(beer_reviews_10k$taste, k$k2))
r3 = randIndex(table(beer_reviews_10k$taste, k$k3))
r4 = randIndex(table(beer_reviews_10k$taste, k$k4))
r5 = randIndex(table(beer_reviews_10k$taste, k$k5))
r6 = randIndex(table(beer_reviews_10k$taste, k$k6))
r7 = randIndex(table(beer_reviews_10k$taste, k$k7))
r8 = randIndex(table(beer_reviews_10k$taste, k$k8))
r9 = randIndex(table(beer_reviews_10k$taste, k$k9))
r10 = randIndex(table(beer_reviews_10k$taste, k$k10))
r11 = randIndex(table(beer_reviews_10k$taste, k$k11))
r12 = randIndex(table(beer_reviews_10k$taste, k$k12))
r13 = randIndex(table(beer_reviews_10k$taste, k$k13))
r14 = randIndex(table(beer_reviews_10k$taste, k$k14))
r15 = randIndex(table(beer_reviews_10k$taste, k$k15))
r13 = randIndex(table(beer_reviews_10k$taste, k$k13))
r14 = randIndex(table(beer_reviews_10k$taste, k$k14))
r15 = randIndex(table(beer_reviews_10k$taste, k$k15))
rand_Ind = c(r1, r2,r3, r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15)
nc = 1:15
# plot amount of clusters (x) and Rand value (y)
plot(nc, rand_Ind)

# ---- KCCA ----
# ?kcca
beer_kcca = kcca(beer_reviews_df, k = 4, family=kccaFamily("kmedians"))
randIndex(table(beer_reviews_1$taste, beer_kcca@cluster))# kmedians -> 0.2761
randIndex(table(beer_reviews_10k$aroma, beer_kcca@cluster))
randIndex(table(beer_reviews_10k$appearance, beer_kcca@cluster))
randIndex(table(beer_reviews_10k$palate, beer_kcca@cluster))
randIndex(table(beer_reviews_10k$ovr_grade, beer_kcca@cluster))
# ---- CCLUST ----
# ?cclust
beer_ccl = cclust(beer_reviews_df, k = 4, method = 'hardcl', dist = 'manhattan') 
# beer_ccl@cluster
randIndex(table(beer_reviews_10k$taste, beer_ccl@cluster))# hardcl + manhattan -> 0.3673
randIndex(table(beer_reviews_10k$aroma, beer_ccl@cluster))
randIndex(table(beer_reviews_10k$appearance, beer_kcca@cluster))
randIndex(table(beer_reviews_10k$palate, beer_kcca@cluster))
randIndex(table(beer_reviews_10k$ovr_grade, beer_kcca@cluster))
# ---- PAM ----
#clusplot(beer.pam)
# ?pam
beer_pam = pam(beer_reviews_df, k = 4, metric = 'manhattan', cluster.only = TRUE)
bpam_clust = beer_pam$clustering
randIndex(table(beer_reviews_10k$taste, beer_pam)) # manhattan -> 0.3783
randIndex(table(beer_reviews_10k$aroma, bpam_clust))
randIndex(table(beer_reviews_10k$appearance, bpam_clust))
randIndex(table(beer_reviews_10k$palate, bpam_clust))
randIndex(table(beer_reviews_10k$ovr_grade, bpam_clust))
# ---- CLARA ----
beer_clara = clara(beer_reviews_df, k = 5, metric = "manhattan")
bclr_clust = beer_clara$clustering
randIndex(table(beer_reviews_1$taste, bclr_clust)) # manhattan -> 0.3783


### RRAND
truth    <- c(1,1,2,2,2,1,3,3,3)
estimate <- c(1,2,2,2,2,1,3,3,3)
table(truth, estimate)
randIndex(truth,estimate)
comPart(truth,estimate)

true.id <- c(1, 1, 1, 2, 2, 2, 3, 3, 3)
pred.id <- c(1, 1, 1, 2, 2, 5, 3, 3, 3)
label   <- c(0, 0, 0, 0, 1, 0, 2, 0, 0)
table(true.id, pred.id)
RRand(true.id, pred.id)
RRand(true.id, pred.id, lab = label)
###


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
subset(beer_reviews_20k, beerClusters == 4)

# expand search with filter()
beer_reviews_20k_sub = 
  beer_reviews_20k %>%
  subset(beerClusters == 4) %>%
  filter(general_beer_style == 'lager', beer_abv_factor == 'normal') %>%
  arrange(desc(ovr_grade))

# select cluster for further analysis
beer_reviews_20k %>%
  subset(beerClusters == 4) %>%
  group_by(beer_name) %>%
  summarise(
    review_count     = n(),
    overall_mean     = mean(overall), 
    taste_mean       = mean(taste),
    aroma_mean       = mean(aroma), 
    appearance_mean  = mean(appearance), 
    palate_mean      = mean(palate),
    mean_consistency = (overall_mean + taste_mean + aroma_mean + appearance_mean + palate_mean)/5,
    
    overall_sd       = sd(overall), 
    taste_sd         = sd(taste),
    aroma_sd         = sd(aroma), 
    appearance_sd    = sd(appearance), 
    palate_sd        = sd(palate),
    sd_consistency   = (overall_sd + taste_sd + aroma_sd + appearance_sd + palate_sd)/5) %>%
  filter(review_count > 2) %>%
  arrange(desc(mean_consistency), desc(sd_consistency))






# ---- DATA SET #2: part 1, k-means ----
# group by beer name
# calculate mean, standard deviation, overall grade for each beer, and tally amount of reviews 
beer_reviews_SD = 
  beer_reviews %>%
  group_by(beer_id, brewery_id) %>%
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
  
  filter(beer_name_count > 5) %>%
  arrange(desc(overall_sd)) %>%
  ungroup()

glimpse(beer_reviews_SD)


?sample_n
# reduce the dataset to 10,000 points to make it easier to work with
set.seed(1)
beer_reviews_10k = sample_n(beer_reviews_SD, size = 19000)
glimpse(beer_reviews_10k)

beer_reviews_sd_2 = beer_reviews_SD
# ---- SCALE ---- 
beer_reviews_df = scale(beer_reviews_10k[3:9])
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
randIndex(table(beer_reviews_10k$beer_name_count, beerClusters))
randIndex(table(beer_reviews_10k$ovr_grade, beerClusters))
randIndex(table(beer_reviews_10k$overall_mean, beerClusters))
randIndex(table(beer_reviews_10k$palate_sd, beerClusters))


# cluster plot
beer.pam = pam(beer_reviews_df, k = 4)
beer.pam
clusplot(beer.pam)

# ----- PLOT Rrand ----
# plot error on y-axis, and number of clusters on x-axis
# build a cluster tibble for k-means 
k = tibble(k1,k2,k3,k4,k5,k6,k7,k8,k9,k10,k11,k12,k13,k14,k15)
for (i in 1:15){
  k[i] = kmeans(beer_reviews_df, centers = i, iter.max = 50, nstart = 25)$cluster}

r1 = randIndex(table(beer_reviews_10k$taste, k$k1))
r2 = randIndex(table(beer_reviews_10k$taste, k$k2))
r3 = randIndex(table(beer_reviews_10k$taste, k$k3))
r4 = randIndex(table(beer_reviews_10k$taste, k$k4))
r5 = randIndex(table(beer_reviews_10k$taste, k$k5))
r6 = randIndex(table(beer_reviews_10k$taste, k$k6))
r7 = randIndex(table(beer_reviews_10k$taste, k$k7))
r8 = randIndex(table(beer_reviews_10k$taste, k$k8))
r9 = randIndex(table(beer_reviews_10k$taste, k$k9))
r10 = randIndex(table(beer_reviews_10k$taste, k$k10))
r11 = randIndex(table(beer_reviews_10k$taste, k$k11))
r12 = randIndex(table(beer_reviews_10k$taste, k$k12))
r13 = randIndex(table(beer_reviews_10k$taste, k$k13))
r14 = randIndex(table(beer_reviews_10k$taste, k$k14))
r15 = randIndex(table(beer_reviews_10k$taste, k$k15))
r13 = randIndex(table(beer_reviews_10k$taste, k$k13))
r14 = randIndex(table(beer_reviews_10k$taste, k$k14))
r15 = randIndex(table(beer_reviews_10k$taste, k$k15))
rand_Ind = c(r1, r2,r3, r4,r5,r6,r7,r8,r9,r10,r11,r12,r13,r14,r15)
nc = 1:15
# plot amount of clusters (x) and Rand value (y)
plot(nc, rand_Ind)


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









