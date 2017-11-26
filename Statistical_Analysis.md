
------------------------------------------------------------------------

title: "Beer Reviews: Statistical Analysis" author: "Sergey Mouzykin" date: "November 25, 2017" output: rmarkdown::github\_document

------------------------------------------------------------------------

### Summary Statistics

### Beer Name

Summarizing the standard deviation, variance, mean, median, max, and min for every beer style.

    ##                    Overall Rating Summary
    ## standard deviation 0.7206219             
    ## variance           0.5192959             
    ## mean               3.815581              
    ## median             4                     
    ## max                5                     
    ## min                0

    ##                    Taste Rating Summary
    ## standard deviation 0.7319696           
    ## variance           0.5357795           
    ## mean               3.79286             
    ## median             4                   
    ## max                5                   
    ## min                1

    ##                    Aroma Rating Summary
    ## standard deviation 0.6976167           
    ## variance           0.4866691           
    ## mean               3.735636            
    ## median             4                   
    ## max                5                   
    ## min                1

    ##                    Appearance Rating Summary
    ## standard deviation 0.6160928                
    ## variance           0.3795703                
    ## mean               3.841642                 
    ## median             4                        
    ## max                5                        
    ## min                0

    ##                    Palate Rating Summary
    ## standard deviation 0.6822184            
    ## variance           0.4654219            
    ## mean               3.743701             
    ## median             4                    
    ## max                5                    
    ## min                1

The min and max for two columns, overall and appearance, are 0 and 5 respectively. It's worth taking a closer look at those ratings since the other aspects range from 1 to 5.

Looking at the mean and standard deviation (SD) of overall column where the overall rating is given a zero, it is interesting to find that in some of the more extreme scenarios, the ratings between different aspects vary greatly. In particular, for the beer, *Latter Days Stout*, we can find that a rating of zero for the overall was given out while at the same time its aroma was rated a four. It seems contradictory to rate the overall as a zero while enjoying at least one aspect of the beer, in particular, its aroma.

    ## # A tibble: 7 x 9
    ## # Groups:   beer_name, overall, taste, aroma, appearance [7]
    ##                 beer_name overall taste aroma appearance palate
    ##                     <chr>   <dbl> <dbl> <dbl>      <dbl>  <dbl>
    ## 1       latter days stout       0   2.0     4          0    2.0
    ## 2                pub pils       0   2.0     2          0    3.0
    ## 3      red rock amber ale       0   3.5     3          0    2.5
    ## 4 red rock bavarian weiss       0   2.0     2          0    2.5
    ## 5  red rock dunkel weizen       0   2.0     2          0    2.5
    ## 6        red rock pilsner       0   1.5     2          0    3.0
    ## 7           utah pale ale       0   2.0     3          0    2.0
    ## # ... with 3 more variables: beer_name_count <int>, overall_mean <dbl>,
    ## #   overall_sd <dbl>

    ## # A tibble: 38,364 x 8
    ## # Groups:   beer_name [37,852]
    ##                                   beer_name general_beer_style
    ##                                       <chr>              <chr>
    ##  1                 '99 wee heavy scotch ale                ale
    ##  2              't hommelhof cuvée spéciale                ale
    ##  3                                "\"100\""                ale
    ##  4      "\"12\"  belgian golden strong ale"                ale
    ##  5                          "\"33\" export"              lager
    ##  6              "\"4\" horse oatmeal stout"              stout
    ##  7                 "\"76\" anniversary ale"                ale
    ##  8                      "\"alt\"ered state"                ale
    ##  9            "\"naughty scot\" scotch ale"                ale
    ## 10         "\"old school\" craft cream ale"                ale
    ## 11                "\"the camp\" barleywine"         barleywine
    ## 12                                #1 saison                ale
    ## 13                      #1073 prairie stout              stout
    ## 14                             ¿por que no?                ale
    ## 15                          10 bbl pale ale                ale
    ## 16                                   1000.0                ale
    ## 17                     10th anniversary ale              wheat
    ## 18 10th anniversary oak aged rye barleywine         barleywine
    ## 19                             111 pilsener            pilsner
    ## 20                      1133 biere d'abbaye                ale
    ## # ... with 3.834e+04 more rows, and 6 more variables:
    ## #   beer_name_count <int>, overall_sd <dbl>, taste_sd <dbl>,
    ## #   aroma_sd <dbl>, appearance_sd <dbl>, palate_sd <dbl>

    ##                    Beer Review Count
    ## standard deviation 146.3773         
    ## variance           21426.3          
    ## mean               40.85022         
    ## median             5                
    ## max                3290             
    ## min                2

