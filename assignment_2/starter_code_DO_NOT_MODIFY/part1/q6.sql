--Year-over-year sales

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q6 CASCADE;

CREATE TABLE q6 (
    IID INT NOT NULL,
    year1 INT NOT NULL,
    year1_avg FLOAT NOT NULL,
    year2 INT NOT NULL,
    year2_avg FLOAT NOT NULL,
    yoy_change FLOAT NOT NULL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps. (But give them better names!)
DROP VIEW IF EXISTS IntermediateStep CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW IntermediateStep AS ... ;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q6