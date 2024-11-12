**ChurnGuard Dashboard and Analysis**

**Project Overview**

This project focuses on the analysis and prediction of banking customer churn using a dataset sourced from **Kaggle**. The goal was to explore the key factors influencing customer churn, develop a predictive model, and display the results in an interactive **Power BI** dashboard. This README outlines the workflow, including exploratory data analysis (EDA), data preprocessing, and model selection using **R**.

**Technologies Used**

- **MySQL**: Used for creating local host server to host dataset and perform initial exploratory data analysis by querying the dataset.
- **Power BI**: For data visualization and dashboard creation.
- **R**: For model creation, comparison of **linear regression** and **random forest** models, and generating feature importance plots.

**Setup Instructions**

To set up the project on your local machine:

1. **Clone the repository**: use “git clone &lt;<https://github.com/amasody/ChurnGuard-Analytics-Dashboard.git>&gt;"
2. **Setup MySQL**: Import the **bank_churn_train.csv** file from the repository into your MySQL instance, then run the queries to perform the initial exploratory analysis.
3. **Install R and required libraries**: Make sure R and RStudio are installed and run the **R Required Packages.R** file in R to install the necessary packages
4. **Run the R script**: Open **ChurnGuard R model.R** in RStudio and run the script to preprocess data, compare models, and build the random forest model. If you prefer to skip model training and use the pre-trained model, load the saved **random forest model** directly in R using the file location path: “model <- readRDS("Rf_model.RDS")”
5. **Power BI Service & R Script Visuals**: To display the R script visual used for churn prediction, users must have **R** and the necessary libraries installed on their local machines and import the **Rf_model.RDS** file using the file location path into the script used in the dashboard. An example script is in the **powerbi-churn-prediction.r** file
6. **Open PowerBI Dashboard**: Download BankChurnDash.pbix and open it in Power BI Desktop for full access to the interactive dashboard. Alternatively, if you have a Power BI Pro account, you can fully utilize the dashboard, including the predictor tool. Otherwise, you can still use the dashboard for exploratory analysis via the Power BI service: &lt;insert-link-here&gt;.

**Dataset**

