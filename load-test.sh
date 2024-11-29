#!/bin/bash

# List of endpoints
endpoints=(
    "http://localhost:5000/index"
    "http://localhost:5000/action"
    "http://localhost:5000/error_endpoint"
    "http://localhost:5000/client_error_endpoint"
)

for endpoint in "${endpoints[@]}"
do
    echo "Sending request to $endpoint"
    # Repeat 20 times
    for i in {1..20}
    do
        # -s: silent mode, -o: discard output, -w: format output with HTTP response code
        curl -s -o /dev/null -w "Response Code: %{http_code}\n" $endpoint
        sleep 0.5  # 0.5-second delay
    done
done

