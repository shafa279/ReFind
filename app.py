from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import sys


# =========================================================
# BACKEND IMPORT SETUP
# =========================================================

BACKEND_FOLDER = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    'backend'
)

if BACKEND_FOLDER not in sys.path:
    sys.path.insert(0, BACKEND_FOLDER)

from database import get_db_connection
from matching import find_matches


# =========================================================
# FLASK APP
# =========================================================

app = Flask(__name__)
CORS(app)


# =========================================================
# HOME
# =========================================================

@app.route('/')
def home():

    return "ReFind Backend is running!"


# =========================================================
# LOGIN
# =========================================================

@app.route('/api/login', methods=['POST'])
def login():

    data = request.get_json(silent=True)

    if not data:

        return jsonify({
            'success': False,
            'message': 'Login data is missing'
        }), 400

    user_id = data.get('user_id')
    password = data.get('password')

    if not user_id or not password:

        return jsonify({
            'success': False,
            'message': 'College ID and password are required'
        }), 400

    users = {

        'TEST001': {
            'password': 'test123',
            'role': 'student'
        },

        'TEST002': {
            'password': 'test123',
            'role': 'student'
        },

        'TEST003': {
            'password': 'test123',
            'role': 'student'
        },

        'ADMIN001': {
            'password': 'admin123',
            'role': 'admin'
        }
    }

    if user_id not in users:

        return jsonify({
            'success': False,
            'message': 'User not found'
        }), 401

    if users[user_id]['password'] != password:

        return jsonify({
            'success': False,
            'message': 'Incorrect password'
        }), 401

    return jsonify({

        'success': True,

        'message': 'Login successful',

        'user_id': user_id,

        'role': users[user_id]['role']

    }), 200


# =========================================================
# REPORT ITEM
# =========================================================

@app.route('/api/report', methods=['POST'])
def report_item():

    item_type = request.form.get('item_type')
    item_name = request.form.get('item_name')
    category = request.form.get('category')
    location = request.form.get('location')
    date = request.form.get('date')
    time = request.form.get('time')

    public_details = request.form.get(
        'public_details'
    )

    private_details = request.form.get(
        'private_details'
    )

    description = request.form.get(
        'description'
    )

    reporter_id = request.form.get(
        'reporter_id'
    )

    if (
        not item_type
        or not item_name
        or not category
        or not location
        or not date
    ):

        return jsonify({
            'success': False,
            'message': 'Required fields are missing'
        }), 400

    # =====================================================
    # LOST ITEM
    # =====================================================

    if item_type.lower() == 'lost':

        # Lost description is stored separately.
        # It is NOT stored in public_details.
        public_details = ''
        private_details = ''

    # =====================================================
    # FOUND ITEM
    # =====================================================

    else:

        # Found items continue using the existing
        # public_details and private_details fields.

        description = ''

    image_path = None

    if 'image' in request.files:

        image = request.files['image']

        if image and image.filename:

            os.makedirs(
                'uploads',
                exist_ok=True
            )

            filename = image.filename

            image_path = os.path.join(
                'uploads',
                filename
            )

            image.save(image_path)

    connection = get_db_connection()

    try:

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
                description,
                image_path,
                status,
                reporter_id
            )

            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Searching', ?)

        """, (

            item_type,
            item_name,
            category,
            location,
            date,
            time,
            public_details,
            private_details,
            description,
            image_path,
            reporter_id

        ))

        item_id = cursor.lastrowid

        connection.commit()

        return jsonify({

            'success': True,

            'message':
                'Item reported successfully',

            'item_id': item_id

        }), 201

    except Exception as e:

        connection.rollback()

        return jsonify({

            'success': False,

            'message':
                f'Failed to report item: {str(e)}'

        }), 500

    finally:

        connection.close()


# =========================================================
# LEGACY REPORT ROUTE
# =========================================================

@app.route('/report', methods=['POST'])
def legacy_report():

    data = request.form

    item_type = data.get('item_type')
    item_name = data.get('item_name')
    category = data.get('category')
    location = data.get('location')
    date = data.get('date')
    time = data.get('time')

    public_details = data.get(
        'public_details'
    )

    private_details = data.get(
        'private_details'
    )

    description = data.get(
        'description'
    )

    reporter_id = data.get(
        'reporter_id'
    )

    # Keep the same Lost/Found behavior
    if item_type and item_type.lower() == 'lost':

        public_details = ''
        private_details = ''

    elif item_type:

        description = ''

    connection = get_db_connection()

    try:

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
                description,
                status,
                reporter_id
            )

            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'Searching', ?)

        """, (

            item_type,
            item_name,
            category,
            location,
            date,
            time,
            public_details,
            private_details,
            description,
            reporter_id

        ))

        item_id = cursor.lastrowid

        connection.commit()

        return jsonify({

            'success': True,

            'message':
                'Item reported successfully',

            'item_id': item_id

        }), 201

    except Exception as e:

        connection.rollback()

        return jsonify({

            'success': False,

            'message': str(e)

        }), 500

    finally:

        connection.close()


