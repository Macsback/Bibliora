import os
import time
import requests
from dotenv import load_dotenv

# Database and queries
from mysql.connector import Error
from db import get_db_connection
from queries import (
    get_all_users,
    get_user_by_id,
    get_books_by_user,
    get_all_books,
    get_bookclubs_by_user,
    get_all_bookclubs,
    insert_new_user,
)

# Flask and CORS
from flask import (
    Flask,
    jsonify,
    request,
    render_template,
    send_file,
    redirect,
    abort,
    url_for,
    session, 
    make_response,
)
from flask_cors import CORS
from io import BytesIO
from functools import wraps

# PubNub service
from pubnub_service import init_pubnub, publish_message

# Google Login
import google.auth.transport.requests
from datetime import datetime, timedelta
from flask_dance.contrib.google import make_google_blueprint, google

# JWT
from flask_jwt_extended import (
    JWTManager,
    jwt_required,
    create_access_token,
    get_jwt_identity,
    set_access_cookies,
)


load_dotenv()

# App
app = Flask(__name__)
app.secret_key = os.getenv("APP_SECRET_KEY")
app.config["JWT_SECRET_KEY"] = os.getenv("APP_SECRET_KEY")
jwt = JWTManager(app)
CORS(app,supports_credentials=True)


# Configure Flask app to use Google OAuth
app.config["OAUTHLIB_INSECURE_TRANSPORT"] = False
REDIRECT_URI = os.getenv("REDIRECT_URI")
SESSION_LIFETIME = timedelta(minutes=10)

active_sessions = {}
admin_google_ids = os.getenv("ADMIN_GOOGLE_ID")

app.config['JWT_TOKEN_LOCATION'] = ['cookies', 'headers']
app.config["JWT_COOKIE_SECURE"] = True 
app.config["JWT_ACCESS_COOKIE_NAME"] = "jwt_token"
app.config["JWT_COOKIE_CSRF_PROTECT"] = True


google_bp = make_google_blueprint(
    client_id=os.getenv("GOOGLE_CLIENT_ID"),
    client_secret=os.getenv("GOOGLE_CLIENT_SECRET"),
    redirect_to="callback",
    scope=[
        "openid",
        "https://www.googleapis.com/auth/userinfo.profile",
        "https://www.googleapis.com/auth/userinfo.email",
    ],
    reprompt_select_account=True,
)
app.register_blueprint(google_bp, url_prefix="/login")


# Hardware
LED_pin = 12
Buzzer_pin = 11

# Initialize PubNub
pubnub = init_pubnub()


@app.route("/")
def index():
    return render_template("login.html")


def admin_required(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        if session.get("google_id") not in admin_google_ids:
            abort(403)
        return f(*args, **kwargs)

    return decorated_function


# Frontend Google Login
app.route("/frontend_login", methods=["POST"])
def frontend_login():
    data = request.json

    user_id = data.get("google_id")
    email = data.get("email")
    username = data.get("displayName")
    profile_picture = data.get("profile_picture")

    if not user_id or not email:
        return jsonify({"error": "Invalid data"}), 400

    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)

    user = get_user_by_id(cursor, user_id)

    access_token = create_access_token(identity=username)
    if user:
        response = jsonify({"message": "User can log in"})
        set_access_cookies(response, access_token) 
        return response, 200
    else:
        insert_new_user(cursor, user_id, username, email, profile_picture)
        connection.commit()

        response = jsonify({"message": "User was created"})
        response.set_cookie('jwt_token', access_token, httponly=True, secure=True, samesite='Strict')
        return response, 201
# Backend Login
@app.route("/login", methods=["GET"])
def login():
    if not google.authorized:
        return redirect(url_for("google.login"))
    return redirect(url_for("navigation"))


@app.route("/callback")
def callback():
    if not google.authorized:
        return redirect(url_for("login"))

    user_info = google.get("/oauth2/v3/userinfo")
    if not user_info.ok:
        return redirect(url_for("login"))

    user_info = user_info.json()

    session.update(
        google_id=user_info["sub"],
        email=user_info["email"],
        name=user_info["name"],
    )

    jwt_token = create_access_token(identity=user_info["sub"])

    response = make_response(redirect(url_for("navigation")))
    response.set_cookie(
        "jwt_token",
        jwt_token,
        httponly=True,
        secure=True,   
        samesite="Strict"  
    )

    return response  


@app.route("/navigation")
def navigation():
    user_google_id = session.get("google_id")

    if not user_google_id:
        return redirect(url_for("login"))

    is_admin = user_google_id in admin_google_ids

    name = session.get("name")
    email = session.get("email")
    jwt_token = session.get("jwt_token") 
    
    return render_template(
        "navigation.html",
        is_admin=is_admin,
        user_id=user_google_id,
        name=name,
        email=email,
        jwt_token=jwt_token,
    )


@app.route("/admin")
@admin_required
def admin_page():
    google_id = session.get("google_id")
    if not google_id:
        return redirect(url_for("login"))
    if google_id not in admin_google_ids:
        return "Access Denied: You do not have admin privileges.", 403

    name = session.get("name")
    email = session.get("email")

    expires_at = datetime.now() + SESSION_LIFETIME
    start_at = datetime.now().strftime("%H:%M")
    expire_time = expires_at.strftime("%H:%M")

    active_sessions[google_id] = {
        "google_id": google_id,
        "name": name,
        "email": email,
        "created_at": start_at,
        "expires_at": expire_time,
    }

    return render_template("admin.html", active_sessions=active_sessions)


