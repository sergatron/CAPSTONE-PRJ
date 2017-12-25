# install.packages('factoextra')
library(readr)
library(tidyr)
library(dplyr)
library(ggplot2)

# library(EMCluster)
# detach('package:EMCluster')
# detach('package:MASS') # MASS comes with a select() function and therefore conflicts with DPLYR::select
# search() # current packages loaded

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
         beer_name, brewery_name, beer_abv_factor, beer_style, general_beer_style)

glimpse(beer_reviews_1)
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
# using filter, attempt to remove some of the outliers
stats_function_2(beer_reviews_1$beer_name_cnt, 'beer') 
stats_function_2(beer_reviews_1$brewery_name_cnt, 'brewery')
stats_function_2(beer_reviews_1$profile_name_cnt, 'profile name')
stats_function_2(beer_reviews_1$beer_abv, 'abv')
# look for median and mean converging, reduce the outliers' have effect on mean


# ---- SCALE ---- 
# *** NOTE: 1:7 and 4 clusters have highest Accuracy so far, 0.30
# WITH: filter(beer_name_cnt > 350 & brewery_name_cnt > 10000 & profile_name_cnt > 500)
beer_reviews_df = scale(beer_reviews_1[1:7])

# ---- (WSS) within-groups sums of squares ----
# find the number of clusters to start with
wssplot <- function(data, nc = 15, seed = 1){
  wss <- (nrow(data)-1)*sum(apply(data,2,var))
  
  for (i in 2:nc){
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i, iter.max = 100)$withinss)}
  
  plot(1:nc, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares")
}
wssplot(beer_reviews_df)



# ---- K-Means ----
# choose clusters 
#?kmeans
kmc_beer = kmeans(beer_reviews_df, centers = 4, iter.max = 20, nstart = 25)
beerClusters = kmc_beer$cluster # list of clusters

# ---- ERROR/AGREEMENT -----
# find agreement of partitions
randIndex(table(beer_reviews_1$overall, beerClusters))
randIndex(table(beer_reviews_1$taste, beerClusters))
randIndex(table(beer_reviews_1$aroma, beerClusters))
randIndex(table(beer_reviews_1$appearance, beerClusters))
randIndex(table(beer_reviews_1$palate, beerClusters))
randIndex(table(beer_reviews_1$ovr_grade, beerClusters))

# reduce the dataset to 10,000 points to make it easier to work with and plot faster
set.seed(1)
beer_reviews_10k = sample_n(beer_reviews_1, size = 10000)
# glimpse(beer_reviews_10k)
# ---- SCALE ---- 
beer_reviews_df2 = scale(beer_reviews_10k[1:7])

# ----- PLOT Rrand ----
# plot error on y-axis, and number of clusters on x-axis
# build a cluster tibble for k-means 
k = data_frame(1:nrow(beer_reviews_df2)) # specify length of data frame for clusters
for (i in 1:15){
  k[i] = kmeans(beer_reviews_df2, centers = i, iter.max = 50, nstart = 25)$cluster
}
names(k) = c('k1','k2','k3','k4','k5','k6','k7','k8','k9','k10','k11','k12','k13','k14','k15')
glimpse(k)
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
# this plot indicates that the least error occurs with 4 clusters

# Try various methods to find least error with Rrand  
# ---- KCCA ----
beer_kcca = kcca(beer_reviews_df2, k = 4, family=kccaFamily("kmedians"))
randIndex(table(beer_reviews_10k$taste, beer_kcca@cluster))# kmedians -> 0.2761
randIndex(table(beer_reviews_10k$aroma, beer_kcca@cluster))
randIndex(table(beer_reviews_10k$ovr_grade, beer_kcca@cluster))
# ---- CCLUST ----
beer_ccl = cclust(beer_reviews_df2, k = 4, method = 'hardcl', dist = 'manhattan') 
# beer_ccl@cluster
randIndex(table(beer_reviews_10k$taste, beer_ccl@cluster))# hardcl + manhattan -> 0.3673
randIndex(table(beer_reviews_10k$aroma, beer_ccl@cluster)) # 0.2346
randIndex(table(beer_reviews_10k$ovr_grade, beer_ccl@cluster)) # 0.2051
# ---- PAM ----
#clusplot(beer_pam)
beer_pam = pam(beer_reviews_df2, k = 4, metric = 'manhattan', cluster.only = TRUE)
#bpam_clust = beer_pam$clustering
randIndex(table(beer_reviews_10k$taste, beer_pam)) # manhattan -> 0.3783
randIndex(table(beer_reviews_10k$aroma, bpam_clust)) # 0.2407
randIndex(table(beer_reviews_10k$ovr_grade, bpam_clust)) # 0.2040
# ---- CLARA ----
beer_clara = clara(beer_reviews_df2, k = 4, metric = "manhattan")
bclr_clust = beer_clara$clustering
randIndex(table(beer_reviews_10k$taste, bclr_clust)) # manhattan -> 0.3071
randIndex(table(beer_reviews_10k$aroma, bclr_clust)) # 0.2256
randIndex(table(beer_reviews_10k$ovr_grade, bclr_clust)) # 0.1914