# =========================================================
# GET ALL ITEMS
# =========================================================

@app.route('/items', methods=['GET'])
def get_items():

    connection = get_db_connection()

    try:

        rows = connection.execute("""

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

            ORDER BY id DESC

        """).fetchall()

        items = []

        for row in rows:

            items.append({

                'id':
                    row['id'],

                'reporter_id':
                    row['reporter_id'],

                'item_type':
                    row['item_type'],

                'item_name':
                    row['item_name'],

                'category':
                    row['category'],

                'location':
                    row['location'],

                'date':
                    row['date'],

                'time':
                    row['time'],

                'public_details':
                    row['public_details'],

                'image_path':
                    row['image_path'],

                'status':
                    row['status']

            })

        return jsonify({

            'success': True,

            'items': items

        })

    except Exception as e:

        return jsonify({

            'success': False,

            'message': str(e)

        }), 500

    finally:

        connection.close()


# =========================================================
# MATCHING
# =========================================================

@app.route(
    '/api/matches/<int:item_id>',
    methods=['GET']
)
def get_matches(item_id):

    connection = get_db_connection()

    try:

        item = connection.execute("""

            SELECT *
            FROM items
            WHERE id = ?

        """, (item_id,)).fetchone()

        if not item:

            return jsonify({

                'success': False,

                'message':
                    'Item not found'

            }), 404

        if item['status'] != 'Searching':

            return jsonify({

                'success': True,

                'matches': []

            })

        # find_matches() expects the complete item object
        matches = find_matches(item)

        return jsonify({

            'success': True,

            'matches': matches

        })

    except Exception as e:

        return jsonify({

            'success': False,

            'message': str(e)

        }), 500

    finally:

        connection.close()


# =========================================================
# CREATE CLAIM
# =========================================================

@app.route('/api/claims', methods=['POST'])
def create_claim():

    item_id = request.form.get(
        'item_id'
    )

    claimant_id = request.form.get(
        'claimant_id'
    )

    if not item_id or not claimant_id:

        return jsonify({

            'success': False,

            'message':
                'Item ID and claimant ID are required'

        }), 400

    connection = get_db_connection()

    try:

        item = connection.execute("""

            SELECT *
            FROM items
            WHERE id = ?

        """, (item_id,)).fetchone()

        if not item:

            return jsonify({

                'success': False,

                'message':
                    'Item not found'

            }), 404

        if item['status'] != 'Searching':

            return jsonify({

                'success': False,

                'message':
                    'This item is no longer available for claiming'

            }), 400

        if item['reporter_id'] == claimant_id:

            return jsonify({

                'success': False,

                'message':
                    'You cannot claim your own reported item'

            }), 400

        existing_claim = connection.execute("""

            SELECT id
            FROM claims
            WHERE item_id = ?
            AND claimant_id = ?
            AND status = 'Pending'

        """, (

            item_id,
            claimant_id

        )).fetchone()

        if existing_claim:

            return jsonify({

                'success': False,

                'message':
                    'You already have a pending claim for this item'

            }), 400

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
            item['reporter_id']

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

            item['reporter_id'],

            item_id,

            claim_id,

            'Someone has submitted a claim for your reported item.'

        ))

        connection.commit()

        return jsonify({

            'success': True,

            'message':
                'Claim submitted successfully',

            'claim_id':
                claim_id

        }), 201

    except Exception as e:

        connection.rollback()

        return jsonify({

            'success': False,

            'message':
                f'Claim failed: {str(e)}'

        }), 500

    finally:

        connection.close()


