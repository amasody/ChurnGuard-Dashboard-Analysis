## Install the required packages (run this only if you don't have the packages installed already)
install.packages(c( "tidymodels", "parsnip", "workflows", "ggrepel", 
  "ranger", "yardstick", "forcats", "pROC"))

# Load necessary libraries
library(tidymodels)  # A framework for modeling and machine learning that unifies various packages.
library(parsnip)     # Part of tidymodels; used for creating models in a unified interface.
library(workflows)   # Manages the entire workflow of preprocessing, fitting models, and making predictions.
library(ggrepel)     # Enhances ggplot2 visualizations by adding labels that don't overlap, useful for feature importance plots.
library(ranger)      # A fast implementation of the random forest algorithm, used for predictive modeling.
library(yardstick)   # Provides functions for assessing the performance of machine learning models.
library(forcats)     # Simplifies working with categorical variables (factors), especially for encoding.
library(pROC)        # Used to analyze and visualize the performance of binary classification models, especially ROC curves.

# Package explanations:

# tidymodels: Provides an integrated system of packages for modeling, streamlining the process from data preprocessing to model evaluation.
# parsnip: Offers a simple way to specify different machine learning models (linear regression, random forest, etc.).
# workflows: Helps combine preprocessing steps (like scaling/encoding) and model specification into a streamlined workflow.
# ggrepel: Makes it easier to add non-overlapping text labels in ggplot visualizations, important for feature importance or data points.
# ranger: Fast random forest implementation, used for building the predictive churn model.
# yardstick: Assists in calculating performance metrics (accuracy, precision, etc.) for models, used to compare model performance.
# forcats: Makes handling categorical (factor) variables easier, crucial for preparing the dataset for model fitting.
# pROC: Used for plotting ROC curves to evaluate the classification models (random forest vs linear models).

# Note: Ensure you have these packages installed before running the script. If not, use the install.packages() commands at the top to install them.
