#!/bin/bash

COOKIE_ENV=${NS_COOKIE:-${COOKIE}}
pushplus_token=${PUSHPLUS_TOKEN}
telegram_bot_token=${TELEGRAM_BOT_TOKEN}
chat_id=${CHAT_ID}
telegram_api_url=${TELEGRAM_API_URL:-"https://api.telegram.org"}

telegram_Bot() {
    local response=$(curl -s -X POST "${telegram_api_url}/bot${1}/sendMessage" \
        -H "Content-Type: application/json" \
        -d "{\"chat_id\":\"${2}\",\"message_thread_id\":\"${thread_id}\",\"text\":\"${3}\"}")
    echo "telegram推送结果：$(echo "$response" | jq -r '.ok')"
}

pushplus_ts() {
    local response=$(curl -s -X POST "https://www.pushplus.plus/send/" \
        -H "Content-Type: application/json" \
        -d "{\"token\":\"${1}\",\"title\":\"${2}\",\"content\":\"${3}\"}")
    echo "pushplus推送结果：$(echo "$response" | jq -r '.msg')"
}

if [ -z "$COOKIE_ENV" ]; then
    echo "请先设置Cookie"
    exit 1
fi

url="https://www.nodeseek.com/api/attendance?random=${NS_RANDOM:-"true"}"
headers=(
    "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36 Edg/125.0.0.0"
    "Cookie: ${COOKIE_ENV}"
)

response=$(curl -s -X POST -H "${headers[@]}" "$url")
response_data=$(echo "$response" | jq .)
message=$(echo "$response_data" | jq -r '.message')
success=$(echo "$response_data" | jq -r '.success')

echo "$response_data"
echo "$COOKIE_ENV"

if [ "$success" = "true" ]; then
    echo "$message"
    [ -n "$telegram_bot_token" ] && [ -n "$chat_id" ] && telegram_Bot "$telegram_bot_token" "$chat_id" "$message"
else
    echo "$message"
    [ -n "$telegram_bot_token" ] && [ -n "$chat_id" ] && telegram_Bot "$telegram_bot_token" "$chat_id" "$message"
    [ -n "$pushplus_token" ] && pushplus_ts "$pushplus_token" "nodeseek签到" "$message"
fi
