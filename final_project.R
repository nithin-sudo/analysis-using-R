install.packages("installr")
library(installr)
updateR() 

library(tidyverse)  # Collection of data science packages including ggplot2, dplyr, tidyr, readr, purrr
library(GGally)     # Extends ggplot2 for creating complex plots
library(readxl)     # For reading Excel files directly
library(lubridate)  # For easy manipulation of date-times
library(stringr)    # For handling and manipulating textual data
library(forcats)    # For handling categorical variables
library(quantmod)   # For handling currency codes
library(countrycode) # For handling Messy country names
library(randomForest) # For random Forest model

############################# Data Cleaning ##########################################
# Read the Excel file
salary_data <- read_excel('N:/BIS 581/salary_survey/salary_survey.xlsx')

view(salary_data) # view the dataset

# Renaming the columns to simpler names
salary_data <- salary_data %>%
  rename(
    Timestamp = Timestamp,
    Age = `How old are you?`,
    Industry = `What industry do you work in?`,
    JobTitle = `Job title`,
    JobContext = `If your job title needs additional context, please clarify here:`,
    AnnualSalary = `What is your annual salary? (You'll indicate the currency in a later question. If you are part-time or hourly, please enter an annualized equivalent -- what you would earn if you worked the job 40 hours a week, 52 weeks a year.)`,
    AdditionalCompensation = `How much additional monetary compensation do you get, if any (for example, bonuses or overtime in an average year)? Please only include monetary compensation here, not the value of benefits.`,
    Currency = `Please indicate the currency`,
    OtherCurrency = `If "Other," please indicate the currency here:`,
    IncomeContext = `If your income needs additional context, please provide it here:`,
    Country = `What country do you work in?`,
    State = `If you're in the U.S., what state do you work in?`,
    City = `What city do you work in?`,
    YearsExperience = `How many years of professional work experience do you have overall?`,
    YearsInField = `How many years of professional work experience do you have in your field?`,
    EducationLevel = `What is your highest level of education completed?`,
    Gender = `What is your gender?`,
    Race = `What is your race? (Choose all that apply.)`
  )

#viewing to confirm the changed columns
view(salary_data)

# Count the number of NA values in each column
missing_data_counts <- salary_data %>%
  summarize_all(~ sum(is.na(.)))

# View the counts of missing data
# Increase the maximum number of columns printed in the console
options(width = 1000)
view(print(missing_data_counts))

# Remove the specified columns from the dataset
salary_data_clean <- subset(salary_data, select = -c(JobContext, IncomeContext, OtherCurrency))
view(salary_data_clean)

# Remove rows where the 'Industry' column is NA
salary_data_clean <- salary_data_clean[!is.na(salary_data_clean$Industry), ]
view(salary_data_clean)

# Confirm that there are no more NA values in the 'Industry' column
sum(is.na(salary_data_clean$Industry))
# Check the new size of the dataset
view(dim(salary_data_clean))

# Check current data types
str(salary_data_clean)

# Convert 'AnnualSalary' to numeric if it's not already
salary_data_clean$AnnualSalary <- as.numeric(as.character(salary_data_clean$AnnualSalary))

# Output the structure again to confirm changes
str(salary_data_clean)

# Find the unique currencies in the dataset
unique_currencies <- unique(salary_data_clean$Currency)

# Output the unique currencies
view(unique_currencies)

#handling Australia and NewZealand currencies
country_currency_map <- c(
  "Australia" = "AUD",
  "Australi" = "AUD",
  "australia" = "AUD",
  "AUS" = "AUD",
  "Australian" = "AUD",
  "New Zealand" = "NZD",
  "NZ" = "NZD",
  "New Zealand Aotearea" = "NZD"
)

# Modify the currency column for the "AUD/NZD" case
salary_data_clean$Currency <- ifelse(salary_data_clean$Currency == "AUD/NZD",
                                     ifelse(salary_data_clean$Country %in% names(country_currency_map),
                                            country_currency_map[salary_data_clean$Country],
                                            salary_data_clean$Currency),
                                     salary_data_clean$Currency)
view(salary_data_clean)

# Define the actual currencies
possible_currencies <- c("USD", "GBP", "CAD","AUD","NZD", "EUR", "CHF", "ZAR", "SEK", "HKD", "JPY")

