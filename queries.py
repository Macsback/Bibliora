import datetime


def get_all_users(cursor):
    query = "SELECT * FROM users"
    cursor.execute(query)
    return cursor.fetchall()


def get_user_by_id(cursor, user_id):
    query = "SELECT * FROM users WHERE user_id = %s"
    cursor.execute(query, (user_id,))
    result = cursor.fetchone()
    return result


def get_books_by_user(cursor, user_id):
    query = """
    SELECT 
        user_books.user_id,
        user_books.book_isbn, 
        books.title, 
        books.description,
        books.publish_year,  
        books.cover_image_url,  
        authors.name AS author,
        GROUP_CONCAT(genres.name) AS genres,
        user_books.status
    FROM user_books
    JOIN books ON user_books.book_isbn = books.isbn
    JOIN book_authors ON books.isbn = book_authors.book_isbn
    JOIN authors ON book_authors.author_id = authors.author_id
    LEFT JOIN book_genres ON books.isbn = book_genres.book_isbn 
    LEFT JOIN genres ON book_genres.genre_id = genres.genre_id  
    WHERE user_books.user_id = %s
    GROUP BY user_books.user_id, user_books.book_isbn
    """
    cursor.execute(query, (user_id,))
    return cursor.fetchall()

def get_isbn_by_title(cursor, title):
    query = "SELECT isbn FROM books WHERE title = %s LIMIT 1;"
    cursor.execute(query, (title,))
    result = cursor.fetchone()
    if result:
        return result[0] 
    return None



def get_all_books(cursor):
    query = """
    SELECT 
        books.isbn, 
        books.title, 
        books.description,
        books.publish_year,  
        books.cover_image_url,  
        books.borrowlink,
        authors.name AS author,
        GROUP_CONCAT(genres.name) AS genres
    FROM books
    JOIN book_authors ON books.isbn = book_authors.book_isbn
    JOIN authors ON book_authors.author_id = authors.author_id
    LEFT JOIN book_genres ON books.isbn = book_genres.book_isbn 
    LEFT JOIN genres ON book_genres.genre_id = genres.genre_id      
    GROUP BY books.isbn
    """
    cursor.execute(query)
    return cursor.fetchall()


def get_bookclubs_by_user(cursor, user_id):
    query = """
    SELECT 
        book_clubs.book_club_id,
        book_clubs.name AS book_club_name,
        book_clubs.description,
        user_book_clubs.member_since
    FROM user_book_clubs
    JOIN book_clubs ON user_book_clubs.book_club_id = book_clubs.book_club_id
    WHERE user_book_clubs.user_id = %s
    """
    cursor.execute(query, (user_id,))
    return cursor.fetchall()


def get_all_bookclubs(cursor):
    query = "SELECT * FROM book_clubs"
    cursor.execute(query)
    return cursor.fetchall()


def insert_new_user(cursor, user_id, username, email, profile_picture=None):
    query = """
    INSERT INTO users (user_id, username, email, profile_picture, created_at)
    VALUES (%s, %s, %s, %s, %s)
    """
    created_at = datetime.datetime.now()
    cursor.execute(query, (user_id, username, email, profile_picture, created_at))
