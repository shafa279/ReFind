from flask import Flask, render_template, request
from backend.database import create_tables, get_db_connection

app = Flask(__name__)

create_tables()


@app.route("/")
def home():
    return "Welcome to ReFind!"


@app.route("/report", methods=["GET", "POST"])
def report():
    if request.method == "POST":
        item_type = request.form["item_type"]
        item_name = request.form["item_name"]
        category = request.form["category"]
        location = request.form["location"]
        date = request.form["date"]
        time = request.form["time"]
        public_details = request.form["public_details"]
        private_details = request.form["private_details"]

        connection = get_db_connection()

        connection.execute("""
            INSERT INTO items (
                item_type,
                item_name,
                category,
                location,
                date,
                time,
                public_details,
                private_details
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            item_type,
            item_name,
            category,
            location,
            date,
            time,
            public_details,
            private_details
        ))

        connection.commit()
        connection.close()

        return "Report submitted successfully!"

    return render_template("report.html")


@app.route("/items")
def items():
    connection = get_db_connection()

    items = connection.execute("""
        SELECT
            id,
            item_type,
            item_name,
            category,
            location,
            date,
            time,
            public_details,
            image_path,
            status
        FROM items
    """).fetchall()

    connection.close()

    return str([dict(item) for item in items])


if __name__ == "__main__":
    app.run(debug=True)