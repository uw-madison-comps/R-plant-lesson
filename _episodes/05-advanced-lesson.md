---
title: 'Investigating large datasets in R'
author: "Data Carpentry Contributors"
date: "9/05/2019"
output: html_document
---

#```{r setup, include=FALSE, warning=FALSE, error=FALSE, message=FALSE}
#knitr::opts_chunk$set(echo = TRUE)
#```

###Learning Objectives

1. Explore a large dataset graphically
2. Develop simple models with `lm()`
3. Choose new packages and interpret package descriptions
4. Analyze complex models using Information Theoretic (IT) Model Averaging (`arm` and `MuMIn` packages)

###Setup
Let's begin by loading the data and packages necessary to start this lesson.

```r
# Set working directory
#setwd("/Users/Kim/Documents/UW/Data Carpentry/Plant_DC_Workshop/")

# Load packages
library(ggplot2)

# Load data
phys_data<-read.csv("data/Physiology_Environmental_Data.csv")
```

###Exploring the dataset
In previous lessons we've worked with the plant physiology dataset from O'Keefe and Nippert 2018. As a reminder, these data were collected to address the following objectives:

1. How do nocturnal and daytime transpiration vary among coexisting grasses, forbs, and shrubs in a tallgrass prairie? 
2. What environmental variables drive nocturnal transpiration and do these differ from the drivers of daytime transpiration?
3. Are nocturnal transpiration and stomatal conductance associated with daytime physiological processes?

Let's use this dataset to explore the relationships between **leaf transpiration** and potential **drivers** of transpiration

**Transpiration parameters:**

1. Nocturnal transpiration (Trmmol_night)
2. Nocturnal stomatal conductance (Cond_night)
3. Daytime transpiration (Trmmol_day)
4. Daytime stomatal conductance (Cond_night)

**Potential drivers:**

1. Nocturnal vapor pressure deficit (VPD_N)
2. Nocturnal air temperature (TAIR_N)
3. Daytime vapor pressure deficit (VPD_D)
4. Daytime air temperature (TAIR_D)
5. Daily average soil moisture (Soil_moisture)
6. Predawn leaf water potential (PD)
7. Midday leaf water potential (MD)
8. Photosynthesis (Photo)
9. Plant functional group (Fgroup)

>###<font color="grey">Challenge 1</font>
>
>Use ggplot to create a scatterplot of the relationship between a transpiration parameter and a potential driver.
>
> > ###<font color="grey">Example Solution to Challenge 1</font>
> >
> >```r
> ># Nocturnal transpiration vs. nocturnal VPD
> >ggplot(phys_data, aes(x=VPD_N, y=Trmmol_night)) +
> >  geom_point() +
> >  xlab("Nocturnal VPD (kPa)") +
> >  ylab(expression(paste(italic('E')[night]," ", "(mmol"," ",m^-2,s^-1,")"))) +
> >  theme_bw() 
> >```
> >
> >![plot of chunk unnamed-chunk-2](figure/unnamed-chunk-2-1.png)

>###<font color="grey">Challenge 2</font>
>
>How does this relationship differ between the different plant functional groups (grass, forb, woody)?
>
> > ###<font color="grey">Example Solution to Challenge 2</font>
> >
> >```r
> >ggplot(phys_data, aes(x=VPD_N, y=Trmmol_night, color=Fgroup)) +
> >  geom_point() +
> >  xlab("Nocturnal VPD") +
> >  ylab(expression(paste(italic('E')[night]," ", "(mmol"," ",m^-2,s^-1,")"))) +
> >  theme_bw()
> >```
> >
> >![plot of chunk unnamed-chunk-3](figure/unnamed-chunk-3-1.png)

### Using a Simple Model
As you can see, plotting our data can be informative, but it doesn't necessarily tell us much about the statistical relationships between variables. We are going to start investigate the relationships between these data by using a simple **linear regression.** Linear regression is used to predict the value of a dependent variable **Y** based on one or more input independent (predictor) variables **X**, with the following basic equation:

 $y  = \beta_1 + \beta_2 X + \epsilon$
 
In this equation, $y$ is the dependent variable, $\beta_1$ is the intercept, $\beta_2$ is the slope, and $\epsilon$ is the error term.

To build this equation in R, we'll use the `lm()` function. `lm()` is included in the base R package, so you don't have to load it into your workspace to use. `lm()` takes three basic arguments: the dependent variable, the independent variable, and the dataframe from which the data is used. The model is specified using a particular format, and is typically assigned to an object:

