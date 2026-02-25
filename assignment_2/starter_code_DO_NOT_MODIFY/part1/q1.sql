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
DROP VIEW IF EXISTS IntermediateStep CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW IntermediateStep AS ... ;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1