-- Hyperconsumers

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
    year VARCHAR(4) NOT NULL,
    name VARCHAR(65) NOT NULL,
    email VARCHAR(300) NOT NULL,
    items INTEGER NOT NULL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps. (But give them better names!)
DROP VIEW IF EXISTS IntermediateStep CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW IntermediateStep AS ... ;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5
