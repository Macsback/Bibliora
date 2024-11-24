from dotenv import load_dotenv
import os
import mysql.connector
from flask import Flask, jsonify, request, render_template
from mysql.connector import Error
from flask_cors import CORS
import time
import uuid
from pubnub.pubnub import PubNub
from pubnub.pnconfiguration import PNConfiguration

load_dotenv()

app = Flask(__name__)
app.secret_key = os.getenv("APP_SECRET_KEY")
CORS(app)

LED_pin = 12
Buzzer_pin = 11

pnconfig = PNConfiguration()
pnconfig.subscribe_key = os.getenv("PUBNUB_SUBSCRIBE_KEY")
pnconfig.publish_key = os.getenv("PUBNUB_PUBLISH_KEY")
generated_uuid = str(uuid.uuid4())
pnconfig.uuid = generated_uuid

pubnub = PubNub(pnconfig)


# Function to check if running on a Raspberry Pi
def is_raspberry_pi():
    try:
        # Check if running on Raspberry Pi by looking for the 'model' file
        with open("/sys/firmware/devicetree/base/model", "r") as f:
            model = f.read().lower()
            return "raspberry pi" in model
    except IOError:
        return False


# Conditionally import RPi.GPIO only if running on a Raspberry Pi
if is_raspberry_pi():
    import RPi.GPIO as GPIO

    GPIO.setmode(GPIO.BOARD)
    GPIO.setup(LED_pin, GPIO.OUT)
    GPIO.setup(Buzzer_pin, GPIO.OUT)


@app.route("/")
def index():
    return render_template("index.html")


@app.route("/trigger", methods=["POST"])
def trigger_method():
    try:
        # Check if running on a Raspberry Pi
        if is_raspberry_pi():
            GPIO.output(LED_pin, True)
            time.sleep(0.5)
            GPIO.output(LED_pin, False)

            beep(6)

        response = {
            "message": "Success",
            "status": (
                "LED and Buzzer Triggered!"
                if is_raspberry_pi()
                else "Simulation LED and Buzzer Triggered!"
            ),
        }

        pubnub.publish().channel("PUBNUB_CHANNEL_NAME").message(response).sync()

        return jsonify(response)

    except Exception as e:
        return jsonify(message=f"Error: {str(e)}")


def beep(repeat):
    if is_raspberry_pi():
        for i in range(repeat):
            GPIO.output(Buzzer_pin, True)
            time.sleep(0.001)
            GPIO.output(Buzzer_pin, False)
    else:
        # Simulate beep in non-Raspberry Pi environments
        print("Beep simulated")


# Clean up GPIO if running on a Raspberry Pi
if is_raspberry_pi():
    GPIO.cleanup()


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


@app.route("/add_user_book/<int:user_id>", methods=["POST"])
def add_user_book(user_id=None):
    data = request.get_json()

    isbn = data.get("ISBN")

    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    try:
        cursor = connection.cursor()

        cursor.execute(
            "INSERT INTO UserBook (UserID, BookISBN) VALUES (%s, %s)", (user_id, isbn)
        )
        connection.commit()

        return jsonify({"message": "Book successfully added to UserBook"}), 200

    except Exception as e:
        connection.rollback()
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        connection.close()


@app.route("/add_book", methods=["POST"])
def add_book():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    # Hardcoded values for the book
    title = "Cleverlands"
    author = "Lucy Crehan"
    genres = "Education"
    isbn = "9781783524914"
    format = "digital"

    # Check if 'author' or 'genres' are missing or empty
    if not author or not genres:
        return (
            jsonify({"Author and Genre cannot be empty"}),
            400,
        )

    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    try:
        cursor = connection.cursor()

        # Add Book (hardcoded data)
        cursor.execute(
            "INSERT INTO Book (ISBN, Title, Description, Format, DigitalLink, DigitalVersion, BorrowLink, IsAvailableForBorrow) VALUES (%s, %s, '', %s, null, null, '', 1)",
            (isbn, title, format),
        )

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
        cursor.execute("SELECT * FROM Genre WHERE Name = %s", (genres,))
        genre_data = cursor.fetchone()

        if not genre_data:
            cursor.execute("INSERT INTO Genre (Name) VALUES (%s)", (genres,))
            connection.commit()
            genre_id = cursor.lastrowid
        else:
            genre_id = genre_data[0]

        # Add combination of BookISBN and GenreID
        cursor.execute(
            "INSERT INTO BookGenre (BookISBN, GenreID) VALUES (%s, %s)",
            (isbn, genre_id),
        )
        connection.commit()

        # Add combination of BookISBN and AuthorID
        cursor.execute(
            "INSERT INTO BookAuthor (BookISBN, AuthorID) VALUES (%s, %s)",
            (isbn, author_id),
        )
        connection.commit()

        return jsonify({"message": "Book successfully added"}), 200

    except Exception as e:
        connection.rollback()
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        connection.close()


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
