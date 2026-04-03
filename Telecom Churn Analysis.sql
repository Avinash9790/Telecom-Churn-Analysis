-- 1. OVERALL KPIs
SELECT 
    COUNT(*) as total_customers,
    ROUND(AVG(tenure),1) as avg_tenure,
    ROUND(AVG(MonthlyCharges),2) as avg_monthly_charge,
    ROUND(AVG(TotalCharges),2) as avg_total_charge,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn;

-- 2. CHURN BY GENDER
SELECT 
    gender,
    COUNT(*) as customer_count,
    ROUND(AVG(tenure),1) as avg_tenure,
    ROUND(AVG(MonthlyCharges),2) as avg_monthly,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
GROUP BY gender;

-- 3. CHURN BY SENIOR CITIZEN
SELECT 
    SeniorCitizen,
    COUNT(*) as customer_count,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
GROUP BY SeniorCitizen;

-- 4. CHURN BY CONTRACT TYPE
SELECT 
    Contract,
    COUNT(*) as customer_count,
    ROUND(AVG(tenure),1) as avg_tenure,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- 5. CHURN BY INTERNET SERVICE
SELECT 
    InternetService,
    COUNT(*) as customer_count,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

-- 6. CHURN BY PAYMENT METHOD
SELECT 
    PaymentMethod,
    COUNT(*) as customer_count,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- 7. TENURE DISTRIBUTION BY CHURN
SELECT 
    Churn,
    COUNT(*) as customer_count,
    ROUND(AVG(tenure),1) as avg_tenure,
    MIN(tenure) as min_tenure,
    MAX(tenure) as max_tenure
FROM churn 
GROUP BY Churn;

-- 8. MONTHLY CHARGES BY CHURN
SELECT 
    Churn,
    COUNT(*) as customer_count,
    ROUND(AVG(MonthlyCharges),2) as avg_monthly
FROM churn 
GROUP BY Churn;

-- 9. HIGH-RISK SEGMENTS (Multiple factors)
SELECT 
    SeniorCitizen,
    Contract,
    InternetService,
    COUNT(*) as customer_count,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
WHERE SeniorCitizen=1 OR Contract='Month-to-month' OR InternetService='Fiber optic'
GROUP BY SeniorCitizen, Contract, InternetService
HAVING COUNT(*) >= 50
ORDER BY churn_rate_pct DESC;

-- 10. TOP 5 CHURN DRIVERS (Single factors)
WITH churn_analysis AS (
    SELECT 
        gender, SeniorCitizen, Contract, InternetService, PaymentMethod, PaperlessBilling,
        COUNT(*) as cnt,
        SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) as churn_cnt,
        ROUND(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*),2) as churn_pct
    FROM churn 
    GROUP BY gender, SeniorCitizen, Contract, InternetService, PaymentMethod, PaperlessBilling
)
SELECT * FROM churn_analysis 
ORDER BY churn_pct DESC 
LIMIT 5;

-- 11. RETENTION ANALYSIS - LOW TENURE CUSTOMERS
SELECT 
    tenure,
    COUNT(*) as customer_count,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
WHERE tenure <= 12
GROUP BY tenure
ORDER BY tenure;

-- 12. PAPERLESS BILLING IMPACT
SELECT 
    PaperlessBilling,
    COUNT(*) as customer_count,
    ROUND(AVG(MonthlyCharges),2) as avg_monthly,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
GROUP BY PaperlessBilling;

-- 13. SERVICE BUNDLE IMPACT
SELECT 
    CASE 
        WHEN OnlineSecurity='No internet service' THEN 'No Internet'
        WHEN TechSupport='No internet service' THEN 'No Internet'
        ELSE 'Has Internet Services'
    END as service_bundle,
    COUNT(*) as customer_count,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
GROUP BY service_bundle;

-- 14. MONTH-TO-MONTH CHURNERS PROFILE
SELECT 
    AVG(tenure) as avg_tenure,
    ROUND(AVG(MonthlyCharges),2) as avg_monthly,
    ROUND(AVG(TotalCharges),2) as avg_total,
    COUNT(*) as customer_count
FROM churn 
WHERE Contract='Month-to-month' AND Churn = 1;

-- 15. FIBER OPTIC CHURNERS PROFILE
SELECT
    AVG(tenure) as avg_tenure,
    ROUND(AVG(MonthlyCharges),2) as avg_monthly,
    COUNT(*) as customer_count
FROM churn 
WHERE InternetService='Fiber optic' AND Churn = 1;

-- 16. COHORT ANALYSIS - TENURE GROUPS
SELECT 
    CASE 
        WHEN tenure <= 12 THEN '0-12 months'
        WHEN tenure <= 24 THEN '13-24 months'
        WHEN tenure <= 36 THEN '25-36 months'
        ELSE '37+ months'
    END as tenure_group,
    COUNT(*) as customer_count,
    ROUND((SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END)*100.0/COUNT(*)),2) as churn_rate_pct
FROM churn 
GROUP BY tenure_group
ORDER BY churn_rate_pct DESC;

-- 17. REVENUE IMPACT OF CHURN
SELECT 
    Churn,
    COUNT(*) as customer_count,
    ROUND(SUM(MonthlyCharges),2) as total_monthly_revenue,
    ROUND(SUM(TotalCharges),2) as total_lifetime_revenue,
    ROUND(AVG(MonthlyCharges),2) as avg_monthly_per_customer
FROM churn 
GROUP BY Churn;

-- 18. PREDICTIVE SEGMENT - HIGH CHURN RISK
SELECT 
    customerID,
    tenure,
    MonthlyCharges,
    CASE 
        WHEN tenure <= 6 
             AND Contract = 'Month-to-month' 
             AND (InternetService = 'Fiber optic' OR SeniorCitizen = 1)
        THEN 'HIGH RISK'
        WHEN tenure <= 12 AND Contract = 'Month-to-month'
        THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END as churn_risk_score
FROM churn 
WHERE Churn = 1
ORDER BY tenure ASC;

-- 19. COMPARISON - RETAINED vs CHURNED (Key Metrics)
SELECT 
    'Churned' as customer_type,
    COUNT(*) as customer_count,
    ROUND(AVG(tenure),1) as avg_tenure_months,
    ROUND(AVG(MonthlyCharges),2) as avg_monthly_revenue,
    ROUND(AVG(TotalCharges),2) as avg_ltv
FROM churn WHERE Churn = 1
UNION ALL
SELECT 
    'Retained' as customer_type,
    COUNT(*) as customer_count,
    ROUND(AVG(tenure),1) as avg_tenure_months,
    ROUND(AVG(MonthlyCharges),2) as avg_monthly_revenue,
    ROUND(AVG(TotalCharges),2) as avg_ltv
FROM churn WHERE Churn = 0
ORDER BY avg_tenure_months DESC;

-- 20. EXECUTIVE SUMMARY
SELECT 
    'Churn Analysis Summary' as metric_category,
    ROUND((SELECT COUNT(*) FROM churn WHERE Churn = 1)*100.0/(SELECT COUNT(*) FROM churn),2) as overall_churn_rate_pct,
    ROUND((SELECT AVG(tenure) FROM churn WHERE Churn = 1),1) as avg_churner_tenure,
    ROUND((SELECT SUM(MonthlyCharges) FROM churn WHERE Churn = 1),2) as lost_monthly_revenue,
    (SELECT Contract FROM churn WHERE Churn = 1 GROUP BY Contract ORDER BY COUNT(*)*100.0/COUNT(*) DESC LIMIT 1) as highest_churn_contract;