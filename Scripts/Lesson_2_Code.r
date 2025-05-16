#################################################################
### This file provides all the code required for this lesson. ###  
### Please follow instructions on the Github page:            ###
### https://github.com/JamesBOPRC/R_Tutorial_Lesson_2         ###
#################################################################

#load required packages
library(dplyr)
library(aquarius2018)
library(tidyverse)
library(BoPRC2022)

#
Site_List <- searchlocationnames("Pongakawa at*")

head(t(Site_List[3, ]), 5)

SiteID <- Site_List[3, 1]

Datasets <- datasets(SiteID)



AvailableWQParams <- LocationWQParameters(SiteID)


ParamList <- c("E coli", "NNN", "NH4-N")

WQData_Pongakawa <- AQMultiExtractFlat(SiteID, ParamList, start = "2020-01-01", end = "2025-01-01")
WQData_Pongakawa_wide <- AQMultiExtract(SiteID, ParamList, start = "2020-01-01", end = "2025-01-01")

write.csv(WQData_Pongakawa, file = "Pongakawa_Data.csv", row.names = FALSE)

WQData_Pongakawa %>%
  ggplot() + 
  geom_point(aes(x = Time, y = Value)) + 
  facet_wrap(~Parameter, scales = "free_y",nrow = 3) + 
  xlab(NULL) + theme_bw()

WQData_Pongakawa %>%
  filter(Qualifiers == "Routine") %>%
  ggplot() + geom_point(aes(x = Time, y = Value)) + facet_wrap(~Parameter, scales = "free_y",
                                                               nrow = 3) + xlab(NULL) + theme_bw()

Routine_Data <- WQData_Pongakawa %>%
  filter(Qualifiers == "Routine")

WQData_Pongakawa %>%
  filter(Parameter == "E coli (cfu/100ml)") %>%
  filter(Qualifiers == "Recreational") %>%
  ggplot() + geom_point(aes(x = Time, y = Value)) + xlab(NULL) + theme_bw()

Rec_Bathing_Data <- WQData_Pongakawa %>%
  filter(Parameter == "E coli (cfu/100ml)") %>%
  filter(Qualifiers == "Recreational")
