#!/bin/bash
set -e

SAMPLE_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SAMPLE_DIR/Config.toml"

# Kill any leftover process on the Telegram webhook port
lsof -ti :8090 | xargs kill -9 2>/dev/null || true

# Start ngrok on the webhook port with JSON logging so we can read the URL from this instance
echo "Starting ngrok..."
ngrok http 8090 --log=stdout --log-format=json > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!

# Stop this ngrok instance when the script exits
trap 'kill "$NGROK_PID" 2>/dev/null' EXIT

# Wait for the tunnel URL to appear in this instance's log
echo "Waiting for ngrok tunnel..."
until grep -q '"url":"https://' /tmp/ngrok.log 2>/dev/null; do
  sleep 1
done

# Extract the https URL from this instance's log (not the API, which may return another session's URL)
NGROK_URL=$(python3 -c "
import json
with open('/tmp/ngrok.log') as f:
    for line in f:
        try:
            d = json.loads(line)
            if 'url' in d and d['url'].startswith('https://'):
                print(d['url'])
                break
        except Exception:
            pass
")

echo "ngrok URL: $NGROK_URL"

# Update telegramCallbackUrl in Config.toml
python3 -c "
import re, sys
path = sys.argv[1]
url  = sys.argv[2]
with open(path) as f:
    content = f.read()
content = re.sub(r'telegramCallbackUrl\s*=\s*\"[^\"]*\"',
                 'telegramCallbackUrl = \"' + url + '\"', content)
with open(path, 'w') as f:
    f.write(content)
" "$CONFIG" "$NGROK_URL"
echo "Updated Config.toml"

# Run the app from the sample root
cd "$SAMPLE_DIR"
bal run
