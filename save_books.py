import mysql.connector
from mysql.connector import Error
import csv
from dotenv import load_dotenv
import os

# Load environment variables from .env file
load_dotenv()

# Get database credentials from environment variables
DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_NAME = os.getenv("DB_NAME")


# Function to connect to the MySQL database
def connect_to_db():
    try:
        connection = mysql.connector.connect(
            host=DB_HOST, user=DB_USER, password=DB_PASSWORD, database=DB_NAME
        )
        if connection.is_connected():
            print("Connected to the database.")
            return connection
    except Error as e:
        print(f"Error: {e}")
        return None


# Function to insert book details into the books table
def insert_book(connection, book_details):
    if not book_details["isbn"]:
        print(f"Skipping book with empty ISBN: {book_details['title']}")
        return None

    cursor = connection.cursor()
    cursor.execute(
        """
    INSERT INTO books (isbn, title, description, borrowlink, publish_year, cover_image_url)
    VALUES (%s, %s, %s, %s, %s, %s)
    ON DUPLICATE KEY UPDATE 
        title=VALUES(title), 
        description=VALUES(description),
        borrowlink=VALUES(borrowlink),
        publish_year=VALUES(publish_year),
        cover_image_url=VALUES(cover_image_url)
    """,
        (
            book_details["isbn"],
            book_details["title"],
            book_details["description"],
            book_details["borrow_link"],
            book_details["publish_year"],
            book_details["cover_image_url"],
        ),
    )

    connection.commit()
    return cursor.lastrowid


# Function to insert authors into the authors table
def insert_author(connection, author_name):
    cursor = connection.cursor()
    cursor.execute(
        "INSERT INTO authors (name) VALUES (%s) ON DUPLICATE KEY UPDATE name=VALUES(name)",
        (author_name,),
    )
    connection.commit()
    return cursor.lastrowid  # Return the author ID


# Function to insert genres into the genres table
def insert_genre(connection, genre_name):
    if not genre_name:
        return None

    cursor = connection.cursor()
    cursor.execute(
        """
        INSERT INTO genres (name)
        VALUES (%s)
        ON DUPLICATE KEY UPDATE name=VALUES(name)
        """,
        (genre_name,),
    )
    connection.commit()

    # Return the ID of the inserted or existing genre
    cursor.execute("SELECT genre_id FROM genres WHERE name = %s", (genre_name,))
    result = cursor.fetchone()
    return result[0] if result else None


# Function to insert book-author relationship into book_authors table
def insert_book_author(connection, isbn, author_id):
    cursor = connection.cursor()

    # Check if the relationship already exists
    cursor.execute(
        """
        SELECT COUNT(*) FROM book_authors WHERE book_isbn = %s AND author_id = %s
        """,
        (isbn, author_id),
    )
    result = cursor.fetchone()
    if result[0] > 0:
        print(f"Skipping duplicate entry for ISBN {isbn} and Author ID {author_id}")
        return

    # Insert the relationship if it doesn't exist
    cursor.execute(
        """
        INSERT INTO book_authors (book_isbn, author_id)
        VALUES (%s, %s)
        """,
        (isbn, author_id),
    )
    connection.commit()


def clean_invalid_genres(connection):
    cursor = connection.cursor()
    cursor.execute("DELETE FROM book_genres WHERE genre_id = 0;")
    connection.commit()


# Function to insert book-genre relationship into book_genres table
def insert_book_genre(connection, isbn, genre_id):
    if genre_id is None:
        return None

    cursor = connection.cursor()
    cursor.execute(
        """
        INSERT INTO book_genres (book_isbn, genre_id)
        VALUES (%s, %s)
        ON DUPLICATE KEY UPDATE book_isbn=VALUES(book_isbn), genre_id=VALUES(genre_id)
        """,
        (isbn, genre_id),
    )
    connection.commit()


# Function to process CSV files and save them to the database
def process_and_save_data():
    # Connect to the database
    connection = connect_to_db()
    if connection is None:
        return

    try:
        # Disable foreign key checks temporarily
        cursor = connection.cursor()
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
        connection.commit()

        # Open and process the books details CSV file
        with open(
            "novels_with_details.csv", mode="r", encoding="utf-8"
        ) as details_file:
            details_reader = csv.reader(details_file)
            next(details_reader)

            for row in details_reader:
                title, description, isbn, publish_year, cover_image_url, borrow_link = (
                    row
                )

                try:
                    publish_year = int(publish_year) if publish_year.isdigit() else None
                except ValueError:
                    publish_year = None

                # Insert book details
                book_details = {
                    "isbn": isbn,
                    "title": title,
                    "description": description,
                    "borrow_link": borrow_link,
                    "publish_year": publish_year,
                    "cover_image_url": cover_image_url,
                }
                insert_book(connection, book_details)

        # Open and process the authors CSV file
        with open("authors.csv", mode="r", encoding="utf-8") as authors_file:
            authors_reader = csv.reader(authors_file)
            next(authors_reader)  # Skip the header row

            for row in authors_reader:
                isbn, author_name = row

                # Insert the author and get their ID
                author_id = insert_author(connection, author_name)

                # Link book and author
                insert_book_author(connection, isbn, author_id)

        # Open and process the genres CSV file
        with open("genres.csv", mode="r", encoding="utf-8") as genres_file:
            genres_reader = csv.reader(genres_file)
            next(genres_reader)  # Skip the header row

            for row in genres_reader:
                isbn, genre_name = row

                # Insert the genre and get its ID
                genre_id = insert_genre(connection, genre_name)

                # Link book and genre
                clean_invalid_genres(connection)
                insert_book_genre(connection, isbn, genre_id)

        # Re-enable foreign key checks
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
        connection.commit()

    except Exception as e:
        print(f"Error processing data: {e}")
    finally:
        connection.close()
        print("Data has been saved to the database.")


# Call the function to process and save the data
process_and_save_data()
