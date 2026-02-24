-- This code is provided solely for the personal and private use of students
-- taking CSC343 at the University of Toronto. Copying for purposes other
-- than this use is expressly prohibited. All forms of distribution of this
-- code, whether as given or with any changes, are expressly prohibited.

-- All of the files in this directory and all subdirectories are:
-- Copyright (c) 2026 Diane Horton, Emily Franklin and Marina Tawfik

-- NOTE: we have included some constraints in comments in cases where
-- enforcing the constraint using SQL would be costly. For all parts of A2,
-- you may assume that these constraints hold, unless we explicitly specify
-- otherwise. Don't make any additional assumptions, regarding constraints
-- not enforced by the schema, or provided in the comments.

DROP SCHEMA IF EXISTS Recommender CASCADE;
CREATE SCHEMA Recommender;
SET SEARCH_PATH TO Recommender;

CREATE DOMAIN RATING AS SMALLINT 
	CHECK (VALUE BETWEEN 1 AND 5);

-- An item for sale.
-- <IID> is the item's ID, 
-- <category> is the category to which this item belongs, 
-- <description> gives further details about the item, and
-- <price> is its current price.
CREATE TABLE Item (
	IID INT PRIMARY KEY,
	category VARCHAR(30) NOT NULL,
	description TEXT UNIQUE NOT NULL,
	price FLOAT NOT NULL CHECK (price >= 0)
);

-- A customer.
-- <CID> is the customer's ID, 
-- <email> is their email address, 
-- <last_name> and <first_name> make up their name, and
-- <title> is the title by which they prefer to be addressed, 
-- e.g., 'Ms', 'Dr.'. It may or may not include punctuation, 
-- and could be any string the customer wishes. 
-- It need not be a standard title.
CREATE TABLE Customer (
	CID INT PRIMARY KEY,
	email VARCHAR(300) NOT NULL UNIQUE,
	last_name VARCHAR(30) NOT NULL,
	first_name VARCHAR(30) NOT NULL,
	title VARCHAR(15) DEFAULT 'Customer'
);

-- A purchase by a customer.
-- (This could also be called an "order", but order is a keyword in SQL.)
-- <PID> is the ID for this purchase, 
-- <CID> is the ID of the customer who made the purchase, 
-- <checkout_time> is the timestamp when the purchase was made, 
-- <card_pan> is the credit card number, and 
-- <card_type> is the type of the card e.g., 'visa', 'mastercard', ... etc.
CREATE TABLE Purchase (
	PID INT PRIMARY KEY,
	CID INT NOT NULL REFERENCES Customer(CID),
	checkout_time TIMESTAMP NOT NULL,
	card_pan VARCHAR(20) NOT NULL,
	card_type VARCHAR(15) NOT NULL,
	UNIQUE (CID, checkout_time)
);

-- A line item on a particular purchase.
-- <PID> is the purchase ID, 
-- <IID> is the item that was ordered, 
-- <quantity> indicates how many of it was ordered. 
-- For instance, a customer might order three of the same t-shirt.
-- You may assume:
-- 	* Each Purchase has at least one LineItem recorded i.e.,
--	  i.e., Purchase[PID] \subseteq LineItem[PID].
CREATE TABLE LineItem (
	PID INT REFERENCES Purchase(PID),
	IID INT REFERENCES Item(IID),
	quantity INT NOT NULL CHECK (quantity > 0),
	PRIMARY KEY (PID, IID)
);

-- A customer's review of an item.
-- <CID> is the ID of the customer who gave the review, 
-- <IID> is ID of the item that they reviewed, 
-- <rating> is a numeric rating, and 
-- <comment> is a review comment that they may have 
-- given along with the rating.
CREATE TABLE Review (
	CID INT REFERENCES Customer(CID),
	IID INT REFERENCES Item(IID),
	rating RATING NOT NULL,
	comment TEXT DEFAULT NULL,
	PRIMARY KEY (CID, IID)
);

-- One customer's vote on the helpfulness of another customer's review.
-- <reviewer> is the ID of the customer whose review is being judged,
-- <IID> is the item they reviewed, 
-- <observer> is the ID of the customer who is judging reviewer's review, and
-- <helpfulness> indicates whether observer found the review helpful.
CREATE TABLE Helpfulness (
	reviewer INT REFERENCES Customer(CID),
	IID INT REFERENCES Item(IID),
	observer INT REFERENCES Customer(CID),
	helpfulness BOOLEAN NOT NULL,
	PRIMARY KEY (reviewer, IID, observer),
	FOREIGN KEY (reviewer, IID) REFERENCES Review(CID, IID)
);

------------------------ Derived tables used in part 3 ------------------------

-- <CID>'s of people who are considered elite customers.
CREATE TABLE EliteMember (
	CID INT PRIMARY KEY,
	FOREIGN KEY (CID) REFERENCES Customer(CID)
);

-- The <IID> of a popular item and its corresponding average rating
-- <avg_rating>.
-- Popular items are the two items from each category that have sold the 
-- highest number of units among all items in that category.
CREATE TABLE PopularItem (
	IID INT PRIMARY KEY,
	avg_rating FLOAT,
	FOREIGN KEY (IID) REFERENCES Item(IID)
);

-- The elite member <CID> gave popular item <IID> a rating <rating>.
CREATE TABLE EliteRating (
	CID INT,
	IID INT,
	rating RATING NOT NULL,
	PRIMARY KEY (CID, IID),
	FOREIGN KEY (CID) REFERENCES EliteMember(CID),
	FOREIGN KEY (IID) REFERENCES PopularItem(IID)
);