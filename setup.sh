#!/bin/bash
# Leaga serverul de GitHub: la fiecare minut ia ce e nou si ruleaza deploy.sh.
# Nu modifica nimic altceva de pe server.
set -e
APP=/opt/app
cat > /usr/local/bin/app-update <<'EOF'
#!/bin/bash
cd /opt/app || exit 0
OLD=$(git rev-parse HEAD)
git pull -q --ff-only || exit 0
NEW=$(git rev-parse HEAD)
if [ "$OLD" != "$NEW" ] && [ -f deploy.sh ]; then
  bash deploy.sh >> /var/log/app-update.log 2>&1
fi
date > /opt/app-last-check
EOF
chmod +x /usr/local/bin/app-update
echo '* * * * * root /usr/local/bin/app-update' > /etc/cron.d/app-update
chmod 644 /etc/cron.d/app-update
echo "GATA: serverul se actualizeaza singur din GitHub la fiecare minut."
