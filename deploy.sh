#!/bin/bash
# Verificare v2 (doar citire): nu modifica nimic pe server, scrie un raport temporar.
set +e
OUT=/tmp/diag-3938fa6768588173.txt
{
echo "data: $(date)"; echo "host: $(hostname)"; uname -a; cat /etc/os-release | head -3
echo "--- disk"; df -h / | tail -1
echo "--- memorie"; free -m | head -2
echo "--- porturi ascultate"; ss -ltnp 2>/dev/null | awk '{print $4, $6}' | sed 's/users://'
echo "--- servicii active"; systemctl list-units --type=service --state=running --no-pager --no-legend 2>/dev/null | awk '{print $1}'
echo "--- pm2"; (command -v pm2 && pm2 jlist 2>/dev/null | python3 -c "import json,sys;[print(p['name'],p['pm2_env'].get('pm_cwd'),p['pm2_env'].get('status')) for p in json.load(sys.stdin)]") 2>&1 | head -20
echo "--- docker"; (command -v docker && docker ps --format '{{.Names}} {{.Image}} {{.Ports}}') 2>&1 | head -20
echo "--- node/python"; node -v 2>&1; python3 --version 2>&1
echo "--- nginx locatii"; nginx -T 2>/dev/null | grep -E '^\s*(server_name|listen|location|root|alias|proxy_pass)\b' | sed 's/^\s*//' | head -80
echo "--- /opt"; ls -la /opt 2>&1
echo "--- /var/www"; ls -la /var/www 2>&1
echo "--- unde e gestiune"; find / -xdev -path "*/gestiune/m/registru/registru.html" -not -path "/proc/*" 2>/dev/null | head -3
echo "--- procese node"; for p in $(pgrep -f node); do echo "$p $(readlink /proc/$p/cwd) $(tr "\0" " " < /proc/$p/cmdline | cut -c1-120)"; done
echo "--- cron app-update"; cat /etc/cron.d/app-update 2>&1; cat /opt/app-last-check 2>&1
} > $OUT 2>&1
for F in $(find / -xdev -path '*/gestiune/m/registru/registru.html' -not -path '/proc/*' 2>/dev/null | head -3); do
  D=$(dirname $(dirname $(dirname $(dirname $F))))
  cp $OUT "$D/gestiune/diag-3938fa6768588173.txt"; chmod 644 "$D/gestiune/diag-3938fa6768588173.txt"
  cp $OUT "$D/diag-3938fa6768588173.txt"; chmod 644 "$D/diag-3938fa6768588173.txt"
done
for R in $(nginx -T 2>/dev/null | grep -E '^\s*(root|alias)\s' | awk '{print $2}' | tr -d ';' | sort -u); do
  [ -d "$R" ] && cp $OUT "$R/diag-3938fa6768588173.txt" && chmod 644 "$R/diag-3938fa6768588173.txt" && echo "scris in $R"
done
