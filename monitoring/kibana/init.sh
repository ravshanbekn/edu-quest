#!/bin/sh
set -e

BASE="http://kibana:5601"
XSRF="kbn-xsrf: true"
JSON="Content-Type: application/json"

log() { echo "[kibana-init] $*"; }

log "Waiting for Kibana APIs to settle..."
sleep 10

# ── 1. Data view ────────────────────────────────────────────────────────────
log "Creating data view 'eduquest-logs-*'..."
cat > /tmp/dv.json << 'EOF'
{
  "data_view": {
    "id": "eduquest-logs",
    "title": "eduquest-logs-*",
    "timeFieldName": "@timestamp",
    "name": "EduQuest Logs"
  },
  "override": true
}
EOF
curl -sf -X POST "$BASE/api/data_views/data_view" \
  -H "$XSRF" -H "$JSON" -d @/tmp/dv.json \
  && log "Data view OK" || log "Data view skipped (already exists)"

# ── Common references block (reused in all saved searches) ─────────────────
REF='[{"name":"kibanaSavedObjectMeta.searchSourceJSON.index","type":"index-pattern","id":"eduquest-logs"}]'
COLS_ALL='["level","message","logger_name","requestUri","method","userId","stack_trace"]'
COLS_HTTP='["level","message","requestUri","method","userId","logger_name"]'
COLS_ERR='["level","message","logger_name","requestUri","userId","stack_trace"]'

# ── 2. Saved search: All Logs ────────────────────────────────────────────────
log "Creating saved search: All Logs..."
cat > /tmp/s_all.json << 'EOF'
{
  "attributes": {
    "title": "EduQuest — All Logs",
    "columns": ["level","message","logger_name","requestUri","method","userId","stack_trace"],
    "sort": [["@timestamp","desc"]],
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"query\":{\"query\":\"\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
    }
  },
  "references": [{"name":"kibanaSavedObjectMeta.searchSourceJSON.index","type":"index-pattern","id":"eduquest-logs"}]
}
EOF
curl -sf -X POST "$BASE/api/saved_objects/search/eduquest-all?overwrite=true" \
  -H "$XSRF" -H "$JSON" -d @/tmp/s_all.json \
  && log "All Logs OK" || log "All Logs skipped"

# ── 3. Saved search: Errors ──────────────────────────────────────────────────
log "Creating saved search: Errors..."
cat > /tmp/s_err.json << 'EOF'
{
  "attributes": {
    "title": "EduQuest — Errors",
    "columns": ["level","message","logger_name","requestUri","userId","stack_trace"],
    "sort": [["@timestamp","desc"]],
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"query\":{\"query\":\"level:ERROR\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
    }
  },
  "references": [{"name":"kibanaSavedObjectMeta.searchSourceJSON.index","type":"index-pattern","id":"eduquest-logs"}]
}
EOF
curl -sf -X POST "$BASE/api/saved_objects/search/eduquest-errors?overwrite=true" \
  -H "$XSRF" -H "$JSON" -d @/tmp/s_err.json \
  && log "Errors OK" || log "Errors skipped"

# ── 4. Saved search: Warnings ────────────────────────────────────────────────
log "Creating saved search: Warnings..."
cat > /tmp/s_warn.json << 'EOF'
{
  "attributes": {
    "title": "EduQuest — Warnings",
    "columns": ["level","message","logger_name","requestUri","userId"],
    "sort": [["@timestamp","desc"]],
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"query\":{\"query\":\"level:WARN\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
    }
  },
  "references": [{"name":"kibanaSavedObjectMeta.searchSourceJSON.index","type":"index-pattern","id":"eduquest-logs"}]
}
EOF
curl -sf -X POST "$BASE/api/saved_objects/search/eduquest-warnings?overwrite=true" \
  -H "$XSRF" -H "$JSON" -d @/tmp/s_warn.json \
  && log "Warnings OK" || log "Warnings skipped"

# ── 5. Saved search: HTTP Requests ───────────────────────────────────────────
log "Creating saved search: HTTP Requests..."
cat > /tmp/s_http.json << 'EOF'
{
  "attributes": {
    "title": "EduQuest — HTTP Requests",
    "columns": ["level","message","requestUri","method","userId","logger_name"],
    "sort": [["@timestamp","desc"]],
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"query\":{\"query\":\"requestUri:*\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
    }
  },
  "references": [{"name":"kibanaSavedObjectMeta.searchSourceJSON.index","type":"index-pattern","id":"eduquest-logs"}]
}
EOF
curl -sf -X POST "$BASE/api/saved_objects/search/eduquest-http?overwrite=true" \
  -H "$XSRF" -H "$JSON" -d @/tmp/s_http.json \
  && log "HTTP Requests OK" || log "HTTP Requests skipped"

# ── 6. Saved search: конкретный пользователь (фильтр по userId) ──────────────
log "Creating saved search: By User..."
cat > /tmp/s_user.json << 'EOF'
{
  "attributes": {
    "title": "EduQuest — By User",
    "columns": ["level","message","requestUri","method","userId","logger_name","stack_trace"],
    "sort": [["@timestamp","desc"]],
    "kibanaSavedObjectMeta": {
      "searchSourceJSON": "{\"query\":{\"query\":\"userId:*\",\"language\":\"kuery\"},\"filter\":[],\"indexRefName\":\"kibanaSavedObjectMeta.searchSourceJSON.index\"}"
    }
  },
  "references": [{"name":"kibanaSavedObjectMeta.searchSourceJSON.index","type":"index-pattern","id":"eduquest-logs"}]
}
EOF
curl -sf -X POST "$BASE/api/saved_objects/search/eduquest-by-user?overwrite=true" \
  -H "$XSRF" -H "$JSON" -d @/tmp/s_user.json \
  && log "By User OK" || log "By User skipped"

log "──────────────────────────────────────────"
log "Kibana готова к работе!"
log "Откройте: http://localhost:5601"
log "Discover → Open → выберите нужный поиск"
log "──────────────────────────────────────────"
