#################################################################
### This file provides all the code required for this lesson. ###  
### Please follow instructions on the Github page:            ###
### https://github.com/JamesBOPRC/R_Tutorial_Lesson_2         ###
#################################################################

library(devtools)

#for aquarius2018 
install_local("aquarius2018-main.zip")

#for BoPRC2025
install_local("BoPRC2025-main.zip")

#Now you should be able to each package using the following commands:
library(aquarius2018)
library(BoPRC2025)

#Once all of these packages are installed you can load them using the ‘library’ function:
library(tidyverse)
library(lubridate)

################
# aquarius2018 #
################

#Use the function ‘searchlocationname()’ to conduct a wildcard search for all sites that have ‘Pongakawa at’ in the title. 
#There are quite a few, so it would pay to save this as a dataframe for easier reference.

Site_List <- searchlocationnames("Pongakawa at*")

# ~~~~~~~~~~~~~~~~~~~
#!!!! CHALLENGE 1 !!!!
# ~~~~~~~~~~~~~~~~~~~

#Use the ‘view’ function to view the object you just created, or click on the name ‘Site_List’ in the Data pane on the right.
View(Site_List)

# store the 'siteID' as an object that we can call upon later.  The syntax is
# DATAFILE[ROW,COLUMN].
SiteID <- Site_List[3, 1]
SiteID

# Create an object with all discrete WQ parameters at the site.
Datasets <- datasets(SiteID)
head(Datasets)

# ~~~~~~~~~~~~~~~~~~~
#!!!! CHALLENGE 2 !!!!
# ~~~~~~~~~~~~~~~~~~~

# use the getdata function to extract the entire NNN dataset for 'Pongakawa at
# SH2'.
getdata("NNN.LabResult@GN922883")

# ~~~~~~~~~~~~~~~~~~~
#!!!! CHALLENGE 3 !!!!
# ~~~~~~~~~~~~~~~~~~~

# Create an object with all discrete WQ parameters at the site.
AvailableWQParams <- LocationWQParameters(SiteID)

# Let’s define a parameter list of: E. coli, Nitrite Nitrate (as N), and Ammoniacal N.
ParamList <- c("E coli", "NNN", "NH4-N")

#AQMultiExtractFlat will extract the requested data query in long format and include any metadata that is stored in the database. 
#There is another function called AQMultiExtract which has the same input requirements, but outputs data in a wide format (i.e., Parameters will be columns). The downside to this is that no metadata will be included.
WQData_Pongakawa <- AQMultiExtractFlat(SiteID, ParamList, start = "2020-01-01", end = "2025-01-01")

#It’s as easy as that. You can save this data to a csv file if you wish.
write.csv(WQData_Pongakawa, file = "Pongakawa_Data.csv", row.names = FALSE)

# You might also want to briefly check over the data to ensure that everything is in order. 
# A simple way to do this is using the ‘tidyverse’ ecosystem. 
# In this case we can pass the object (WQData_Pongakawa) to the ggplot function to create a plot.
WQData_Pongakawa %>%
  ggplot() + geom_point(aes(x = Time, y = Value)) + 
  facet_wrap(~Parameter, scales = "free_y",nrow = 3) + 
  xlab(NULL) + 
  theme_bw()

# Use the filter function in the tidyverse pipeline below to see what the data looks like if only ‘routine’ data are included. 
# Note the code below doesn’t make any changes to the dataset or create any new objects, which is why tidyverse is great for exploring data.

WQData_Pongakawa %>%
  filter(Qualifiers == "Routine") %>%
  ggplot() + 
  geom_point(aes(x = Time, y = Value)) + 
  facet_wrap(~Parameter, scales = "free_y", nrow = 3) + 
  xlab(NULL) + 
  theme_bw()


#This looks much better and we might want to save the filtered data as ‘routine’ dataset.
Routine_Data <- WQData_Pongakawa %>%
  filter(Qualifiers == "Routine")


# Use tidyverse to filter and plot a recreational bathing dataset
WQData_Pongakawa %>%
  filter(Parameter == "E coli (cfu/100ml)") %>%
  filter(Qualifiers == "Recreational") %>%
  ggplot() + geom_point(aes(x = Time, y = Value)) + xlab(NULL) + theme_bw()

# If we're happy with how this works then we can save it for future use.
Rec_Bathing_Data <- WQData_Pongakawa %>%
  filter(Parameter == "E coli (cfu/100ml)") %>%
  filter(Qualifiers == "Recreational")

# ~~~~~~~~~~~~~~~~~~~
#!!!! CHALLENGE 4 !!!!
# ~~~~~~~~~~~~~~~~~~~

#############
# BoPRC2025 #
#############

#lets copy the WQData_Pongakawa dataset and paste it in an excel sheet. 
#Run the following code and then open Excel, select a cell, and paste.
Write.Excel(WQData_Pongakawa)

#find tidal information for Opotiki on the 24th June 2024.
TidalFromDate("2024-06-24 08:45:00",SecondaryPort = "Opotiki")

