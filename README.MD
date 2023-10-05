1. Вам выпала редкая возможность — помочь аналитикам оценить эффективность планирования продаж линейки отечественных смартфонов. Линейка насчитывает целых 3 модели: «Испорченный телефон», «Сарафанное радио» и «Патефон». Вы неплохого прокачали ваших аналитиков в SQL, и они даже смогли соорудить подобную конструкцию (см. выше). Однако она не лишена недостатков — в ней отсутствует одна важная связующая деталь (таблица). Добавить недостающую деталь будет вашим первым заданием. 

Решение:
Добавим таблицу "sales_forecast", которая будет содержать информацию о прогнозируемом спросе на каждый товар в каждом магазине на определенный период времени. 

Структура таблицы "sales_forecast" будет следующей:

sales_forecast (product_id, shop_name, forecast_date, forecasted_sales)

Где:

    "product_id" - идентификатор товара, который будет связан с таблицей "products".
    "shop_name" - название магазина, который будет связан с таблицами "shop_dns", "shop_mvideo", и "shop_sitilink".
    "forecast_date" - дата, на которую делается прогноз продаж.
    "forecasted_sales" - прогнозируемое количество продаж товара в данном магазине на указанную дату.

Эта таблица позволит управлять планированием продаж, предсказывать будущий спрос на товары и принимать решения на основе прогнозов.

2.     После того как схема приобретет законченный вид, вам необходимо решить главную задачу — собрать вашу первую витрину! Как уже изначально было озвучено, аналитикам нужно оценить, насколько отдел планирования хорошо делает свою работу. Для этого вам необходимо разработать SQL-скрипт, который формирует таблицу со следующим набором атрибутов:

shop_name — название магазина,
product_name — название товара,
sales_fact — количество фактических продаж на конец месяца,
sales_plan — количество запланированных продаж на конец месяца,
sales_fact/sales_plan — отношение количества фактических продаже к запланированному,
income_fact — фактический доход,
income_plan — планируемый доход,
income_fact/income_plan — отношение фактического дохода к запланированному.

Решение:
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


