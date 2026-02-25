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
DROP VIEW IF EXISTS Bought CASCADE;
DROP VIEW IF EXISTS CustomersWithUnratedProduct CASCADE;

-- (CID, IID) pairs: items each customer has purchased
CREATE VIEW Bought AS
SELECT DISTINCT p.CID, li.IID
FROM Purchase p
JOIN LineItem li ON p.PID = li.PID;

-- Customers who bought at least one item they did not review
CREATE VIEW CustomersWithUnratedProduct AS
SELECT DISTINCT b.CID
FROM Bought b
WHERE NOT EXISTS (
    SELECT 1 FROM Review r
    WHERE r.CID = b.CID AND r.IID = b.IID
);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1
SELECT c.CID, c.first_name, c.last_name, c.email
FROM Customer c
WHERE c.CID IN (SELECT CID FROM CustomersWithUnratedProduct);