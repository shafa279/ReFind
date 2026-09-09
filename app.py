from flask import Flask, request, jsonify
from flask_cors import CORS
import os

from backend.database import get_db_connection
from backend.matching import find_matches


app = Flask(__name__)
CORS(app)


# =========================
# HOME
# =========================

@app.route("/")
def home():
    return "ReFind backend is running!"


# =========================
# LOGIN
# =========================

@app.route("/api/login", methods=["POST"])
def login():

    user_id = request.form.get("user_id")
    password = request.form.get("password")

    if not user_id or not password:
        return jsonify({
            "success": False,
            "message": "College / Student ID and password are required"
        }), 400

    users = {
        "TEST001": {
            "password": "test123",
            "role": "student"
        },
        "TEST002": {
            "password": "test123",
            "role": "student"
        },
        "TEST003": {
            "password": "test123",
            "role": "student"
        },
        "ADMIN001": {
            "password": "admin123",
            "role": "admin"
        }
    }

    user = users.get(user_id)

    if not user:
        return jsonify({
            "success": False,
            "message": "Invalid College / Student ID"
        }), 401

    if user["password"] != password:
        return jsonify({
            "success": False,
            "message": "Incorrect password"
        }), 401

    return jsonify({
        "success": True,
        "message": "Login successful!",
        "user_id": user_id,
        "role": user["role"]
    }), 200


# =========================
# REPORT ITEM
# =========================

@app.route("/api/report", methods=["POST"])
def report_item():

    item_type = request.form.get("item_type")
    item_name = request.form.get("item_name")
    category = request.form.get("category")
    location = request.form.get("location")
    date = request.form.get("date")
    time = request.form.get("time")
    public_details = request.form.get("public_details")
    private_details = request.form.get("private_details")
    reporter_id = request.form.get("reporter_id")

    image = request.files.get("image")

    if not item_type or not item_name or not category or not location or not date:
        return jsonify({
            "success": False,
            "message": "Required fields are missing"
        }), 400

    image_path = None

    if image:
        filename = image.filename

        if filename:
            image_path = os.path.join(
                "uploads",
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
            image_path,
            status,
            reporter_id
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        item_type,
        item_name,
        category,
        location,
        date,
        time,
        public_details,
        private_details,
        image_path,
        "Searching",
        reporter_id
    ))

    item_id = cursor.lastrowid

    connection.commit()
    connection.close()

    return jsonify({
        "success": True,
        "message": "Report submitted successfully!",
        "item_id": item_id
    }), 201


# =========================
# OLD REPORT ENDPOINT
# =========================

@app.route("/report", methods=["POST"])
def old_report():

    item_type = request.form.get("item_type")
    item_name = request.form.get("item_name")
    category = request.form.get("category")
    location = request.form.get("location")
    date = request.form.get("date")
    time = request.form.get("time")
    public_details = request.form.get("public_details")
    private_details = request.form.get("private_details")
    reporter_id = request.form.get("reporter_id")

    if not item_type or not item_name or not category or not location or not date:
        return jsonify({
            "success": False,
            "message": "Required fields are missing"
        }), 400

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
            status,
            reporter_id
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        item_type,
        item_name,
        category,
        location,
        date,
        time,
        public_details,
        private_details,
        "Searching",
        reporter_id
    ))

    item_id = cursor.lastrowid

    connection.commit()
    connection.close()

    return jsonify({
        "success": True,
        "message": "Report submitted successfully!",
        "item_id": item_id
    }), 201


# =========================
# GET ALL ITEMS
# =========================

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

    return jsonify({
        "success": True,
        "items": [
            dict(item)
            for item in items
        ]
    })


# =========================
# FIND MATCHES
# =========================

@app.route("/api/matches/<int:item_id>")
def matches(item_id):

    connection = get_db_connection()

    item = connection.execute("""
        SELECT *
        FROM items
        WHERE id = ?
    """, (item_id,)).fetchone()

    connection.close()

    if not item:
        return jsonify({
            "success": False,
            "message": "Item not found"
        }), 404

    if item["status"] != "Searching":
        return jsonify({
            "success": True,
            "matches": []
        })

    results = find_matches(item)

    return jsonify({
        "success": True,
        "item_id": item_id,
        "matches": results
    })


