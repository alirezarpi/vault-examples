import time, os
import socket
import redis
import psycopg2
from flask import Flask, json, request
from flask_cors import CORS


version = os.environ.get("VERSION")

app = Flask(__name__)
CORS(app)


def connect_to_redis():
    cache = redis.Redis(
        host=os.environ.get("CACHE_HOST"),
        port=os.environ.get("CACHE_PORT"),
    )
    return cache


def get_hit_count():
    retries = 5
    while True:
        try:
            return connect_to_redis().incr("hits")
        except redis.exceptions.ConnectionError as exc:
            if retries == 0:
                raise exc
            retries -= 1
            time.sleep(0.5)


def get_db_conn():
    conn = psycopg2.connect(
        host=os.environ.get("DB_HOST"),
        database=os.environ.get("DB_NAME"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASSWORD"),
    )
    return conn


@app.route("/")
def hostname_api():
    data = {
        "version": version,
        "hostname": socket.gethostname(),
    }
    return app.response_class(
        response=json.dumps(data),
        status=200,
        mimetype="application/json",
    )


@app.route("/query/")
def query_api():
    conn = get_db_conn()
    conn.rollback()
    cur = conn.cursor()
    cur.execute("SELECT * from {};".format("actor"))
    query = cur.fetchall()
    data = {
        "version": version,
        "data": "{}".format(query),
    }
    return app.response_class(
        response=json.dumps(data),
        status=200,
        mimetype="application/json",
    )


@app.route("/cache/")
def cache_api():
    count = get_hit_count()
    data = {
        "version": version,
        "call_count": count,
    }
    return app.response_class(
        response=json.dumps(data),
        status=200,
        mimetype="application/json",
    )


@app.route("/health/")
def health_api():
    data = {
        "version": version,
        "state": "RUNNING",
    }
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

    data = {
        "version": version,
        "state": "SHUTDOWN",
    }
    return app.response_class(
        response=json.dumps(data),
        status=503,
        mimetype="application/json",
    )
