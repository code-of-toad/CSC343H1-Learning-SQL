-- Unrated products


-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF exists q1 CASCADE;

CREATE TABLE q1(
    CID INTEGER,
    first_name TEXT NOT NULL,
	last_name TEXT NOT NULL,
    email TEXT	
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps. (But give them better names!)
DROP VIEW IF EXISTS UnratedItem CASCADE;
DROP VIEW IF EXISTS UnratedItemBoughtByMultiple CASCADE;
DROP VIEW IF EXISTS CustomersWithUnratedProduct CASCADE;

-- Unrated product = item that has no reviews from anyone
CREATE VIEW UnratedItem AS
SELECT i.IID
FROM Item i
WHERE NOT EXISTS (SELECT 1 FROM Review r WHERE r.IID = i.IID);

-- Unrated items that have been purchased by at least 2 different customers
CREATE VIEW UnratedItemBoughtByMultiple AS
SELECT li.IID
FROM LineItem li
JOIN Purchase p ON p.PID = li.PID
WHERE li.IID IN (SELECT IID FROM UnratedItem)
GROUP BY li.IID
HAVING COUNT(DISTINCT p.CID) >= 2;

-- Customers who purchased at least one such unrated product (popular unrated)
CREATE VIEW CustomersWithUnratedProduct AS
SELECT DISTINCT p.CID
FROM Purchase p
JOIN LineItem li ON p.PID = li.PID
WHERE li.IID IN (SELECT IID FROM UnratedItemBoughtByMultiple);

INSERT INTO q1
SELECT c.CID, c.first_name, c.last_name, c.email
FROM Customer c
WHERE c.CID IN (SELECT CID FROM CustomersWithUnratedProduct);