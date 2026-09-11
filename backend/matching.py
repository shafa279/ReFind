import os
import re
import torch

from PIL import Image
from transformers import CLIPProcessor, CLIPModel


# ============================================================
# CLIP SETUP
# ============================================================

MODEL_NAME = "openai/clip-vit-base-patch32"

print("Loading CLIP model...")

clip_model = CLIPModel.from_pretrained(MODEL_NAME)
clip_processor = CLIPProcessor.from_pretrained(MODEL_NAME)

print("CLIP model ready!")


# ============================================================
# TEXT CLEANING
# ============================================================

def clean_text(text):
    if not text:
        return set()

    text = str(text).lower()

    words = re.findall(r"[a-z0-9]+", text)

    stop_words = {
        "the",
        "a",
        "an",
        "and",
        "or",
        "is",
        "in",
        "on",
        "at",
        "to",
        "of",
        "for",
        "with",
        "my",
        "this",
        "that",
        "item"
    }

    return {
        word
        for word in words
        if word not in stop_words
    }


# ============================================================
# TEXT SIMILARITY
# ============================================================

def text_similarity(text1, text2):

    words1 = clean_text(text1)
    words2 = clean_text(text2)

    if not words1 or not words2:
        return 0

    common_words = words1.intersection(words2)
    union_words = words1.union(words2)

    if not union_words:
        return 0

    return len(common_words) / len(union_words)


# ============================================================
# GET IMAGE EMBEDDING
# ============================================================

def get_image_embedding(image_path):

    if not image_path:
        return None

    # If database stores a relative path,
    # convert it to an absolute path.
    if not os.path.isabs(image_path):

        project_root = os.path.dirname(
            os.path.dirname(
                os.path.abspath(__file__)
            )
        )

        image_path = os.path.join(
            project_root,
            image_path
        )

    if not os.path.exists(image_path):

        print(
            "CLIP image not found:",
            image_path
        )

        return None

    try:

        image = Image.open(
            image_path
        ).convert("RGB")

        inputs = clip_processor(
            images=image,
            return_tensors="pt"
        )

        with torch.no_grad():

            outputs = clip_model.get_image_features(
                **inputs
            )

        # Transformers versions can return
        # either a tensor or an output object.

        if hasattr(outputs, "pooler_output"):

            features = outputs.pooler_output

        else:

            features = outputs

        # Normalize the embedding
        features = features / features.norm(
            dim=-1,
            keepdim=True
        )

        return features

    except Exception as error:

        print(
            "CLIP image processing error:",
            error
        )

        return None


# ============================================================
# IMAGE SIMILARITY
# ============================================================

def image_similarity(
    image1_path,
    image2_path
):

    embedding1 = get_image_embedding(
        image1_path
    )

    embedding2 = get_image_embedding(
        image2_path
    )

    if embedding1 is None or embedding2 is None:

        return 0

    similarity = torch.nn.functional.cosine_similarity(
        embedding1,
        embedding2
    )

    similarity_value = similarity.item()

    # Convert cosine similarity
    # from -1..1 into 0..1

    similarity_value = max(
        0,
        min(
            1,
            (similarity_value + 1) / 2
        )
    )

    return similarity_value


# ============================================================
# MATCH SCORE
# ============================================================

def calculate_match_score(
    lost_item,
    found_item
):

    score = 0

    # --------------------------------------------------------
    # CATEGORY — 20 POINTS
    # --------------------------------------------------------

    lost_category = str(
        lost_item["category"] or ""
    ).strip().lower()

    found_category = str(
        found_item["category"] or ""
    ).strip().lower()

    if (
        lost_category
        and found_category
        and lost_category == found_category
    ):

        score += 20


    # --------------------------------------------------------
    # LOCATION — 20 POINTS
    # --------------------------------------------------------

    lost_location = clean_text(
        lost_item["location"]
    )

    found_location = clean_text(
        found_item["location"]
    )

    if lost_location and found_location:

        if lost_location == found_location:

            score += 20

        elif lost_location.intersection(
            found_location
        ):

            score += 15


    # --------------------------------------------------------
    # DATE — 15 POINTS
    # --------------------------------------------------------

    lost_date = str(
        lost_item["date"] or ""
    ).strip()

    found_date = str(
        found_item["date"] or ""
    ).strip()

    if (
        lost_date
        and found_date
        and lost_date == found_date
    ):

        score += 15


    # --------------------------------------------------------
    # TIME — 5 POINTS
    # --------------------------------------------------------

    lost_time = str(
        lost_item["time"] or ""
    ).strip()

    found_time = str(
        found_item["time"] or ""
    ).strip()

    if lost_time and found_time:

        if lost_time == found_time:

            score += 5

        else:

            lost_hour = lost_time.split(":")[0]
            found_hour = found_time.split(":")[0]

            if lost_hour == found_hour:

                score += 3


    # --------------------------------------------------------
    # PUBLIC DESCRIPTION — 10 POINTS
    # --------------------------------------------------------

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
        similarity * 10
    )

    score += description_score


    # --------------------------------------------------------
    # CLIP IMAGE SIMILARITY — 30 POINTS
    # --------------------------------------------------------

    image_similarity_score = 0

    lost_image = lost_item["image_path"]
    found_image = found_item["image_path"]

    if lost_image and found_image:

        image_similarity_score = image_similarity(
            lost_image,
            found_image
        )

        clip_score = round(
            image_similarity_score * 30
        )

        score += clip_score

        print(
            "CLIP similarity:",
            round(
                image_similarity_score * 100,
                2
            ),
            "%"
        )

        print(
            "CLIP score:",
            clip_score,
            "/ 30"
        )


    # --------------------------------------------------------
    # FINAL SCORE
    # --------------------------------------------------------

    final_score = min(
        round(score),
        100
    )

    return final_score


# ============================================================
# FIND MATCHES
# ============================================================

def find_matches(item):

    from backend.database import get_db_connection

    connection = get_db_connection()

    item_type = str(
        item["item_type"]
    ).strip().lower()

    # Lost → search Found
    # Found → search Lost

    if item_type == "lost":

        opposite_type = "Found"

    else:

        opposite_type = "Lost"


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
            item["id"]
        )
    ).fetchall()

    connection.close()


    results = []


    for match in matches:

        score = calculate_match_score(
            item,
            match
        )

        # Only show potential matches
        # with a score of 20 or higher.

        if score >= 20:

            results.append({

                "id": match["id"],

                "item_type": match["item_type"],

                "item_name": match["item_name"],

                "category": match["category"],

                "location": match["location"],

                "date": match["date"],

                "time": match["time"],

                "public_details": (
                    match["public_details"]
                ),

                "image_path": (
                    match["image_path"]
                ),

                "status": match["status"],

                "match_score": score

            })


    # Highest match first

    results.sort(
        key=lambda x: x["match_score"],
        reverse=True
    )


    return results