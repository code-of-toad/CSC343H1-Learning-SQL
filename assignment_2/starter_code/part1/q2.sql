-- Helpfulness


-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;
DROP TABLE IF EXISTS q2 CASCADE;

create table q2(
    CID INTEGER,
    name TEXT NOT NULL,
    helpfulness_category TEXT NOT NULL
);

-- You may find it convenient to do this for each of the views
-- that define your intermediate steps. (But give them better names!)
DROP VIEW IF EXISTS IntermediateStep CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW IntermediateStep AS ... ;



-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q2