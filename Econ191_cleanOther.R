# Econ191_cleanOther.R #
# All other sources

library(dplyr)
setwd("~/Desktop/School/ECON 191")


# GDP per Capita #
gdpCapita <- read.csv("data/MIMIC/gdpPerCapita.csv", stringsAsFactors = F)
gdpCapita$Fips <- NULL
gdpCapita <- reshape(gdpCapita, 
                varying = c("X2012", "X2013", "X2014", "X2015", "X2016"),
                v.names = c("realGDPCapita"),
                idvar = "Area",
                times = c("2012", "2013", "2014", "2015", "2016"),
                direction = "long")
rownames(gdpCapita) <- NULL
gdpCapita <- gdpCapita[gdpCapita$Area != "District of Columbia", ]

# GDP #
gdp <- read.csv("data/MIMIC/gdp.csv", stringsAsFactors = F)
gdp$Fips <- NULL
gdp <- reshape(gdp, 
                     varying = c("X2012", "X2013", "X2014", "X2015", "X2016"),
                     v.names = c("realGDP"),
                     idvar = "Area",
                     times = c("2012", "2013", "2014", "2015", "2016"),
                     direction = "long")
rownames(gdp) <- NULL
gdp <- gdp[gdp$Area != "District of Columbia", ]

# All GDP data by Join #
allGDP <- inner_join(gdp, gdpCapita, by = c("Area", "time"))
allGDP <- rename(allGDP, Year = time)

write.csv(allGDP, file = "cleandata/gdpClean.csv", row.names = F)


# Labor Force #
LF <- read.csv("cleandata/LFData_xlclean.csv", stringsAsFactors = F,
               colClasses = rep("character", 10))
LFuse <- LF[LF$Year %in% c(2012:2015) & 
              nchar(LF$FIPS.Code) <= 2 & LF$FIPS.Code != 11, 
            c("State.and.area", "Year", "Labor.Force.Total")]
LFuse$Labor.Force.Total <- 
  as.numeric(gsub(",", "", trimws(LFuse$Labor.Force.Total)))

LFuse <- transform(LFuse, Growth = ave(Labor.Force.Total, State.and.area, 
                              FUN=function(x) c(NA, diff(x)/x[-length(x)])))
LFuse <- na.omit(LFuse)
write.csv(LFuse, file = "cleandata/LFClean.csv", row.names = F)

# Electricity #
elec <- read.csv("data/MIMIC/elecData.csv", stringsAsFactors = F)
elec$Data_Status <- NULL
elecLong <- reshape(elec, 
                varying = paste0("X", 1960:2015),
                v.names = c("milkWh"),
                idvar = c("State", "MSN"),
                times = 1960:2015,
                timevar = "Year",
                direction = "long")
elecLong <- elecLong[elecLong$Year > 2012 &
                       substr(elecLong$MSN, 1, 2) == "ES" & 
                       elecLong$MSN != "ESTXP" &
                       !(elecLong$State %in% c("DC", "US")), ]
totalElec <- 
  elecLong %>% group_by(., State, Year) %>% summarise(., TotMilKwh = sum(milkWh))

statAbbr <- read.csv("data/MIMIC/states.csv", stringsAsFactors = F)
totalElec <- left_join(totalElec, statAbbr, by = c("State" = "Abbreviation"))
totalElec$State <- totalElec$State.y
totalElec$State.y <- NULL

write.csv(totalElec, file = "cleandata/elecClean.csv", row.names = F)


# Unemployment # 
allUnemp <- data.frame()
for (i in 2012:2015) {
  fname <- paste0("data/unemp", i, ".csv")
  unemp <- read.csv(fname, stringsAsFactors = F)  
  colnames(unemp) <- c("State", "uRate", "Rank")
  unemp$Year <- i
  allUnemp <- rbind(allUnemp, unemp)
}
write.csv(allUnemp, file = "cleandata/unempClean.csv", row.names = F)

# Education #
allEduc <- data.frame()
for (i in 2012:2015) {
  fname <- paste0("data/educ", i, ".txt")
  educ <- read.delim(fname, sep = "\t", stringsAsFactors = F)
  educ <- educ[ ,1:2]
  educ$State <- rownames(educ)
  rownames(educ) <- NULL
  educ$percHS2564 <- educ[ ,1]
  educ$Year <- i
  educ[, 1:2] <- NULL
  allEduc <- rbind(allEduc, educ)
}
write.csv(allEduc, file = "cleandata/educClean.csv", row.names = F)

# Housing Price #
allHP <- readxl::read_excel("data/housePrice.xlsx", sheet = "data")
allHP <- subset(allHP, Year > 2011)
allHP$HPI2000NSA <- allHP$`HPI with 2000 base`
allHP[ ,c("HPI", "HPI with 1990 base", "Abbreviation", "Annual Change (%)", "FIPS", "HPI with 2000 base")] <- NULL
write.csv(allHP, file = "cleandata/HPIClean.csv", row.names = F)


# Global Temperature Data #
temp <- read.csv("data/temperature.csv", stringsAsFactors = F)
temp$Date <- gsub("12$", "", temp$Date)
hawaiis <- c("Hilo", "Honolulu", "Kahului", "Lihue")
hawaiiDf <- subset(temp, State %in% hawaiis)
hawaiiDf <- hawaiiDf %>% group_by(., Date) %>% summarise(Value = mean(Value))
hawaiiDf$State <- "Hawaii"
temp <- rbind(temp, hawaiiDf)
temp <- filter(temp, !(State %in% hawaiis))
temp <- rename(temp, avgTemp = Value, Year = Date)
write.csv(temp, file = "cleandata/tempClean.csv", row.names = F)
