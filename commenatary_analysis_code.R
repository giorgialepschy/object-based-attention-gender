rm(list=ls())

# Loading libraries -------------------------------------------------------
# lme4
if (!require("lme4", character.only = TRUE)) {
  install.packages("lme4")
  library("lme4")
}

# osfr
if (!require("osfr", character.only = TRUE)) {
  install.packages("osfr")
  library("osfr")
}


# Download file -----------------------------------------------------------

# Retrieve the file information using its 5-character ID
file_info <- osf_retrieve_file("v7der") 

# Download the file
file_downloaded <- osf_download(file_info, path = tempdir(), conflicts = "overwrite")

# Read the  downloaded file
dati <- read.csv(file_downloaded$local_path, sep = ";")


# Data cleaning -----------------------------------------------------------

# Initial inspection of the original dataset structure
str(dati)

# Data conversion to factors/numerics 
dati$id        <- as.factor(dati$id)
dati$group     <- as.factor(dati$group)
dati$condition <- as.factor(dati$condition)
dati$Stmulus   <- as.factor(dati$Stmulus)   
dati$sex       <- as.factor(dati$sex)         
dati$age       <- as.numeric(dati$age)
dati$Target.Detection.Time <- as.numeric(dati$Target.Detection.Time)

# Set ASD as the reference baseline level for group
dati$group <- relevel(dati$group, ref = "ASD")
# Set VAL as the reference baseline level for condition
dati$condition <- factor(dati$condition, levels = c("VAL", "ISO", "IDO"))

# Generate contingency tables to check for typos or structural distribution issues
table(dati$group, useNA = "ifany")
table(dati$condition, useNA = "ifany")
table(dati$Stmulus, useNA = "ifany")
table(dati$sex, useNA = "ifany")
table(dati$age, useNA = "ifany")

# Identify and exclude participants with missing age values (NA)
table(is.na(dati$age), dati$id) # id=29
dati = dati[!is.na(dati$age), ]

# Binning age (originally in months) into classes: 
# 3-5 (36-60 months)| 5-8 (60-96 months)| 8-12 (96-144 months)| 12+ (>144 months)
dati$age_class <- ifelse(dati$age >= 36 & dati$age < 60, "3-5",
                         ifelse(dati$age >= 60 & dati$age < 96, "5-8",
                                ifelse(dati$age >= 96 & dati$age < 144, "8-12",
                                       ifelse(dati$age >= 144, "12+", NA))))

# Convert the new column into a ordered factor
dati$age_class <- factor(dati$age_class, levels = c("3-5", "5-8", "8-12", "12+"))

# Subset: select only cases where Stimulus is equal to "F"
dati <- dati[dati$Stmulus == "F" , ]



# Exploratory Analysis ----------------------------------------------------

### Univariate ###

# Create a subject-level dataset (1 row per subject)
unique_id <- dati[!duplicated(dati$id), ]

# Total number of unique subjects remaining in the subset
length(unique(dati$id)) # 29 subjects
# Sex
table(dati$sex)
table(unique_id$sex)
# Condition
table(dati$condition)
#Group
table(dati$group)
table(unique_id$group)
#Age
table(dati$age_class)
table(unique_id$age_class)
table(dati$age)
table(unique_id$age)

# Histogram and density of Target Detection Time
hist(dati$Target.Detection.Time, probability = TRUE, breaks = 30,
     col = "lightblue", border = "black",
     main = "Histogram and density of Target Detection Time",
     xlab = "Target Detection Time", ylab = "Density")
lines(density(dati$Target.Detection.Time, na.rm = TRUE), col = "red", lwd = 2)

# Histogram and density of age
hist(unique_id$age, probability = TRUE, breaks = 10,
     col = "lightblue", border = "black",
     main = "Histogram and density of age",
     xlab = "Age", ylab = "Density")
lines(density(dati$age, na.rm = TRUE), col = "red", lwd = 2)

# Target Detection Time - boxplot with overlaid jittered raw data points to flag outliers
boxplot(dati$Target.Detection.Time, col = "steelblue", 
        main = "Distribution of Target Detection Time",
        ylab = "Reaction Time (ms)", outline = FALSE)
stripchart(dati$Target.Detection.Time, method = "jitter", jitter = 0.1, 
           vertical = TRUE, add = TRUE, pch = 16, col = rgb(0, 0, 0.5, 0.3))


### Bivariate ####
# Cross-tabulations based on total row observations
table(dati$sex, dati$condition)
table(dati$sex, dati$age_class)
table(dati$sex, dati$group)
table(dati$condition, dati$group)
table(dati$condition, dati$age_class)
table(dati$group, dati$age_class)

# Tables in which a subject count as one
table(unique_id$sex, unique_id$age_class)
table(unique_id$sex, unique_id$group)
table(unique_id$group, unique_id$age_class) # only 1 cell for control

tapply(unique_id$age, unique_id$group, summary)
tapply(unique_id$age, unique_id$group, mean)
tapply(unique_id$age, unique_id$group, sd)