Plot the Standard Deviation Distribution
========================================

In support to the histogram, we can also calculate the mean, median, standard deviation, maximum rating, and minimum rating. Essentially, the deviation can tell us how divisive people are among the ratings. Generally, it appears that people will agree on a rating value to within about 3/4 of a point. However, the deviation will vary with the beer name.

``` r
# PLOT
# overall_sd histogram
ggplot(beer_reviews_SD, aes(x = overall_sd)) + 
  geom_histogram(binwidth = 0.1, fill = '#3182BD', col = 'black') + 
  scale_x_continuous('Overall Deviation', breaks = seq(0, 3.0, by = 0.2)) +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-1.png)

``` r
stats_function_2(beer_reviews_SD$overall_sd, 'Overall SD Summary')
```

    ##                    Overall SD Summary
    ## standard deviation 0.2995806         
    ## variance           0.08974856        
    ## mean               0.5390207         
    ## median             0.5188745         
    ## max                2.828427          
    ## min                0

``` r
ggplot(beer_reviews_SD, aes(x = taste_sd)) + 
  geom_histogram(binwidth = 0.1, fill = '#3182BD', col = 'black') + 
  scale_x_continuous('Taste Deviation', breaks = seq(0, 3.0, by = 0.2)) +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-2.png)

``` r
stats_function_2(beer_reviews_SD$taste_sd, 'Taste SD Summary')
```

    ##                    Taste SD Summary
    ## standard deviation 0.2844422       
    ## variance           0.08090736      
    ## mean               0.5029366       
    ## median             0.4936502       
    ## max                2.828427        
    ## min                0

``` r
ggplot(beer_reviews_SD, aes(x = aroma_sd)) + 
  geom_histogram(binwidth = 0.1, fill = '#3182BD', col = 'black') + 
  scale_x_continuous('Aroma Deviation', breaks = seq(0, 3.0, by = 0.2)) +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-3.png)

``` r
stats_function_2(beer_reviews_SD$aroma_sd, 'Aroma SD Summary')
```

    ##                    Aroma SD Summary
    ## standard deviation 0.2541058       
    ## variance           0.06456977      
    ## mean               0.4724818       
    ## median             0.4714045       
    ## max                2.474874        
    ## min                0

``` r
ggplot(beer_reviews_SD, aes(x = appearance_sd)) + 
  geom_histogram(binwidth = 0.1, fill = '#3182BD', col = 'black') + 
  scale_x_continuous('Appearance Deviation', breaks = seq(0, 3.0, by = 0.2)) +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-4.png)

``` r
stats_function_2(beer_reviews_SD$appearance_sd, 'Appearance SD Summary')
```

    ##                    Appearance SD Summary
    ## standard deviation 0.2418059            
    ## variance           0.05847009           
    ## mean               0.4395605            
    ## median             0.4291975            
    ## max                2.12132              
    ## min                0