# =========================================================
# GET CLAIMS
# =========================================================

@app.route(
    '/api/claims/<int:item_id>',
    methods=['GET']
)
def get_claims(item_id):

    connection = get_db_connection()

    try:

        claims = connection.execute("""

            SELECT
                c.id,
                c.item_id,
                c.claimant_id,
                c.reporter_id,
                c.status,
                c.created_at,

                v.id AS verification_id,
                v.status AS verification_status,
                v.verification_details,
                v.created_at AS verification_created_at,
                v.reviewed_at AS verification_reviewed_at

            FROM claims c

            LEFT JOIN verifications v
                ON c.id = v.claim_id

            WHERE c.item_id = ?

            ORDER BY c.id DESC

        """, (item_id,)).fetchall()

        result = []

        for claim in claims:

            result.append({

                'id':
                    claim['id'],

                'item_id':
                    claim['item_id'],

                'claimant_id':
                    claim['claimant_id'],

                'reporter_id':
                    claim['reporter_id'],

                'status':
                    claim['status'],

                'created_at':
                    claim['created_at'],

                'verification_id':
                    claim['verification_id'],

                'verification_status':
                    claim['verification_status'],

                'verification_details':
                    claim['verification_details'],

                'verification_created_at':
                    claim['verification_created_at'],

                'verification_reviewed_at':
                    claim['verification_reviewed_at']

            })

        return jsonify({

            'success': True,

            'claims': result

        })

    except Exception as e:

        return jsonify({

            'success': False,

            'message': str(e)

        }), 500

    finally:

        connection.close()


# =========================================================
# NOTIFICATIONS
# =========================================================

@app.route(
    '/api/notifications/<user_id>',
    methods=['GET']
)
def get_notifications(user_id):

    connection = get_db_connection()

    try:

        notifications = connection.execute("""

            SELECT *
            FROM notifications
            WHERE user_id = ?
            ORDER BY id DESC

        """, (user_id,)).fetchall()

        result = []

        for notification in notifications:

            result.append({

                'id':
                    notification['id'],

                'user_id':
                    notification['user_id'],

                'item_id':
                    notification['item_id'],

                'claim_id':
                    notification['claim_id'],

                'message':
                    notification['message'],

                'read':
                    notification['read'],

                'created_at':
                    notification['created_at']

            })

        return jsonify({

            'success': True,

            'notifications': result

        })

    except Exception as e:

        return jsonify({

            'success': False,

            'message': str(e)

        }), 500

    finally:

        connection.close()


# =========================================================
# MARK NOTIFICATION AS READ
# =========================================================

@app.route(
    '/api/notifications/<int:notification_id>/read',
    methods=['POST']
)
def mark_notification_read(notification_id):

    connection = get_db_connection()

    try:

        connection.execute("""

            UPDATE notifications

            SET read = 1

            WHERE id = ?

        """, (notification_id,))

        connection.commit()

        return jsonify({

            'success': True,

            'message':
                'Notification marked as read'

        })

    except Exception as e:

        connection.rollback()

        return jsonify({

            'success': False,

            'message': str(e)

        }), 500

    finally:

        connection.close()


# =========================================================
# SUBMIT VERIFICATION
# =========================================================

