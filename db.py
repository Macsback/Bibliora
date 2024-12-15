import os
import mysql.connector
from mysql.connector import Error
from datetime import datetime
import subprocess

# Function to get DB connection
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
        else:
            print("Failed to establish database connection.")
            return None

    except Error as err:
        print(f"Database connection error: {err}")
        return None

    except Exception as e:
        print(f"Unexpected error: {e}")
        return None

def backup_database():
    db_name = os.getenv("DB_NAME")
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")
    backup_dir = "/path/to/backup/directory"

    timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
    backup_filename = f"{backup_dir}/backup_{timestamp}.sql"

    command = f"mysqldump -u {db_user} -p{db_password} {db_name} > {backup_filename}"

    try:
        subprocess.run(command, shell=True, check=True)
        print(f"Backup successful: {backup_filename}")
    except subprocess.CalledProcessError as e:
        print(f"Error during backup: {e}")

def schedule_backup_cron():
    script_dir = os.path.dirname(os.path.abspath(__file__)) 
    cron_command = f"0 2 * * * /usr/bin/python3 {script_dir}/backup_script.py"

    try:
        with open("/etc/crontab", "a") as crontab_file:
            crontab_file.write(f"\n{cron_command}")
        print("Cron job scheduled successfully!")
    except Exception as e:
        print(f"Error scheduling cron job: {e}")

if __name__ == "__main__":
    schedule_backup_cron()
    backup_database()
