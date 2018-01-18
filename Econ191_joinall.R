# Econ19_joinall.R #

library(dplyr)
setwd("~/Desktop/School/ECON 191")

##### MIMIC dataset ######
census <- read.csv("cleandata/censusClean.csv", stringsAsFactors = F)

LF <- read.csv("cleandata/LFClean.csv", stringsAsFactors = F)
gdp <- read.csv("cleandata/gdpClean.csv", stringsAsFactors = F)
elec <- read.csv("cleandata/elecClean.csv", stringsAsFactors = F)

joined <- inner_join(LF, gdp, by = c("State.and.area" = "Area",
                                     "Year"))
joined <- rename(joined, State = State.and.area)
joined <- inner_join(joined, elec, by = c("State", "Year"))
joined$elecPerGDP <- joined$TotMilKwh / joined$realGDP

census[, c("GEO.id", "GEO.id2", "FINTYPE.id", "FINTYPE.display.label",
           "FINSRC.id", "AMOUNT", "GDP")] <- NULL
wideCensus <-
  reshape(census, 
          idvar = c("GEO.display.label", "YEAR.id"),
          timevar = c("FINSRC.display.label"),
          direction = "wide")
colnames(wideCensus) <- c("State", "Year", "pctCurrCharge", "pctTotalExp", 
                          "pctInsureExp", "pctPIR", "pctIndTax") 

joined <- inner_join(joined, wideCensus, by = c("State", "Year"))
joined[ , c(4, 8:13)] <- round(joined[ , c(4, 8:13)] * 100, 2)

scaled <- joined
scaled[ , 3:13] <- scale(scaled[ ,3:13])

write.csv(joined, file = "cleandata/MIMICData.csv", row.names = F)
write.csv(scaled, file = "cleandata/MIMICDataScaled.csv", row.names = F)

##### HIC PIC dataset (HUD) #####
HIC <- read.csv("cleandata/HICClean.csv", stringsAsFactors = F)
PIT <- read.csv("cleandata/PITClean.csv", stringsAsFactors = F)
stateAbbr <- read.csv("data/MIMIC/states.csv", stringsAsFactors = F)

HIC <- inner_join(HIC, stateAbbr, by = c("State" = "Abbreviation"))
PIT <- inner_join(PIT, stateAbbr, by = c("State" = "Abbreviation"))
HIC$State <- HIC$State.y
PIT$State <- PIT$State.y
PIT[ ,c(2:10, 55)] <- NULL
PIT <- subset(PIT, PIT$Year != "Change")
PIT$Year <- as.numeric(PIT$Year)
HUDjoin <- inner_join(HIC, PIT, by = c("State", "Year"))

HUDjoin <- HUDjoin[HUDjoin$State != "District of Columbia", ]
HUDjoin$State.y <- NULL
HUDjoin$treatVar <- HUDjoin$Total.Year.Round.Beds..RRH. / HUDjoin$totalBeds
scaledHUD <- HUDjoin
scaledHUD[ , c(3:15, 17:ncol(scaledHUD))] <- scale(scaledHUD[ , c(3:15, 17:ncol(scaledHUD))])
write.csv(HUDjoin, file = "cleandata/HUDData.csv", row.names = F)
#write.csv(scaledHUD, file = "cleandata/HUDDataScaled.csv", row.names = F)


##### OTHER CONTROLS #####
unemp <- read.csv("cleandata/unempClean.csv", stringsAsFactors = F)
unemp$Rank <- NULL
incomeCapita <- gdp
incomeCapita$realGDP <- NULL
educ <- read.csv("cleandata/educClean.csv", stringsAsFactors = F)
hpi <- read.csv("cleandata/HPIClean.csv", stringsAsFactors = F)
temp <- read.csv("cleandata/tempClean.csv", stringsAsFactors = F)
controlJoin <- inner_join(unemp, incomeCapita, by = c("State" = "Area", "Year"))
controlJoin <- inner_join(controlJoin, educ, by = c("State", "Year"))
controlJoin <- inner_join(controlJoin, hpi, by = c("State", "Year"))
controlJoin <- inner_join(controlJoin, temp, by = c("State", "Year"))
write.csv(controlJoin, file = "cleandata/controlData.csv", row.names = F)
#scaledcontrolJoin <- controlJoin
#scaledcontrolJoin[ ,c(2,4:7)] <- scale(controlJoin[ ,c(2,4:7)])
