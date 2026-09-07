from flask import Flask, render_template, request, jsonify
from backend.database import create_tables, get_db_connection
from backend.matching import find_matches
from werkzeug.utils import secure_filename
import os

app = Flask(__name__)

UPLOAD_FOLDER = "uploads"
app.config["UPLOAD_FOLDER"] = UPLOAD_FOLDER

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

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

        image_path = None

        if "image" in request.files:
            image = request.files["image"]

            if image.filename:
                filename = secure_filename(image.filename)
                image_path = os.path.join(
                    app.config["UPLOAD_FOLDER"],
                    filename
                )
                image.save(image_path)

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
                private_details,
                image_path
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            item_type,
            item_name,
            category,
            location,
            date,
            time,
            public_details,
            private_details,
            image_path
        ))

        connection.commit()
        connection.close()

        return "Report submitted successfully!"

    return render_template("report.html")


@app.route("/api/report", methods=["POST"])
def api_report():

    item_type = request.form.get("item_type")
    item_name = request.form.get("item_name")
    category = request.form.get("category")
    location = request.form.get("location")
    date = request.form.get("date")
    time = request.form.get("time")
    public_details = request.form.get("public_details")
    private_details = request.form.get("private_details")

    required_fields = {
        "item_type": item_type,
        "item_name": item_name,
        "category": category,
        "location": location,
        "date": date,
        "public_details": public_details,
        "private_details": private_details
    }

    for field, value in required_fields.items():
        if not value:
            return jsonify({
                "success": False,
                "message": f"Missing field: {field}"
            }), 400

    image_path = None

    if "image" in request.files:
        image = request.files["image"]

        if image.filename:
            filename = secure_filename(image.filename)

            image_path = os.path.join(
                app.config["UPLOAD_FOLDER"],
                filename
            )

            image.save(image_path)

    connection = get_db_connection()

    cursor = connection.execute("""
        INSERT INTO items (
            item_type,
            item_name,
            category,
            location,
            date,
            time,
            public_details,
            private_details,
            image_path
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        item_type,
        item_name,
        category,
        location,
        date,
        time,
        public_details,
        private_details,
        image_path
    ))

    item_id = cursor.lastrowid

    connection.commit()

    connection.close()

    return jsonify({
        "success": True,
        "message": "Report submitted successfully!",
        "item_id": item_id,
        "image_path": image_path
    }), 201


@app.route("/api/matches/<int:item_id>", methods=["GET"])
def get_matches(item_id):

    connection = get_db_connection()

    item = connection.execute("""
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
        WHERE id = ?
    """, (item_id,)).fetchone()

    connection.close()

    if not item:
        return jsonify({
            "success": False,
            "message": "Item not found"
        }), 404

    matches = find_matches(item)

    return jsonify({
        "success": True,
        "item_id": item_id,
        "matches": matches
    })


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