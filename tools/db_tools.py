from flask import Flask, request, send_from_directory
from flask_restx import Api, Resource, fields
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
CUSTOM_DB_PATH = './custom_db.json'

cred = credentials.Certificate(FIREBASE_KEY_PATH)
firebase_admin.initialize_app(cred)
db = firestore.client()

error_model = api.model('Error', {
    'error': fields.String(description='Error message'),
    'status': fields.Integer(description='HTTP status code')
})

upload_response_model = api.model('UploadResponse', {
    'message': fields.String(description='Success message'),
    'collections_processed': fields.Integer(description='Number of collections processed'),
    'documents_uploaded': fields.Integer(description='Total documents uploaded'),
    'details': fields.Raw(description='Details of uploaded collections')
})

@ns.route('/<string:collection_name>/<string:document_id>')
@ns.param('collection_name')
@ns.param('document_id')
class DocumentResource(Resource):
    @ns.doc('get_document_by_id')
    @ns.response(200, 'Success')
    @ns.response(404, 'Document not found', error_model)
    @ns.response(500, 'Internal server error', error_model)
    def get(self, collection_name, document_id):
        """Fetch a document by ID from a Firestore collection"""
        try:
            doc_ref = db.collection(collection_name).document(document_id)
            doc = doc_ref.get()
            
            if doc.exists:
                document_data = doc.to_dict()
                document_data['id'] = doc.id
                return document_data, 200
            else:
                return {
                    'error': f'Document with ID "{document_id}" not found in collection "{collection_name}"',
                    'status': 404
                }, 404
                
        except Exception as e:
            return {
                'error': f'Error fetching document: {str(e)}',
                'status': 500
            }, 500
            
@ns.route('/upload-custom-db')
class CustomDbUploadResource(Resource):
    @ns.doc('upload_custom_db')
    @ns.response(200, 'Success', upload_response_model)
    @ns.response(400, 'Bad request', error_model)
    @ns.response(404, 'custom_db.json not found', error_model)
    @ns.response(500, 'Internal server error', error_model)
    def post(self):
        """Upload data from custom_db.json to Firestore collections"""
        try:
            if not os.path.exists(CUSTOM_DB_PATH):
                return {
                    'error': f'File {CUSTOM_DB_PATH} not found',
                    'status': 404
                }, 404
            
            with open(CUSTOM_DB_PATH, 'r', encoding='utf-8') as file:
                custom_data = json.load(file)
            
            if not isinstance(custom_data, dict):
                return {
                    'error': 'custom_db.json must contain a JSON object with collection names as keys',
                    'status': 400
                }, 400
            
            upload_details = {}
            total_documents = 0
            collections_processed = 0
            
            for collection_name, documents in custom_data.items():
                if not isinstance(documents, list):
                    upload_details[collection_name] = {
                        'status': 'skipped',
                        'reason': 'Value is not a list of documents'
                    }
                    continue
                
                collection_ref = db.collection(collection_name)
                documents_uploaded = 0
                errors = []
                
                for document in documents:
                    if not isinstance(document, dict):
                        errors.append('Non-object document found, skipping')
                        continue
                    
                    if 'id' not in document:
                        errors.append('Document missing "id" field, skipping')
                        continue
                    
                    doc_id = document['id']
                    
                    doc_data = {k: v for k, v in document.items() if k != 'id'}
                    
                    try:
                        collection_ref.document(doc_id).set(doc_data)
                        documents_uploaded += 1
                        total_documents += 1
                    except Exception as e:
                        errors.append(f'Failed to upload document {doc_id}: {str(e)}')
                
                upload_details[collection_name] = {
                    'status': 'completed',
                    'documents_uploaded': documents_uploaded,
                    'total_documents': len(documents),
                    'errors': errors if errors else None
                }
                collections_processed += 1
            
            return {
                'message': 'Custom database upload completed',
                'collections_processed': collections_processed,
                'documents_uploaded': total_documents,
                'details': upload_details
            }, 200
            
        except json.JSONDecodeError as e:
            return {
                'error': f'Invalid JSON in custom_db.json: {str(e)}',
                'status': 400
            }, 400
        except Exception as e:
            return {
                'error': f'Error uploading custom database: {str(e)}',
                'status': 500
            }, 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')