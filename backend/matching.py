def calculate_match_score(lost_item, found_item):
    score = 0

    # Category match
    if lost_item["category"].lower() == found_item["category"].lower():
        score += 30

    # Location match
    if lost_item["location"].lower() == found_item["location"].lower():
        score += 25

    # Date match
    if lost_item["date"] == found_item["date"]:
        score += 20

    # Time match
    if lost_item["time"] and found_item["time"]:
        if lost_item["time"] == found_item["time"]:
            score += 10

    # Description match
    lost_description = lost_item["public_details"].lower()
    found_description = found_item["public_details"].lower()

    lost_words = set(lost_description.split())
    found_words = set(found_description.split())

    common_words = lost_words.intersection(found_words)

    if common_words:
        score += 15

    return score


def find_matches(item):
    from backend.database import get_db_connection

    connection = get_db_connection()

    # If the item is Lost, search Found items.
    # If the item is Found, search Lost items.
    opposite_type = "Found" if item["item_type"] == "Lost" else "Lost"

    matches = connection.execute("""
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
        WHERE item_type = ?
        AND status = 'Searching'
    """, (opposite_type,)).fetchall()

    connection.close()

    results = []

    for match in matches:
        score = calculate_match_score(item, match)

        if score >= 40:
            results.append({
                "id": match["id"],
                "item_name": match["item_name"],
                "category": match["category"],
                "location": match["location"],
                "date": match["date"],
                "time": match["time"],
                "image_path": match["image_path"],
                "status": match["status"],
                "match_score": score
            })

    results.sort(
        key=lambda x: x["match_score"],
        reverse=True
    )

    return results