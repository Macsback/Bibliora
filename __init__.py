from dotenv import load_dotenv
import os
import mysql.connector
from flask import Flask, jsonify, request, render_template
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
            ssl_disabled=True,
        )

        if connection.is_connected():
            print("Database connection established successfully!")
            return connection

    except mysql.connector.Error as err:
        print(f"Database connection error: {err}")
        return None


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/users", methods=["GET"])
@app.route("/users/<int:user_id>", methods=["GET"])
def get_user(user_id=None):
    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)

    if user_id is not None:
        # Fetch a specific user by ID
        query = "SELECT * FROM User WHERE UserID = %s"
        cursor.execute(query, (user_id,))
        result = cursor.fetchone()

        if result:  # Format the MemberSince field
            if result.get("MemberSince"):
                result["MemberSince"] = result["MemberSince"].strftime("%Y-%m-%d")
            return jsonify({"user": result}), 200
        else:
            return jsonify({"error": "User not found"}), 404
    else:
        # Fetch all users
        query = "SELECT * FROM User"
        cursor.execute(query)
        results = cursor.fetchall()

        # Format MemberSince field for all users
        for user in results:
            if user.get("MemberSince"):
                user["MemberSince"] = user["MemberSince"].strftime("%Y-%m-%d")

        return jsonify({"users": results}), 200


@app.route("/books", methods=["GET"])
@app.route("/user_books/<int:user_id>", methods=["GET"])
def get_books(user_id=None):
    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = connection.cursor(dictionary=True)
    try:  # If user_id is provided, fetch user-specific books
        if user_id is not None:
            cursor.execute(
                """
                SELECT 
                    UserBook.UserID,
                    UserBook.BookISBN, 
                    Book.Title, 
                    Book.Description, 
                    Author.Name AS Author,
                    GROUP_CONCAT(Genre.Name) AS Genres,
                    UserBook.IsDownloaded,
                    UserBook.IsBorrowed,
                    UserBook.BorrowStartDate,
                    UserBook.BorrowEndDate
                FROM UserBook
                JOIN Book ON UserBook.BookISBN = Book.ISBN
                JOIN BookAuthor ON Book.ISBN = BookAuthor.BookISBN
                JOIN Author ON BookAuthor.AuthorID = Author.AuthorID
                LEFT JOIN BookGenre ON Book.ISBN = BookGenre.BookISBN 
                LEFT JOIN Genre ON BookGenre.GenreID = Genre.GenreID  
                WHERE UserBook.UserID = %s
                GROUP BY UserBook.UserID, UserBook.BookISBN
                """,
                (user_id,),
            )
            books = cursor.fetchall()
            response = {"user_books": books}
        else:  # If no user_id is provided, fetch all books
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
            response = {"books": books}
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500
    finally:
        cursor.close()
        connection.close()

    return jsonify(response)


@app.route("/bookclubs", methods=["GET"])
@app.route("/user_bookclubs/<int:user_id>", methods=["GET"])
def get_bookclubs(user_id=None):
    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)
    try:
        if user_id is not None:
            cursor.execute(
                """
                SELECT 
                    BookClub.BookClubID,
                    BookClub.Name AS BookClubName,
                    BookClub.Description
                FROM UserBookClub
                JOIN BookClub ON UserBookClub.BookClubID = BookClub.BookClubID
                WHERE UserBookClub.UserID = %s
                """,
                (user_id,),
            )
            bookclubs = cursor.fetchall()
            response = {"user_bookclubs": bookclubs}
        else:
            cursor.execute("SELECT * FROM BookClub")
            bookclubs = cursor.fetchall()
            response = {"bookclubs": bookclubs}

    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500
    finally:
        cursor.close()
        connection.close()

    return jsonify(response)


@app.route("/add_book/<int:user_id>", methods=["POST"])
def add_book(user_id=None):
    # Get the JSON data from the request
    data = request.get_json()

    # Extract the data
    title = data.get("Title")
    author = data.get("Author")
    genre = data.get("Genre")
    isbn = data.get("ISBN")
    format = data.get("Format")

    # Check if all required fields are provided
    if not all([title, author, genre, isbn, format]):
        return jsonify({"error": "Missing required fields"}), 400

    # Get database connection
    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    try:
        cursor = connection.cursor()

        # Check if the book already exists in the Book table
        cursor.execute("SELECT * FROM Book WHERE ISBN = %s", (isbn,))
        book = cursor.fetchone()

        if not book:
            # If book doesn't exist, insert it
            cursor.execute(
                "INSERT INTO Book (ISBN, Title, Format) VALUES (%s, %s, %s)",
                (isbn, title, format),
            )
            connection.commit()

        # Check if the author exists, if not, add it
        cursor.execute("SELECT * FROM Author WHERE Name = %s", (author,))
        author_data = cursor.fetchone()

        if not author_data:
            cursor.execute("INSERT INTO Author (Name) VALUES (%s)", (author,))
            connection.commit()
            author_id = cursor.lastrowid
        else:
            author_id = author_data[0]

        # Check if the genre exists, if not, add it
        cursor.execute("SELECT * FROM Genre WHERE Name = %s", (genre,))
        genre_data = cursor.fetchone()

        if not genre_data:
            cursor.execute("INSERT INTO Genre (Name) VALUES (%s)", (genre,))
            connection.commit()
            genre_id = cursor.lastrowid
        else:
            genre_id = genre_data[0]

        # Check if the combination of BookISBN and AuthorID already exists in BookAuthor table
        cursor.execute(
            "SELECT * FROM BookAuthor WHERE BookISBN = %s AND AuthorID = %s",
            (isbn, author_id),
        )
        book_author = cursor.fetchone()

        if not book_author:
            cursor.execute(
                "INSERT INTO BookAuthor (BookISBN, AuthorID) VALUES (%s, %s)",
                (isbn, author_id),
            )
            connection.commit()

        # Check if the combination of BookISBN and GenreID already exists in BookGenre table
        cursor.execute(
            "SELECT * FROM BookGenre WHERE BookISBN = %s AND GenreID = %s",
            (isbn, genre_id),
        )
        book_genre = cursor.fetchone()

        if not book_genre:
            cursor.execute(
                "INSERT INTO BookGenre (BookISBN, GenreID) VALUES (%s, %s)",
                (isbn, genre_id),
            )
            connection.commit()

        # Insert into UserBook table using the userId from the URL
        cursor.execute(
            "INSERT INTO UserBook (UserID, BookISBN) VALUES (%s, %s)", (user_id, isbn)
        )
        connection.commit()  # Commit the insertion to UserBook table

        return jsonify({"message": "Book successfully added"}), 200

    except Exception as e:
        connection.rollback()
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        connection.close()


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
