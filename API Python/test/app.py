# app.py
from flask import Flask, request, jsonify, render_template

app = Flask(__name__)

# Configuration de Cosmos DB
#COSMOS_ENDPOINT = "https://<ton-cosmosdb-account>.documents.azure.com:443/"
#COSMOS_KEY = "<ta-clef-cosmosdb>"
#DATABASE_NAME = "example-database"
#CONTAINER_NAME = "example-container"

#cosmos_client = CosmosClient(COSMOS_ENDPOINT, COSMOS_KEY)
#database = cosmos_client.get_database_client(DATABASE_NAME)
#container = database.get_container_client(CONTAINER_NAME)

# Configuration du Blob Storage
#BLOB_CONNECTION_STRING = "<ta-connection-string-de-stockage>"
#BLOB_CONTAINER_NAME = "example-container"
#blob_service_client = BlobServiceClient.from_connection_string(BLOB_CONNECTION_STRING)
#blob_container_client = blob_service_client.get_container_client(BLOB_CONTAINER_NAME)

@app.route('/')
def index():
   print('Request for index page received')
   return render_template('index.html')


#@app.route("/items", methods=["GET"])
#def get_items():
#    items = list(container.read_all_items())
#    return jsonify(items)


#@app.route("/upload", methods=["POST"])
#def upload_file():
#    file = request.files['file']
#    blob_client = blob_container_client.get_blob_client(file.filename)
#    blob_client.upload_blob(file)
#    return f"File {file.filename} uploaded successfully", 200


if __name__ == "__main__":
    app.run()