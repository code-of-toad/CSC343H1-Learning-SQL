"""
Part3 of csc343 A2: Tests for A2 code.
csc343, Winter 2026
University of Toronto

--------------------------------------------------------------------------------
This file is Copyright (c) 2026 Diane Horton and Marina Tawfik.
All forms of distribution, whether as given or with any changes, are
expressly prohibited.
--------------------------------------------------------------------------------
"""
import pytest
from a2 import *
from psycopg2 import sql
from psycopg2.extras import execute_values


# TODO: Change the values of the following variables to connect to your
#  own database:
DB_NAME = "csc343h-username"
USER = "username"
PASSWORD = ""
# The following uses the relative paths to the schema file and the data file
# we have provided. For your own tests, you will want to make your own data
# files to use for testing.
SCHEMA_FILE = "../schema.ddl"
SAMPLE_DATA = "../data.sql"


def setup(schema_path: str, data_path: str) -> None:
    """Set up the testing environment by importing the schema file
    at <schema_path> and the file containing the data at <data_path>.

    <schema_path> and <data_path> are the relative/absolute paths to the files
    containing the schema and the data respectively.
    """
    connection, cursor, schema_file, data_file = None, None, None, None
    try:
        connection = pg.connect(
            dbname=DB_NAME, user=USER, password=PASSWORD,
            options="-c search_path=recommender"
        )
        cursor = connection.cursor()

        with open(schema_path, "r") as schema_file:
            cursor.execute(schema_file.read())

        with open(data_path, "r") as info_file:
            cursor.execute(info_file.read())

        connection.commit()
    except Exception as ex:
        connection.rollback()
        raise Exception(f"Couldn't set up environment for tests: \n{ex}")
    finally:
        if cursor and not cursor.closed:
            cursor.close()
        if connection and not connection.closed:
            connection.close()


def get_rows(table_name: str) -> Optional[set[tuple]]:
    """Return the contents of the table <table_name> under our recommender
    schema.
    """
    conn, cur = None, None
    try:
        conn = pg.connect(
            dbname=DB_NAME, user=USER, password=PASSWORD,
            options="-c search_path=recommender"
        )
        cur = conn.cursor()
        cur.execute(sql.SQL("SELECT * FROM {}").format(
            sql.Identifier(table_name.lower())))
        return set(elem for elem in cur.fetchall())
    except pg.Error as ex:
        conn.rollback()
        raise Exception(f"Couldn't retrieve data from table {table_name}")
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


def insert_rows(table_name: str, rows: set[tuple]) -> bool:
    """Insert the tuples <rows> in table <table_name> under our recommender
    schema. Return False if an error occurs.
    """
    conn, cur = None, None
    try:
        conn = pg.connect(
            dbname=DB_NAME, user=USER, password=PASSWORD,
            options="-c search_path=recommender"
        )
        cur = conn.cursor()
        insert_query = sql.SQL("INSERT INTO {} VALUES %s").format(
            sql.Identifier(table_name.lower()))
        execute_values(cur, insert_query, list(rows))
    except pg.Error:
        conn.rollback()
        raise Exception(f"Couldn't populate table {table_name}")
    else:
        conn.commit()
        return True
    finally:
        if cur:
            cur.close()
        if conn:
            conn.close()


def test_repopulate_basic() -> None:
    """Test basic aspects of the A2 repopulate method.
    """
    a2 = Recommender()
    try:
        # The following function call will set up the testing environment by
        # loading a fresh copy of the schema and the sample data we have
        # provided into your database. You can create more sample data files
        # and call the same function to load them into your database.
        setup(SCHEMA_FILE, SAMPLE_DATA)

        connected = a2.connect(DB_NAME, USER, PASSWORD)

        # The following is an assert statement. It checks that the value for
        # connected is True. The message after the comma will be printed if
        # that is not the case (that is, if connected is False).
        # Use the same notation throughout your testing.
        assert connected, f"[Connect] Expected True | Got {connected}."

        # TODO: Add more test cases here, or better yet, make more testing
        #   functions, each testing a different aspect of the code.

        # ------------------------ Testing Repopulate ------------------------ #

        # Note: These results assume that the instance has already been
        # populated with the provided data e.g., using the setup function.

        # TEST: The EliteMember table is empty
        repopulated = a2.repopulate()
        assert repopulated, f"[Repopulate] Expected True | Got {repopulated}."

        # You can manually check the contents of your instance to make sure
        # it was updated correctly, or you can use the provided function
        # get_rows.
        actual_popular_items = get_rows("PopularItem")
        # Using sets because the order doesn't matter.
        expected_popular_items = {(2, None), (3, None), (5, None)}
        assert actual_popular_items == expected_popular_items, \
            "[Repopulate] PopularItem content is incorrect."

        actual_elite_ratings = get_rows("EliteRating")
        expected_elite_ratings = set()
        assert actual_elite_ratings == expected_elite_ratings, \
            "[Repopulate] EliteRating content is incorrect."

        # TEST: The EliteMember table includes one member.
        # For your other tests, you can include the contents of the EliteMember
        # as part of your data file. Alternatively, you can use the provided
        # function insert_rows.
        insert_rows("EliteMember", {(1518,)})

        repopulated = a2.repopulate()
        assert repopulated, f"[Repopulate] Expected True | Got {repopulated}."

        # You can manually check the contents of your instance to make sure
        # it was updated correctly, or you can use the provided function
        # get_rows.
        actual_popular_items = get_rows("PopularItem")
        # Using sets because the order doesn't matter.
        expected_popular_items = {(2, None), (3, None), (5, None)}
        assert actual_popular_items == expected_popular_items, \
            "[Repopulate] PopularItem content is incorrect."
        actual_elite_ratings = get_rows("EliteRating")
        expected_elite_ratings = set()
        assert actual_elite_ratings == expected_elite_ratings, \
            "[Repopulate] EliteRating content is incorrect."
    finally:
        a2.disconnect()


