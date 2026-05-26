# AsPredicted Registration: Object-Based Attention and Gender Differences in an ASD Cohort

## 1. Have any data been collected for this study already?
Yes, at least some data have been collected for this study already. 

Note: This study is a commentary and secondary re-analysis of an existing open dataset available on OSF ([OSF Original Study](https://osf.io/jqz3p/overview)). The data were originally collected by Valenza and Calignano. However, the specific hypotheses, variables, and model configurations proposed in this pre-registration have not yet been observed, tested, or analyzed by our team.

## 2. What's the main question being asked or hypothesis being tested in this study?
We investigate whether there are biological sex differences (Male vs. Female) in object-based attention speed, isolated strictly through face-processing trials within an ASD and neurotypical cohort.

- **Research Question:** Do males and females exhibit a difference in their object-based processing speed during face stimuli presentation, after accounting for individual characteristics such as age and ASD diagnosis?
- **Hypothesis:** Males will exhibit a significantly longer processing time (slower reaction times) in object-based face processing compared to females.

## 3. Describe the key dependent variable(s) specifying how they will be measured.
The key dependent variable is **Reaction Time (RT)** measured in milliseconds. 

To isolate object-based attention mechanisms specifically which rely on coherent structures we will restrict our dependent variable exclusively to trials presenting **Face stimuli (Stimulus F)**. Trials presenting scrambled faces are excluded from the main analysis as they prime space-based attention dynamics rather than object-based ones.

## 4. How many and which conditions will participants be assigned to?
This is an observational re-analysis of a predetermined dataset. Participants are grouped by:

1.  **Sex (Primary Predictor):** Male vs. Female.
2.  **Diagnosis (Clinical Covariate):** ASD Cases vs. Neurotypical Controls.
3.  **Attentional Condition:** Within the face trials, all three cueing conditions; Valid (Val), Invalid Different Object (Ido), and Invalid Same Object (Iso) will be retained in the model.

## 5. Specify exactly which analyses you will conduct to examine the main question/hypothesis.
We will carry out exploratory analyses, in particular we will observe the sampling distribution of Reaction Time, considering it separately by gender and condition.
We will use a **generalized linear mixed-effects model (GLMM)** to account for repeated measurements within subjects to model Reaction Time (RT) during face trials.

GLMMs allow us to model heteroscedasticity and positive skewness of Reaction Time. Specifically, GLMMs with the Gamma family and a logarithmic link function have been implemented in similar developmental studies to account for eye-tracking measurements. In the analysis, we will always consider models with the variable sex to assess its effect.  We will classify the age variable into classes, specifically considering the ranges 36-60, 60-96, 96-144, and >144 months

We will evaluate the following model formulas (expressed in lme4 syntax). Every formula will be tested under two random effects structures: (a) Random Intercept Only (1 | id) and (b) Random Intercept and Slope (Condition | id).

<pre>
M1: RT ~ Sex
M2: RT ~ Sex + Age_class
M3: RT ~ Sex + Age_class + Condition`
M4: RT ~ Sex + Age_class + Condition + Group
M5: RT ~ Sex + Age_class + Condition * Group
M6: RT ~ Age_class + Condition * Group * Sex
M7: RT ~ Sex + Age_class * Condition * Group
M8: RT ~ Sex * Age_class + Condition * Group
</pre>

**Model Selection Strategy:**
We will use the Akaike Information Criterion (AIC) and the Bayesian Information Criterion (BIC), that compare all models simultaneously, using them as a goodness-of-fit indicators. Given the different AIC and BIC values ​​for different models, the one with the lowest AIC or BIC value is preferred. 

**Justification for keeping the three conditions (Val, Ido, Iso)**: Retaining all three conditions is crucial to capture the broad latent variable of "processing/processing speed" (the overall dynamic of moving attention within or outside a complex object). If we restricted the analysis only to Val trials, we would change the definition of our latent construct from "processing speed" to "speed of attentional engagement/maintenance" on a fixed point. Therefore, keeping the three conditions is necessary to properly evaluate overall object-based attention.

## 6. Any secondary analyses?
Descriptive univariant exploration of individual variables will be performed prior to modeling to inspect data distribution, look for outliers, and assess missingness patterns.

## 7. How many observations will be collected or what will determine the sample size?
The sample size is entirely predetermined by the existing dataset available in the original repository ([OSF Original Study](https://osf.io/jqz3p/overview)). We will inherit the maximum number of participants and observations available in that dataset.
Our target sample size for the final analysis will be strictly determined by adhering to the data cleaning and inclusion criteria established in the reference study. Therefore, the final number of observations will be the total available pool minus any mandatory exclusions outlined in Section 8.


## 8. Anything else you would like to pre-register? (e.g., data exclusions, variables collected for exploratory purposes, unusual analyses planned?)
- **Missing Data:** Any participant with missing values (NA) in key demographic covariates (Age, Sex, Diagnosis) will be removed via listwise deletion to ensure a complete case analysis matching the original paper's final cohort.
- **Data Reduction:** All trials involving non-face stimuli (Scrambled Faces) will be systematically filtered out prior to running the GLMMs.