# Bivariate analysis of Target.Detection.Time with respect to each explanatory variable
# Condition
tapply(dati$Target.Detection.Time, dati$condition, summary)
tapply(dati$Target.Detection.Time, dati$condition, mean)
tapply(dati$Target.Detection.Time, dati$condition, sd)

# Group
tapply(dati$Target.Detection.Time, dati$group, summary)
tapply(dati$Target.Detection.Time, dati$group, mean)
tapply(dati$Target.Detection.Time, dati$group, sd)


table(dati$condition, dati$group, dati$sex)

# Multi-panel visualizations
# Boxplot by group X condition, split by sex
par(mfrow = c(1, 2)) 
for (s in c("f", "m")) {
  sub_d <- subset(dati, sex == s)
  title_sex <- ifelse(s == "f", "Females", "Males")
  boxplot(Target.Detection.Time ~ group * condition, data = sub_d,
          col = c("#F8769D", "#00BFC4"),
          outline = FALSE,
          main = paste("Object-Based Faces:", title_sex),
          xlab = "Experimental Condition", 
          ylab = "Target Detection Time (ms)",
          xaxt = "n") 
  axis(side = 1, at = c(1.5, 3.5, 5.5), labels = c("VAL", "ISO", "IDO"))
  legend("topright", 
         legend = c("ASD", "Control"), 
         fill = c("#F8769D", "#00BFC4"), 
         bty = "n",        
         cex = 0.9)        
}
par(mfrow = c(1, 1))


# Boxplot by group x condition, split across age_class and Sex
age_lvls <- levels(dati$age_class)
sex_lvls <- levels(dati$sex)
par(mfrow = c(length(age_lvls), length(sex_lvls)), mar = c(4, 3, 2, 1))
for (a in age_lvls) {
  for (s in sex_lvls) {
    sub_d <- subset(dati, age_class == a & sex == s)
    title_str <- paste("Age:", a, "| Sex:", ifelse(s == "f", "Females", "Males"))
    if (nrow(sub_d) > 0) {
      boxplot(Target.Detection.Time ~ group * condition, data = sub_d,
              col = c("#F8769D", "#00BFC4"), 
              outline = FALSE,
              main = title_str, 
              cex.main = 0.9,
              xaxt = "n") 
      axis(side = 1, at = c(1.5, 3.5, 5.5), labels = c("VAL", "ISO", "IDO"), cex.axis = 0.8)
      legend("topright", 
             legend = c("ASD", "Control"), 
             fill = c("#F8769D", "#00BFC4"), 
             bty = "n", 
             cex = 0.75) 
    } else {
      plot.new()
      title(main = paste(title_str, "(No Data)"), cex.main = 0.9)
    }
  }
}
par(mfrow = c(1, 1))

# Target Detection Time density curves paneled by sex, split by group and condition
grp_lvls <- levels(dati$group)
cnd_lvls <- levels(dati$condition)
par(mfrow = c(length(grp_lvls), length(cnd_lvls)), mar = c(4, 4, 2, 1))
for (g in grp_lvls) {
  for (c in cnd_lvls) {
    f_vals <- subset(dati, group == g & condition == c & sex == "f")$Target.Detection.Time
    m_vals <- subset(dati, group == g & condition == c & sex == "m")$Target.Detection.Time

    f_dens <- density(f_vals)
    m_dens <- density(m_vals)

    all_vals <- c(f_vals, m_vals)

    max_y <- 0.005 
    max_y <- max(max_y, max(f_dens$y))
    max_y <- max(max_y, max(m_dens$y))

    plot(0, 0, type = "n", 
         xlim = range(all_vals, na.rm = TRUE), 
         ylim = c(0, max_y * 1.20), 
         main = paste(g, "-", c), 
         xlab = "Time (ms)", 
         ylab = "Density")
    
    polygon(f_dens, col = "#e377c240", border = NA)
    lines(f_dens, col = "#e377c2", lwd = 2)
    polygon(m_dens, col = "#1f77b440", border = NA)
    lines(m_dens, col = "#1f77b4", lwd = 2)
    
    legend("topright", 
           legend = c("Females", "Males"), 
           fill = c("#e377c240", "#1f77b440"), 
           border = c("#e377c2", "#1f77b4"), 
           bty = "n", 
           cex = 0.8)
    }
} 
par(mfrow = c(1, 1))



# Models ------------------------------------------------------------------

# GLMM: Generalized Linear Mixed Effects Models
# Models: random effects only with age_class (1|id) and (condition|id)
# Models with only random intercecept (1|id)

# Target.Detection.Time ~ sex 
mod1_i <- glmer(Target.Detection.Time ~ sex + (1 | id), 
                 data = dati, family = Gamma(link = "log"))

# Target.Detection.Time ~ age_class + sex 
mod2_i <- glmer(Target.Detection.Time ~ age_class + sex + (1 | id), 
                 data = dati, family = Gamma(link = "log"))

# Target.Detection.Time ~ condition + age_class + sex
mod3_i <- glmer(Target.Detection.Time ~ condition + age_class + sex + (1 | id), 
                 data = dati, family = Gamma(link = "log"))

