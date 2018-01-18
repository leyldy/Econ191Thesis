##### Econ 191 Data Cleaning from HUD #####
##### Author: Jong Ha Lee #####

library("readxl")
library(dplyr)
setwd("~/Desktop/School/ECON 191")


##### PRELIMINARY CLEANING AND JOINING DATA #####
clean_HIC <- function(filename) {
  sheets <- readxl::excel_sheets(filename)
  sheets <- sheets[-length(sheets)]
  for (i in 1:length(sheets)) {
    cat("Reading sheet", sheets[i], "...\n")
    if (i == 1) {
      aggData <- readxl::read_excel(filename, sheet = sheets[i])
      aggData$Year <- sheets[i]
      aggData[] <- lapply(aggData, as.character)
      aggData <- data.frame(lapply(aggData, function(x) {
        gsub("^\\.$", NA, x)
      }))
    } else {
      newData <- readxl::read_excel(filename, sheet = sheets[i])
      newData[] <- lapply(newData, as.character)
      newData$Year <- sheets[i]
      newData <- data.frame(lapply(newData, function(x) {
          as.character(gsub("^\\.$", NA, x))
      }))
      aggData[] <- lapply(aggData, as.character)
      aggData <- bind_rows(aggData, newData)
    }
  }
  aggData[] <- lapply(aggData, as.character)
  aggData[is.na(aggData)] <- ""
  return(aggData)
}

clean_PIT <- function(filename) {
  sheets <- readxl::excel_sheets(filename)
  sheets <- sheets[-length(sheets)]
  for (i in 1:length(sheets)) {
    cat("Reading sheet", sheets[i], "...\n")
    if (i == 1) {
      aggData <- readxl::read_excel(filename, sheet = sheets[i])
      aggData$Year <- sheets[i]
      aggData[] <- lapply(aggData, as.character)
      aggData <- data.frame(lapply(aggData, function(x) {
        gsub("\\.", NA, x)
      }))
    } else {
      newData <- readxl::read_excel(filename, sheet = sheets[i])
      colnames(newData) <- gsub(",.*", "", colnames(newData))
      newData[] <- lapply(newData, as.character)
      newData$Year <- sheets[i]
      newData[] <- lapply(newData, function(x) {
        as.character(gsub("^\\.$", NA, x))
      })
      aggData[] <- lapply(aggData, as.character)
      
      aggData <- bind_rows(aggData, newData)
    }
  }
  aggData[] <- lapply(aggData, as.character)
  aggData[is.na(aggData)] <- ""
  return(aggData)
}
aggHICdf <- clean_HIC("cleandata/2007-2016-HIC-Counts-by-State_STATA.xlsx")
aggPITdf <- clean_PIT("cleandata/2007-2016-PIT-Counts-by-State_STATA.xlsx")

###########################################################################



###########################################################################
##### Further selecting and cleaning HIC data #####
needHIC <- aggHICdf[as.numeric(aggHICdf$Year) > 2012, c("State", "Year", 
                        grep("RRH", colnames(aggHICdf), ignore.case = T, value = T), "Total.Year.Round.Beds..ES..TH..SH.", "Total.Year.Round.Beds..PSH.", "Total.Year.Round.Beds..OPH.", "Total.PSH.Beds")]


for (i in 11:18) {
  first <- as.numeric(needHIC[[i]])
  fNAInd <- is.na(first)
  first[fNAInd] <- 0
  second <- as.numeric(needHIC[[i + 18]])
  sNAInd <- is.na(second)
  second[sNAInd] <- 0
  needHIC[i] <- first + second
  needHIC[[i]][fNAInd & sNAInd] <- NA
}

test <-
  ifelse(as.numeric(needHIC$Year) != 2013,
         as.numeric(needHIC$Total.Year.Round.Beds..RRH...DEM.) + as.numeric(needHIC$Total.Year.Round.Beds..ES..TH..SH.) + as.numeric(needHIC$Total.Year.Round.Beds..PSH.) + as.numeric(needHIC$Total.Year.Round.Beds..OPH.),
         as.numeric(needHIC$Total.Year.Round.Beds..ES.TH.RRH.SH.) + as.numeric(needHIC$Total.PSH.Beds))

needHIC$totalBeds <- test
needHIC[ ,-c(1:2, 11:18, 38, 39, 40, 41)] <- NULL

###########################################################################



###########################################################################
##### Further selecting and cleaning PIT data #####
## Nothing to be done. already clean. #



write.csv(needHIC, file = "cleandata/HICClean.csv", row.names = F)
write.csv(aggPITdf, file = "cleandata/PITClean.csv", row.names = F)
