import sqlite3


def get_db_connection():
    connection = sqlite3.connect("database/refind.db")
    connection.row_factory = sqlite3.Row
    return connection


def create_tables():
    connection = get_db_connection()

    # ITEMS TABLE
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
            status TEXT DEFAULT 'Searching',
            reporter_id TEXT
        )
    """)

    # CLAIMS TABLE
    connection.execute("""
        CREATE TABLE IF NOT EXISTS claims (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            item_id INTEGER NOT NULL,
            claimant_id TEXT NOT NULL,
            reporter_id TEXT NOT NULL,
            status TEXT DEFAULT 'Pending',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (item_id) REFERENCES items (id)
        )
    """)

    # NOTIFICATIONS TABLE
    connection.execute("""
        CREATE TABLE IF NOT EXISTS notifications (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id TEXT NOT NULL,
            item_id INTEGER NOT NULL,
            claim_id INTEGER,
            message TEXT NOT NULL,
            read INTEGER DEFAULT 0,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (item_id) REFERENCES items (id),
            FOREIGN KEY (claim_id) REFERENCES claims (id)
        )
    """)

    connection.commit()
    connection.close()


def update_database():
    connection = get_db_connection()

    columns = connection.execute("""
        PRAGMA table_info(items)
    """).fetchall()

    column_names = [column["name"] for column in columns]

    if "reporter_id" not in column_names:
        connection.execute("""
            ALTER TABLE items
            ADD COLUMN reporter_id TEXT
        """)

    connection.commit()
    connection.close()


create_tables()
update_database()