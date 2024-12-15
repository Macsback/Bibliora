import mysql.connector
import os


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
            ssl_ca='./rds-combined-ca-bundle.pem', 
            ssl_disabled=False 
        )

        if connection.is_connected():
            print("Database connection established successfully!")
            return connection
    except mysql.connector.Error as err:
        print(f"Database connection error: {err}")
        return None