# Initialize a data frame to store the rates
rates <- data.frame(from = "USD", to = possible_currencies)

# Fetch the exchange rates using getQuote and add them to the rates data frame
rates <- rates %>% 
  rowwise() %>% 
  mutate(rate = if (from != to) {
    getQuote(paste0(from, to, "=X"))$Last
  } else {
    1 # If from and to are the same (USD to USD), the rate is 1
  })

# Define a function to convert currency

currencyCon <- function(amount, from, to, rates) {
  # If the 'from' currency is the same as 'to', no conversion is needed
  if (from == to) {
    return(amount)
  }
  # Find the rate for 'from' and 'to' currencies
  rate <- rates$rate[rates$to == to]
  # Calculate the converted amount
  return(amount / rate)
}

#changing Datatype for 'AdditionalCompensation'
salary_data_clean$AdditionalCompensation <- as.numeric(salary_data_clean$AdditionalCompensation)

salary_data_clean <- salary_data_clean %>%
  rowwise() %>%
  mutate(
    AnnualSalaryUSD = currencyCon(AnnualSalary + ifelse(is.na(AdditionalCompensation), 0, AdditionalCompensation), 
                                  Currency, "USD", rates)
  )

view(salary_data_clean)

# Check for "Other" Category in the Currency column
unique(salary_data_clean$Currency)

# Change the entire Currency column to "USD"
# Set Currency to "USD" except where it is "Other"
salary_data_clean$Currency[salary_data_clean$Currency != "Other"] <- "USD"

# View the dataset to confirm the change
View(salary_data_clean)

unique(salary_data_clean$Country)

# Standardize country names
# This will attempt to match each name to a standardized country name
# Even if the names are misspelled or not in ISO format
salary_data_clean$Country <- countrycode(salary_data_clean$Country, "country.name", "country.name", warn = TRUE)
View(salary_data_clean)
# Check for unmatched entries
unmatched <- salary_data_clean$Country[is.na(salary_data_clean$Country)]
unique(unmatched)

# Count the number of NA values in the Country column
num_na_country <- sum(is.na(salary_data_clean$Country))

# Print the result
print(num_na_country)

View(salary_data_clean)

salary_data_further_clean <- salary_data_clean %>%
  select(-c(AnnualSalary, AdditionalCompensation, Race,City))

View(salary_data_further_clean)
# Check the structure and data types of the dataframe
str(salary_data_further_clean)

# Count the number of NA values in the Age,YearsExperience,YearsInField column
missing_data_2 <- sum(is.na(salary_data_further_clean$Age))
missing_data_3 <- sum(is.na(salary_data_further_clean$YearsExperience))
missing_data_4 <- sum(is.na(salary_data_further_clean$YearsInField))

# Print the result
print(missing_data_2)
print(missing_data_3)
print(missing_data_4)

#Function to refine Age,YearsExperience,YearsInField columns and move them to their midpoint for better analysis.
calculate_midpoint <- function(range_str) {
  # Ensure input is character and remove all whitespaces for consistency
  range_str <- gsub(" ", "", as.character(range_str))
  
  # Check for special cases and return their specific values
  if (grepl("^65orover$", range_str, ignore.case = TRUE)) {
    return(65)
  } else if (grepl("^45orless$", range_str, ignore.case = TRUE)) {
    return(45)
  } else if (grepl("^1yearorless$", range_str, ignore.case = TRUE)) {
    return(1)
  } else if (grepl("^41yearsormore$", range_str, ignore.case = TRUE)) {
    return(41)
  } else if (grepl("^under18$", range_str, ignore.case = TRUE)) {
    return(18)
  }else if (grepl("^\\d+yearsormore$", range_str, ignore.case = TRUE)) {
    return(as.numeric(sub("yearsormore", "", range_str)))
  }
  
  # Handle typical ranges such as "25-34years" and "25 - 35 years"
  parts <- strsplit(range_str, "(-|years)")[[1]]
  if (length(parts) == 2) {
    parts <- as.numeric(parts)
    if (!any(is.na(parts))) {
      # Round the midpoint to the nearest integer
      return(round(mean(parts)))
    }
  }
  
  # If the string is already a number like "30", return it as an integer
  if (!is.na(as.numeric(range_str))) {
    return(as.numeric(range_str))
  }
  
  # If none of the above conditions are met, it's an unhandled format
  print(paste("Unhandled format:", range_str))
  return(NA)
}