``` r
ggplot(beer_reviews_SD, aes(x = palate_sd)) + 
  geom_histogram(binwidth = 0.1, fill = '#3182BD', col = 'black') + 
  scale_x_continuous('Palate Deviation', breaks = seq(0, 3.0, by = 0.2)) +
  theme_blue 
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-1-5.png)

``` r
stats_function_2(beer_reviews_SD$palate_sd, 'Palate SD Summary')
```

    ##                    Palate SD Summary
    ## standard deviation 0.2693696        
    ## variance           0.07255996       
    ## mean               0.4966859        
    ## median             0.4929625        
    ## max                2.474874         
    ## min                0

``` r
# NOTE: 
# with only 1 or 2 reviews, disagreements vary greatly among the 5 observations
# 1. lower deviation implies agreement between different reviews
# 2. higher deviation implies disagreement between reviewers

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
```

    ## # A tibble: 75 x 8
    ## # Groups:   beer_name [75]
    ##                                                   beer_name
    ##                                                       <chr>
    ##  1                                  founders dirty darkness
    ##  2                                kelso industrial pale ale
    ##  3                                                red scare
    ##  4                                  starobrno cerne (black)
    ##  5                                                super wit
    ##  6                                    oak-aged cherry stout
    ##  7                                                   spooky
    ##  8                                                 rye not?
    ##  9                                     limited edition 2004
    ## 10     st. denis pilzenn imperialni (deni pilsner imperial)
    ## 11                              old bad cat barleywine 2008
    ## 12                 andechser dunkel naturtrüb jubiläumsbier
    ## 13                                                pale tail
    ## 14                                        sandy paws (2010)
    ## 15 pilot series passionfruit and dragonfruit berliner weiss
    ## 16                               chaos chaos imperial stout
    ## 17                                                      sfo
    ## 18                                             live oak ipa
    ## 19                     maduro oatmeal brown ale - blueberry
    ## 20                                       hotter than helles
    ## # ... with 55 more rows, and 7 more variables: general_beer_style <chr>,
    ## #   beer_name_count <int>, overall_sd <dbl>, taste_sd <dbl>,
    ## #   aroma_sd <dbl>, appearance_sd <dbl>, palate_sd <dbl>

### General Beer Style

    ## # A tibble: 24 x 8
    ##                 general_beer_style style_count overall_sd overall_mean
    ##                              <chr>       <int>      <dbl>        <dbl>
    ##  1                low alcohol beer        1201  1.0073243     2.578268
    ##  2            american malt liquor        3925  1.0338246     2.678854
    ##  3                        happoshu         241  0.9863785     2.914938
    ##  4          fruit / vegetable beer       33861  0.8917166     3.415124
    ##  5                   spiced/herbed       13663  0.8712269     3.424907
    ##  6                           lager      132481  0.9056884     3.438693
    ##  7                     black & tan        2358  0.7200659     3.486853
    ##  8 bière de champagne / bière brut        1046  0.8661809     3.648184
    ##  9                           sahti        1061  0.7065662     3.700283
    ## 10                         pilsner       40330  0.7304550     3.768634
    ## 11                          smoked        6948  0.6740619     3.778929
    ## 12                             ale      577361  0.6902948     3.795629
    ## 13                            bock       46501  0.6678802     3.813047
    ## 14                       wheatwine        3714  0.6502937     3.815563
    ## 15                          bitter       25999  0.6536035     3.825743
    ## 16                           wheat       80947  0.6865366     3.868840
    ## 17                      barleywine       40459  0.6392141     3.881089
    ## 18              flanders oud bruin        4995  0.6840799     3.902503
    ## 19                          porter       73249  0.6347968     3.908558
    ## 20                          lambic       18682  0.7081593     3.954502
    ## 21                        trappist       68397  0.6326675     3.958068
    ## 22                           stout      182268  0.6612623     3.960232
    ## 23                             rye       10893  0.6122244     3.963233
    ## 24                             ipa      216034  0.6193515     3.977897
    ## # ... with 4 more variables: taste_sd <dbl>, aroma_sd <dbl>,
    ## #   appearance_sd <dbl>, palate_sd <dbl>

    ##                    Style Count
    ## standard deviation 123448.7   
    ## variance           15239576394
    ## mean               66108.92   
    ## median             22340.5    
    ## max                577361     
    ## min                241

    ##                    Overall SD
    ## standard deviation 0.1329949 
    ## variance           0.01768764
    ## mean               0.7472439 
    ## median             0.6884157 
    ## max                1.033825  
    ## min                0.6122244

    ##                    Overall Mean
    ## standard deviation 0.399404    
    ## variance           0.1595236   
    ## mean               3.644107    
    ## median             3.804338    
    ## max                3.977897    
    ## min                2.578268

    ##                    Aroma SD   
    ## standard deviation 0.09766952 
    ## variance           0.009539336
    ## mean               0.6561789  
    ## median             0.6188605  
    ## max                0.8507946  
    ## min                0.5366802

    ##                    Taste SD  
    ## standard deviation 0.1132976 
    ## variance           0.01283634
    ## mean               0.717111  
    ## median             0.6716393 
    ## max                0.9552426 
    ## min                0.6070527

    ##                    Appearance SD
    ## standard deviation 0.1131763    
    ## variance           0.01280887   
    ## mean               0.5966167    
    ## median             0.5577862    
    ## max                0.8427827    
    ## min                0.4783073

    ##                    Palate SD 
    ## standard deviation 0.1034379 
    ## variance           0.01069939
    ## mean               0.6709814 
    ## median             0.6295702 
    ## max                0.8835709 
    ## min                0.5470604

We can find the least disliked beer style by looking at the mean of the overall (shown above). However, the standard deviation (1.00) is quite high in this case which implies disagreement and the ratings can vary by one point. Therefore, we cannot absolutely conclude that the low alcohol beer is rated the worst. Although, we can say that it is one the least appreaciated beer styles among others.

Also, we can find the beer styles which are relatively best rated (shown below).

### Beer Style

    ## # A tibble: 104 x 8
    ##                             beer_style style_count overall_sd overall_mean
    ##                                  <chr>       <int>      <dbl>        <dbl>
    ##  1                   american wild ale       17794  0.6542419     4.093262
    ##  2                              gueuze        6009  0.6413163     4.086287
    ##  3                    quadrupel (quad)       18086  0.6296276     4.071630
    ##  4                  lambic - unblended        1114  0.6567664     4.048923
    ##  5    american double / imperial stout       50705  0.6664566     4.029820
    ##  6              russian imperial stout       54129  0.6354456     4.023084
    ##  7                          weizenbock        9412  0.5983101     4.007969
    ##  8      american double / imperial ipa       85977  0.6367582     3.998017
    ##  9                    flanders red ale        6664  0.6752854     3.992722
    ## 10                            rye beer       10130  0.5930640     3.981737
    ## 11          keller bier / zwickel bier        2591  0.6257269     3.981088
    ## 12                             eisbock        2663  0.6250778     3.977094
    ## 13                        american ipa      117586  0.6107604     3.965221
    ## 14                                gose         686  0.6221699     3.965015
    ## 15              saison / farmhouse ale       31480  0.6183095     3.962564
    ## 16                         belgian ipa       12471  0.5726129     3.958704
    ## 17                       baltic porter       11572  0.5905583     3.955410
    ## 18                          roggenbier         466  0.5313079     3.948498
    ## 19                       oatmeal stout       18145  0.6314181     3.941692
    ## 20                  american black ale       11446  0.5622348     3.934475
    ## 21                          hefeweizen       27908  0.6767538     3.929626
    ## 22                              dubbel       19983  0.6270035     3.921733
    ## 23                      english porter       11200  0.6361153     3.917946
    ## 24                              tripel       30328  0.6299255     3.914287
    ## 25             belgian strong dark ale       37743  0.6353371     3.913322
    ## 26                  flanders oud bruin        4995  0.6840799     3.902503
    ## 27                  berliner weissbier        3475  0.7678588     3.901151
    ## 28                             old ale       14703  0.6402962     3.899000
    ## 29                 american barleywine       26728  0.6206632     3.896756
    ## 30                     american porter       50477  0.6437006     3.895735
    ## 31             belgian strong pale ale       31490  0.6514504     3.895602
    ## 32                  milk / sweet stout       13166  0.6554527     3.892526
    ## 33                      lambic - fruit       10950  0.7297482     3.892283
    ## 34                      bière de garde        6729  0.6160419     3.880294
    ## 35              foreign / export stout        5972  0.6308640     3.877679
    ## 36              scotch ale / wee heavy       17441  0.6065514     3.874262
    ## 37                 american strong ale       31945  0.6956994     3.873501
    ## 38                          doppelbock       21699  0.6604465     3.872805
    ## 39                 munich helles lager        7870  0.6924057     3.869441
    ## 40                      american stout       24538  0.6710999     3.865311
    ## 41  american double / imperial pilsner        5435  0.6335278     3.858694
    ## 42                  american brown ale       25297  0.6226342     3.857434
    ## 43                        dunkelweizen        7122  0.6448806     3.856782
    ## 44             american pale ale (apa)       63469  0.6604517     3.852306
    ## 45                  english barleywine       13731  0.6728391     3.850594
    ## 46      california common / steam beer        4038  0.6472510     3.847821
    ## 47 extra special / strong bitter (esb)       17212  0.6195223     3.847025
    ## 48               english dark mild ale        2314  0.7312741     3.837511
    ## 49                         schwarzbier        9826  0.6367924     3.835030
    ## 50           dortmunder / export lager        4440  0.7259446     3.833108
    ## # ... with 54 more rows, and 4 more variables: taste_sd <dbl>,
    ## #   aroma_sd <dbl>, appearance_sd <dbl>, palate_sd <dbl>

    ##                    Overall SD
    ## standard deviation 0.1080415 
    ## variance           0.01167296
    ## mean               0.7007821 
    ## median             0.6698763 
    ## max                1.12708   
    ## min                0.5313079

    ##                    Overall Mean
    ## standard deviation 0.3019827   
    ## variance           0.09119353  
    ## mean               3.732231    
    ## median             3.821994    
    ## max                4.093262    
    ## min                2.578268

    ##                    Taste SD   
    ## standard deviation 0.09168585 
    ## variance           0.008406294
    ## mean               0.6661918  
    ## median             0.6370729  
    ## max                1.096588   
    ## min                0.4824496

    ##                    Aroma SD   
    ## standard deviation 0.07634401 
    ## variance           0.005828408
    ## mean               0.6078849  
    ## median             0.584121   
    ## max                0.9147802  
    ## min                0.4632211

    ##                    Appearance SD
    ## standard deviation 0.08295096   
    ## variance           0.006880862  
    ## mean               0.5579751    
    ## median             0.5283527    
    ## max                0.8498464    
    ## min                0.4154222

    ##                    Palate SD  
    ## standard deviation 0.08356234 
    ## variance           0.006982665
    ## mean               0.6312968  
    ## median             0.6119725  
    ## max                1.009596   
    ## min                0.498748

### Beer ABV (alcohol by volume)

This plot shows us that the ABV is actually a right-skewed distribution due to some beers having a a very high alcohol by volume content. The minimum and maximum of ABV content are 0.01% and 57.7%, respectively. The mean lies at 7.04, the median at 6.6, and the standard deviation is 2.27. We can also infer that the distribution is right-skewed due to the median being lower than the mean. Although the values range from 0.01 to 57.7, in theory, about 95% of these values should lie within two standard deviations from the mean.

``` r
# reduce the amount of data points with the sample_n()
# this will produce the plots much faster than plotting all 1.5 million reviews
beer_reviews_10k = sample_n(beer_reviews, size = 10000)

