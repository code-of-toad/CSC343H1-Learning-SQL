-- Fraud Prevention

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO Recommender;


-- You may find it convenient to do this for each of the views
-- that define your intermediate steps. (But give them better names!)
DROP VIEW IF EXISTS IntermediateStep CASCADE;

-- Define views for your intermediate steps here:
CREATE VIEW IntermediateStep AS ... ;