# Applying the function to the columns
salary_data_further_clean$Age <- sapply(salary_data_further_clean$Age, calculate_midpoint)
salary_data_further_clean$YearsExperience <- sapply(salary_data_further_clean$YearsExperience, calculate_midpoint)
salary_data_further_clean$YearsInField <- sapply(salary_data_further_clean$YearsInField, calculate_midpoint)
view(salary_data_further_clean)

#To Find Unique Values in the columns
unique(salary_data_further_clean$YearsExperience)
unique(salary_data_further_clean$YearsInField)
unique(salary_data_further_clean$Age)

#To check Cleaned Dataset
write.csv(salary_data_further_clean, "salary_data_further_clean.csv")

################################### Data Visualization ##################################################

#1
#To find the unusual values
summary(salary_data_further_clean$AnnualSalaryUSD)

#histogram

# Removing outliers
max_salary <- quantile(salary_data_further_clean$AnnualSalaryUSD, 0.99) # Adjust the percentile as needed
salary_data_filtered <- salary_data_further_clean[salary_data_further_clean$AnnualSalaryUSD <= max_salary, ]

# Re-plotting without outliers
ggplot(salary_data_filtered, aes(x = AnnualSalaryUSD)) +
  geom_histogram(binwidth = 10000, fill = "blue", color = "black") + # Adjusted binwidth
  labs(title = "Distribution of Annual Salaries (Outliers Removed)",
       x = "Annual Salary (USD)",
       y = "Frequency") +
  scale_x_continuous(labels = scales::comma,
                     breaks = seq(0, max(salary_data_filtered$AnnualSalaryUSD), by = 50000)) + # Set breaks every $50,000
  theme_minimal()

#2
#bar chart

# Calculate the average salary by industry
average_salary_by_industry <- salary_data_filtered %>%
  group_by(Industry) %>%
  summarize(AverageSalary = mean(AnnualSalaryUSD, na.rm = TRUE)) %>%
  arrange(desc(AverageSalary))

# Filter the top 5 industries
top5_industries <- head(average_salary_by_industry, 5)
view(top5_industries)

industry_short_names <- c(
  `Sports` = "Sports",
  `Biotech / life sciences` = "Biotech/Life Sci.",
  `Biotech/pharmaceuticals` = "Biotech/Pharma",
  `pharma / medical device design and manufacturing` = "Pharma/Med. Devices",
  `Energy (oil & gas & associated products, renewable power, etc)` = "Energy"
)

# Map the abbreviated names to your top5_industries data frame
top5_industries$Industry <- industry_short_names[top5_industries$Industry]

# Create the bar chart
ggplot(top5_industries, aes(x = reorder(Industry, -AverageSalary), y = AverageSalary )) +
  geom_bar(stat = "identity") +
  scale_y_continuous(labels = scales::comma) + # Changes numbers to standard notation
  labs(title = "Top 5 Industries by Average Annual Salary (USD)",
       x = "Average Annual Salary (USD)",
       y = "Industry") +
  theme_minimal()

#3
#boxplot

# Preprocess the data
salary_data_processed <- salary_data_filtered %>%
  filter(!is.na(EducationLevel)) %>%  # Exclude NA values
  mutate(EducationLevel = ifelse(EducationLevel == "Some college", "College degree", EducationLevel))  # Combine "Some college" with "College degree"

# Now plot using the processed data
ggplot(salary_data_processed, aes(x = EducationLevel, y = AnnualSalaryUSD)) +
  geom_boxplot() +
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Annual Salary by Education Level",
       x = "Education Level",
       y = "Annual Salary (USD)") +
  theme_minimal()

#4
# histogram of Age Distribution of Survey Respondents
ggplot(salary_data_filtered, aes(x = Age)) +
  geom_histogram(binwidth = 10, fill = "cornflowerblue", color = "black") +  # Set binwidth to 1 for each year
  labs(title = "Age Distribution of Survey Respondents",
       x = "Age Group",
       y = "Number of Respondents") +
  theme_minimal()

#5
# Count the number of responses per industry and arrange in descending order
response_count_by_industry <- salary_data_filtered %>%
  count(Industry, sort = TRUE)

