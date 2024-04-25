from flask import Flask, request, jsonify, send_from_directory
from flask_restx import Api, Resource, fields
from datetime import datetime
import json
import os

import requests

app = Flask(__name__)
api = Api(app, version='1.0', title='D&D API',
          description='A simple D&D API')

ns = api.namespace('api', description='D&D operations')

DB_PATH = '../database.json'
CUSTOM_DB_PATH = '../custom_db.json'
TIMESTAMP_PATH = '../db_timestamp.txt'
BASE_API_URL = 'https://api.open5e.com/v1/'
ALT_API_URL = 'https://www.dnd5eapi.co/api/'

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
    
def sync_field(field):
    has_next = True
    fields_json = []
    while has_next:
        response = requests.get(f'{BASE_API_URL}{field}/')
        if response.status_code == 200:
            results = response.json()['results']
            fields_json.extend(results)
            if not response.json()['next']:
                has_next = False
    db = read_db()
    db[field] = fields_json
    write_db(db)

def sync_equipments():
    

def add_custom_db():
    with open(CUSTOM_DB_PATH, 'r') as file:
        custom_db = json.load(file)
        db = read_db()
        for table_name in custom_db:
            if table_name == 'characters':
                continue
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
    
@ns.route('/api_sync')
class ApiFetch(Resource):
    @api.doc(responses={200: 'Success'})
    def post(self):
        sync_field('races')
        sync_field('feats')
        sync_field('classes')
        sync_field('spelllist')
        sync_field('spells')
        sync_field('backgrounds')
        sync_field('monsters')
        sync_field('conditions')
        sync_field('magicitems')
        sync_field('armor')
        sync_field('weapons')
        add_custom_db()
        return {'success': True}

@ns.route('/db')
class Sync(Resource):
    @api.doc(responses={200: 'Data and Timestamp'})
    def get(self):
        db = read_db()
        timestamp = read_timestamp()
        return {'data': db, 'timestamp': timestamp}

@ns.route('/update')
class Update(Resource):
    @api.doc(responses={200: 'Database updated'}, body=race_model)
    def post(self):
        data = request.json
        write_db(data)
        return {'success': True, 'timestamp': read_timestamp()}

@ns.route('/handouts/<filename>')
class Handouts(Resource):
    @api.doc(responses={200: 'File delivered'}, params={'filename': 'The name of the file'})
    def get(self, filename):
        return send_from_directory('static/handouts', filename)

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