`model_name <- lm(dependent_variable ~ independent_variable, data=dataframe_name )`

We can then view our model output with the `summary()` function. 


```r
fit_vpd <- lm(Trmmol_night ~ VPD_N, data=phys_data)
summary(fit_vpd)
```

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
## Multiple R-squared:  0.06359,	Adjusted R-squared:  0.06028 
## F-statistic: 19.22 on 1 and 283 DF,  p-value: 1.646e-05
```

From this output, we're usually interested in the following results:

- `(Intercept) Estimate`: This is the y-intercept of our regression

- `VPD_N Estimate`: This is the slope of our regression

- `Std. Error`: The standard error for our intercept and slope estimates

- `Pr(>|t|)`: These are the p-values associated with the intercept and our independent variable

- `Multiple R-squared`: The $r^2$ value that indicates model fit

- `F-statistic` and `p-value`: Indicate overall model significance

### More Complex Models
Now that we know how to test for the effect of one variable on the dependent variable, let's test for the effect of *multiple* variables on the dependent variable. You can add additional variables to your model by using the following formula:

`model_name <- lm(dependent_variable ~ independent_variable_1 * independent_variable_2, data=dataframe_name )`

Note that adding an asterisk `*` between the two independent variables indicates that we will be testing for the effects of independent variable 1, independent variable 2, and their interaction on the dependent variable. If we were not interested in testing for interactions among independent variables, we could replace the `*` with a `+` sign.

>###<font color="grey">Challenge 3</font>
>
>Create a model that tests for the effects of four factors on either transpiration or stomatal conductance.
>
> > ###<font color="grey">Example Solution to Challenge 3</font>
> >
> >```r
> >fit_all <- lm(Trmmol_night ~ VPD_N * TAIR_N * Soil_moisture * Fgroup, data=phys_data)
> >summary(fit_all)
> >```

### How to Work with Complex Models: IT Model Averaging
As you can see, we have a lot of potential interactions with just four independent variables in our model! This becomes incredibly difficult to interpret, so we often have to look for other methods to analyze complex relationships in our data.

Although there are many different and valid ways to approach a statistical problem, today we are going to use *Information Theoretic (IT) Model Averaging*. Rather than creating a model with all possible variables and interactions, IT Model Averaging:

- Compares mulitple competing models using information criteria

- Ranks and weights each competing model

- Averages a top model set to produce a final model that only include predictor variables represented in the top model set

IT Model Averaging quantifies multiple competing hypotheses and is better able to avoid over-parameterization than traditional methods using a single model. To get started, we need to create a "global model" that includes all possible predictor variables. To simplify things even further, lets only consider pairwise interactions among predictors. For this we need to use a `+` sign between variables and square the variables with `()^2`.

`model_name <- lm(dependent_variable ~ (independent_variable_1 + independent_variable_2)^2, data=dataframe_name )`


```r
# Global model
fit_all <- lm(Trmmol_night ~ (VPD_N + TAIR_N + Soil_moisture + Fgroup)^2, data=phys_data)
```

**IT Model Averaging** requires the following packages:
`arm`: Includes the `standardize()` function that standardizes the input variables
`MuMIn`: The `dredge()` function creates a full submodel set, the `get.models()` function creates a top model set, and `model.avg()` creates the average model and `importance()` calculates relative importance. Let's install and load these packages before we begin:


```r
# Install packages
install.packages("arm")
install.packages("MuMIn")
```


```r
# Load packages
library(arm)
library(MuMIn)
```
Before we start using these functions, let's take a look at the package descriptions for [arm](https://cran.r-project.org/web/packages/arm/arm.pdf) and [MuMIn](https://cran.r-project.org/web/packages/MuMIn/MuMIn.pdf)

**Note:** When reading package descriptions, it is important to:

- Read the overall package description. This will give you a good overall idea of what this package does, and if it would be useful for you.

- Identify particular functions of interest. You don't necessarily need to read the documentation for all of the functions within a package (typically, you'll only use a few functions).

- For individual functions, read through the basic description, usage, argument descriptions, details / notes, and examples. This will tell you what syntax to use and what the syntax means. 

- You can access package descriptions online (google search), from the CRAN website, or by using the `help()` function in R.

First, let's standardize our input variables with the `standardize()` function in the `arm` package. `standardize()` rescales numeric variables that take on more than two values to have a mean of 0 and a standard deviation of 0.5. To do this, we just need to specify the object to standardize (our global model, `fit_all`):