# PLOT: Beer ABV distribution
ggplot(beer_reviews_10k, aes(x = beer_abv)) + 
  geom_histogram(binwidth = 0.5, position = 'dodge', fill = '#3182BD', col = 'black') + 
  scale_x_continuous('Alcohol by Volume (%)', breaks = seq(0, 60, by = 2)) +
  scale_y_continuous('Beer Count') +
  ggtitle('Beer ABV Distribution') +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-2-1.png)

``` r
stats_function_2(beer_reviews$beer_abv, 'Beer ABV Summary')
```

    ##                    Beer ABV Summary
    ## standard deviation 2.272372        
    ## variance           5.163673        
    ## mean               7.042387        
    ## median             6.6             
    ## max                57.7            
    ## min                0.01

``` r
# HISTOGRAM
ggplot(beer_reviews_10k, aes(x = as.factor(overall), fill = general_beer_style)) +
  geom_histogram(binwidth = 15, stat = 'count') +
  #scale_x_continuous(limits = c(1,20)) + 
  theme_classic()
```

    ## Warning: Ignoring unknown parameters: binwidth, bins, pad

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-2-2.png)

``` r
# ABV factor and beer style
ggplot(beer_reviews_10k, aes(x = beer_abv_factor, fill = general_beer_style)) + 
  geom_histogram(stat = 'count', position = 'dodge') +
  scale_x_discrete('Beer ABV') + 
  theme_blue
```

    ## Warning: Ignoring unknown parameters: binwidth, bins, pad

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-2-3.png)

