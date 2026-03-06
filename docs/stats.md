# Stats (GraphQL v2)

Global and per-agent statistics.

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004-api.qnt.sh/v2/graphql"
```

## Queries

- `globalStats: GlobalStats` (preferred global rollups)
- `agentStats(id: ID!): AgentStats` (per-agent aggregates)
- `protocols(first, skip): [Protocol!]!` (deprecated; use `globalStats`)

## Examples

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
      "totalCollections": "89",
      "tags": ["tag_a", "tag_b"]
    }
  }
}
```

`totalCollections` counts canonical collection scopes (`creator + collectionPointer`), not registries or raw Metaplex collection pubkeys.

### Per-agent stats

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($id: ID!) { agentStats(id: $id) { id totalFeedback averageFeedbackValue lastActivity } }",
    "variables": { "id": "ASSET_PUBKEY" }
  }'
```

Response (example):

```json
{
  "data": {
    "agentStats": {
      "id": "ASSET_PUBKEY",
      "totalFeedback": "12",
      "averageFeedbackValue": "95.00",
      "lastActivity": "1700000000"
    }
  }
}
```

## Deprecated

### Global protocol rollups (`protocols`)

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
        "id": "solana-mainnet",
        "totalAgents": "136",
        "totalFeedback": "420",
        "tags": ["tag_a", "tag_b"]
      }
    ]
  }
}
```
