# custom-prometheus-flask-exporter
from flask import Flask, jsonify, request, abort
from prometheus_client import start_http_server, Counter, generate_latest
import time

app = Flask(__name__)

# Create prometheus metrics
REQUESTS = Counter('http_requests_total', 'Total number of HTTP requests')
CLIENT_ERRORS = Counter('http_requests_400_total', 'Total number of 400 HTTP errors')
SERVER_ERRORS = Counter('http_requests_500_total', 'Total number of 500 HTTP errors')

# Dictionary to store metric values
metric_values = {
    "400_count": 0,
    "500_count": 0,
    "request_count": 0
}

@app.route("/index")
def index():
    return "hello"

@app.route("/http_data")
def http_data():
    return metric_values

@app.route("/action")
def action():
    metric_values["request_count"] = metric_values["request_count"] + 1
    REQUESTS.inc()
    return "act!"

# 'abort' instructing flask to respond with a 500 error
@app.route("/error_endpoint")
def errored_endpoint():
    # return "error", 500
    abort(500)

# 'abort' instructing flask to respond with a 400 error
@app.route("/client_error_endpoint")
def client_errored_endpoint():
    # return "client error", 400
    abort(400)

# error handlers for 400 and 500 errors
@app.errorhandler(500)
def five_x_handler(e):
    metric_values["500_count"] = metric_values["500_count"] + 1
    SERVER_ERRORS.inc()
    return "error", 500

@app.errorhandler(400)
def four_x_handler(e):
    metric_values["400_count"] = metric_values["400_count"] + 1
    CLIENT_ERRORS.inc()
    return "client_and_server_is_not_degreed", 400

# Expose the metrics on a /metrics endpoint
@app.route('/metrics')
def metrics():
    # Return prometheus-formatted metrics data
    return generate_latest()

if __name__ == "__main__":
    # Start the prometheus metrics server on port 8000 for scraping metrics.
    start_http_server(8000)

    # Run the flask app on port 5000
    app.run(host="0.0.0.0", port=5000)