def test_recommend_generic_basic() -> None:
    """Test basic aspects of the A2 recommend_generic method.
    """
    a2 = Recommender()
    try:
        # The following function call will set up the testing environment by
        # loading a fresh copy of the schema and the sample data we have
        # provided into your database. You can create more sample data files
        # and call the same function to load them into your database.
        setup(SCHEMA_FILE, SAMPLE_DATA)

        connected = a2.connect(DB_NAME, USER, PASSWORD)

        # The following is an assert statement. It checks that the value for
        # connected is True. The message after the comma will be printed if
        # that is not the case (that is, if connected is False).
        # Use the same notation throughout your testing.
        assert connected, f"[Connect] Expected True | Got {connected}."

        # TODO: Add more test cases here, or better yet, make more testing
        #   functions, each testing a different aspect of the code.

        # --------------------- Testing Recommend Generic -------------------- #

        # Note: These results assume that the instance has already been
        # populated with the provided data e.g., using the setup function.

        # Note: You can call repopulate first. I manually populate the
        # PopularItem table so that you can test this method even if you are not
        # done implementing repopulate.
        # For your other tests, you can include the contents of the PopularItem
        # table as part of your data file. Alternatively, you can use the
        # provided function insert_rows like I do here.

        # TEST: The PopularItem table is empty
        actual_recommended = a2.recommend_generic(3)
        expected_recommended = []
        assert actual_recommended == expected_recommended, \
            f"[Recommend Generic] "\
            f"Expected {expected_recommended} | Got {actual_recommended}."

        # TEST: The PopularItem table is not empty
        insert_rows("PopularItem", {(2, 3.5), (4, 3.5), (3, 2.5)})

        actual_recommended = a2.recommend_generic(2)
        expected_recommended = [2, 4]
        assert actual_recommended == expected_recommended, \
            f"[Recommend Generic] " \
            f"Expected {expected_recommended} | Got {actual_recommended}."
    finally:
        a2.disconnect()


def test_recommend_basic() -> None:
    """Test basic aspects of the A2 recommend method.
    """
    a2 = Recommender()
    try:
        # The following function call will set up the testing environment by
        # loading a fresh copy of the schema and the sample data we have
        # provided into your database. You can create more sample data files
        # and call the same function to load them into your database.
        setup(SCHEMA_FILE, SAMPLE_DATA)

        connected = a2.connect(DB_NAME, USER, PASSWORD)

        # The following is an assert statement. It checks that the value for
        # connected is True. The message after the comma will be printed if
        # that is not the case (that is, if connected is False).
        # Use the same notation throughout your testing.
        assert connected, f"[Connect] Expected True | Got {connected}."

        # TODO: Add more test cases here, or better yet, make more testing
        #   functions, each testing a different aspect of the code.

        # ------------------------ Testing Recommend ------------------------- #

        # Note: These results assume that the instance has already been
        # populated with the provided data e.g., using the setup function.

        # Note: You can call repopulate first. I manually populate the
        # EliteMember, PopularItem and EliteRating tables so that you can test
        # this method even if you are not done implementing repopulate.
        # For your other tests, you can include the contents of these
        # tables as part of your data file. Alternatively, you can use the
        # provided function insert_rows like I do here.

        # TEST: No elite members
        insert_rows("PopularItem", {(2, 3.5), (4, 3.5), (3, 2.5)})

        actual_recommended = a2.recommend(1599, 2)
        expected_recommended = [2, 4]
        assert actual_recommended == expected_recommended, \
            f"[Recommend] "\
            f"Expected {expected_recommended} | Got {actual_recommended}."

    finally:
        a2.disconnect()


if __name__ == "__main__":
    pytest.main()
