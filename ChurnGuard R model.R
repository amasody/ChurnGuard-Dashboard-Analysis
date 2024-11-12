library(tidymodels)
library(parsnip)
library(workflows)
library(ggrepel)
library(ranger)
library(yardstick)
library(forcats)
library(pROC)

tidymodels_prefer()

#adjust to where downloaded dataset file is#

setwd("C:/Users/mortt/Documents/DATASETS")
getwd()

#load in training dataset from local files

Training <- read.csv("bank_churn_train.csv")

#split training data into 80/20 training/validation set

split_data <- Training %>%
  initial_split(prop = 0.8, strata = NULL)

Training <- training(split_data)
validation <- testing(split_data)

truth <- validation$Exited

#relevel the exited column from binary (0,1) to "churn" and "not churned"
#for both of the splits

Training <- Training %>%
  mutate(Exited = ifelse(Exited == 1, "Churned", "Not_Churned")) %>%
  mutate(Exited = factor(Exited, levels = c("Churned", "Not_Churned")))

validation <- validation %>%
  mutate(Exited = ifelse(Exited == 1, "Churned", "Not_Churned")) %>%
  mutate(Exited = factor(Exited, levels = c("Churned", "Not_Churned")))

#make sure it refactored correctly

validation$Exited

print(levels(Training$Exited))

#establish models to be used for comparison 

log_model <- 
  logistic_reg() %>%
  set_engine("glm") %>%
  set_mode("classification")

rf_spec <- rand_forest() %>%
  set_engine("ranger") %>%
  set_mode("classification")

#pre-process data for each respective model with additional complexity for the
#logistic regression model

rf_recipe <- recipe(Exited ~ Geography + Age + Tenure + EstimatedSalary + 
                      Balance + CreditScore + NumOfProducts + IsActiveMember, Training) %>%
  step_zv()   %>%
  step_impute_mean(all_numeric_predictors())  %>%
  step_impute_mode(all_nominal_predictors())

Log_recipe <- recipe(Exited ~ Geography + Age + Tenure + EstimatedSalary + 
                       Balance + CreditScore + NumOfProducts , Training) %>%
  step_dummy(Geography) %>%
  step_zv()   %>%
  step_impute_mean(all_numeric_predictors())  %>%
  step_impute_mode(all_nominal_predictors())  %>%
  step_normalize(all_numeric_predictors())


Log_interact <- Log_recipe %>%  
  step_interact(~ Age:Tenure) 

Log_pca <- Log_interact %>%
  step_pca(all_numeric_predictors(), threshold = 0.8)

#create list of logistic regression models with increasing complexity

preproc <-
  list(primary = Log_recipe,
       interact = Log_interact,
       pca = Log_pca)


log_models <- workflow_set(preproc, list(glm = logistic_reg()),
                           cross = FALSE)

log_workflow <-
  workflow() %>%
  add_recipe(Log_recipe) %>%
  add_model(log_model)


rf_workflow <-
  workflow()  %>%
  add_recipe(rf_recipe) %>%
  add_model(rf_spec)

set.seed(1010)

Training_fold <- vfold_cv(Training, v = 10)

keep_pred <- control_resamples(save_pred = TRUE, save_workflow = TRUE)

log_res <- 
  log_models %>% 
  workflow_map("fit_resamples",
               seed = 1101, verbose = TRUE,
               resamples = Training_fold, control = keep_pred)

set.seed(1003)
rf_res <- rf_workflow %>% fit_resamples(resamples = Training_fold, control = keep_pred)

four_models <- 
  as_workflow_set(random_forest = rf_res) %>%
  bind_rows(log_res)

autoplot(four_models, metric = "accuracy") +
  geom_text_repel(aes(label = wflow_id), nudge_x = 1/8, nudge_y = 1/100) +
  theme(legend.position = "none")

###### Because the Random Forest performs the best we will attempt
##to make it more accurate with hyperparamter tuning #####

rf_tuned_spec <- rf_spec %>%
  update(trees = tune(), mtry = tune(), min_n = tune()) %>%
  set_engine("ranger", importance = 'impurity')


rf_tuned_workflow <- workflow() %>%
  add_recipe(rf_recipe) %>%
  add_model(rf_tuned_spec)

rf_grid_random <- grid_random(
  trees(range = c(100, 400)),
  mtry(range = c(1, 5)),
  min_n(range = c(5, 20)),
  size = 4  
)

set.seed(3402)

rf_tuned_res <- rf_tuned_workflow %>%
  tune_grid(
    resamples = Training_fold,
    grid = rf_grid_random,
    control = control_grid(save_pred = TRUE)
  )

best_param <- rf_tuned_res %>%
  select_best(metric = "accuracy")

final_rf_wf <- finalize_workflow(
  rf_tuned_workflow,
  best_param
)

final_rf_fit <- fit(final_rf_wf, Training)

final_rf_model <- extract_fit_engine(final_rf_fit)

saveRDS(final_rf_model, "rf_model.rds")

predictions <- predict(final_rf_model, validation)

validation <- validation %>%
  select(-Exited)   %>%
  mutate(
    pred_prob = predictions$predictions[, "Churned"],
    pred_prob2 = predictions$predictions[, "Not_Churned"])

threshold <- 0.5

validation_results <- validation %>%
  mutate(
    pred_class = factor(if_else(pred_prob >= threshold, 1, 0), 
                        levels = c(0, 1))) %>%
  cbind(truth)  %>%
  mutate(
    truth = factor(truth, levels = c(0, 1)),
    pred_class = factor(pred_class, levels = c(0, 1))
  ) 

write.csv(validation_results, "validation_df.csv")

metrics <- metric_set(accuracy, precision, recall, f_meas)

val_metrics <- validation_results %>%
  metrics(truth = truth, estimate = pred_class, pred_prob)

roc_obj_auc <- validation_results %>%
  roc(truth, pred_prob) %>%
  auc() %>%
  as.numeric()

write.csv(val_metrics, "val_metrics.csv", row.names = FALSE)
write.csv(roc_obj_auc, "roc_auc", row.names = FALSE)

roc_data <- validation_results %>%
  roc_curve(truth, pred_prob2)
  
write.csv(roc_data, "roc_data.csv", row.names = FALSE)

ggplot(roc_data, aes(x = 1 - specificity, y = sensitivity)) +
  geom_line(color = "#1c61b6", size = 1) +
  geom_abline(lty = 2, color = "gray") +
  labs(
    title = "ROC Curve",
    x = "1 - Specificity",
    y = "Sensitivity"
  ) +
  theme_minimal() 
##use for r script visual for roc curve in PowerBI

featImport <- final_rf_model$variable.importance

importance_df <- data.frame(
    Feature = names(featImport),
    Importance = as.numeric(featImport)
  ) %>%
    arrange(desc(featImport))

write.csv(importance_df, "feature_importance.csv", row.names = FALSE)

  #####save feature importance data frame as csv and import to dashboard and use
  ##### ggplot code as R script visual
FI_plot <- ggplot(importance_df, aes(x = reorder(Feature, Importance), y = Importance)) +
    geom_bar(stat = "identity", fill = "steelblue") +
    coord_flip() +
    labs(title = "Feature Importance of Random Forest",
         x = "Features",
         y = "Importance Score") +
    theme_minimal() +
    theme(axis.text.y = element_text(angle = 0, hjust = 1))


###################testing data to import to powerbi for what-if parameters




