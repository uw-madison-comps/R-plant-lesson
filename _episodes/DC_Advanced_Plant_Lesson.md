Investigating large datasets in R
================
Data Carpentry Contributors
9/05/2019

### Learning Objectives

1.  Explore a large dataset graphically
2.  Develop simple models with `lm()`
3.  Choose new packages and interpret package descriptions
4.  Analyze complex models using Information Theoretic (IT) Model Averaging (`arm` and `MuMIn` packages)

### Setup

Let's begin by loading the data and packages necessary to start this lesson.

``` r
# Set working directory
setwd("/Users/Kim/Documents/UW/Data Carpentry/Plant_DC_Workshop/")

# Load packages
library(ggplot2)

# Load data
phys_data<-read.csv("Physiology_Environmental_Data.csv")
```

### Exploring the dataset

In previous lessons we've worked with the plant physiology dataset from O'Keefe and Nippert 2018. As a reminder, these data were collected to address the following objectives:

1.  How do nocturnal and daytime transpiration vary among coexisting grasses, forbs, and shrubs in a tallgrass prairie?
2.  What environmental variables drive nocturnal transpiration and do these differ from the drivers of daytime transpiration?
3.  Are nocturnal transpiration and stomatal conductance associated with daytime physiological processes?

Let's use this dataset to explore the relationships between **leaf transpiration** and potential **drivers** of transpiration

**Transpiration parameters:**

1.  Nocturnal transpiration (Trmmol\_night)
2.  Nocturnal stomatal conductance (Cond\_night)
3.  Daytime transpiration (Trmmol\_day)
4.  Daytime stomatal conductance (Cond\_night)

**Potential drivers:**

1.  Nocturnal vapor pressure deficit (VPD\_N)
2.  Nocturnal air temperature (TAIR\_N)
3.  Daytime vapor pressure deficit (VPD\_D)
4.  Daytime air temperature (TAIR\_D)
5.  Daily average soil moisture (Soil\_moisture)
6.  Predawn leaf water potential (PD)
7.  Midday leaf water potential (MD)
8.  Photosynthesis (Photo)
9.  Plant functional group (Fgroup)

> ### <font color="grey">Challenge 1</font>
>
> Use ggplot to create a scatterplot of the relationship between a transpiration parameter and a potential driver.
>
> > ### <font color="grey">Example Solution to Challenge 1</font>
> >
> > ``` r
> > # Nocturnal transpiration vs. nocturnal VPD
> > ggplot(phys_data, aes(x=VPD_N, y=Trmmol_night)) +
> >  geom_point() +
> >  xlab("Nocturnal VPD (kPa)") +
> >  ylab(expression(paste(italic('E')[night]," ", "(mmol"," ",m^-2,s^-1,")"))) +
> >  theme_bw() 
> > ```
> >
> > ![](DC_Advanced_Plant_Lesson_files/figure-markdown_github/unnamed-chunk-2-1.png)

> ### <font color="grey">Challenge 2</font>
>
> How does this relationship differ between the different plant functional groups (grass, forb, woody)?
>
> > ### <font color="grey">Example Solution to Challenge 2</font>
> >
> > ``` r
> > ggplot(phys_data, aes(x=VPD_N, y=Trmmol_night, color=Fgroup)) +
> >  geom_point() +
> >  xlab("Nocturnal VPD") +
> >  ylab(expression(paste(italic('E')[night]," ", "(mmol"," ",m^-2,s^-1,")"))) +
> >  theme_bw()
> > ```
> >
> > ![](DC_Advanced_Plant_Lesson_files/figure-markdown_github/unnamed-chunk-3-1.png)

### Using a Simple Model

As you can see, plotting our data can be informative, but it doesn't necessarily tell us much about the statistical relationships between variables. We are going to start investigate the relationships between these data by using a simple **linear regression.** Linear regression is used to predict the value of a dependent variable **Y** based on one or more input independent (predictor) variables **X**, with the following basic equation:

*y* = *β*<sub>1</sub> + *β*<sub>2</sub>*X* + *ϵ*

