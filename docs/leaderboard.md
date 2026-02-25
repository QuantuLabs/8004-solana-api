# Leaderboard (GraphQL v2)

The GraphQL API exposes ordering and filtering primitives that can be used to build leaderboards.

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004-indexer-production.up.railway.app/v2/graphql"
```

## Examples

### Top agents by quality score (ATOM-enabled)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query { agents(first: 20, where: { atomEnabled: true, trustTier_gte: 2 }, orderBy: qualityScore, orderDirection: desc) { id owner totalFeedback solana { trustTier qualityScore confidence riskScore diversityRatio } } }"
  }'
```

Response (example):

```json
{
  "data": {
    "agents": [
      {
        "id": "sol:ASSET_PUBKEY",
        "owner": "OWNER_WALLET",
        "totalFeedback": "12",
        "solana": {
          "trustTier": 2,
          "qualityScore": 8400,
          "confidence": 9100,
          "riskScore": 15,
          "diversityRatio": 40
        }
      }
    ]
  }
}
```

### Top agents by total feedback (activity leaderboard)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query { agents(first: 20, orderBy: totalFeedback, orderDirection: desc) { id owner totalFeedback solana { trustTier qualityScore } } }"
  }'
```

Response (example):

```json
{
  "data": {
    "agents": [
      {
        "id": "sol:ASSET_PUBKEY",
        "owner": "OWNER_WALLET",
        "totalFeedback": "42",
        "solana": { "trustTier": 3, "qualityScore": 9100 }
      }
    ]
  }
}
```

### Top agents filtered by collection scope (`collection` + `creator`)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($collection: String!, $creator: String!) { agents(first: 20, where: { collectionPointer: $collection, creator: $creator }, orderBy: qualityScore, orderDirection: desc) { id owner creator collectionPointer totalFeedback solana { collection trustTier qualityScore } } }",
    "variables": { "collection": "my-col", "creator": "CREATOR_WALLET" }
  }'
```

Response (example):

```json
{
  "data": {
    "agents": [
      {
        "id": "sol:ASSET_PUBKEY",
        "owner": "OWNER_WALLET",
        "creator": "CREATOR_WALLET",
        "collectionPointer": "my-col",
        "totalFeedback": "12",
        "solana": { "collection": "COLLECTION_PUBKEY", "trustTier": 2, "qualityScore": 8400 }
      }
    ]
  }
}
```
