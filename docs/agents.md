# Agents (GraphQL v2)

List registered agents (Metaplex Core assets) and their ATOM reputation stats.

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004-indexer-production.up.railway.app/v2/graphql"
```

## IDs

GraphQL uses namespaced IDs:

- Agent: `sol:<asset_pubkey>`

Notes:

- `Agent.id` is a string ID (namespaced with `sol:`).
- The raw Solana pubkey is available at `agent.solana.assetPubkey`.

## Queries

- `agent(id: ID!): Agent`
- `agents(first, skip, after, where, orderBy, orderDirection): [Agent!]!`

## Pagination

You can paginate lists in 2 ways:

1. Offset pagination (simple): `first` + `skip`
2. Cursor pagination (efficient for deep pages): `first` + `after`

Rules:

- Do not combine `skip` and `after`.
- `after` is only supported with `orderBy: createdAt`.

The API returns an opaque `Agent.cursor` (not the asset pubkey). You do not need to compute it: request it in the page results, then pass it back as `after`. To fetch the next page, pass the last row cursor back as `after`.

## Filters

The `agents(where: AgentFilter)` input supports:

- `id`, `id_in`
- `owner`, `owner_in`
- `creator`
- `agentWallet`
- `collection` (raw Metaplex collection)
- `collectionPointer` (canonical collection id)
- `parentAsset`, `parentCreator`
- `colLocked`, `parentLocked`
- `atomEnabled`
- `trustTier_gte`
- `totalFeedback_gt`, `totalFeedback_gte`
- `createdAt_gt`, `createdAt_lt` (unix seconds)
- `updatedAt_gt`, `updatedAt_lt` (unix seconds)

## Ordering

Use `orderBy: AgentOrderBy`:

- `createdAt` (default)
- `updatedAt`
- `totalFeedback`
- `qualityScore`
- `trustTier`

## Examples

### List latest agents

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($first: Int!) { agents(first: $first, orderBy: createdAt, orderDirection: desc) { id owner createdAt totalFeedback solana { assetPubkey trustTier qualityScore } } }",
    "variables": { "first": 10 }
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
        "createdAt": "1700000000",
        "totalFeedback": "12",
        "solana": { "assetPubkey": "ASSET_PUBKEY", "trustTier": 2, "qualityScore": 8400 }
      }
    ]
  }
}
```

### Fetch one agent (with Solana extension)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($id: ID!) { agent(id: $id) { id owner creator agentURI agentWallet collectionPointer colLocked parentAsset parentCreator parentLocked createdAt updatedAt totalFeedback solana { assetPubkey collection atomEnabled trustTier qualityScore confidence riskScore diversityRatio verificationStatus feedbackDigest responseDigest revokeDigest } } }",
    "variables": { "id": "sol:ASSET_PUBKEY" }
  }'
```

Response (example):

```json
{
  "data": {
    "agent": {
      "id": "sol:ASSET_PUBKEY",
      "owner": "OWNER_WALLET",
      "creator": "CREATOR_WALLET",
      "agentURI": "https://example.com/agent.json",
      "agentWallet": "AGENT_WALLET",
      "collectionPointer": "my-col",
      "colLocked": true,
      "parentAsset": "PARENT_ASSET_PUBKEY",
      "parentCreator": "PARENT_CREATOR_WALLET",
      "parentLocked": false,
      "createdAt": "1700000000",
      "updatedAt": "1700000000",
      "totalFeedback": "12",
      "solana": {
        "assetPubkey": "ASSET_PUBKEY",
        "collection": "COLLECTION_PUBKEY",
        "atomEnabled": true,
        "trustTier": 2,
        "qualityScore": 8400,
        "confidence": 9100,
        "riskScore": 15,
        "diversityRatio": 40,
        "verificationStatus": "FINALIZED",
        "feedbackDigest": "0x...",
        "responseDigest": "0x...",
        "revokeDigest": "0x..."
      }
    }
  }
}
```

### Fetch one agent (with registration file)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($id: ID!) { agent(id: $id) { id owner agentURI registrationFile { name description image active mcpEndpoint mcpTools a2aEndpoint a2aSkills oasfSkills oasfDomains hasOASF } } }",
    "variables": { "id": "sol:ASSET_PUBKEY" }
  }'
```

Response (example):

```json
{
  "data": {
    "agent": {
      "id": "sol:ASSET_PUBKEY",
      "owner": "OWNER_WALLET",
      "agentURI": "https://example.com/agent.json",
      "registrationFile": {
        "name": "My Agent",
        "description": "Short description",
        "image": "ipfs://bafy...",
        "active": true,
        "mcpEndpoint": "https://example.com/mcp",
        "mcpTools": ["tool_a", "tool_b"],
        "a2aEndpoint": "https://example.com/a2a",
        "a2aSkills": ["skill_a", "skill_b"],
        "oasfSkills": ["skill_a", "skill_b"],
        "oasfDomains": ["domain_a", "domain_b"],
        "hasOASF": true
      }
    }
  }
}
```

### List agents (cursor pagination with `after`)

Step 1: query the first page (request the `cursor` field):

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query { agents(first: 3, orderBy: createdAt, orderDirection: desc) { id cursor createdAt } }"
  }'
```

Step 2: query the next page by passing `after` as the last cursor from step 1:

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($after: String!) { agents(first: 3, after: $after, orderBy: createdAt, orderDirection: desc) { id cursor createdAt } }",
    "variables": { "after": "PASTE_CURSOR_HERE" }
  }'
```

### List oldest (first registered) agents

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query { agents(first: 10, orderBy: createdAt, orderDirection: asc) { id owner createdAt } }"
  }'
```

### Agents by owner

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($owner: String!) { agents(first: 20, where: { owner: $owner }, orderBy: createdAt, orderDirection: desc) { id owner createdAt } }",
    "variables": { "owner": "OWNER_WALLET" }
  }'
```

Response (example):

```json
{
  "data": {
    "agents": [
      { "id": "sol:ASSET_PUBKEY", "owner": "OWNER_WALLET", "createdAt": "1700000000" }
    ]
  }
}
```

### Incremental sync by update window

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($from: BigInt!, $to: BigInt!) { agents(first: 100, where: { updatedAt_gt: $from, updatedAt_lt: $to }, orderBy: updatedAt, orderDirection: asc) { id owner totalFeedback updatedAt } }",
    "variables": { "from": "1770421000", "to": "1770422000" }
  }'
```

### Agents by canonical collection and creator

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($collection: String!, $creator: String!) { agents(first: 20, where: { collectionPointer: $collection, creator: $creator }, orderBy: createdAt, orderDirection: desc) { id creator collectionPointer colLocked parentAsset } }",
    "variables": { "collection": "my-col", "creator": "CREATOR_WALLET" }
  }'
```

### Direct children via `parentAsset`

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($parent: String!) { agents(first: 20, where: { parentAsset: $parent }, orderBy: createdAt, orderDirection: desc) { id owner parentAsset parentCreator parentLocked } }",
    "variables": { "parent": "PARENT_ASSET_PUBKEY" }
  }'
```

For dedicated collection and hierarchy queries (`collections`, `collectionAssets`, `agentChildren`, `agentTree`, `agentLineage`), see [Collections](collections.md).
