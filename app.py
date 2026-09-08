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

        reporter_id = request.form["reporter_id"]
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
                reporter_id,
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
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            reporter_id,
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

    reporter_id = request.form.get("reporter_id")
    item_type = request.form.get("item_type")
    item_name = request.form.get("item_name")
    category = request.form.get("category")
    location = request.form.get("location")
    date = request.form.get("date")
    time = request.form.get("time")
    public_details = request.form.get("public_details")
    private_details = request.form.get("private_details")

    required_fields = {
        "reporter_id": reporter_id,
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
            reporter_id,
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
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        reporter_id,
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
        "reporter_id": reporter_id,
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


@app.route("/api/claim", methods=["POST"])
def create_claim():

    item_id = request.form.get("item_id")
    claimant_id = request.form.get("claimant_id")

    if not item_id or not claimant_id:
        return jsonify({
            "success": False,
            "message": "item_id and claimant_id are required"
        }), 400

    connection = get_db_connection()

    item = connection.execute("""
        SELECT
            id,
            reporter_id,
            status
        FROM items
        WHERE id = ?
    """, (item_id,)).fetchone()

    if not item:
        connection.close()

        return jsonify({
            "success": False,
            "message": "Item not found"
        }), 404

    if item["status"] != "Searching":
        connection.close()

        return jsonify({
            "success": False,
            "message": "This item is no longer available for claims"
        }), 400

    if not item["reporter_id"]:
        connection.close()

        return jsonify({
            "success": False,
            "message": "This item does not have a reporter assigned"
        }), 400

    if claimant_id == item["reporter_id"]:
        connection.close()

        return jsonify({
            "success": False,
            "message": "The original reporter cannot claim their own item"
        }), 400

    existing_claim = connection.execute("""
        SELECT id
        FROM claims
        WHERE item_id = ?
        AND claimant_id = ?
        AND status = 'Pending'
    """, (item_id, claimant_id)).fetchone()

    if existing_claim:
        connection.close()

        return jsonify({
            "success": False,
            "message": "You already have a pending claim for this item",
            "claim_id": existing_claim["id"]
        }), 400

    # CREATE CLAIM
    cursor = connection.execute("""
        INSERT INTO claims (
            item_id,
            claimant_id,
            reporter_id,
            status
        )
        VALUES (?, ?, ?, 'Pending')
    """, (
        item_id,
        claimant_id,
        item["reporter_id"]
    ))

    claim_id = cursor.lastrowid

    # CREATE NOTIFICATION FOR ORIGINAL REPORTER
    notification_message = "Someone has claimed your found item."

    connection.execute("""
        INSERT INTO notifications (
            user_id,
            item_id,
            claim_id,
            message,
            read
        )
        VALUES (?, ?, ?, ?, 0)
    """, (
        item["reporter_id"],
        item_id,
        claim_id,
        notification_message
    ))

    connection.commit()
    connection.close()

    return jsonify({
        "success": True,
        "message": "Claim submitted successfully!",
        "claim_id": claim_id,
        "item_id": item_id,
        "claimant_id": claimant_id,
        "reporter_id": item["reporter_id"],
        "status": "Pending"
    }), 201


@app.route("/api/notifications/<user_id>", methods=["GET"])
def get_notifications(user_id):

    connection = get_db_connection()

    notifications = connection.execute("""
        SELECT
            id,
            user_id,
            item_id,
            claim_id,
            message,
            read,
            created_at
        FROM notifications
        WHERE user_id = ?
        ORDER BY created_at DESC
    """, (user_id,)).fetchall()

    connection.close()

    return jsonify({
        "success": True,
        "user_id": user_id,
        "notifications": [dict(notification) for notification in notifications]
    })


# =========================
# VERIFICATION SYSTEM
# =========================

@app.route("/api/verification", methods=["POST"])
def create_verification():

    claim_id = request.form.get("claim_id")
    verification_details = request.form.get("verification_details")

    if not claim_id or not verification_details:
        return jsonify({
            "success": False,
            "message": "claim_id and verification_details are required"
        }), 400

    connection = get_db_connection()

    claim = connection.execute("""
        SELECT
            id,
            item_id,
            claimant_id,
            reporter_id,
            status
        FROM claims
        WHERE id = ?
    """, (claim_id,)).fetchone()

    if not claim:
        connection.close()

        return jsonify({
            "success": False,
            "message": "Claim not found"
        }), 404

    if claim["status"] != "Pending":
        connection.close()

        return jsonify({
            "success": False,
            "message": "This claim is no longer pending"
        }), 400

    existing_verification = connection.execute("""
        SELECT id
        FROM verifications
        WHERE claim_id = ?
        AND status = 'Pending'
    """, (claim_id,)).fetchone()

    if existing_verification:
        connection.close()

        return jsonify({
            "success": False,
            "message": "A verification request already exists for this claim",
            "verification_id": existing_verification["id"]
        }), 400

    cursor = connection.execute("""
        INSERT INTO verifications (
            claim_id,
            item_id,
            reporter_id,
            claimant_id,
            verification_details,
            status
        )
        VALUES (?, ?, ?, ?, ?, 'Pending')
    """, (
        claim["id"],
        claim["item_id"],
        claim["reporter_id"],
        claim["claimant_id"],
        verification_details
    ))

    verification_id = cursor.lastrowid

    # Notify the original reporter that verification details were submitted
    connection.execute("""
        INSERT INTO notifications (
            user_id,
            item_id,
            claim_id,
            message,
            read
        )
        VALUES (?, ?, ?, ?, 0)
    """, (
        claim["reporter_id"],
        claim["item_id"],
        claim["id"],
        "Verification details have been submitted for a claim."
    ))

    connection.commit()
    connection.close()

    return jsonify({
        "success": True,
        "message": "Verification submitted successfully!",
        "verification_id": verification_id,
        "claim_id": claim["id"],
        "item_id": claim["item_id"],
        "claimant_id": claim["claimant_id"],
        "reporter_id": claim["reporter_id"],
        "status": "Pending"
    }), 201


@app.route("/api/verification/<int:verification_id>", methods=["GET"])
def get_verification(verification_id):

    connection = get_db_connection()

    verification = connection.execute("""
        SELECT
            id,
            claim_id,
            item_id,
            reporter_id,
            claimant_id,
            verification_details,
            status,
            created_at,
            reviewed_at
        FROM verifications
        WHERE id = ?
    """, (verification_id,)).fetchone()

    connection.close()

    if not verification:
        return jsonify({
            "success": False,
            "message": "Verification not found"
        }), 404

    return jsonify({
        "success": True,
        "verification": dict(verification)
    })


@app.route("/api/verification/<int:verification_id>/review", methods=["POST"])
def review_verification(verification_id):

    reviewer_id = request.form.get("reviewer_id")
    decision = request.form.get("decision")

    if not reviewer_id or not decision:
        return jsonify({
            "success": False,
            "message": "reviewer_id and decision are required"
        }), 400

    decision = decision.capitalize()

    if decision not in ["Approved", "Rejected"]:
        return jsonify({
            "success": False,
            "message": "decision must be Approved or Rejected"
        }), 400

    connection = get_db_connection()

    verification = connection.execute("""
        SELECT
            id,
            claim_id,
            item_id,
            reporter_id,
            claimant_id,
            status
        FROM verifications
        WHERE id = ?
    """, (verification_id,)).fetchone()

    if not verification:
        connection.close()

        return jsonify({
            "success": False,
            "message": "Verification not found"
        }), 404

    if verification["status"] != "Pending":
        connection.close()

        return jsonify({
            "success": False,
            "message": "This verification has already been reviewed"
        }), 400

    # Only the original reporter can review the verification
    if reviewer_id != verification["reporter_id"]:
        connection.close()

        return jsonify({
            "success": False,
            "message": "Only the original reporter can review this verification"
        }), 403

    if decision == "Approved":

        connection.execute("""
            UPDATE verifications
            SET status = 'Approved',
                reviewed_at = CURRENT_TIMESTAMP
            WHERE id = ?
        """, (verification_id,))

        connection.execute("""
            UPDATE claims
            SET status = 'Approved'
            WHERE id = ?
        """, (verification["claim_id"],))

        connection.execute("""
            UPDATE items
            SET status = 'Resolved'
            WHERE id = ?
        """, (verification["item_id"],))

        # Notify claimant
        connection.execute("""
            INSERT INTO notifications (
                user_id,
                item_id,
                claim_id,
                message,
                read
            )
            VALUES (?, ?, ?, ?, 0)
        """, (
            verification["claimant_id"],
            verification["item_id"],
            verification["claim_id"],
            "Your claim has been approved. The item is now resolved."
        ))

    else:

        connection.execute("""
            UPDATE verifications
            SET status = 'Rejected',
                reviewed_at = CURRENT_TIMESTAMP
            WHERE id = ?
        """, (verification_id,))

        connection.execute("""
            UPDATE claims
            SET status = 'Rejected'
            WHERE id = ?
        """, (verification["claim_id"],))

        # Notify claimant
        connection.execute("""
            INSERT INTO notifications (
                user_id,
                item_id,
                claim_id,
                message,
                read
            )
            VALUES (?, ?, ?, ?, 0)
        """, (
            verification["claimant_id"],
            verification["item_id"],
            verification["claim_id"],
            "Your claim could not be verified."
        ))

    connection.commit()
    connection.close()

    return jsonify({
        "success": True,
        "message": f"Verification {decision.lower()} successfully!",
        "verification_id": verification_id,
        "claim_id": verification["claim_id"],
        "item_id": verification["item_id"],
        "decision": decision
    })


@app.route("/items")
def items():

    connection = get_db_connection()

    items = connection.execute("""
        SELECT
            id,
            reporter_id,
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