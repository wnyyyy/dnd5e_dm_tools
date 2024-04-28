from flask import Flask, request, send_from_directory
from flask_restx import Api, Resource
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, firestore
import json
import os

import requests

app = Flask(__name__)
api = Api(app, version='1.0', title='D&D API',
          description='A simple D&D API')

ns = api.namespace('api', description='D&D operations')

FIREBASE_KEY_PATH = './firebase_key.json'
BASE_DB_PATH = './base_db.json'
DB_PATH = './database.json'
CUSTOM_DB_PATH = './custom_db.json'
TIMESTAMP_PATH = './db_timestamp.txt'
BASE_API_URL = 'https://api.open5e.com/v1/'
ALT_API_URL = 'https://www.dnd5eapi.co/api/'

cred = credentials.Certificate(FIREBASE_KEY_PATH)
firebase_admin.initialize_app(cred)
db = firestore.client()

def read_db():
    try:
        with open(DB_PATH, 'r') as file:
            return json.load(file)
    except FileNotFoundError:
        return {}

def write_db(data):
    with open(DB_PATH, 'w') as file:
        json.dump(data, file)
    update_timestamp()

def read_base_db():
    try:
        with open(BASE_DB_PATH, 'r') as file:
            return json.load(file)
    except FileNotFoundError:
        return {}

def write_base_db(data):
    with open(BASE_DB_PATH, 'w') as file:
        json.dump(data, file)

def update_timestamp():
    with open(TIMESTAMP_PATH, 'w') as file:
        file.write(datetime.now().isoformat())

def read_timestamp():
    try:
        with open(TIMESTAMP_PATH, 'r') as file:
            return file.read().strip()
    except FileNotFoundError:
        update_timestamp()
        return read_timestamp()
    
def sync_from_base_api(field):
    print("Syncing ", field)
    has_next = True
    fields_json = []
    url = f'{BASE_API_URL}{field}/'
    while has_next:
        print("Fetching ", url)
        response = requests.get(url, timeout=10)
        if response.status_code == 200:
            results = response.json()['results']
            fields_json.extend(results)
            if not response.json()['next']:
                has_next = False
            else:
                url = response.json()['next']
        else:
            print("Error fetching ", url)
    db = read_base_db()
    db[field] = fields_json
    write_base_db(db)

def sync_from_alt_api(field):
    print("Syncing ", field)
    fields_json = []
    url = f'{ALT_API_URL}{field}'
    print("Fetching ", url)
    response = requests.get(url)
    equipments = []
    if response.status_code == 200:
        fields_json = response.json()['results']
    for equipment_key in fields_json:
        url = f'{ALT_API_URL}{field}/{equipment_key["index"]}'
        print("Fetching ", url)
        response_eq = requests.get(url)
        if response_eq.status_code == 200:
            equipment = response_eq.json()
            equipment['slug'] = equipment['index']
            equipments.append(equipment)
    db = read_base_db()
    db['equipment'] = equipments
    write_base_db(db)        

def generate_db():
    db = read_base_db()
    with open(CUSTOM_DB_PATH, 'r') as file:
        custom_db = json.load(file)
        for table_name in custom_db:
            table = db[table_name]
            for custom_entry in custom_db[table_name]:
                fallbackSlug = custom_entry['fallback']
                newRef = [x for x in table if x['slug'] == fallbackSlug][0]
                new = newRef.copy()
                for key in custom_entry:
                    if key != 'fallback':
                        new[key] = custom_entry[key]
                table.append(new)
    write_db(db)

def upload_to_firestore(collection_name, documents):
    collection_ref = db.collection(collection_name)
    for doc_data in documents:
        doc_id = doc_data['slug']
        doc_data.pop('slug', None) 
        collection_ref.document(doc_id).set(doc_data)
        print(f"Document {doc_id} uploaded to {collection_name}.")
    
@ns.route('/api_sync')
class ApiSync(Resource):
    @api.doc(responses={200: 'Success'})
    def post(self):
        db = read_base_db()
        if 'races' not in db:
            sync_from_base_api('races')
        if 'feats' not in db:
            sync_from_base_api('feats')
        if 'classes' not in db:
            sync_from_base_api('classes')
        if 'spelllist' not in db:
            sync_from_base_api('spelllist')
        if 'spells' not in db:
            sync_from_base_api('spells')
        if 'backgrounds' not in db:
            sync_from_base_api('backgrounds')
        if 'monsters' not in db:
            sync_from_base_api('monsters')
        if 'conditions' not in db:
            sync_from_base_api('conditions')
        if 'magicitems' not in db:
            sync_from_base_api('magicitems')
        if 'armor' not in db:
            sync_from_base_api('armor')
        if 'weapons' not in db:
            sync_from_base_api('weapons')
        sync_from_alt_api('equipment')
        return {'success': True}
    
@ns.route('/db')
class Db(Resource):
    @api.doc(responses={200: 'Success'})
    def post(self):
        generate_db()        
        return {'success': True}
    
    @api.doc(responses={200: 'Data and Timestamp'})
    def get(self):
        db = read_db()
        timestamp = read_timestamp()
        return {'data': db, 'timestamp': timestamp}

@ns.route('/custom_db')
class CustomDb(Resource):
    @api.doc(responses={200: 'Custom database updated'})
    def post(self):
        data = request.json
        if data:
            with open(CUSTOM_DB_PATH, 'w') as file:
                json.dump(data, file)
            generate_db()
            firebase_service_key = os.getenv('FIREBASE_SERVICE_ACCOUNT_KEY')
            return {'success': True, 'timestamp': read_timestamp()}
        else:
            api.abort(400, 'No data provided')

@ns.route('/db/upload_custom')
class UploadCustomDb(Resource):
    @api.doc(responses={200: 'Custom database uploaded'})
    def post(self):
        with open(CUSTOM_DB_PATH, 'r') as file:
            custom_db = json.load(file)
            for table_name in custom_db:
                upload_to_firestore(table_name, custom_db[table_name])

@ns.route('/handouts/<filename>')
class Handouts(Resource):
    @api.doc(responses={200: 'File delivered'}, params={'filename': 'The name of the file'})
    def get(self, filename):
        return send_from_directory('static/handouts', filename)
    
@ns.route('/upload_db')
class Firestore(Resource):
    @api.doc(responses={200: 'Database uploaded to Firestore'})
    def post(self):
        db = read_db()
        for category, docs in db.items():
            if category == 'equipment':
                upload_to_firestore(category, docs)      

@ns.route('/upload_handout')
class UploadHandout(Resource):
    @api.doc(responses={200: 'File uploaded successfully'})
    def post(self):
        if 'handout' in request.files:
            file = request.files['handout']
            filename = file.filename
            file.save(os.path.join('static/handouts', filename))
            return {'success': True, 'filename': filename}
        else:
            api.abort(400, 'No file provided')

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
