-- Создаем временную таблицу с данными о фактических продажах и доходе
CREATE TEMPORARY TABLE temp_sales_income AS
SELECT
    s.shop_name,
    p.product_name,
    SUM(sales_cnt) AS sales_fact,
    SUM(sales_cnt * p.price) AS income_fact
FROM
    (SELECT * FROM shop_dns
    UNION ALL
    SELECT * FROM shop_mvideo
    UNION ALL
    SELECT * FROM shop_sitilink) AS s
JOIN products p ON s.product_id = p.product_id
GROUP BY
    s.shop_name,
    p.product_name;

-- Создаем временную таблицу с данными о запланированных продажах
CREATE TEMPORARY TABLE temp_sales_plan AS
SELECT
    p.product_name,
    plan.shop_name,
    SUM(plan_cnt) AS sales_plan,
    SUM(plan_cnt * p.price) AS income_plan
FROM
    plan
JOIN products p ON plan.product_id = p.product_id
GROUP BY
    p.product_name,
    plan.shop_name;

-- Создаем итоговую таблицу
CREATE TABLE sales_comparison AS
SELECT
    ts.shop_name,
    ts.product_name,
    ts.sales_fact,
    tp.sales_plan,
    CASE
        WHEN tp.sales_plan > 0 THEN ts.sales_fact / tp.sales_plan
        ELSE NULL
    END AS sales_fact_sales_plan_ratio,
    ts.income_fact,
    tp.income_plan,
    CASE
        WHEN tp.income_plan > 0 THEN ts.income_fact / tp.income_plan
        ELSE NULL
    END AS income_fact_income_plan_ratio
FROM
    temp_sales_income ts
LEFT JOIN temp_sales_plan tp ON ts.shop_name = tp.shop_name AND ts.product_name = tp.product_name;
