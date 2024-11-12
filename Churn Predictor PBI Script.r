#dataset <- data.frame(IsActiveMember, Tenure, CreditScore, Geography, NumOfProducts, EstimatedSalary, Balance, Age)
# dataset <- unique(dataset)

library(ranger)
library(dplyr)
library(ggplot2)

model <- readRDS(".../rf_model.rds")

predictions <- predict(model, dataset)

churn_prob <- predictions$predictions[, "Churned"]

churn_percentage <- round(churn_prob * 100, 2)

ggplot() +
  annotate("text", x = 0.5, y = 0.5, 
           label = paste0("Churn Likelihood: ", churn_percentage, "%"), 
           size = 8) +
  theme_void() +
  xlim(0, 1) + ylim(0, 1)