``` r
# --- Point Plot
# overall vs. beer ABV, colored by beer style
ggplot(beer_reviews_10k, aes(x = overall, y = beer_abv, col = general_beer_style)) + 
  geom_point(alpha = 0.3) +
  geom_jitter() +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-3-1.png)

``` r
# Overall vs. Style, colored by beer style
ggplot(beer_reviews_10k, aes(x = overall, y = general_beer_style, col = beer_abv_factor)) + 
  geom_point(alpha = 0.1, shape = 21) +
  geom_jitter() + 
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-3-2.png)

``` r
ggplot(beer_reviews_10k, aes(x = beer_abv, y = general_beer_style, col = as.factor(overall))) + 
  geom_point(alpha = 0.1, shape = 21) +
  geom_jitter() + 
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-3-3.png)

``` r
# --- Histograms
# Overall and Beer ABV distribution
ggplot(beer_reviews_10k, aes(x = overall, fill = beer_abv_factor)) + 
  geom_histogram(binwidth = 0.25) +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-3-4.png)

``` r
# Overall and Beer Styles
ggplot(beer_reviews_10k, aes(x = overall, fill = general_beer_style)) + 
  geom_histogram(binwidth = 0.25) +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-3-5.png)

The graphs above helps visualize the overall rating distribution amongst the beer styles and their respective alcohol content.

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/Five%20Aspects-1.png)![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/Five%20Aspects-2.png)![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/Five%20Aspects-3.png)![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/Five%20Aspects-4.png)

    ## function (x, y = NULL, use = "everything", method = c("pearson", 
    ##     "kendall", "spearman")) 
    ## {
    ##     na.method <- pmatch(use, c("all.obs", "complete.obs", "pairwise.complete.obs", 
    ##         "everything", "na.or.complete"))
    ##     if (is.na(na.method)) 
    ##         stop("invalid 'use' argument")
    ##     method <- match.arg(method)
    ##     if (is.data.frame(y)) 
    ##         y <- as.matrix(y)
    ##     if (is.data.frame(x)) 
    ##         x <- as.matrix(x)
    ##     if (!is.matrix(x) && is.null(y)) 
    ##         stop("supply both 'x' and 'y' or a matrix-like 'x'")
    ##     if (!(is.numeric(x) || is.logical(x))) 
    ##         stop("'x' must be numeric")
    ##     stopifnot(is.atomic(x))
    ##     if (!is.null(y)) {
    ##         if (!(is.numeric(y) || is.logical(y))) 
    ##             stop("'y' must be numeric")
    ##         stopifnot(is.atomic(y))
    ##     }
    ##     Rank <- function(u) {
    ##         if (length(u) == 0L) 
    ##             u
    ##         else if (is.matrix(u)) {
    ##             if (nrow(u) > 1L) 
    ##                 apply(u, 2L, rank, na.last = "keep")
    ##             else row(u)
    ##         }
    ##         else rank(u, na.last = "keep")
    ##     }
    ##     if (method == "pearson") 
    ##         .Call(C_cor, x, y, na.method, FALSE)
    ##     else if (na.method %in% c(2L, 5L)) {
    ##         if (is.null(y)) {
    ##             .Call(C_cor, Rank(na.omit(x)), NULL, na.method, method == 
    ##                 "kendall")
    ##         }
    ##         else {
    ##             nas <- attr(na.omit(cbind(x, y)), "na.action")
    ##             dropNA <- function(x, nas) {
    ##                 if (length(nas)) {
    ##                   if (is.matrix(x)) 
    ##                     x[-nas, , drop = FALSE]
    ##                   else x[-nas]
    ##                 }
    ##                 else x
    ##             }
    ##             .Call(C_cor, Rank(dropNA(x, nas)), Rank(dropNA(y, 
    ##                 nas)), na.method, method == "kendall")
    ##         }
    ##     }
    ##     else if (na.method != 3L) {
    ##         x <- Rank(x)
    ##         if (!is.null(y)) 
    ##             y <- Rank(y)
    ##         .Call(C_cor, x, y, na.method, method == "kendall")
    ##     }
    ##     else {
    ##         if (is.null(y)) {
    ##             ncy <- ncx <- ncol(x)
    ##             if (ncx == 0) 
    ##                 stop("'x' is empty")
    ##             r <- matrix(0, nrow = ncx, ncol = ncy)
    ##             for (i in seq_len(ncx)) {
    ##                 for (j in seq_len(i)) {
    ##                   x2 <- x[, i]
    ##                   y2 <- x[, j]
    ##                   ok <- complete.cases(x2, y2)
    ##                   x2 <- rank(x2[ok])
    ##                   y2 <- rank(y2[ok])
    ##                   r[i, j] <- if (any(ok)) 
    ##                     .Call(C_cor, x2, y2, 1L, method == "kendall")
    ##                   else NA
    ##                 }
    ##             }
    ##             r <- r + t(r) - diag(diag(r))
    ##             rownames(r) <- colnames(x)
    ##             colnames(r) <- colnames(x)
    ##             r
    ##         }
    ##         else {
    ##             if (length(x) == 0L || length(y) == 0L) 
    ##                 stop("both 'x' and 'y' must be non-empty")
    ##             matrix_result <- is.matrix(x) || is.matrix(y)
    ##             if (!is.matrix(x)) 
    ##                 x <- matrix(x, ncol = 1L)
    ##             if (!is.matrix(y)) 
    ##                 y <- matrix(y, ncol = 1L)
    ##             ncx <- ncol(x)
    ##             ncy <- ncol(y)
    ##             r <- matrix(0, nrow = ncx, ncol = ncy)
    ##             for (i in seq_len(ncx)) {
    ##                 for (j in seq_len(ncy)) {
    ##                   x2 <- x[, i]
    ##                   y2 <- y[, j]
    ##                   ok <- complete.cases(x2, y2)
    ##                   x2 <- rank(x2[ok])
    ##                   y2 <- rank(y2[ok])
    ##                   r[i, j] <- if (any(ok)) 
    ##                     .Call(C_cor, x2, y2, 1L, method == "kendall")
    ##                   else NA
    ##                 }
    ##             }
    ##             rownames(r) <- colnames(x)
    ##             colnames(r) <- colnames(y)
    ##             if (matrix_result) 
    ##                 r
    ##             else drop(r)
    ##         }
    ##     }
    ## }
    ## <bytecode: 0x000000001cd99378>
    ## <environment: namespace:stats>

Plotting overall against other aspects, we can observe a linear correlation emerging.

Plot: Distribution of Ratings
=============================

These plots below help visualize the rating distribution of the five aspects, overall, taste, aroma, appearance, and palate.

``` r
# ------ Histogram Plot -------
# Overall Rating Distribution
ggplot(beer_reviews_10k, aes(x = overall)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-4-1.png)