# Select the top industry with the most respondents
top1_industries <- head(response_count_by_industry, 1)
view(top1_industries)
# Filter the dataset to only include data from these top industry.
top_industry_data <- salary_data_filtered %>%
  filter(Industry %in% top1_industries$Industry)

ggplot(top_industry_data, aes(x = YearsExperience, y = AnnualSalaryUSD)) +
  geom_jitter(width = 0.5, alpha = 0.2) +  # Smaller jitter width
  geom_smooth(method = "loess", color = "blue", se = FALSE) +  # Add a LOESS curve for trend
  scale_y_continuous(labels = scales::comma) +
  labs(title = "Jittered Scatter Plot with Trend for Top Industry: Annual Salary vs. Years of Experience",
       x = "Years of Experience",
       y = "Annual Salary (USD)") +
  theme_minimal() +
  theme(legend.position = "bottom")

############################# Data Modelling #################################################

####### linear regression
view(top_industry_data)

# Set a seed for reproducibility
set.seed(123)  # Ensures that the random selection is the same each time the script runs

# Randomly sample 80% of the data indices for training
training_indices <- sample(1:nrow(top_industry_data), 0.8 * nrow(top_industry_data))

# Create training data based on the sampled indices
train_data <- top_industry_data[training_indices, ]

# Create test data based on the non-sampled indices
test_data <- top_industry_data[-training_indices, ]

# Convert the EducationLevel column to a factor for proper treatment in the model
train_data$EducationLevel <- as.factor(train_data$EducationLevel)
test_data$EducationLevel <- as.factor(test_data$EducationLevel)

# Check for missing values in the YearsInField and EducationLevel columns
sum(is.na(train_data$YearsInField))  # Sum and print the number of NA values in YearsInField in the train data
sum(is.na(train_data$EducationLevel))  # Sum and print the number of NA values in EducationLevel in the train data

# Omit rows with missing values in both training and testing datasets
train_data <- na.omit(train_data)  # Remove rows with NAs in the training data
test_data <- na.omit(test_data)  # Remove rows with NAs in the testing data

# Fit a linear regression model using YearsInField and EducationLevel as predictors
model_with_educationlevel <- lm(AnnualSalaryUSD ~ YearsInField + EducationLevel, data = train_data)

# Summarize the model to see coefficients and other statistics
summary(model_with_educationlevel)  # Display a summary of the model, including coefficients and their significance

# Make salary predictions on the testing set using the fitted model
predictions_with_educationlevel <- predict(model_with_educationlevel, test_data)

# Calculate and print the Mean Squared Error (MSE) between the predicted and actual salaries
mean_squared_error_with_educationlevel <- mean((predictions_with_educationlevel - test_data$AnnualSalaryUSD)^2)
print(mean_squared_error_with_educationlevel)  # Output the MSE to check the prediction accuracy

################# Random Forest ########

# Set a seed for reproducibility
set.seed(123)

# Split the data into training and testing sets
splitting_indices <- sample(1:nrow(salary_data_further_clean), 0.8 * nrow(top_industry_data))
train_data <- top_industry_data[splitting_indices, ]
test_data <- top_industry_data[-splitting_indices, ]

# Convert into factors for modelling
train_data$Industry <- as.factor(train_data$Industry)
train_data$EducationLevel <- as.factor(train_data$EducationLevel)
test_data$Industry <- as.factor(test_data$Industry)
test_data$EducationLevel <- as.factor(test_data$EducationLevel)

# Remove rows with missing values
train_data_clean <- na.omit(train_data)

# Check if there are no missing values
sum(is.na(train_data_clean))

rf_model <- randomForest(AnnualSalaryUSD ~ ., data = train_data_clean, ntree = 500)

# Print model details
print(rf_model)

# Predict on the test data
rf_predictions <- predict(rf_model, test_data)

# Remove NA values from predictions and the corresponding test data
valid_indices <- !is.na(rf_predictions) & !is.na(test_data$AnnualSalaryUSD)
clean_predictions <- rf_predictions[valid_indices]
clean_test_data <- test_data[valid_indices,]

# Now calculate the Mean Squared Error with the clean data
rf_mse <- mean((clean_test_data$AnnualSalaryUSD - clean_predictions)^2)
print(paste("Clean Mean Squared Error: ", rf_mse))

importance(rf_model)  # Prints the importance of each variable in the model
varImpPlot(rf_model)  # Plots variable importance