# ---- CONCLUSION ----
# CCLUST produces least error and works relatively quickly 
# PAM also results in a lower error but works much slower

# ---- SCALE ---- 
# *** NOTE: 1:7 and 4 clusters have highest Accuracy so far, 0.30
# WITH: filter(beer_name_cnt > 350 & brewery_name_cnt > 10000 & profile_name_cnt > 500)
beer_reviews_df = scale(beer_reviews_1[1:7])

# ---- CCLUST ----
# ?cclust
# now use the full data set
beer_ccl = cclust(beer_reviews_df, k = 4, method = 'hardcl', dist = 'manhattan') 
randIndex(table(beer_reviews_1$taste, beer_ccl@cluster))# hardcl + manhattan -> 0.3658
randIndex(table(beer_reviews_1$overall, beer_ccl@cluster))# hardcl + manhattan -> 0.3033
randIndex(table(beer_reviews_1$ovr_grade, beer_ccl@cluster))# hardcl + manhattan -> 0.2074


# ---- Summarize the Clusters ----
# summarize resulting clusters
beer_ccl@clusinfo
ccl_clust = beer_ccl@cluster
beer_reviews_1 %>%
  mutate(ccl_clust = beer_ccl@cluster) %>%
  group_by(ccl_clust) %>%
  summarise_all('mean')
# Cluster 4 appears to have the highest ratings for taste, aroma, appearance, overall, palate, and overall grade
# it also has the highest amount of reviews 
# ***NOTE: running clustering again MAY not return the same cluster number as having the highest ratings. It's not always #4
glimpse(beer_reviews_1)
beer_reviews_1_ordered = 
  beer_reviews_1 %>%
  select(taste, aroma, appearance, overall, palate,beer_abv, ovr_grade,beer_name, brewery_name, beer_abv_factor, beer_style,
         general_beer_style, beer_name_cnt, brewery_name_cnt)

# explore contents of the clusters and search through them
glimpse(beer_reviews_1)
ccl_clust = beer_ccl@cluster
beer_reviews_1_sub = subset(beer_reviews_1_ordered, ccl_clust == 4)


# ---- RECOMMENDATION ----
# list of criteria:
# taste, overall, aroma, palate, appearance, overall grade, beer ABV, beer style


# search for specific criteria
beer_rec_df = 
  beer_reviews_1_ordered %>%
  filter(ovr_grade >= 4.0, beer_abv_factor == 'below normal')


# analyse the criteria further before recommendation 
beer_reviews_1_sub = 
  beer_rec_df %>% 
  group_by(beer_name) %>%
  summarise(
    review_count     = n(),
    overall_mean     = mean(overall), 
    taste_mean       = mean(taste),
    aroma_mean       = mean(aroma), 
    appearance_mean  = mean(appearance), 
    palate_mean      = mean(palate),
    rev_cnt_ovr      = review_count/overall_mean,
    mean_consistency = (overall_mean + taste_mean + aroma_mean + appearance_mean + palate_mean)/5,
    
    overall_sd       = sd(overall), 
    taste_sd         = sd(taste),
    aroma_sd         = sd(aroma), 
    appearance_sd    = sd(appearance), 
    palate_sd        = sd(palate),
    sd_consistency   = (overall_sd + taste_sd + aroma_sd + appearance_sd + palate_sd)/5) %>%
  filter(review_count > 10) %>%
  arrange(desc(mean_consistency), desc(sd_consistency))

stats_function_2(beer_reviews_1_sub$rev_cnt_ovr, 'sub clus stats')

# select random beer from list
# using sample_n(), generate 5 recommendations
rec_func = function(df){
  if (length(df$beer_name) <= 5){
    head(df)
  }
  else if(length(df$beer_name) > 5){
    head(sample_n(df, 5))
  }
  else if (length(df$beer_name) == 0){
    print('None found')
  }
}
rec_func(beer_reviews_1_sub)








