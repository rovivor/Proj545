library(plyr)

LFS97 <- read.csv(file="97.csv")
LFS98 <- read.csv(file="98.csv")
LFS99 <- read.csv(file="99.csv")
LFS00 <- read.csv(file="00.csv")
LFS01 <- read.csv(file="01.csv")
LFS02 <- read.csv(file="02.csv")
LFS03 <- read.csv(file="03.csv")
LFS04 <- read.csv(file="04.csv")
LFS05 <- read.csv(file="05.csv")
LFS06 <- read.csv(file="06.csv")
LFS07 <- read.csv(file="07.csv")
LFS08 <- read.csv(file="08.csv")
LFS09 <- read.csv(file="09.csv")
LFS10 <- read.csv(file="10.csv")
LFS11 <- read.csv(file="11.csv")
LFS12 <- read.csv(file="12.csv")
LFS13 <- read.csv(file="13.csv")

## Making a list and tracking which columns to keep
data <- list(LFS97, LFS98, LFS99, LFS00, LFS01, LFS02, LFS03, LFS04, LFS05, LFS06, LFS07, LFS08, LFS09, LFS10, LFS11, LFS12, LFS13)
columnKeep <- c("SURVYEAR", "LFSSTAT", "PROV", "AGE_12", "SEX", "EDUC90", "TENURE", "UNION", "HRLYEARN", "UHRSMAIN")
keep <- function(x) {
  x<-subset(x, select = columnKeep)
  return(x)
}
LFSraw <- ldply(data, keep)

## Dropping every province except BC, AB, ON, and QC and people not in the labour force
provinces <- c("Manitoba", "New Brunsw", "Newfoundla", "Nova Scoti", "Prince Edw", "Saskatchew")
LFS <- droplevels(subset(LFSraw, !(PROV %in% provinces) & LFSSTAT != "Not in lab"))

## Creating a random sample of 1000 observations for each year.
set.seed(123)
random <- function(x){
  samples<-sample(1:nrow(x), 1000)
  set <- x[samples,]
}

LFS<-ddply(LFS, ~SURVYEAR, random)

head(LFS)

## Making three functions to change some of the values for education, union, province, and age. Allowing them to be more easily read.

newEducation <- function(x){
  if(x=="0 to 8 yea" | x=="Some secon")
    return("HS Dropout")
  if(x=="Grade 11 t")
    return("HS Grad")
  if(x=="Post secon" | x=="Some post")
    return("Some PS")
  else
    return("Ba or More")
}

newUnion <- function(x){
  if(x=="Union memb")
    return("Yes")
  if(x=="Not member")
    return("No")
  else
    return("NA")
}

newProv <- function(x){
  if(x=="British Co")
    return("BC")
  if(x=="Alberta")
    return("AB")
  if(x=="Ontario")
    return("ON")
  else
    return("QC")
}

newAge <- function(x){
  if(x=="15 to 19" | x=="20 to 24" | x=="25 to 29")
    return("15-29")
  if(x=="30 to 34" | x=="35 to 39" | x=="40 to 44")
    return("30-44")
  if(x=="45 to 49" | x=="50 to 54" | x=="55 to 59")
    return("45-59")
  else
    return("60+")
}

## Create the new variables
LFS$EDUC <- as.factor(sapply(LFS$EDUC90, newEducation))
LFS$PROV <- as.factor(sapply(LFS$PROV, newProv))
LFS$UNION<- as.factor(sapply(LFS$UNION, newUnion))
LFS$AGE <- as.factor(sapply(LFS$AGE_12, newAge))

#Changing a column name to more understandable
colnames(LFS)[colnames(LFS) == "UHRSMAIN"] <- "HOURS"

#Adding an annual wage column
LFS$ANNUAL_WAGE <- LFS$HRLYEARN * LFS$HOURS * 52

# Dropping 'EDUC90' and 'AGE_12' columns
LFS<-LFS[,!names(LFS) %in% c("EDUC90", "AGE_12")]

str(LFS)

write.table(LFS, "LFS.csv", quote=FALSE, sep="\t", row.names=FALSE)