@app.route(
    '/api/verification',
    methods=['POST']
)
def submit_verification():

    claim_id = request.form.get(
        'claim_id'
    )

    verification_details = request.form.get(
        'verification_details'
    )

    if not claim_id or not verification_details:

        return jsonify({

            'success': False,

            'message':
                'Claim ID and verification details are required'

        }), 400

    connection = get_db_connection()

    try:

        claim = connection.execute("""

            SELECT *
            FROM claims
            WHERE id = ?

        """, (claim_id,)).fetchone()

        if not claim:

            return jsonify({

                'success': False,

                'message':
                    'Claim not found'

            }), 404

        if claim['status'] != 'Pending':

            return jsonify({

                'success': False,

                'message':
                    'This claim is no longer pending'

            }), 400

        existing_verification = connection.execute("""

            SELECT id
            FROM verifications
            WHERE claim_id = ?

        """, (claim_id,)).fetchone()

        if existing_verification:

            return jsonify({

                'success': False,

                'message':
                    'Verification has already been submitted'

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

            claim['id'],

            claim['item_id'],

            claim['reporter_id'],

            claim['claimant_id'],

            verification_details

        ))

        verification_id = cursor.lastrowid

        connection.commit()

        return jsonify({

            'success': True,

            'message':
                'Verification submitted successfully',

            'verification_id':
                verification_id,

            'claim_id':
                claim['id'],

            'item_id':
                claim['item_id'],

            'reporter_id':
                claim['reporter_id'],

            'claimant_id':
                claim['claimant_id'],

            'status':
                'Pending'

        }), 201

    except Exception as e:

        connection.rollback()

        return jsonify({

            'success': False,

            'message':
                f'Verification submission failed: {str(e)}'

        }), 500

    finally:

        connection.close()


# =========================================================
# GET VERIFICATION
# =========================================================

@app.route(
    '/api/verification/<int:verification_id>',
    methods=['GET']
)
def get_verification(verification_id):

    connection = get_db_connection()

    try:

        verification = connection.execute("""

            SELECT *
            FROM verifications
            WHERE id = ?

        """, (verification_id,)).fetchone()

        if not verification:

            return jsonify({

                'success': False,

                'message':
                    'Verification not found'

            }), 404

        result = {

            'id':
                verification['id'],

            'claim_id':
                verification['claim_id'],

            'item_id':
                verification['item_id'],

            'reporter_id':
                verification['reporter_id'],

            'claimant_id':
                verification['claimant_id'],

            'verification_details':
                verification['verification_details'],

            'status':
                verification['status'],

            'created_at':
                verification['created_at'],

            'reviewed_at':
                verification['reviewed_at']

        }

        return jsonify({

            'success': True,

            'verification': result

        })

    except Exception as e:

        return jsonify({

            'success': False,

            'message': str(e)

        }), 500

    finally:

        connection.close()


# =========================================================
# REVIEW VERIFICATION
# =========================================================

