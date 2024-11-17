from dotenv import load_dotenv
import os
import mysql.connector
from flask import Flask, jsonify
from mysql.connector import Error
from flask_cors import CORS

load_dotenv()


app = Flask(__name__)
app.secret_key = os.getenv("APP_SECRET_KEY")
CORS(app)


def get_db_connection():
    try:
        db_host = os.getenv("DB_HOST")
        db_user = os.getenv("DB_USER")
        db_password = os.getenv("DB_PASSWORD")
        db_name = os.getenv("DB_NAME")

        connection = mysql.connector.connect(
            host=db_host,
            user=db_user,
            password=db_password,
            database=db_name,
        )

        if connection.is_connected():
            print("Database connection established successfully!")
            return connection

    except mysql.connector.Error as err:
        print(f"Database connection error: {err}")
        return None


@app.route("/")
def index():
    return "This is bibliora's backend"


@app.route("/users")
def get_users():
    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT * FROM User")
    users = cursor.fetchall()
    cursor.close()
    connection.close()
    return jsonify({"users": users})


@app.route("/books")
def get_books():
    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = connection.cursor(dictionary=True)
    cursor.execute(
        """
        SELECT 
            Book.ISBN, 
            Book.Title, 
            Book.Description, 
            Book.Format, 
            Book.DigitalLink,
            Book.DigitalVersion, 
            Book.BorrowLink, 
            Book.IsAvailableForBorrow,
            Author.Name AS Author,
            GROUP_CONCAT(Genre.Name) AS Genres
        FROM Book
        JOIN BookAuthor ON Book.ISBN = BookAuthor.BookISBN
        JOIN Author ON BookAuthor.AuthorID = Author.AuthorID
        LEFT JOIN BookGenre ON Book.ISBN = BookGenre.BookISBN 
        LEFT JOIN Genre ON BookGenre.GenreID = Genre.GenreID      
        GROUP BY Book.ISBN
    """
    )
    books = cursor.fetchall()
    cursor.close()
    connection.close()
    return jsonify({"books": books})


@app.route("/bookclubs")
def get_bookclubs():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT * FROM BookClub")
    bookclubs = cursor.fetchall()
    connection.close()
    return jsonify({"bookclubs": bookclubs})


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
