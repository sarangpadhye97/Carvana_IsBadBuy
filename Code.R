
###

### MISM 6210 - 35492 - Spring 2024

### Analysis 02 - PADHYE SARANG

### Load libraries
library(tidyverse)
library(readxl)
library(ggplot2)
library(dplyr)
library(reshape2)
#install.packages("caret")
library(caret)
#install.packages("corrplot")
library(corrplot)

carvana_data <- read.csv("/Users/sarangpadhye/Desktop/Career/MS/Northeastern MSBA/Subjects/MISM-6210/Assignment 2/training.csv")

# Question 1

# Dimensions of Dataset
dim(carvana_data)
sum(duplicated(carvana_data))

# Display first 6 rows of all columns
head(carvana_data)

# Summarize data and variables
summary(carvana_data)

# Display the structure of the dataset
str(carvana_data)

# Most popular car makes
most_popular_cars <- carvana_data %>%
  group_by(Make) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

cat("Top 10 popular car companies are:\n")
print(most_popular_cars[1:10,])

# Most common car sizes
sizes <- carvana_data %>%
  group_by(Size) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

cat("Most common car sizes:\n")
print(sizes)

# Average age of the cars
average_car_age <- mean(carvana_data$VehicleAge)
cat("Average age of the cars:", average_car_age, "years\n")

# Average miles of the cars
average_running <- mean(carvana_data$VehOdo)
cat("Average miles of the cars:", average_running, "miles\n")

# Where the cars are coming from
car_state <- carvana_data %>%
  group_by(VNST) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

cat("State from where cars are brought in are:\n")
print(car_state)

car_nationality <- carvana_data %>%
  group_by(Nationality) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

cat("The nationalities of the cars are:\n")
print(car_nationality)

# Histogram to show Acquisition price for the vehicle in the retail market in 
# above‐average condition as of current day

carvana_data$MMRCurrentRetailCleanPrice <- as.numeric(as.character(carvana_data$MMRCurrentRetailCleanPrice))
ggplot(data = carvana_data, aes(x = MMRCurrentRetailCleanPrice)) +
  geom_histogram(fill = "blue", color = "white", bins = 30) +
  labs(title = "Distribution of MMRCurrentRetailCleanPrice",
       x = "MMRCurrentRetailCleanPrice",
       y = "Frequency")

# Was the car purchased online

online_purchase <- table(carvana_data$IsOnlineSale)
online_sales <- (online_purchase / sum(online_purchase)) * 100
cat("Percentage of cars with online sales (IsOnlineSale = 1):", online_sales[2], "%\n")
cat("Percentage of cars without online sales (IsOnlineSale = 0):", online_sales[1] ,"%\n")

pie(online_sales,
   # labels = c("Without Online Sales (IsOnlineSale = 0)", "With Online Sales (IsOnlineSale = 1)"),
    col = c("red", "yellow"),
    main = "Percentage of Cars with Online Sales"
)
legend("topright", 
       legend = paste(c("Offline Sales", "Online Sales"), " ", round(online_sales, 1), "%", sep = ""),
       fill = c("red", "yellow"),
       bty = "n"
)

###########################################
# Question 2
continuous_variables <- carvana_data[, sapply(carvana_data, is.numeric)]
  
correlation_matrix <- cor(continuous_variables)
correlations_with_IsBadBuy <- correlation_matrix[, "IsBadBuy"]
print(correlations_with_IsBadBuy)

# Convert correlation matrix to long format for plotting
correlation_df <- melt(correlation_matrix)

options(repr.plot.width = 15, repr.plot.height = 13)
ggplot(correlation_df, aes(x = Var1, y = Var2, fill = value, label = round(value, 2))) +
  geom_tile() +
  geom_text(color = "black") +
  scale_fill_gradient2(low = "orange", mid = "skyblue", high = "red", 
                       midpoint = 0, limits = c(-1, 1), 
                       name = "Correlation") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 7)) +
  labs(title = "Correlation Heatmap")

significant_correlations <- correlations_with_IsBadBuy[abs(correlations_with_IsBadBuy) > 0.1]
print(significant_correlations)

significant_variables <- names(significant_correlations)
significant_variables <- intersect(significant_variables, colnames(correlation_matrix))
significant_correlation_matrix <- correlation_matrix[significant_variables, significant_variables]
print(significant_correlation_matrix)

