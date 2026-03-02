# Stats (GraphQL v2)

Global and per-agent statistics.

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004.qnt.sh/v2/graphql"
```

## Queries

- `protocols(first, skip): [Protocol!]!` (global rollups for the current network)
- `globalStats: GlobalStats` (global rollups)
- `agentStats(id: ID!): AgentStats` (per-agent aggregates)

## Examples

### Global protocol rollups

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query { protocols { id totalAgents totalFeedback tags } }"
  }'
```

Response (example):

```json
{
  "data": {
    "protocols": [
      {
        "id": "global-mainnet",
        "totalAgents": "136",
        "totalFeedback": "420",
        "tags": ["tag_a", "tag_b"]
      }
    ]
  }
}
```

### Global stats

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query { globalStats { id totalAgents totalFeedback totalCollections tags } }"
  }'
```

Response (example):

```json
{
  "data": {
    "globalStats": {
      "id": "global-mainnet",
      "totalAgents": "136",
      "totalFeedback": "420",
      "totalCollections": "1",
      "tags": ["tag_a", "tag_b"]
    }
  }
}
```

### Per-agent stats

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($id: ID!) { agentStats(id: $id) { id totalFeedback averageFeedbackValue lastActivity } }",
    "variables": { "id": "sol:ASSET_PUBKEY" }
  }'
```

Response (example):

```json
{
  "data": {
    "agentStats": {
      "id": "sol:ASSET_PUBKEY",
      "totalFeedback": "12",
      "averageFeedbackValue": "95.00",
      "lastActivity": "1700000000"
    }
  }
}
```