@app.route(
    '/api/verification/<int:verification_id>/review',
    methods=['POST']
)
def review_verification(verification_id):

    reviewer_id = request.form.get(
        'reviewer_id'
    )

    decision = request.form.get(
        'decision'
    )

    if not reviewer_id or not decision:

        return jsonify({

            'success': False,

            'message':
                'Reviewer ID and decision are required'

        }), 400

    if decision not in [
        'Approved',
        'Rejected'
    ]:

        return jsonify({

            'success': False,

            'message':
                'Invalid decision'

        }), 400

    connection = get_db_connection()

    try:

        verification = connection.execute("""

            SELECT *
            FROM verifications
            WHERE id = ?

        """, (verification_id,)).fetchone()

        if not verification:

            return jsonify({

                'success': False,

                'message':
                    'Verification not found'

            }), 404

        if verification['reporter_id'] != reviewer_id:

            return jsonify({

                'success': False,

                'message':
                    'Only the original reporter can review this verification'

            }), 403

        if verification['status'] != 'Pending':

            return jsonify({

                'success': False,

                'message':
                    'This verification has already been reviewed'

            }), 400

        claim_id = verification['claim_id']

        item_id = verification['item_id']

        claimant_id = verification['claimant_id']


        # =====================================================
        # APPROVED
        # =====================================================

        if decision == 'Approved':

            item = connection.execute("""

                SELECT image_path
                FROM items
                WHERE id = ?

            """, (item_id,)).fetchone()

            image_path = (
                item['image_path']
                if item
                else None
            )

            connection.execute("""

                UPDATE claims

                SET status = 'Approved'

                WHERE id = ?

            """, (claim_id,))

            connection.execute("""

                UPDATE verifications

                SET status = 'Approved',
                    reviewed_at = CURRENT_TIMESTAMP

                WHERE id = ?

            """, (verification_id,))

            connection.execute("""

                UPDATE items

                SET status = 'Resolved'

                WHERE id = ?

            """, (item_id,))

            # Notify claimant
            connection.execute("""

                INSERT INTO notifications (
                    user_id,
                    item_id,
                    claim_id,
                    message
                )

                VALUES (?, ?, ?, ?)

            """, (

                claimant_id,

                item_id,

                claim_id,

                'Your claim has been approved. '
                'The item has been successfully resolved.'

            ))

            # Remove other notifications for this item
            connection.execute("""

                DELETE FROM notifications

                WHERE item_id = ?

                AND claim_id != ?

            """, (

                item_id,

                claim_id

            ))

            # Remove other verification records
            connection.execute("""

                DELETE FROM verifications

                WHERE item_id = ?

                AND id != ?

            """, (

                item_id,

                verification_id

            ))

            # Remove other claims
            connection.execute("""

                DELETE FROM claims

                WHERE item_id = ?

                AND id != ?

            """, (

                item_id,

                claim_id

            ))

            # Delete approved verification
            connection.execute("""

                DELETE FROM verifications

                WHERE id = ?

            """, (verification_id,))

            # Delete approved claim
            connection.execute("""

                DELETE FROM claims

                WHERE id = ?

            """, (claim_id,))

            # Delete resolved item
            connection.execute("""

                DELETE FROM items

                WHERE id = ?

            """, (item_id,))

            # Delete uploaded image
            if image_path:

                try:

                    full_image_path = os.path.join(

                        os.path.dirname(
                            os.path.abspath(__file__)
                        ),

                        image_path

                    )

                    if os.path.exists(
                        full_image_path
                    ):

                        os.remove(
                            full_image_path
                        )

                except Exception:

                    pass

            connection.commit()

            return jsonify({

                'success': True,

                'message':
                    'Verification approved and report deleted successfully',

                'verification_id':
                    verification_id,

                'claim_id':
                    claim_id,

                'item_id':
                    item_id,

                'decision':
                    decision

            }), 200


        # =====================================================
        # REJECTED
        # =====================================================

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

            """, (claim_id,))

            connection.execute("""

                INSERT INTO notifications (
                    user_id,
                    item_id,
                    claim_id,
                    message
                )

                VALUES (?, ?, ?, ?)

            """, (

                claimant_id,

                item_id,

                claim_id,

                'Your claim verification was rejected.'

            ))

            connection.commit()

            return jsonify({

                'success': True,

                'message':
                    'Verification rejected successfully',

                'verification_id':
                    verification_id,

                'claim_id':
                    claim_id,

                'item_id':
                    item_id,

                'decision':
                    decision

            }), 200


    except Exception as e:

        connection.rollback()

        return jsonify({

            'success': False,

            'message':
                f'Verification review failed: {str(e)}'

        }), 500

    finally:

        connection.close()


# =========================================================
# RUN SERVER
# =========================================================

if __name__ == '__main__':

    app.run(

        host='0.0.0.0',

        port=5000,

        debug=True

    )