The dataset was sourced from [**Kaggle**](https://www.kaggle.com/datasets/saurabhbadole/bank-customer-churn-prediction-dataset/data) and contains information on 165,000 customers of a bank. Key columns include:

- CreditScore: Customer’s credit score.
- Age: Customer’s age.
- Tenure: Duration of relationship with the bank.
- Geography: customer’s country of residence
- Balance: Account balance.
- NumOfProducts: Number of products the customer uses.
- HasCrCard: Whether the customer holds a credit card.
- IsActiveMember: Whether the customer is an active bank member.
- Exited: Whether the customer churned (1) or stayed (0).

**Exploratory Data Analysis (EDA)**

The **EDA** was performed initially in **MySQL** and then replicated in **Power BI** using **DAX** and **Power Query**.

The full MySQL query file with the commented analysis can be found in the project repository. Key findings from the EDA helped inform how to structure the **Power BI dashboard**:

- Age and NumOfProducts significantly affected the churn rate, especially when customers had a high number of products and those over the age of 40
- Customers with a balance of zero showed different churn behaviors, prompting further model exploration.

These insights shaped the design of the dashboard, including the use of **interactive slicers** to explore relationships between these variables and customer churn

**MySQL Queries and Analysis**

For a detailed view of the exploratory data analysis conducted using MySQL, please refer to the **EDA KPI SCRIPT.sql** included in the repository. This file contains:

- **Comments** on the queries used to examine key features of the dataset (customer churn by credit score, age group, and tenure).
- The **results of these queries** were used to shape the insights and design choices in the dashboard.

**Data Preprocessing**

The dataset was **relatively clean**, with no major missing values. It required minor preprocessing for modeling purposes, as detailed below.

**Handling Missing Values**

Although the dataset appeared clean, the mitigation for missing values was conducted by imputing the mean and mode for all numeric and nominal predictors as well as getting rid of zero variance variables with a singular value.

**Scaling and Normalization**

For continuous features like Age, CreditScore, Balance, and EstimatedSalary, **scaling** was applied to normalize the data for model training. This was particularly important for the **linear regression model**, where the range of features could otherwise bias the model.

**Encoding Categorical Variables**

The Exited column was refactored into “Churned” or “Not Churned” from binary values (0,1) for easier interpretation.

**Increasing Complexity of model recipe for Logistic Regression Models**

Created interaction term between Age and Tenure to see effect on logistic model. Also utilized Principle Component Analysis to potentially further optimize the logistic regression model by establishing an explained variance threshold of 0.8.

**Model Workflow**

The data was preprocessed to fit into a machine learning workflow in **R**, with steps including:

- **Splitting the dataset** into training and validation sets.
- **Cross-validation** to tune hyperparameters for both models (linear regression and random forest).
- **Comparison of model accuracy** using the **accuracy** metric.

**Model Comparison: Linear Regression vs. Random Forest**

Two machine learning models were implemented and compared:

- **Linear Regression**: A baseline model was constructed to predict customer churn, with added complexity (e.g., polynomial terms) to capture non-linear relationships. While it performed decently on simple features, it struggled to capture the underlying complexity of the data.
- **Random Forest**: A more robust, non-linear model was developed using the ranger package. This model significantly outperformed linear regression in terms of accuracy, feature importance insights, and predictive power.

![Model Accuracy Comparison](https://github.com/user-attachments/assets/0142991b-cdf0-4da6-8377-7fb1018010cc)

**Feature Importance**

The random forest model provided clear insights into which features were most critical in predicting customer churn:

- **Age**, **Balance**, and **Number of Products** emerged as the most important variables.

The **random forest model** was selected for integration into the Power BI dashboard due to its higher accuracy and interpretability.

**Dashboard Design**

The Power BI dashboard includes several features over two pages:

1. **Exploratory Data Analysis**: Displays key trends and insights from the EDA, including visualizations for churn by credit score, age group, tenure, average balance, and country

![EDABankChurnScreenshot](https://github.com/user-attachments/assets/9105315b-4935-4f68-bea3-cf1ee64a8106)

2. **Customer Segmentation**: Slicers and filters allow users to explore churn rates by various dimensions (gender, active status, and credit card holder status).
3. **Predictive Model**: Integrates the random forest model to predict the likelihood of churn based on user-defined inputs using the **rf_model.rds** file and displays supporting performance metrics.
    - **What-If Analysis**: Users can adjust the parameters age, balance, tenure, salary, # of products, credit score, active status, and country to see their impact on the churn prediction.

<img width="653" alt="BankChurnPBIScreenshot" src="https://github.com/user-attachments/assets/f2fb7862-bced-4cbd-8b79-6275d6838d36">

**Conclusion**

This project provided valuable insights into the drivers of customer churn by combining **MySQL** for exploratory data analysis, **Power BI** for interactive reporting, and machine learning models in **R**. Based on the **feature importance metrics** from the **random forest model** and the findings from the **exploratory data analysis (EDA)**, confirmed a few key patterns:

- The majority of **Customers between the age of 51-60** tend to have a higher likelihood of churning.
- All customers that have less than or more than **2 products** are at an increased risk of churn
- Customers that left the bank aggregately had a lower total sum of deposits as compared to the retained customers.

These insights suggest that future retention efforts should prioritize specific age ranges and those with multiple products, as these groups are at higher risk of churning. Additionally, targeted strategies to engage customers with lower average balances could improve retention rates, such as personalized marketing campaigns, special offers, or financial planning services.

Looking ahead, there are areas for improvement to further refine the model and insights:

- Implementing more advanced machine learning models, such as **XGBoost** or **neural networks**, could improve prediction accuracy.
- Automating the integration of the prediction model in a live environment would allow for real-time churn predictions.
- Expanding the dataset to include customer transactions or behavioral data could enhance the model's predictive power and provide a more holistic view of customer churn.

By focusing on these key customer segments and implementing more advanced tools, the bank could reduce churn rates and retain a higher proportion of its valuable customers.

**Project Files**

The repository contains the following files to reproduce the analysis and build the customer churn prediction model:

- **bank_churn_train.csv**: The training dataset from Kaggle containing the customer data
- **Churn KPI Scpript.sql**: Contains the MySQL queries used for initial exploratory data analysis (EDA). The file is annotated with comments explaining the key findings from the data and how those insights shaped the design of the dashboard.
- **ChurnGuard R model.R**: The R script containing the code used for preprocessing the data, training and evaluating the linear regression models, and building the final random forest model. The code includes comments for clarity and can be broken down if needed, but the script is designed to flow naturally as-is.
- **rf_model.RDS**: The saved random forest model, pre-tuned with hyperparameters for optimal accuracy. This file can be loaded directly into R for predictions without retraining.
- **BankChurnDash.pbix**: The Power BI dashboard file, which visualizes the customer churn data and includes an interactive predictor based on the random forest model. It uses DAX queries and slicers for dynamic reporting and parameter adjustments.
- **R Required Packages.R**: Lists all required R packages to ensure compatibility with the R script visuals in Power BI.
- **README.md**: This file, which provides an overview of the project, its setup, and usage instructions.
