#!/bin/bash
set -e

SAMPLE_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$SAMPLE_DIR/Config.toml"

# Kill any leftover process on the Telegram webhook port
lsof -ti :8090 | xargs kill -9 2>/dev/null || true

# Start ngrok on the webhook port and remember its PID
echo "Starting ngrok..."
ngrok http 8090 --log=stdout > /tmp/ngrok.log 2>&1 &
NGROK_PID=$!

# Wait for ngrok tunnel to be ready
echo "Waiting for ngrok tunnel..."
until curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -q '"public_url"'; do
  sleep 1
done

# Extract the https URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | \
  python3 -c "import sys,json; ts=json.load(sys.stdin)['tunnels']; print(next(t['public_url'] for t in ts if t['proto']=='https'))")

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
