-- SALE!SALE!SALE!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;


-- Sale: 20% off only on items that have sold at least 10 units (total quantity).
UPDATE Item
SET price = price * 0.8
WHERE IID IN (
    SELECT IID
    FROM LineItem
    GROUP BY IID
    HAVING SUM(quantity) >= 10
);

