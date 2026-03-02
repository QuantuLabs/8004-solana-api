# Metadata (GraphQL v2)

Read agent metadata key-value pairs.

Metadata values are decoded server-side when possible.

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004.qnt.sh/v2/graphql"
```

## Queries

- `agent(id: ID!): Agent` (includes `metadata`)
- `agentMetadatas(first, skip, where): [AgentMetadata!]!`

## Filters

The `agentMetadatas(where: AgentMetadataFilter)` input supports:

- `agent` (Agent ID)
- `key`

## Examples

### All metadata for one agent (via agent.metadata)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($id: ID!) { agent(id: $id) { id metadata { key value updatedAt } } }",
    "variables": { "id": "sol:ASSET_PUBKEY" }
  }'
```

Response (example):

```json
{
  "data": {
    "agent": {
      "id": "sol:ASSET_PUBKEY",
      "metadata": [
        { "key": "website", "value": "https://example.com", "updatedAt": "1700000000" },
        { "key": "twitter", "value": "https://x.com/example", "updatedAt": "1700000000" }
      ]
    }
  }
}
```

### One metadata key for one agent (via agentMetadatas)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($agent: ID!, $key: String!) { agentMetadatas(first: 1, where: { agent: $agent, key: $key }) { key value updatedAt } }",
    "variables": { "agent": "sol:ASSET_PUBKEY", "key": "website" }
  }'
```

Response (example):

```json
{
  "data": {
    "agentMetadatas": [
      { "key": "website", "value": "https://example.com", "updatedAt": "1700000000" }
    ]
  }
}
```
