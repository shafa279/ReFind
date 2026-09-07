import re


def clean_text(text):
    """Convert text into simple lowercase words."""
    if not text:
        return set()

    text = text.lower()
    words = re.findall(r"[a-z0-9]+", text)

    # Ignore very common words
    stop_words = {
        "the", "a", "an", "and", "or", "with",
        "in", "on", "at", "near", "my", "is",
        "was", "it", "has", "have"
    }

    return {
        word for word in words
        if word not in stop_words
    }


def text_similarity(text1, text2):
    """Calculate similarity between two descriptions."""
    words1 = clean_text(text1)
    words2 = clean_text(text2)

    if not words1 or not words2:
        return 0

    common_words = words1.intersection(words2)

    # Jaccard similarity
    similarity = len(common_words) / len(words1.union(words2))

    return similarity


def calculate_match_score(lost_item, found_item):
    score = 0

    # -------------------------
    # 1. CATEGORY - 25 POINTS
    # -------------------------
    if lost_item["category"].lower() == found_item["category"].lower():
        score += 25

    # -------------------------
    # 2. LOCATION - 25 POINTS
    # -------------------------
    lost_location = clean_text(lost_item["location"])
    found_location = clean_text(found_item["location"])

    if lost_location and found_location:
        if lost_location.intersection(found_location):
            score += 25

    # -------------------------
    # 3. DATE - 20 POINTS
    # -------------------------
    if lost_item["date"] == found_item["date"]:
        score += 20

    # -------------------------
    # 4. TIME - 10 POINTS
    # -------------------------
    if lost_item["time"] and found_item["time"]:

        if lost_item["time"] == found_item["time"]:
            score += 10

        else:
            # Compare hours if exact time is different
            lost_hour = lost_item["time"].split(":")[0]
            found_hour = found_item["time"].split(":")[0]

            if lost_hour == found_hour:
                score += 5

    # -------------------------
    # 5. DESCRIPTION - 20 POINTS
    # -------------------------
    similarity = text_similarity(
        lost_item["public_details"],
        found_item["public_details"]
    )

    description_score = round(similarity * 20)

    score += description_score

    return min(score, 100)


def find_matches(item):
    from backend.database import get_db_connection

    connection = get_db_connection()

    # Lost searches Found.
    # Found searches Lost.
    opposite_type = (
        "Found"
        if item["item_type"] == "Lost"
        else "Lost"
    )

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
        AND id != ?
    """, (opposite_type, item["id"])).fetchall()

    connection.close()

    results = []

    for match in matches:

        score = calculate_match_score(item, match)

        # Only show reasonably likely matches
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

    # Highest score first
    results.sort(
        key=lambda x: x["match_score"],
        reverse=True
    )

    return results