# Econ191_cleanCensus.R #

library(dplyr)
setwd("~/Desktop/School/ECON 191")

alldf <- data.frame()
for (i in 13:15) {
  df <- read.csv(paste0("data/MIMIC/Census20", i, ".csv"), stringsAsFactors = F)
  raw <- read.delim(paste0("data/MIMIC/", i, "statetypepu.txt"),
                    sep = "", header = F, colClasses = rep("character", 5))
  stateGovt <- substr(raw$V1, 3, 3) == "2"
  state <- substr(raw$V1, 1, 2) != "00"
  
  stateOnlyPIR <- raw[raw$V2 == "E66" & stateGovt & state, ]
  df <- df[-1, ]
  df <- df[df$GEO.display.label != "United States", ]
  
  stateOnlyPIR$GEO.display.label <- unique(df$GEO.display.label)
  stateOnlyPIR$YEAR.id <- unique(df$YEAR.id)
  stateOnlyPIR$AMOUNT <- stateOnlyPIR$V3
  stateOnlyPIR$FINSRC.id <- stateOnlyPIR$V2
  stateOnlyPIR$FINSRC.display.label <- "PIR"
  stateOnlyPIR[, c("V1", "V2", "V3", "V4", "V5")] <- NULL
  
  tax <- 
    df %>% dplyr::filter(., FINSRC.id %in% c("01021", "01022")) %>%
    group_by(., GEO.display.label, YEAR.id) %>%
    summarise(., AMOUNT = as.character(sum(as.numeric(AMOUNT))))
  tax$FINSRC.display.label <- "Indirect Tax"
  tax$FINSRC.id <- "01021+01022"
  
  withGDP <-
    df %>% group_by(., GEO.display.label, YEAR.id) %>%
    dplyr::filter(., nchar(FINSRC.id) == 2) %>%
    summarise(., GDP = sum(as.numeric(AMOUNT)))
  
  withoutGDP <- bind_rows(df, stateOnlyPIR, tax)
  joined <- left_join(withoutGDP, withGDP, by = c("GEO.display.label", "YEAR.id"))
  
  joined$pct <- as.numeric(joined$AMOUNT) / as.numeric(joined$GDP)
  
  need <- c("02", "01021+01022", "0103", "027", "E66")
  
  output <- filter(joined, FINSRC.id %in% need)
  output <- arrange(output, GEO.display.label)
  output[is.na(output)] <- ""
  
  alldf <- rbind(alldf, output)
}

write.csv(alldf, file = "cleandata/censusClean.csv", row.names = F)
