import time, os
import socket

from flask import Flask, json, request
from flask_cors import CORS


version = os.environ.get("VERSION")

app = Flask(__name__)
CORS(app)


@app.route("/")
def hostname_api():
    data = {"version": version, "hostname": socket.gethostname()}
    return app.response_class(
        response=json.dumps(data),
        status=200,
        mimetype="application/json",
    )

@app.route("/health/")
def health_api():
    data = {"version": version, "state": "RUNNING"}
    return app.response_class(
        response=json.dumps(data),
        status=200,
        mimetype="application/json",
    )


@app.route("/fail/")
def fai_apil():
    func = request.environ.get("werkzeug.server.shutdown")
    if func is None:
        raise RuntimeError("Not running with Werkzeug Server")
    func()

    data = {"version": version, "state": "SHUTDOWN"}
    return app.response_class(
        response=json.dumps(data),
        status=503,
        mimetype="application/json",
    )
