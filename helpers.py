from datetime import datetime


def export_book_request_to_file(data):
    isbn = data.get("isbn")
    title = data.get("title")
    author = data.get("author")
    genres = data.get("genres")

    file_path = "book_requests.txt"
    request_data = f"Request Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n"
    request_data += f"ISBN: {isbn}\n"
    request_data += f"Title: {title}\n"
    request_data += f"Author: {author}\n"
    request_data += f"Genres: {genres}\n"
    request_data += "-" * 40 + "\n"

    try:
        with open(file_path, "a") as file:
            file.write(request_data)
        return {
            "message": "Book request submitted successfully. An admin will review it."
        }
    except Exception as e:
        return {"error": str(e)}
