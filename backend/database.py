import sqlite3

def get_db_connection():
    connection = sqlite3.connect("database/refind.db")
    connection.row_factory = sqlite3.Row
    return connection


def create_tables():
    connection = get_db_connection()

    connection.execute("""
        CREATE TABLE IF NOT EXISTS items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_type TEXT NOT NULL,
            item_name TEXT NOT NULL,
            category TEXT NOT NULL,
            location TEXT NOT NULL,
            date TEXT NOT NULL,
            time TEXT,
            public_details TEXT,
            private_details TEXT,
            image_path TEXT,
            status TEXT DEFAULT 'Searching'
        )
    """)

    connection.commit()
    connection.close()