import re


def clean_text(text):
    """Convert text into simple lowercase words."""
    if not text:
        return set()

    text = str(text).lower()

    words = re.findall(r"[a-z0-9]+", text)

    stop_words = {
        "the", "a", "an", "and", "or", "with",
        "in", "on", "at", "near", "my", "is",
        "was", "it", "has", "have"
    }

    return {
        word
        for word in words
        if word not in stop_words
    }


def text_similarity(text1, text2):
    """Calculate similarity between two descriptions."""
    words1 = clean_text(text1)
    words2 = clean_text(text2)

    if not words1 or not words2:
        return 0

    common_words = words1.intersection(words2)
    union_words = words1.union(words2)

    if not union_words:
        return 0

    return len(common_words) / len(union_words)


def calculate_match_score(lost_item, found_item):
    """Calculate a match score between a lost and found item."""

    score = 0

    # ---------------------------------------------------------
    # 1. CATEGORY - 25 POINTS
    # ---------------------------------------------------------
    lost_category = str(
        lost_item["category"] or ""
    ).strip().lower()

    found_category = str(
        found_item["category"] or ""
    ).strip().lower()

    if lost_category and lost_category == found_category:
        score += 25

    # ---------------------------------------------------------
    # 2. LOCATION - 25 POINTS
    # ---------------------------------------------------------
    lost_location = clean_text(
        lost_item["location"]
    )

    found_location = clean_text(
        found_item["location"]
    )

    if lost_location and found_location:

        # Exact location
        if lost_location == found_location:
            score += 25

        # Any common location word
        elif lost_location.intersection(found_location):
            score += 20

    # ---------------------------------------------------------
    # 3. DATE - 20 POINTS
    # ---------------------------------------------------------
    lost_date = str(
        lost_item["date"] or ""
    ).strip()

    found_date = str(
        found_item["date"] or ""
    ).strip()

    if lost_date and lost_date == found_date:
        score += 20

    # ---------------------------------------------------------
    # 4. TIME - 10 POINTS
    # ---------------------------------------------------------
    lost_time = str(
        lost_item["time"] or ""
    ).strip()

    found_time = str(
        found_item["time"] or ""
    ).strip()

    if lost_time and found_time:

        # Exact time
        if lost_time == found_time:
            score += 10

        else:
            # Compare hours
            lost_hour = lost_time.split(":")[0]
            found_hour = found_time.split(":")[0]

            if lost_hour == found_hour:
                score += 5

    # ---------------------------------------------------------
    # 5. DESCRIPTION - 20 POINTS
    # ---------------------------------------------------------
    lost_description = (
        lost_item["public_details"]
        or ""
    )

    found_description = (
        found_item["public_details"]
        or ""
    )

    similarity = text_similarity(
        lost_description,
        found_description
    )

    description_score = round(
        similarity * 20
    )

    score += description_score

    # ---------------------------------------------------------
    # MAXIMUM SCORE = 100
    # ---------------------------------------------------------
    return min(score, 100)


def find_matches(item):
    """Find potential matches for a lost/found item."""

    from backend.database import get_db_connection

    connection = get_db_connection()

    # ---------------------------------------------------------
    # LOST -> SEARCH FOUND
    # FOUND -> SEARCH LOST
    # ---------------------------------------------------------
    item_type = str(
        item["item_type"]
    ).strip().lower()

    if item_type == "lost":
        opposite_type = "Found"

    else:
        opposite_type = "Lost"

    # ---------------------------------------------------------
    # GET OPPOSITE ITEMS
    # ---------------------------------------------------------
    matches = connection.execute(
        """
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
        WHERE LOWER(item_type) = LOWER(?)
        AND status = 'Searching'
        AND id != ?
        """,
        (
            opposite_type,
            item["id"],
        ),
    ).fetchall()

    connection.close()

    results = []

    # ---------------------------------------------------------
    # CALCULATE MATCHES
    # ---------------------------------------------------------
    for match in matches:

        score = calculate_match_score(
            item,
            match
        )

        # -----------------------------------------------------
        # LOWER THRESHOLD FOR MORE POTENTIAL MATCHES
        # -----------------------------------------------------
        if score >= 20:

            results.append({
                "id": match["id"],
                "item_name": match["item_name"],
                "category": match["category"],
                "location": match["location"],
                "date": match["date"],
                "time": match["time"],
                "image_path": match["image_path"],
                "status": match["status"],
                "match_score": score,
            })

    # ---------------------------------------------------------
    # HIGHEST SCORE FIRST
    # ---------------------------------------------------------
    results.sort(
        key=lambda x: x["match_score"],
        reverse=True,
    )

    return results