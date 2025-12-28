from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import firebase_admin
from firebase_admin import credentials, firestore
import json
import os

# --- Firebase init ---
cred = credentials.Certificate("key.json")
firebase_admin.initialize_app(cred)

db = firestore.client()

# --- FastAPI ---
app = FastAPI(title="Session Helper")

class FetchRequest(BaseModel):
    collection: str
    document_id: str
    
class AddItemRequest(BaseModel):
    character_id: str
    item_id: str
    is_equipped: bool = False
    quantity: int = 1
    
@app.get("/test")
def test():
    return {"status": "ok"}

@app.get("/firestore-test")
def firestore_test():
    docs = db.collection("characters").limit(1).get()
    return {"docs": len(docs)}

@app.post("/fetch")
def fetch_document(req: FetchRequest):
    doc_ref = db.collection(req.collection).document(req.document_id)
    doc = doc_ref.get()

    if not doc.exists:
        raise HTTPException(status_code=404, detail="Document not found")

    data = doc.to_dict()

    with open("output_model.json", "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    return {
        "status": "success",
        "saved_to": os.path.abspath("output_model.json"),
        "data": data
    }


# bracers-1
# cube-of-force
# sage-signet
@app.post("/character/add-item")
def add_item(req: AddItemRequest):
    char_ref = db.collection("characters").document(req.character_id)

    # Firestore map path
    item_path = f"backpack.items.{req.item_id}"

    char_ref.set({
        item_path: {
            "is_equipped": req.is_equipped,
            "quantity": req.quantity
        }
    }, merge=True)

    return {
        "status": "success",
        "added_item": req.item_id
    }