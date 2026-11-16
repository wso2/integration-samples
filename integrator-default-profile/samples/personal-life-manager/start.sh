#!/bin/bash
set -e

PACKAGE_DIR="$(dirname "$0")/personal_life_manager"
CONFIG="$PACKAGE_DIR/Config.toml"

# Kill any leftover processes on our ports
lsof -ti :8090 | xargs kill -9 2>/dev/null || true
lsof -ti :8080 | xargs kill -9 2>/dev/null || true

# Kill any existing ngrok
pkill -f "ngrok http" 2>/dev/null || true
sleep 1

# Start ngrok
echo "Starting ngrok..."
ngrok http 8090 --log=stdout > /tmp/ngrok.log 2>&1 &

# Wait for ngrok tunnel to be ready
echo "Waiting for ngrok tunnel..."
until curl -s http://localhost:4040/api/tunnels 2>/dev/null | grep -q '"public_url"'; do
  sleep 1
done

# Extract the https URL
NGROK_URL=$(curl -s http://localhost:4040/api/tunnels | \
  python3 -c "import sys,json; ts=json.load(sys.stdin)['tunnels']; print(next(t['public_url'] for t in ts if t['proto']=='https'))")

echo "ngrok URL: $NGROK_URL"

# Update telegramCallbackUrl in Config.toml (cross-platform)
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

# Run the app
cd "$PACKAGE_DIR"
bal run