# Target.Detection.Time ~ condition + group + sex + age_class 
mod4_i <- glmer(Target.Detection.Time ~ condition + group + sex + age_class + (1 | id), 
                 data = dati, family = Gamma(link = "log"))

# Target.Detection.Time ~ condition * group + sex + age_class  (interaction group-condition)
mod5_i <- glmer(Target.Detection.Time ~ condition * group + sex + age_class + (1 | id), 
                 data = dati, family = Gamma(link = "log"))

# Target.Detection.Time ~ condition * group * sex + age_class   interaction group-condition-sex) 
mod6_i <- glmer(Target.Detection.Time ~ condition * group * sex + age_class + (1 | id), 
                 data = dati, family = Gamma(link = "log"), control = glmerControl(optimizer = "bobyqa", 
                                                                                   optCtrl = list(maxfun = 1e5)))

# Target.Detection.Time ~ condition * group * age_class + sex   (interaction group-condition-age_class)
mod7_i <- glmer(Target.Detection.Time ~ condition * group * age_class + sex + (1 | id), 
                 data = dati, family = Gamma(link = "log"))

# Target.Detection.Time ~ condition * group + sex * age_class   (interaction group-condition and sex-age_class)
mod8_i <- glmer(Target.Detection.Time ~ condition * group + sex * age_class + (1 | id), 
                 data = dati, family = Gamma(link = "log"), control = glmerControl(optimizer = "bobyqa", 
                                                                                   optCtrl = list(maxfun = 1e5)))
# Compare AIC
AIC(mod1_i, mod2_i, mod3_i, mod4_i, mod5_i, mod6_i, mod7_i, mod8_i)
BIC(mod1_i, mod2_i, mod3_i, mod4_i, mod5_i, mod6_i, mod7_i, mod8_i)
# Best: mod5_i

# Summary of the best
summary(mod5_i)

# Models with only random intercecept and slope (condition|id)

# Target.Detection.Time ~ sex 
mod1_ci <- glmer(Target.Detection.Time ~ sex + (condition | id), 
                  data = dati, family = Gamma(link = "log"))

# Target.Detection.Time ~ age_class + sex
mod2_ci <- glmer(Target.Detection.Time ~ age_class + sex + (condition | id), 
                  data = dati, family = Gamma(link = "log"), control = glmerControl(optimizer = "bobyqa", 
                                                                                    optCtrl = list(maxfun = 1e5)))

# Target.Detection.Time ~ condition + age_class + sex PROBLEMA CONVERGENZA
mod3_ci <- glmer(Target.Detection.Time ~ condition + age_class + sex + (condition | id), 
                  data = dati, family = Gamma(link = "log"), control = glmerControl(optimizer = "bobyqa", 
                                                                                    optCtrl = list(maxfun = 1e5)))

# Target.Detection.Time ~ condition + group + sex + age_class
mod4_ci <- glmer(Target.Detection.Time ~ condition + group + sex + age_class + (condition | id), 
                  data = dati, family = Gamma(link = "log"), control = glmerControl(optimizer = "bobyqa", 
                                                                                    optCtrl = list(maxfun = 1e5)))

# Target.Detection.Time ~ condition * group + sex + age_class  (interaction group-condition)
mod5_ci <- glmer(Target.Detection.Time ~ condition * group + sex + age_class + (condition | id), 
                  data = dati, family = Gamma(link = "log"), control = glmerControl(optimizer = "bobyqa", 
                                                                                    optCtrl = list(maxfun = 1e5)))

# Target.Detection.Time ~ condition * group * sex + age_class   interaction group-condition-sex) 
mod6_ci <- glmer(Target.Detection.Time ~ condition * group * sex + age_class + (condition | id), 
                  data = dati, family = Gamma(link = "log"), control = glmerControl(optimizer = "bobyqa", 
                                                                                    optCtrl = list(maxfun = 1e5)))

# Target.Detection.Time ~ condition * group * age_class + sex   (interaction group-condition-age_class) PROBLEMA CONVERGENZA
mod7_ci <- glmer(Target.Detection.Time ~ condition * group * age_class + sex + (condition | id), 
                  data = dati, family = Gamma(link = "log"), control = glmerControl(optimizer = "bobyqa", 
                                                                                    optCtrl = list(maxfun = 1e5)))

# Target.Detection.Time ~ condition * group + sex * age_class   (interaction group-condition and sex-age_class)
mod8_ci <- glmer(Target.Detection.Time ~ condition * group + sex * age_class + (condition | id), 
                  data = dati, family = Gamma(link = "log"), control = glmerControl(optimizer = "bobyqa", 
                                                                                    optCtrl = list(maxfun = 1e5)))

# Compare AIC
AIC(mod1_ci, mod2_ci, mod3_ci, mod4_ci, mod5_ci, mod6_ci, mod7_ci, mod8_ci)
BIC(mod1_ci, mod2_ci, mod3_ci, mod4_ci, mod5_ci, mod6_ci, mod7_ci, mod8_ci)
# Best: mod5_ci

# Summary of the best
summary(mod5_ci)

# Compare the best two
AIC(mod5_i)
AIC(mod5_ci) # best
