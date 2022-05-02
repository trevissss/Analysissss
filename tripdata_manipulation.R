library(dplyr)
library(tidyverse)

getwd()
setwd("C://Users/trevi/Documents/Capstone_Project_bruno_trevisan/Case_study_1_14-01-22/All_data_unzipped")


data <- dir(pattern = "*.csv", full.names = T) %>% map_df(read_csv)  #Getting the directory, reading the files and combining it...
                                                                    #...into a data frame


#NOW THAT ALL THE DATA WAS COMBINED... HERE COMES THE MOST IMPORTANT PART: CLEANING...


#--------------------------------------CLEANING--------------------------------------------------------#

#LETS CHECK FOR NA VALUES IN THE DF:


data %>% 
  glimpse()

#WELL IT LOOKS LIKE WE'VE SOME INVALID NUMBERS... LET'S SEE IT MORE CLOSELY

data %>% 
  filter(!complete.cases(.)) %>% 
  View(.)

data_cleaning <- data %>% filter(complete.cases(.)) #NEW DF WITHOUT THE NA's VALUES 
#-------------------------------------------------------------------------------------------------------#



data_cleaning_dates <- data_cleaning %>% select(started_at, ended_at)#TO DEAL ONLY WITH THE DATES IN A SEPARATE DF.

#LETS CHECK THE CLASS OF THE VARIABLES

class(data_cleaning$started_at)
class(data_cleaning$ended_at)

#AS WE HAVE POSIXct VARIABLES WE CAN ALREADY USE THE LUBRIDATE PACKAGE TO WORK WITH IT

data_cleaning_dates$week_day <- wday(data_cleaning_dates$started_at, label = T)
View(data_cleaning_dates)

data_cleaning_dates$duration <- data_cleaning_dates$ended_at - data_cleaning_dates$started_at

#HERE WE CAN SEE SOME NEGATIVE NUMBERS WHEN TRYING TO GET THE DURATION OF THE RIDE
#IT LOOKS LIKE THE DATES WERE SWAPPED AND THEN THE RESULTS END UP BEING NEGATIVE.
#SO TO SWAP THESE DATES...


for (i in seq(1:nrow(data_cleaning_dates))){
  
    if(data_cleaning_dates$ended_at[i] < data_cleaning_dates$started_at[i]){    #THERE'S PROBABLY  A WAY BETTER WAY TO DO THIS!
      
      temp <- data_cleaning_dates$ended_at[i]
      data_cleaning_dates$ended_at[i] <- data_cleaning_dates$started_at[i]
      data_cleaning_dates$started_at[i] <- temp
      
    }
}


data_cleaning_dates$duration <- data_cleaning_dates$ended_at - data_cleaning_dates$started_at #NOW IT LOOKS LIKE WE'VE GOT IT

#NOW THAT WE SWAPPED THE DATE COLUMNS THAT HAD NEGATIVE DURATION RESULTS WE MAY CONTINUE

#I MIGHT WANT A MONTH COLUMN FOR POST ANALYSIS... SO:

data_cleaning_dates$month <- month(data_cleaning_dates$started_at)

#WITH THE DATA LOOKING A LOT CLEARER LETS PUT IT BACK TO THE OTHER DATAFRAME MADE INITIALLY.

data_cleaning$started_at <- data_cleaning_dates$started_at
data_cleaning$ended_at <- data_cleaning_dates$ended_at
data_cleaning$duration <- data_cleaning_dates$duration

data_cleaning$duration <- as.numeric(data_cleaning$duration) #TRANSFORMING THE TYPE OF THIS VARIABLE FROM "difftime" to "numeric"

data_cleaning <- data_cleaning %>% 
rename(duration_seconds = duration)

data_cleaning$week_day <- data_cleaning_dates$week_day #AS I WANT EVERY DATA IN ONLY ONE DATAFRAME I'LL ASSIGN THE WEEK_DAY
data_cleaning$month <- data_cleaning_dates$month       #AND THE MONTH TO THE DATA_CLEANING DF.


data_cleaning_filtered <- data_cleaning %>% 
  select(rideable_type, started_at, ended_at, week_day, month, duration_seconds, start_station_name, 
         end_station_name, member_casual,start_lat, start_lng, end_lat, end_lng)



write.csv(data_cleaning_filtered, "divvy-tripdata-cleaned.csv", row.names = FALSE, sep = ",")