``` r
ggplot(beer_reviews_10k, aes(x = taste)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-4-2.png)

``` r
ggplot(beer_reviews_10k, aes(x = aroma)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-4-3.png)

``` r
ggplot(beer_reviews_10k, aes(x = appearance)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-4-4.png)

``` r
ggplot(beer_reviews_10k, aes(x = palate)) + 
  geom_histogram(binwidth = 0.25, position = 'dodge', fill = '#3182BD', col = 'black') +
  theme_blue
```

![](Statistical_Analysis_files/figure-markdown_github-ascii_identifiers/unnamed-chunk-4-5.png)

### Profile Names

Here we can find the summary statistics for the profile names columns.

Amount of profile names: 33,388

Out of these names, 19,821 of them submitted five or less reviews.

``` r
# number of profile names
beer_reviews %>% 
  select(profile_name) %>% 
  distinct()
```

    ## # A tibble: 33,388 x 1
    ##      profile_name
    ##             <chr>
    ##  1        stcules
    ##  2 johnmichaelsen
    ##  3        oline73
    ##  4      reidrover
    ##  5   alpinebryant
    ##  6  lordadmnelson
    ##  7   augustgarage
    ##  8        fodeeoz
    ##  9   madeinoregon
    ## 10        rawthar
    ## # ... with 33,378 more rows

``` r
# amount of reviews by each person
beer_reviews %>% 
  group_by(profile_name) %>% 
  tally(sort = TRUE)
