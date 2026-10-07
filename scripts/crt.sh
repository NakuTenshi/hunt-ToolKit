#!/bin/bash

# Usage: crt <domain> [output-file]

if [ -n "$1" ]; then
    domain="$1"
elif [ ! -t 0 ]; then
    read -r domain
else
    echo "Usage: $0 <domain>"
    exit 1
fi

crtsh=$(
    curl -s -H "User-Agent: Mozilla/5.0" \
        "https://crt.sh/?q=${domain}&output=json" |
    jq -r '.[] | .name_value, .common_name' 2>/dev/null
)

crtname=$(
    curl -s "https://crt.name/v1/search?apex=${domain}"
)

agniops=$(
    curl -s "https://app.agniops.in/v1/search?domain=${domain}"
)

result=$(
    {
        echo "$crtsh"
        echo "$crtname"
        echo "$agniops"
    } |
    tr '[:upper:]' '[:lower:]' |
    sed 's/^\*\.//' |
    sed '/^$/d' |
    sort -u
)

if [ -n "$2" ]; then
    echo "$result" > "$2"
else
    echo "$result"
fi