In this equation, *y* is the dependent variable, *β*<sub>1</sub> is the intercept, *β*<sub>2</sub> is the slope, and *ϵ* is the error term.

To build this equation in R, we'll use the `lm()` function. `lm()` is included in the base R package, so you don't have to load it into your workspace to use. `lm()` takes three basic arguments: the dependent variable, the independent variable, and the dataframe from which the data is used. The model is specified using a particular format, and is typically assigned to an object:

`model_name <- lm(dependent_variable ~ independent_variable, data=dataframe_name )`

We can then view our model output with the `summary()` function.

``` r
fit_vpd <- lm(Trmmol_night ~ VPD_N, data=phys_data)
summary(fit_vpd)
```

    ## 
    ## Call:
    ## lm(formula = Trmmol_night ~ VPD_N, data = phys_data)
    ## 
    ## Residuals:
    ##      Min       1Q   Median       3Q      Max 
    ## -0.57289 -0.27516 -0.07538  0.15691  1.36512 
    ## 
    ## Coefficients:
    ##             Estimate Std. Error t value Pr(>|t|)    
    ## (Intercept)  0.64929    0.04480  14.493  < 2e-16 ***
    ## VPD_N       -0.21335    0.04867  -4.384 1.65e-05 ***
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
    ## 
    ## Residual standard error: 0.3783 on 283 degrees of freedom
    ## Multiple R-squared:  0.06359,    Adjusted R-squared:  0.06028 
    ## F-statistic: 19.22 on 1 and 283 DF,  p-value: 1.646e-05

From this output, we're usually interested in the following results:

-   `(Intercept) Estimate`: This is the y-intercept of our regression

-   `VPD_N Estimate`: This is the slope of our regression

-   `Std. Error`: The standard error for our intercept and slope estimates

-   `Pr(>|t|)`: These are the p-values associated with the intercept and our independent variable

-   `Multiple R-squared`: The *r*<sup>2</sup> value that indicates model fit

-   `F-statistic` and `p-value`: Indicate overall model significance

### More Complex Models

Now that we know how to test for the effect of one variable on the dependent variable, let's test for the effect of *multiple* variables on the dependent variable. You can add additional variables to your model by using the following formula:

`model_name <- lm(dependent_variable ~ independent_variable_1 * independent_variable_2, data=dataframe_name )`

Note that adding an asterisk `*` between the two independent variables indicates that we will be testing for the effects of independent variable 1, independent variable 2, and their interaction on the dependent variable. If we were not interested in testing for interactions among independent variables, we could replace the `*` with a `+` sign.

> ### <font color="grey">Challenge 3</font>
>
> Create a model that tests for the effects of four factors on either transpiration or stomatal conductance.
>
> > ### <font color="grey">Example Solution to Challenge 3</font>
> >
> > ``` r
> > fit_all <- lm(Trmmol_night ~ VPD_N * TAIR_N * Soil_moisture * Fgroup, data=phys_data)
> > summary(fit_all)
> > ```

### How to Work with Complex Models: IT Model Averaging

As you can see, we have a lot of potential interactions with just four independent variables in our model! This becomes incredibly difficult to interpret, so we often have to look for other methods to analyze complex relationships in our data.

Although there are many different and valid ways to approach a statistical problem, today we are going to use *Information Theoretic (IT) Model Averaging*. Rather than creating a model with all possible variables and interactions, IT Model Averaging:

-   Compares mulitple competing models using information criteria

-   Ranks and weights each competing model

-   Averages a top model set to produce a final model that only include predictor variables represented in the top model set

IT Model Averaging quantifies multiple competing hypotheses and is better able to avoid over-parameterization than traditional methods using a single model. To get started, we need to create a "global model" that includes all possible predictor variables. To simplify things even further, lets only consider pairwise interactions among predictors. For this we need to use a `+` sign between variables and square the variables with `()^2`.

`model_name <- lm(dependent_variable ~ (independent_variable_1 + independent_variable_2)^2, data=dataframe_name )`

