USE bankchurn;

####'Churn by Gender'####
##Overall it seems that females have a high propensity to churn at approximately %28 vs the males %15.9 
SELECT Gender,
  COUNT(case when Exited = 1 then 1 end) as Churn,
  COUNT(case when Exited = 0 then 1 end) as Not_churn,
  COUNT(gender) as Total
  FROM `bankchurn`.`training.t`
  GROUP BY 1;
  
####"Made temp table for overall Churn Status table"####
  ##approximately 35k / 165k churn to current customer ratio###
  
  SELECT COUNT(CustomerId) AS Total_Churned
  FROM `bankchurn`.`training.t`
  WHERE Exited = 1;
  
####"Temp Table for Churn by age group"####
###Those over 40 years old seem to have a high propensity for churning##
  WITH temp_age AS(
	SELECT Exited,
		CASE
			WHEN Age > 10 and Age <= 30 THEN '11 - 30' 
			WHEN Age > 30 and Age <= 40 THEN '31 - 40'
			WHEN Age > 40 and Age <= 50 THEN '41 - 50'
			WHEN Age > 50 and Age <= 60 THEN '51 - 60'
			WHEN Age > 60 THEN '61 and Beyond'
		END AS age_group 
	From `bankchurn`.`training.t`)
    
    SELECT age_group,
    COUNT(CASE WHEN exited = 1 then 1 end) as Churn,
    COUNT(CASE WHEN exited = 0 then 1 end) as Not_Churn,
	ROUND((COUNT(CASE WHEN exited = 1 THEN 1 END) / COUNT(*) * 100), 2) AS Percentage
    FROM temp_age
    group by 1
    order by 1;
    
####"Churn by FICO Credit Score Type"####
##Relative uniform churn distribution among the credit score types##
WITH temp_cs AS(
	SELECT Exited,
		CASE
			WHEN CreditScore >= 800 THEN 'Exceptional'
            WHEN CreditScore > 740 and CreditScore <= 799 THEN 'Very Good'
			WHEN CreditScore > 670 and CreditScore <= 739 THEN 'Good'
            WHEN CreditScore > 580 and CreditScore <= 669 THEN 'Fair'
            WHEN CreditScore <= 579 THEN 'Poor'
		END AS cs_range 
	FROM `bankchurn`.`training.t`)
    
    SELECT cs_range,
    COUNT(CASE WHEN exited = 1 then 1 end) as Churn,
    COUNT(CASE WHEN exited = 0 then 1 end) as Not_Churn,
    ROUND((COUNT(CASE WHEN exited = 1 then 1 end) / COUNT(*) * 100), 2) as Percentage
    FROM temp_cs
    WHERE cs_range IS NOT NULL 
    GROUP BY cs_range
    ORDER BY FIELD(cs_range, 'Exceptional', 'Very Good', 'Good', 'Fair', 'Poor');
		
### ACTIVE OR INACTIVE MEMBER ###
##Inactive customers have a higher churn rate at %29.7 vs %12.5 for active ones##
WITH temp_active AS( 
	SELECT Exited,
		CASE
			WHEN IsActiveMember = 1 THEN 'Yes'
            ELSE 'No'
		END AS ActiveOrNot
	FROM `bankchurn`.`training.t`)
    
	SELECT ActiveOrnot,
	COUNT(CASE WHEN exited = 1 then 1 end) as Churn,
	COUNT(CASE WHEN exited = 0 then 1 end) as Not_Churn,
    ROUND((COUNT(CASE WHEN exited = 1 then 1 end) / COUNT(*) * 100), 2) as Percentage
    FROM temp_active
    GROUP BY 1
    ORDER BY 2;

### Churn Credit card holder? ###
##Around the same churn rate between %22.7 for non-credit card holders and %20.6 for credit card holders## 
WITH temp_crcard AS(
SELECT Exited,
	CASE
		WHEN HasCrCard = 1 then 'Yes'
        ELSE 'No'
	END AS CrCardHolder 
    FROM `bankchurn`.`training.t`)
   
	SELECT CrCardHolder,
    COUNT(CASE WHEN exited = 1 then 1 end) as Churn,
    COUNT(CASE WHEN exited = 0 then 1 end) as Not_Churn,
    ROUND((COUNT(CASE WHEN exited = 1 then 1 end) / COUNT(*) * 100), 2) as Percentage
    FROM temp_crcard
    GROUP BY 1
    ORDER BY 1;

    
### overall geographical distribution of churn ###
##Germany seems to have more than double the amount of total customer churn##

SELECT (Geography) AS Countries,
COUNT(CASE WHEN exited = 1 then 1 end) as Churn,
COUNT(CASE WHEN exited = 0 then 1 end) as Not_Churn,
ROUND((COUNT(CASE WHEN exited = 1 then 1 end) / COUNT(*) * 100), 2) as Percentage
FROM `bankchurn`.`training.t`
GROUP BY Geography;

### Churn by tenure  + balance ###
##The percentages of churn seem distributed, within a reasonable margin of error, around %20 however those with#
##0 years of tenure had a modest churn rate of %25 compared to the average 

SELECT tenure,
COUNT(CASE WHEN exited = 1 then 1 end) as Churn,
COUNT(CASE WHEN exited = 0 then 1 end) as Not_Churn,
Count(*) as Total,
ROUND((COUNT(CASE WHEN exited = 1 then 1 end) / COUNT(*) * 100), 2) as Percentage
FROM `bankchurn`.`training.t` 
GROUP BY tenure
ORDER BY tenure;

###estimated salary range and churn #####
##Did not find to much of a discernable difference in salary range in terms of churn rates##
WITH temp_salary AS(
    SELECT EstimatedSalary,
    CASE 
       WHEN Exited = 1 THEN 'Churn'
       ELSE 'Not Churn'
    END AS STATUS
    from `bankchurn`.`training.t`
    )
SELECT STATUS,
	   min(EstimatedSalary) as min,
	   avg(EstimatedSalary) as avg,
       max(EstimatedSalary) as max
From temp_salary
GROUP BY 1;

###Churn by number of products with bank##
##Seems to show significant increase in churn when customers have more than 2 products as well as a relatively high 
##churn rate in the customers with 1 product as they have the highest count of customers respectively##

Select NumOfProducts,
COUNT(CASE WHEN exited = 1 then 1 end) as Churn,
COUNT(CASE WHEN exited = 0 then 1 end) as Not_Churn,
ROUND((COUNT(CASE WHEN exited = 1 then 1 end) / COUNT(*) * 100), 2) as Percentage
from `bankchurn`.`training.t`
group by 1;