```

    ## # A tibble: 33,388 x 2
    ##      profile_name     n
    ##             <chr> <int>
    ##  1 northyorksammy  5817
    ##  2  buckeyenation  4661
    ##  3    mikesgroove  4617
    ##  4      thorpe429  3518
    ##  5  womencantsail  3497
    ##  6    nerofiddled  3488
    ##  7   chaingangguy  3471
    ##  8       brentk56  3357
    ##  9       phyl21ca  3179
    ## 10         weswes  3168
    ## # ... with 33,378 more rows

``` r
# find total amount of profile names
profile_names = 
  beer_reviews %>% 
  group_by(profile_name) %>%
  summarise(reviewed_amount = n(),
            overall_mean = mean(overall),
            overall_sd = sd(overall)) %>%
  arrange(desc(reviewed_amount)) %>%
  filter(reviewed_amount >= 3) %>%
  
  print(n = 20)
```

    ## # A tibble: 18,838 x 4
    ##      profile_name reviewed_amount overall_mean overall_sd
    ##             <chr>           <int>        <dbl>      <dbl>
    ##  1 northyorksammy            5817     3.629362  0.6295269
    ##  2  buckeyenation            4661     3.734714  0.7412904
    ##  3    mikesgroove            4617     4.086203  0.6362618
    ##  4      thorpe429            3518     3.735645  0.7271591
    ##  5  womencantsail            3497     3.546754  0.8250244
    ##  6    nerofiddled            3488     4.107081  0.5032886
    ##  7   chaingangguy            3471     3.547249  0.6857443
    ##  8       brentk56            3357     3.822163  0.6294877
    ##  9       phyl21ca            3179     3.355615  0.7594024
    ## 10         weswes            3168     3.856376  0.5034304
    ## 11         oberon            3128     3.892743  0.4799349
    ## 12  feloniousmonk            3081     3.904901  0.6460761
    ## 13        akorsak            3010     3.842193  0.4757466
    ## 14    beerchitect            2946     3.784623  0.5779166
    ## 15     gueuzedude            2938     3.609598  0.5860451
    ## 16         jwc215            2735     3.653382  0.6179189
    ## 17     russpowell            2696     4.029859  0.5971007
    ## 18 themaniacalone            2659     3.781309  0.7548641
    ## 19         gavage            2630     3.878327  0.6378348
    ## 20         zeff80            2622     3.835431  0.6275618
    ## # ... with 1.882e+04 more rows

``` r
profile_names # 33,388 total profile names
```

    ## # A tibble: 18,838 x 4
    ##      profile_name reviewed_amount overall_mean overall_sd
    ##             <chr>           <int>        <dbl>      <dbl>
    ##  1 northyorksammy            5817     3.629362  0.6295269
    ##  2  buckeyenation            4661     3.734714  0.7412904
    ##  3    mikesgroove            4617     4.086203  0.6362618
    ##  4      thorpe429            3518     3.735645  0.7271591
    ##  5  womencantsail            3497     3.546754  0.8250244
    ##  6    nerofiddled            3488     4.107081  0.5032886
    ##  7   chaingangguy            3471     3.547249  0.6857443
    ##  8       brentk56            3357     3.822163  0.6294877
    ##  9       phyl21ca            3179     3.355615  0.7594024
    ## 10         weswes            3168     3.856376  0.5034304
    ## # ... with 18,828 more rows

``` r
glimpse(profile_names)
```

    ## Observations: 18,838
    ## Variables: 4
    ## $ profile_name    <chr> "northyorksammy", "buckeyenation", "mikesgroov...
    ## $ reviewed_amount <int> 5817, 4661, 4617, 3518, 3497, 3488, 3471, 3357...
    ## $ overall_mean    <dbl> 3.629362, 3.734714, 4.086203, 3.735645, 3.5467...
    ## $ overall_sd      <dbl> 0.6295269, 0.7412904, 0.6362618, 0.7271591, 0....

``` r
# find lowest activity by filtering review amount 
beer_reviews %>% 
  group_by(profile_name) %>%
  summarise(review_amount = n()) %>%
  arrange(desc(review_amount)) %>%
  filter(between(review_amount, 1, 5))
```

    ## # A tibble: 19,821 x 2
    ##       profile_name review_amount
    ##              <chr>         <int>
    ##  1       1001111.0             5
    ##  2         18alpha             5
    ##  3        24beer92             5
    ##  4         2cansam             5
    ##  5 3nlightenedfool             5
    ##  6   4theluvofbrew             5
    ##  7     513hooligan             5
    ##  8     619beerluvr             5
    ##  9           650gs             5
    ## 10             7.0             5
    ## # ... with 19,811 more rows

``` r
# 19,821 names submitted 5 or less reviews
```

For each profile name, we can summarize the overall ratings that were given out as well as the amount of reviews by each person.

    ##                    Review Amount
    ## standard deviation 237.0085     
    ## variance           56173.04     
    ## mean               83.23373     
    ## median             13           
    ## max                5817         
    ## min                3

    ##                    Profile Name
    ## standard deviation 0.369547    
    ## variance           0.136565    
    ## mean               3.888036    
    ## median             3.9         
    ## max                5           
    ## min                1