# =========================
# CREATE CLAIM
# =========================

@app.route("/api/claims", methods=["POST"])
def create_claim():

    item_id = request.form.get("item_id")
    claimant_id = request.form.get("claimant_id")

    if not item_id or not claimant_id:
        return jsonify({
            "success": False,
            "message": "Item ID and claimant ID are required"
        }), 400

    connection = get_db_connection()

    item = connection.execute("""
        SELECT *
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
            "message": "This item is no longer available for claiming"
        }), 400

    if item["reporter_id"] == claimant_id:
        connection.close()

        return jsonify({
            "success": False,
            "message": "You cannot claim your own reported item"
        }), 400

    existing_claim = connection.execute("""
        SELECT *
        FROM claims
        WHERE item_id = ?
        AND claimant_id = ?
        AND status = 'Pending'
    """, (
        item_id,
        claimant_id
    )).fetchone()

    if existing_claim:
        connection.close()

        return jsonify({
            "success": False,
            "message": "You have already claimed this item"
        }), 400

    cursor = connection.execute("""
        INSERT INTO claims (
            item_id,
            claimant_id,
            reporter_id,
            status
        )
        VALUES (?, ?, ?, ?)
    """, (
        item_id,
        claimant_id,
        item["reporter_id"],
        "Pending"
    ))

    claim_id = cursor.lastrowid

    connection.execute("""
        INSERT INTO notifications (
            user_id,
            item_id,
            claim_id,
            message
        )
        VALUES (?, ?, ?, ?)
    """, (
        item["reporter_id"],
        item_id,
        claim_id,
        "Someone has claimed your found item."
    ))

    connection.commit()
    connection.close()

    return jsonify({
        "success": True,
        "message": "Claim submitted successfully!",
        "claim_id": claim_id
    }), 201


# =========================
# GET CLAIMS
# =========================

@app.route("/api/claims/<int:item_id>")
def get_claims(item_id):

    connection = get_db_connection()

    claims = connection.execute("""
        SELECT *
        FROM claims
        WHERE item_id = ?
        ORDER BY created_at DESC
    """, (item_id,)).fetchall()

    connection.close()

    return jsonify({
        "success": True,
        "claims": [
            dict(claim)
            for claim in claims
        ]
    })


# =========================
# NOTIFICATIONS
# =========================

@app.route("/api/notifications/<user_id>")
def get_notifications(user_id):

    connection = get_db_connection()

    notifications = connection.execute("""
        SELECT *
        FROM notifications
        WHERE user_id = ?
        ORDER BY created_at DESC
    """, (user_id,)).fetchall()

    connection.close()

    return jsonify({
        "success": True,
        "user_id": user_id,
        "notifications": [
            dict(notification)
            for notification in notifications
        ]
    })


# =========================
# MARK NOTIFICATION AS READ
# =========================

@app.route(
    "/api/notifications/<int:notification_id>/read",
    methods=["POST"]
)
def mark_notification_read(notification_id):

    connection = get_db_connection()

    connection.execute("""
        UPDATE notifications
        SET read = 1
        WHERE id = ?
    """, (notification_id,))

    connection.commit()
    connection.close()

    return jsonify({
        "success": True,
        "message": "Notification marked as read"
    })


# =========================
# SUBMIT VERIFICATION
# =========================

@app.route("/api/verification", methods=["POST"])
def submit_verification():

    claim_id = request.form.get("claim_id")
    verification_details = request.form.get(
        "verification_details"
    )

    if not claim_id or not verification_details:
        return jsonify({
            "success": False,
            "message": "Claim ID and verification details are required"
        }), 400

    connection = get_db_connection()

    claim = connection.execute("""
        SELECT *
        FROM claims
        WHERE id = ?
    """, (claim_id,)).fetchone()

    if not claim:
        connection.close()

        return jsonify({
            "success": False,
            "message": "Claim not found"
        }), 404

    existing = connection.execute("""
        SELECT *
        FROM verifications
        WHERE claim_id = ?
    """, (claim_id,)).fetchone()

    if existing:
        connection.close()

        return jsonify({
            "success": False,
            "message": "Verification has already been submitted"
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
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        claim_id,
        claim["item_id"],
        claim["reporter_id"],
        claim["claimant_id"],
        verification_details,
        "Pending"
    ))

    verification_id = cursor.lastrowid

    connection.commit()
    connection.close()

    return jsonify({
        "success": True,
        "message": "Verification submitted successfully!",
        "verification_id": verification_id,
        "claim_id": claim_id,
        "item_id": claim["item_id"],
        "reporter_id": claim["reporter_id"],
        "claimant_id": claim["claimant_id"],
        "status": "Pending"
    }), 201


# =========================
# GET VERIFICATION
# =========================

@app.route("/api/verification/<int:verification_id>")
def get_verification(verification_id):

    connection = get_db_connection()

    verification = connection.execute("""
        SELECT *
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


# =========================
# REVIEW VERIFICATION
# =========================

@app.route(
    "/api/verification/<int:verification_id>/review",
    methods=["POST"]
)
def review_verification(verification_id):

    reviewer_id = request.form.get("reviewer_id")
    decision = request.form.get("decision")

    if not reviewer_id or not decision:
        return jsonify({
            "success": False,
            "message": "Reviewer ID and decision are required"
        }), 400

    if decision not in ["Approved", "Rejected"]:
        return jsonify({
            "success": False,
            "message": "Decision must be Approved or Rejected"
        }), 400

    connection = get_db_connection()

    verification = connection.execute("""
        SELECT *
        FROM verifications
        WHERE id = ?
    """, (verification_id,)).fetchone()

    if not verification:
        connection.close()

        return jsonify({
            "success": False,
            "message": "Verification not found"
        }), 404

    if verification["reporter_id"] != reviewer_id:
        connection.close()

        return jsonify({
            "success": False,
            "message": "Only the original reporter can review this verification"
        }), 403

    if verification["status"] != "Pending":
        connection.close()

        return jsonify({
            "success": False,
            "message": "Verification has already been reviewed"
        }), 400

    connection.execute("""
        UPDATE verifications
        SET status = ?,
            reviewed_at = CURRENT_TIMESTAMP
        WHERE id = ?
    """, (
        decision,
        verification_id
    ))

    if decision == "Approved":

        connection.execute("""
            UPDATE claims
            SET status = 'Approved'
            WHERE id = ?
        """, (
            verification["claim_id"],
        ))

        connection.execute("""
            UPDATE items
            SET status = 'Resolved'
            WHERE id = ?
        """, (
            verification["item_id"],
        ))

        connection.execute("""
            INSERT INTO notifications (
                user_id,
                item_id,
                claim_id,
                message
            )
            VALUES (?, ?, ?, ?)
        """, (
            verification["claimant_id"],
            verification["item_id"],
            verification["claim_id"],
            "Your claim has been approved. The item is now marked as resolved."
        ))

    else:

        connection.execute("""
            UPDATE claims
            SET status = 'Rejected'
            WHERE id = ?
        """, (
            verification["claim_id"],
        ))

        connection.execute("""
            INSERT INTO notifications (
                user_id,
                item_id,
                claim_id,
                message
            )
            VALUES (?, ?, ?, ?)
        """, (
            verification["claimant_id"],
            verification["item_id"],
            verification["claim_id"],
            "Your claim verification was rejected."
        ))

    connection.commit()
    connection.close()

    return jsonify({
        "success": True,
        "message": "Verification reviewed successfully!",
        "verification_id": verification_id,
        "claim_id": verification["claim_id"],
        "item_id": verification["item_id"],
        "decision": decision
    })


# =========================
# RUN SERVER
# =========================

if __name__ == "__main__":
    app.run(debug=True)