@app.route("/logout")
def logout():
    session.clear()
    google_id = session.get("google_id")
    if google_id in active_sessions:
        del active_sessions[google_id]
    return redirect("/")


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

        # Use PubNub to publish the message
        publish_message(pubnub, "PUBNUB_CHANNEL_NAME", response)

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

@app.route("/users", methods=["GET"])
@app.route("/users/<string:user_id>", methods=["GET"])
#@jwt_required()
def get_user(user_id=None):
    jwt_token = session.get("jwt_token")
    if user_id is None:
        if not session.get("google_id") in admin_google_ids:
            return jsonify({"error": "Admin access required"}), 403
    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)

    if user_id:
        result = get_user_by_id(cursor, user_id)
        return jsonify({"user": result}), 200
    else:
        results = get_all_users(cursor)
        return jsonify({"users": results}), 200


@app.route("/books", methods=["GET"])
@app.route("/user_books/<string:user_id>", methods=["GET"])
#@jwt_required()
def get_books(user_id=None):
    jwt_token = session.get("jwt_token")
    google_id_in_session = session.get("google_id")
    if google_id_in_session:
        if google_id_in_session not in admin_google_ids:
            # Regular users can only access their own data
            if user_id and user_id != google_id_in_session:
                return jsonify({"error": "You can only access your own data"}), 403
        
    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = connection.cursor(dictionary=True)

    try:
        if user_id:
            books = get_books_by_user(cursor, user_id)
            response = {"user_books": books}
        else:
            books = get_all_books(cursor)
            response = {"books": books}
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500
    finally:
        cursor.close()
        connection.close()
    return jsonify(response)


@app.route("/fetch-image", methods=["POST"])
def fetch_image():
    data = request.get_json()
    cover_image_url = data.get("coverImageUrl")

    response = requests.get(cover_image_url)

    try:
        if response.status_code == 200:
            image_bytes = BytesIO(response.content)
            return send_file(image_bytes, mimetype="image/jpeg")
        else:
            return jsonify({"error": "Failed to fetch image from Google Books"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/bookclubs", methods=["GET"])
@app.route("/user_bookclubs/<string:user_id>", methods=["GET"])
#@jwt_required()
def get_bookclubs(user_id=None):
    google_id_in_session = session.get("google_id")
    if google_id_in_session:
        if google_id_in_session not in admin_google_ids:
            # Regular users can only access their own data
            if user_id and user_id != google_id_in_session:
                return jsonify({"error": "You can only access your own data"}), 403

    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    cursor = connection.cursor(dictionary=True)

    try:
        if user_id:
            bookclubs = get_bookclubs_by_user(cursor, user_id)
            if bookclubs:
                for bookclub in bookclubs:
                    if bookclub.get("member_since"):
                        bookclub["member_since"] = bookclub["member_since"].strftime(
                            "%Y-%m-%d"
                        )
                return jsonify({"user_bookclubs": bookclubs}), 200
            else:
                return jsonify({"error": "User has no Book Clubs"}), 404
        else:
            # Fetch all bookclubs
            bookclubs = get_all_bookclubs(cursor)
            if bookclubs:
                # Format 'created_at' and 'member_since' fields
                for bookclub in bookclubs:
                    if bookclub.get("created_at"):
                        bookclub["created_at"] = bookclub["created_at"].strftime(
                            "%Y-%m-%d"
                        )
                    if bookclub.get("member_since"):
                        bookclub["member_since"] = bookclub["member_since"].strftime(
                            "%Y-%m-%d"
                        )
                return jsonify({"bookclubs": bookclubs}), 200
            else:
                return jsonify({"error": "No Book Clubs found"}), 404
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"}), 500
    finally:
        cursor.close()
        connection.close()


@app.route("/add_user_book/<string:user_id>", methods=["POST"])
#@jwt_required()
def add_user_book(user_id=None):
    data = request.get_json()

    isbn = data.get("ISBN")
    connection = get_db_connection()
    if connection is None:
        return jsonify({"error": "Failed to connect to the database"}), 500

    try:
        cursor = connection.cursor()
        cursor.execute(
            "INSERT INTO user_books (user_id, book_isbn) VALUES (%s, %s)",
            (user_id, isbn),
        )
        connection.commit()

        return jsonify({"message": "Book successfully added to UserBooks"}), 200

    except Exception as e:
        connection.rollback()
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        connection.close()


@app.route("/add_book", methods=["POST"])
def add_book_request():
    if not request.is_json:
        return jsonify({"error": "Request must be JSON"}), 400

    data = request.get_json()
    response = export_book_request_to_file(data)
    if "error" in response:
        return jsonify(response), 500
    return jsonify(response), 200

def export_book_request_to_file(book_request, filename="book_request.txt"):
    try:
        with open(filename, "w") as file:
            file.write("Book Request Details\n")
            file.write("====================\n")
            for key, value in book_request.items():
                file.write(f"{key.capitalize()}: {value}\n")
            file.write("\nThank you for your request!")
        print(f"Book request exported to {filename}")
    except Exception as e:
        print(f"Error exporting book request: {e}")


def main():
    connection = get_db_connection()


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=5000)