corrplot(significant_correlation_matrix, method = "color", type = "upper",
         col = colorRampPalette(c("brown", "skyblue", "grey"))(50),
         tl.col = "black", tl.srt = 45,
         main = "Significant Correlation Matrix")

###########################################
# Question 3

custom_colors <- c("blue", "red")  

# Relationship between IsBadBuy and Vehicle Age
ggplot(carvana_data, aes(x = VehicleAge, fill = factor(IsBadBuy))) +
  geom_bar(position = "dodge", stat = "count") +
  scale_fill_manual(values = custom_colors) + 
  labs(title = "Grouped Bar Plot of IsBadBuy by Vehicle Age",
       x = "Vehicle Age",
       y = "Count",
       fill = "IsBadBuy") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Relationship between IsBadBuy and Vehicle Odometer
carvana_data %>%
  mutate(IsBadBuy = as.factor(IsBadBuy)) %>%
  ggplot(aes(VehOdo, fill=IsBadBuy)) +
  scale_fill_manual(values = custom_colors) + 
  geom_histogram( bins=35,) + 
  labs(title = "Grouped Bar Plot of IsBadBuy by Odometer") +
  ylab("count")+ xlab("Vehicle Odometer")

# Relationship between IsBadBuy and Vehicle Year
ggplot(carvana_data, aes(x = VehYear, fill = factor(IsBadBuy))) +
  geom_bar(position = "dodge", stat = "count") +
  scale_fill_manual(values = custom_colors) +  # Use custom colors
  labs(title = "Grouped Bar Plot of IsBadBuy by Vehicle Year",
       x = "Vehicle Year",
       y = "Count",
       fill = "IsBadBuy") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Relationship between IsBadBuy and Nationality
ggplot(carvana_data, aes(x = Nationality, fill = factor(IsBadBuy))) +
  geom_bar(position = "dodge", stat = "count") +
  scale_fill_manual(values = custom_colors) + 
  labs(title = "Grouped Bar Plot of IsBadBuy by Nationality",
       x = "Nationality",
       y = "Count",
       fill = "IsBadBuy") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

# Scatter plot for relation between IsBadBuy, Vehicle Age and Make
ggplot(carvana_data[!is.na(carvana_data$Make), ], aes(x = factor(IsBadBuy), y = VehicleAge)) +
  geom_boxplot() +
  facet_wrap(~ Make) +
  labs(title = "Relationship b/w age & type of buy changes Makes") + 
  xlab('Type of Buy') + 
  ylab('Age of Vehicle') +
  scale_x_discrete(labels = c('Good','Bad'))

# Scatter plot for relation between IsBadBuy, Vehicle Age and Nationality

ggplot(carvana_data[!is.na(carvana_data$Nationality), ], aes(x = factor(IsBadBuy), y = VehicleAge)) +
  geom_boxplot() +
  facet_wrap(~ Nationality) +
  labs(title = "Relationship b/w age & type of buy changes Nationality") + 
  xlab('Type of Buy') + 
  ylab('Age of Vehicle') +
  scale_x_discrete(labels = c('Good','Bad'))


###########################################
# Question 4

carvana_data$IsBadBuy <- as.factor(carvana_data$IsBadBuy)

# logistic regression model 
#glm_model <- glm(IsBadBuy ~ VehicleAge + VehYear + VehOdo + Size, data = carvana_data,family = "binomial")
#glm_model <- glm(IsBadBuy ~ VehicleAge + VehYear + Make + VehOdo, data = carvana_data,family = "binomial")
glm_model <- glm(IsBadBuy ~ VehicleAge + VehYear + WarrantyCost + VehOdo, data = carvana_data,family = "binomial")

summary(glm_model)

###########################################
# Question 5

custom_colors <- c("blue", "red")  
ggplot(carvana_data, aes(x = VehicleAge, fill = factor(IsBadBuy))) +
  geom_histogram(binwidth = 2, position = "dodge") +
  scale_fill_manual(values = custom_colors) + 
  labs(title = "Distribution of Vehicle Ages by Bad Buy",
       x = "Vehicle Age",
       y = "Frequency",
       fill = "IsBadBuy") +
  theme_minimal()

ggplot(carvana_data, aes(x = VehOdo, fill = factor(IsBadBuy))) +
  geom_histogram(binwidth = 2, position = "dodge") +
  scale_fill_manual(values = custom_colors) + 
  labs(title = "Distribution of odometer by Bad Buy",
       x = "Vehicle Odometer",
       y = "Frequency",
       fill = "IsBadBuy") +
  theme_minimal()