``` r
# Global model
fit_all <- lm(Trmmol_night ~ (VPD_N + TAIR_N + Soil_moisture + Fgroup)^2, data=phys_data)
```

**IT Model Averaging** requires the following packages: `arm`: Includes the `standardize()` function that standardizes the input variables `MuMIn`: The `dredge()` function creates a full submodel set, the `get.models()` function creates a top model set, and `model.avg()` creates the average model and `importance()` calculates relative importance. Let's install and load these packages before we begin:

``` r
# Install packages
install.packages("arm")
install.packages("MuMIn")
```

``` r
# Load packages
library(arm)
library(MuMIn)
```

Before we start using these functions, let's take a look at the package descriptions for [arm](https://cran.r-project.org/web/packages/arm/arm.pdf) and [MuMIn](https://cran.r-project.org/web/packages/MuMIn/MuMIn.pdf)

**Note:** When reading package descriptions, it is important to:

-   Read the overall package description. This will give you a good overall idea of what this package does, and if it would be useful for you.

-   Identify particular functions of interest. You don't necessarily need to read the documentation for all of the functions within a package (typically, you'll only use a few functions).

-   For individual functions, read through the basic description, usage, argument descriptions, details / notes, and examples. This will tell you what syntax to use and what the syntax means.

-   You can access package descriptions online (google search), from the CRAN website, or by using the `help()` function in R.

First, let's standardize our input variables with the `standardize()` function in the `arm` package. `standardize()` rescales numeric variables that take on more than two values to have a mean of 0 and a standard deviation of 0.5. To do this, we just need to specify the object to standardize (our global model, `fit_all`):

``` r
# Standardize the global model
stdz.model<-standardize(fit_all)
summary(stdz.model)
```

Next, we create the full submodel set with the `dredge()` function in the `MuMIn` package by specifying the object that `dredge()` will evaluate (our standardized model, `stdz.model`). We also need to change the default "na.omit" to prevent models from being fitted to different datasets in case of missing values using `options(na.action=na.fail)`:

``` r
options(na.action=na.fail) 
model.set<-dredge(stdz.model)
```

The `get.models()` function will then create a top model set. First, we need to specify the object that `get.models` will evaluate (our model set, `model.set`), and then we need to specify the subset of models to include all models within 4AICcs with `subset=delta<4`:

``` r
top.models<-get.models(model.set, subset=delta<4)
top.models
```

Finally, we'll use the `model.avg()` function to create our average model and calculates relative importance. We need to specify the object that `model.avg()` will evaluate (in this case our top model set, `top.models`):

``` r
average_model<-model.avg(top.models)
```

To check out our final average model, use the `summary()` function:

``` r
summary(average_model)
```

    ## 
    ## Call:
    ## model.avg(object = top.models)
    ## 
    ## Component model call: 
    ## lm(formula = Trmmol_night ~ <18 unique rhs>, data = phys_data)
    ## 
    ## Component models: 
    ##                    df  logLik   AICc delta weight
    ## 1/2/4/5/7          10 -113.11 247.02  0.00   0.13
    ## 1/2/3/4/5/6        11 -112.10 247.16  0.14   0.12
    ## 1/2/3/4/5/6/8/9    13 -110.10 247.54  0.52   0.10
    ## 1/2/4/5/7/9        11 -112.36 247.70  0.68   0.09
    ## 1/2/3/4/5/6/9      12 -111.29 247.73  0.71   0.09
    ## 1/2/3/4/5/6/10     12 -111.77 248.69  1.67   0.06
    ## 1/2/3/4/5/6/8/9/10 14 -109.70 248.97  1.95   0.05
    ## 1/2/3/4/5/6/8      12 -111.94 249.04  2.02   0.05
    ## 1/2/3/4/5/7        11 -113.10 249.17  2.15   0.04
    ## 1/2/4/5             8 -116.33 249.19  2.17   0.04
    ## 1/2/4/7             8 -116.45 249.42  2.40   0.04
    ## 1/2/3/4/5/7/8/9    13 -111.15 249.65  2.63   0.03
    ## 1/2/3/4/5/7/9      12 -112.29 249.73  2.72   0.03
    ## 1/2/3/4/5/6/9/10   13 -111.20 249.74  2.72   0.03
    ## 1/2/4/5/9           9 -115.60 249.86  2.85   0.03
    ## 1/2/4/7/9           9 -115.74 250.14  3.12   0.03
    ## 1/2/3/4/5/7/10     12 -112.77 250.69  3.67   0.02
    ## 1/2/3/4/5/6/8/10   13 -111.74 250.82  3.80   0.02
    ## 
    ## Term codes: 
    ##                   Fgroup          z.Soil_moisture                 z.TAIR_N 
    ##                        1                        2                        3 
    ##                  z.VPD_N   Fgroup:z.Soil_moisture          Fgroup:z.TAIR_N 
    ##                        4                        5                        6 
    ##           Fgroup:z.VPD_N z.Soil_moisture:z.TAIR_N  z.Soil_moisture:z.VPD_N 
    ##                        7                        8                        9 
    ##         z.TAIR_N:z.VPD_N 
    ##                       10 
    ## 
    ## Model-averaged coefficients:  
    ## (full average) 
    ##                             Estimate Std. Error Adjusted SE z value
    ## (Intercept)                  0.47527    0.04821     0.04840   9.819
    ## Fgroupgrass                  0.07570    0.05597     0.05622   1.346
    ## Fgroupwoody                 -0.03641    0.05564     0.05589   0.652
    ## z.Soil_moisture             -0.05090    0.09857     0.09890   0.515
    ## z.VPD_N                     -0.16700    0.11966     0.11998   1.392
    ## Fgroupgrass:z.Soil_moisture  0.30516    0.13974     0.14012   2.178
    ## Fgroupwoody:z.Soil_moisture  0.16574    0.11587     0.11631   1.425
    ## Fgroupgrass:z.VPD_N         -0.10090    0.13993     0.14010   0.720
    ## Fgroupwoody:z.VPD_N         -0.01024    0.07355     0.07387   0.139
    ## z.TAIR_N                     0.09175    0.13362     0.13391   0.685
    ## Fgroupgrass:z.TAIR_N        -0.14907    0.16715     0.16732   0.891
    ## Fgroupwoody:z.TAIR_N        -0.02857    0.08556     0.08590   0.333
    ## z.Soil_moisture:z.TAIR_N    -0.05984    0.16619     0.16645   0.360
    ## z.Soil_moisture:z.VPD_N      0.12634    0.21825     0.21857   0.578
    ## z.TAIR_N:z.VPD_N            -0.02165    0.08572     0.08598   0.252
    ##                             Pr(>|z|)    
    ## (Intercept)                   <2e-16 ***
    ## Fgroupgrass                   0.1782    
    ## Fgroupwoody                   0.5147    
    ## z.Soil_moisture               0.6068    
    ## z.VPD_N                       0.1640    
    ## Fgroupgrass:z.Soil_moisture   0.0294 *  
    ## Fgroupwoody:z.Soil_moisture   0.1542    
    ## Fgroupgrass:z.VPD_N           0.4714    
    ## Fgroupwoody:z.VPD_N           0.8897    
    ## z.TAIR_N                      0.4933    
    ## Fgroupgrass:z.TAIR_N          0.3730    
    ## Fgroupwoody:z.TAIR_N          0.7394    
    ## z.Soil_moisture:z.TAIR_N      0.7192    
    ## z.Soil_moisture:z.VPD_N       0.5632    
    ## z.TAIR_N:z.VPD_N              0.8012    
    ##  
    ## (conditional average) 
    ##                             Estimate Std. Error Adjusted SE z value
    ## (Intercept)                  0.47527    0.04821     0.04840   9.819
    ## Fgroupgrass                  0.07570    0.05597     0.05622   1.346
    ## Fgroupwoody                 -0.03641    0.05564     0.05589   0.652
    ## z.Soil_moisture             -0.05090    0.09857     0.09890   0.515
    ## z.VPD_N                     -0.16700    0.11966     0.11998   1.392
    ## Fgroupgrass:z.Soil_moisture  0.32655    0.11794     0.11843   2.757
    ## Fgroupwoody:z.Soil_moisture  0.17735    0.11094     0.11143   1.592
    ## Fgroupgrass:z.VPD_N         -0.24253    0.11276     0.11326   2.141
    ## Fgroupwoody:z.VPD_N         -0.02462    0.11247     0.11296   0.218
    ## z.TAIR_N                     0.14306    0.14318     0.14360   0.996
    ## Fgroupgrass:z.TAIR_N        -0.29235    0.11359     0.11410   2.562
    ## Fgroupwoody:z.TAIR_N        -0.05603    0.11321     0.11372   0.493
    ## z.Soil_moisture:z.TAIR_N    -0.24222    0.26005     0.26071   0.929
    ## z.Soil_moisture:z.VPD_N      0.26019    0.25154     0.25210   1.032
    ## z.TAIR_N:z.VPD_N            -0.12277    0.17103     0.17177   0.715
    ##                             Pr(>|z|)    
    ## (Intercept)                  < 2e-16 ***
    ## Fgroupgrass                  0.17815    
    ## Fgroupwoody                  0.51470    
    ## z.Soil_moisture              0.60678    
    ## z.VPD_N                      0.16397    
    ## Fgroupgrass:z.Soil_moisture  0.00583 ** 
    ## Fgroupwoody:z.Soil_moisture  0.11148    
    ## Fgroupgrass:z.VPD_N          0.03224 *  
    ## Fgroupwoody:z.VPD_N          0.82747    
    ## z.TAIR_N                     0.31913    
    ## Fgroupgrass:z.TAIR_N         0.01040 *  
    ## Fgroupwoody:z.TAIR_N         0.62222    
    ## z.Soil_moisture:z.TAIR_N     0.35285    
    ## z.Soil_moisture:z.VPD_N      0.30203    
    ## z.TAIR_N:z.VPD_N             0.47477    
    ## ---
    ## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

