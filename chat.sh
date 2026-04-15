#!/bin/bash

MODEL="gemma3:1b"
OLLAMA_URL="http://localhost:11434"

# Check dependencies
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required. Install it with: sudo apt install jq" >&2
  exit 1
fi
if ! command -v curl &>/dev/null; then
  echo "Error: curl is required. Install it with: sudo apt install curl" >&2
  exit 1
fi

# Check Ollama is reachable
if ! curl -sf "$OLLAMA_URL" &>/dev/null; then
  echo "Error: Ollama is not running at $OLLAMA_URL" >&2
  echo "Start it with: ollama serve" >&2
  exit 1
fi

# Check model is available
if ! curl -sf "$OLLAMA_URL/api/tags" | jq -e --arg m "$MODEL" '.models[].name | select(startswith($m))' &>/dev/null; then
  echo "Error: Model '$MODEL' is not available locally." >&2
  echo "Pull it with: ollama pull $MODEL" >&2
  exit 1
fi

echo "Chat with $MODEL (Ctrl+C to exit):"
echo "---"

history="[]"

chat() {
  local payload
  payload=$(jq -n \
    --arg model "$MODEL" \
    --argjson msgs "$history" \
    '{"model": $model, "messages": $msgs, "stream": false}')

  local http_code response body

  # Capture HTTP status code and body separately
  response=$(curl -s -w "\n%{http_code}" \
    --max-time 60 \
    -H "Content-Type: application/json" \
    -d "$payload" \
    "$OLLAMA_URL/api/chat" 2>&1)

  http_code=$(tail -n1 <<< "$response")
  body=$(sed '$d' <<< "$response")

  # Network / timeout errors (non-numeric exit codes or empty body)
  if [[ -z "$body" || ! "$http_code" =~ ^[0-9]+$ ]]; then
    echo "Error: No response from Ollama (network issue or timeout)." >&2
    return 1
  fi

  if [[ "$http_code" -ne 200 ]]; then
    local err
    err=$(jq -r '.error // "Unknown error"' <<< "$body" 2>/dev/null)
    echo "Error: Ollama returned HTTP $http_code — $err" >&2
    return 1
  fi

  local reply
  reply=$(jq -r '.message.content' <<< "$body" 2>/dev/null)

  if [[ -z "$reply" || "$reply" == "null" ]]; then
    echo "Error: Unexpected response format from Ollama." >&2
    return 1
  fi

  echo "LLM: $reply"
  echo ""

  # Append assistant reply to history
  history=$(jq -c --arg content "$reply" \
    '. + [{"role": "assistant", "content": $content}]' <<< "$history")
}

while IFS= read -r -p "Tú: " msg; do
  [[ -z "$msg" ]] && continue

  # Append user message to history
  history=$(jq -c --arg content "$msg" \
    '. + [{"role": "user", "content": $content}]' <<< "$history")

  chat || continue
done

echo ""
echo "Goodbye!"
