"""
Part3 of csc343 A2: a recommender for online shopping.
csc343, Winter 2026
University of Toronto

--------------------------------------------------------------------------------
This file is Copyright (c) 2026
    Diane Horton, Emily Franklin and Marina Tawfik.
All forms of distribution, whether as given or with any changes, are
expressly prohibited.
--------------------------------------------------------------------------------
"""
import psycopg2 as pg
import psycopg2.extensions as pg_ext
from typing import Optional


class Recommender:
    """A simple recommender that can work with data conforming to the schema in
    schema.sql.

    === Instance Attributes ===
    connection: Connection to a database of online purchases and product
        recommendations.

    Representation invariants:
    - The database to which connection is established conforms to the schema
      in schema.sql.
    """
    connection: Optional[pg_ext.connection]

    def __init__(self) -> None:
        """Initialize this Recommender, with no database connection yet.
        """
        self.connection = None

    def connect(self, dbname: str, username: str, password: str) -> bool:
        """Establish a connection to the database <dbname> using the
        username <username> and password <password>, and assign it to the
        instance attribute <connection>. In addition, set the search path to
        recommender.

        Return True if the connection was made successfully, False otherwise.
        I.e., do NOT throw an error if making the connection fails.

        >>> rec = Recommender()
        >>> # This example will work for you if you change the arguments as
        >>> # appropriate for your account.
        >>> rec.connect("csc343h-dianeh", "dianeh", "")
        True
        >>> # In this example, the connection cannot be made.
        >>> rec.connect("nonsense", "silly", "junk")
        False
        """
        try:
            self.connection = pg.connect(
                dbname=dbname, user=username, password=password,
                options="-c search_path=recommender,public"
            )
            return True
        except pg.Error:
            return False

    def disconnect(self) -> bool:
        """Close the database connection.

        Return True if closing the connection was successful, False otherwise.
        I.e., do NOT throw an error if closing the connection failed.

        >>> rec = Recommender()
        >>> # This example will work for you if you change the arguments as
        >>> # appropriate for your account.
        >>> rec.connect("csc343h-dianeh", "dianeh", "")
        True
        >>> rec.disconnect()
        True
        """
        try:
            if not self.connection.closed:
                self.connection.close()
            return True
        except pg.Error:
            return False

    def repopulate(self) -> bool:
        """Repopulate the database tables that store a snapshot of information
        derived from the base tables. To simplify your task, assume that table
        EliteMember has been populated correctly. You are required to populate
        PopularItem and EliteRating by doing the following:
            1. Remove all tuples from both tables.
            2. Repopulate each table based on the current contents of the
               database as described below.

        Return True if the repopulation was successful, False otherwise.
        I.e., do NOT throw an error if an error occurs.

        PopularItem:
            For each category in our database, find the items with the highest
            and second-highest total number of units sold among all items
            in that category. Only consider items that sold at least one unit.
            If there are ties, include them all.
            You also need to record the average rating for each popular item.
            If an item was never rated, its average rating is NULL.

        EliteRating:
            A tuple in this relation indicates that an elite member rated
            a popular item and gave it a specific rating.
            Note that this table should be empty if either the EliteMember
            or PopularItem tables are empty, or if none of the elite members
            ever rated any item.

        Precondition:
           - Assume that EliteMember has been populated correctly.
        """
        # TODO - complete this method

        try:
            pass
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            return False

    def recommend_generic(self, k: int) -> Optional[list[int]]:
        """Return the item IDs of the <k> recommended items.

        An item is recommended if its average rating is among the top <k>
        average ratings for items in the PopularItem table.
        If there are not enough rated popular items, there may be fewer than
        <k> items in the returned list.
        If there are ties among the highly rated popular items, there may be
        more than <k> items that could be returned. In that case, order these
        items by item ID (lowest to highest) and take the lowest <k>.

        The net effect is that the number of items returned will be <= <k>.

        Note: An average rating of NULL is considered lower than an average
        rating of 0.

        Return None if an error occurs i.e., do NOT throw an error.

        Preconditions:
            - <k> > 0
            - Recommender.repopulate has been called at least once.
              That means that you should NOT call repopulate in this method.
              It also means that you can get full credit for this method even if
              you didn't implement Recommender.repopulate.
        """
        # TODO - complete this method

        try:
            pass
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            return None

    def recommend(self, cust: int, k: int) -> Optional[list[int]]:
        """Return the item IDs of the <k> recommended items for customer <cust>
        based on the algorithm outlined below.

        Choose the recommendations as follows:
        1. Find <cust>'s "elite analogous rater". To do that, you will need to
           calculate the "average rating difference" between <cust> and every
           elite member in the EliteMember table:

           a. For each item in the PopularItem table that was rated by both
              <cust> and the elite member, find the absolute difference between
              <cust>'s rating and the elite member's rating of the item, as
              indicated in the EliteRating table.
           b. The "average rating difference" between <cust> and an elite member
              is the average of these ratings differences.
              Consequently, if an elite member and <cust> have no ratings
              in common, their "average rating difference" is NULL.

           <cust>'s "elite analogous rater" is the elite member with the
           lowest non-NULL "average rating difference".
           In the case of ties, select the elite member with the lower CID.

        2. Out of ALL the items (not just popular items) that the
           "elite analogous rater" has ever rated but <cust> has never bought,
           recommend the top <k> products that this "elite analogous rater"
           has rated highest.
           If there are not enough products rated by this
           "elite analogous rater", there may be fewer than <k> items in the
           returned list.
           If there are ties among their top-rated items, there may be more
           than <k> items that could be returned.
           In that case, order these items by item ID (lowest to highest) and
           take the lowest <k>.
           The net effect is that the number of items returned will be <= <k>.

        If <cust> does not have an "elite analogous rater", or if <cust> has
        already bought all the items that are rated by their
        "elite analogous rater", then return generic recommendations.

        Note: An average rating of NULL is considered lower than an average
        rating of 0.

        Return None if an error occurs i.e., do NOT throw an error.

        Preconditions:
            - <k> > 0
            - <cust> is a CID that exists in the database and is not in the
              EliteMember table.
            - Recommender.repopulate has been called at least once.
              That means that you should NOT call repopulate in this method.
              It also means that you can get full credit for this method even if
              you didn't implement Recommender.repopulate.
        """
        # TODO - complete this method

        try:
            pass
        except pg.Error as ex:
            # You may find it helpful to uncomment this line while debugging,
            # as it will show you all the details of the error that occurred:
            # raise ex
            return None


if __name__ == "__main__":
    # Un comment-out the next two lines if you would like all the doctest
    # examples (see ">>>" in the method and class docstrings) to be run
    # and checked.
    # import doctest
    # doctest.testmod()

    # You can add testing code here or even better, add your tests in a
    # separate file like we do in test_preliminary.py.
    pass