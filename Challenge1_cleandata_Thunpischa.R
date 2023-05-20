# import tools
library(googlesheets4)
library(dplyr)
library(lubridate)

# google sheet
url <- "https://docs.google.com/spreadsheets/d/1XozIg4ydzYRGuRl6q3tp9eCe_ag3u0HA0sluWuCa3-U/edit#gid=583794143"
gs4_deauth()

# import all columns as character type
data <- read_sheet(url, sheet = 3, col_types = 'c')

glimpse(data)

# rename columns
names(data) <- gsub("[ -]", "_", names(data))
names(data)[13] <- "Cost_USD"
names(data) <- tolower(names(data))

# convert order_date and ship_date to be datetime type
data <- data %>% 
  # convert to datetime
  mutate(order_date = mdy(order_date), ship_date =  mdy(ship_date) ) %>% 
  # add diff date between order and ship date
  mutate(prepare_days = as.numeric(ship_date - order_date))

# convert cost and quantity to numeric datatype
data <- data %>% 
  mutate_at(c('cost_usd', 'quantity'), as.numeric)

# add order_id from order_date, ship_date, customer_name 
# to check whether there is any order ship separately
data <- data %>% 
  mutate(order_id = paste(order_date,ship_date,customer_name,sep = "-"))

# export data
write.csv(data, "Data_Business_Case_Skillkamp.csv", row.names = FALSE)