#create a sequence of times that covers our timestamp.
time <- seq.POSIXt(as.POSIXct("2024-06-24 03:00:00",tz="etc/GMT+12"),to = as.POSIXct("2024-06-24 12:00:00",tz="etc/GMT+12"),by = "10 mins")

#create a dataframe of time vs tidal height
Tidal_Height_DF <- data.frame(Time=time, height=NA)

#this loop looks tricky but it's not really that bad.  
#It loops through all of the rows in Tidal_Height_DF and 
#calculates the Estimated Water Level for each of the times.  
for(i in 1:nrow(Tidal_Height_DF)){
  Tidal_Height_DF$height[i] <- as.numeric(TidalFromDate(Tidal_Height_DF$Time[i],SecondaryPort = "Opotiki")$EstimatedWaterLevel)
}

#create a plot of the data
Tidal_Height_DF%>%
  ggplot()+
  geom_path(aes(x=Time,y=height))+
  xlab("Time")+
  ylab("Water Level (m)")+
  geom_point(x=as.POSIXct("2024-06-24 08:45:00",tz="etc/GMT+12"), y=1.779,size=5,colour="blue")+
  theme_bw()


#Finally, you can access the datasets for each primary and secondary port using the data() function.
data("KauriPoint")
KauriPoint

# ~~~~~~~~~~~~~~~~~~~
#!!!! CHALLENGE 5 !!!!
# ~~~~~~~~~~~~~~~~~~~

#Bathing_Season is really useful for attributing a bathing season or hydrological year to timestamps. We use the tidyverse method of ‘mutate’, below, to apply this function to a dataset.
Rec_Bathing_Data %>%
  mutate(Season = Bathing_Season(Time))%>%
  select(Site, LocationName, Time, Value, Season)

#You need to input a dataset and a desired percentile to use this function.
Hazen.Percentile(Rec_Bathing_Data$Value,percentile =95)

# ~~~~~~~~~~~~~~~~~~~
#!!!! CHALLENGE 6 !!!!
# ~~~~~~~~~~~~~~~~~~~

#list NERMN River siteID's
NERMN_River()

#wrap the NERMN_River() function in the Site_Metadata() function to return site information. 
Site_Metadata(data.frame(NERMN_River()))

#Use BPU_Check to find out which biophysical unit GJ662805 belongs to.
searchlocationid("GJ662805")%>%
  select(Identifier,LocationName)%>%
  mutate(BPU = BPU_Check(Identifier))

# ~~~~~~~~~~~~~~~~~~~
#!!!! CHALLENGE 7 !!!!
# ~~~~~~~~~~~~~~~~~~~

#creating a list of our sites of interest
Sites<-c("DO406909","GN922883","KL998150")

#creating a list of our parameters of interest
Parameters<-c("NNN","NH4-N","pH")

#creating a dataframe of our sites and parameters (in alphabetical order)
Data<-AQMultiExtractFlat(Sites, Parameters)

#filter the dataset to show NNN only, and then select the most relevant parameters and save as an object.

Nitrate_Data <- Data %>% 
  filter(Parameter == "NNN (g/m^3)") %>% 
  filter(Qualifiers %in% c("Routine","Labstar - Legacy Data")) %>% 
  select(Site, LocationName, Time, Value)

#assess against Table 6 of the NPSFM for 2024-2025 calendar year.  
NOFLakesRiversNO3(Nitrate_Data,start="2024-01-01",end="2025-01-01")

# The Ammonia (toxicity) attribute (Table 5 in the NPS-FM) needs to be adjusted to a pH of 8. 
# Reference tables are built into the NOFLakesRiversNH3 function to allow you to do this. 
# You just need to provide both the NH4-N value and the pH value in the same row. 
# The code below will explain how to do this

NH4_N_Data <- Data %>% 
  filter(Qualifiers %in% c("Routine","Labstar - Legacy Data")) %>% 
  filter(Parameter %in% c("NH4-N (g/m^3)","pH (pH Units)")) %>% 
  select(Site, LocationName, Time, Parameter, Value) %>%
  pivot_wider(names_from = Parameter,id_cols = c("Site","LocationName","Time"),values_from = Value)%>%
  filter(complete.cases(.))

NOFLakesRiversNH4N(NH4_N_Data,start="2024-01-01",end="2025-01-01")


# The Escherichia coli (E. coli) attribute (Table 9 in the NPS FM) can be assessed using two different functions. 
# The first, NOFLakesRiversECOLI, calculates the required statistics from a raw dataset:

Routine_Ecoli_Data <- WQData_Pongakawa %>%
  filter(Parameter == "E coli (cfu/100ml)")%>%
  filter(Qualifiers=="Routine")%>%
  select(Site, LocationName, Time, Value) %>%
  filter(complete.cases(.))

NOFLakesRiversECOLI(Routine_Ecoli_Data,start="2020-01-01",end="2025-01-01")

#use the ECOLI_Banding function and pre-calculated statistics to calculate an attribute band.  
ECOLI_Banding(PercentExceed540 = 10,PercentExceed260 = 23,Median = 130,Percentile95 = 540,method = "max")

# ~~~~~~~~~~~~~~~~~~~
#!!!! CHALLENGE 8 !!!!
# ~~~~~~~~~~~~~~~~~~~