This is a lot of information! We can see which component models were chosen as the top model set and then averaged, as well as their associated ranking information. We can also see the model-averaged coefficients for both the full average model and conditional average model.

The *conditional average* only averages over the models where the parameter appears. Conversely, the *full average* assumes that a variable is included in every model, but in some models the corresponding coefficient (and its respective variance) is set to zero. Unlike the *conditional average*, the *full average* does not bias the value away from zero.

We can also check out the relative importance of each factor within the model with the `importance()` function. Relative importance is a unitless metric ranging from 0 (doesn't contribute to the model at all) to 1 (contributes heavily to the model). This function will also give use the number of models within the top model set that contain each factor.

``` r
importance(average_model)
```

    ##                      Fgroup z.Soil_moisture z.VPD_N Fgroup:z.Soil_moisture
    ## Sum of weights:      1.00   1.00            1.00    0.93                  
    ## N containing models:   18     18              18      16                  
    ##                      z.TAIR_N Fgroup:z.TAIR_N z.Soil_moisture:z.VPD_N
    ## Sum of weights:      0.64     0.51            0.49                   
    ## N containing models:   12        8               9                   
    ##                      Fgroup:z.VPD_N z.Soil_moisture:z.TAIR_N
    ## Sum of weights:      0.42           0.25                    
    ## N containing models:    8              5                    
    ##                      z.TAIR_N:z.VPD_N
    ## Sum of weights:      0.18            
    ## N containing models:    5

> ### <font color="grey">Challenge 4</font>
>
> Using IT Model Averaging, create a model that tests for the effects of four factors on either transpiration or stomatal conductance. Then, create a plot that best illustrates the main finding of your top model. Ultimately, your results should be able to address one of these questions:
>
> -   What environmental variables drive nocturnal transpiration / stomatal conductance, and do these differ from the drivers of daytime transpiration / stomatal conductance?
> -   Are nocturnal transpiration and stomatal conductance associated with daytime physiological processes?
