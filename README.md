# 8004 Solana API

Default public API is **GraphQL**.

> **Legacy REST v1** documentation is available in [`docs/rest-v1.md`](docs/rest-v1.md).
> By default, new deployments should use GraphQL.

> **Self-hosted**: run your own indexer instance with
> [8004-solana-indexer](https://github.com/QuantuLabs/8004-solana-indexer).
> Set `INDEX_COLLECTION_METADATA=true` to ingest collection metadata from CID JSON.

## Architecture

The 8004 Agent Registry is indexed as a set of Metaplex Core assets under the same Solana program.

## Base URLs

| Environment | GraphQL Endpoint | Health | Status |
|---|---|---|---|
| Devnet (reference deployment) | `https://8004-indexer-production.up.railway.app/v2/graphql` | `https://8004-indexer-production.up.railway.app/health` | Live |
| GraphQL legacy alias | `https://8004-indexer-production.up.railway.app/graphql` | - | Live |
| Self-hosted | `https://your-indexer.example.com/v2/graphql` | `https://your-indexer.example.com/health` | Custom |

## Authentication

The reference GraphQL deployment is public read-only.

For self-hosted production, add your own API gateway/auth if needed.

## Rate Limiting

Reference GraphQL deployment applies request limiting:
- `30 requests/minute` per IP on GraphQL routes

## GraphQL Operations

Available `Query` operations:

- `agent(id: ID!)`
- `agents(first, skip, after, where, orderBy, orderDirection)`
- `feedback(id: ID!)`
- `feedbacks(first, skip, after, where, orderBy, orderDirection)`
- `feedbackResponse(id: ID!)`
- `feedbackResponses(first, skip, after, where, orderBy, orderDirection)`
- `agentMetadatas(first, skip, where)`
- `agentStats(id: ID!)`
- `protocol(id: ID!)`
- `protocols(first, skip)`
- `globalStats(id: ID!)`
- `agentSearch(query, first)`
- `agentRegistrationFiles(first, skip, where)`
- `hashChainHeads(agent: ID!)`
- `hashChainLatestCheckpoints(agent: ID!)`
- `hashChainReplayData(agent, chainType, fromCount, toCount, first)`
- `collections(first, skip, collection, creator)`
- `collectionAssetCount(collection, creator)`
- `collectionAssets(collection, creator, first, skip, orderBy, orderDirection)`
- `agentChildren(parent, first, skip)`
- `agentTree(root, maxDepth, includeRoot, first, skip)`
- `agentLineage(asset, includeSelf, first, skip)`

Compatibility note:
- `validation` / `validations` may still exist in some indexer schemas for backward compatibility, but the validation module is archived on-chain (`agent-registry-8004` v0.5.0+).

## ID Formats

GraphQL IDs are namespaced with the Solana prefix:

- Agent: `sol:<asset_pubkey>`
- Feedback: `sol:<asset>:<client>:<feedback_index>`
- Response: `sol:<asset>:<client>:<feedback_index>:<responder>:<tx_signature>`

## Quick Start

### Health Check

```bash
curl "https://8004-indexer-production.up.railway.app/health"
```

Response (example):

```json
{ "status": "ok" }
```

### Basic GraphQL query

```bash
curl -X POST "https://8004-indexer-production.up.railway.app/v2/graphql" \
  -H "content-type: application/json" \
  --data '{"query":"{ __typename }"}'
```

Response (example):

```json
{ "data": { "__typename": "Query" } }
```

### List agents

```bash
curl -X POST "https://8004-indexer-production.up.railway.app/v2/graphql" \
  -H "content-type: application/json" \
  --data '{
    "query":"query { agents(first: 5, orderBy: createdAt, orderDirection: desc) { id owner totalFeedback solana { assetPubkey } } }"
  }'
```

Response (example):

```json
{
  "data": {
    "agents": [
      { "id": "sol:ASSET_PUBKEY", "owner": "OWNER_WALLET", "totalFeedback": "12", "solana": { "assetPubkey": "ASSET_PUBKEY" } }
    ]
  }
}
```

### Incremental agent sync (updatedAt window)

```bash
curl -X POST "https://8004-indexer-production.up.railway.app/v2/graphql" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($from: BigInt!, $to: BigInt!) { agents(first: 100, where: { updatedAt_gt: $from, updatedAt_lt: $to }, orderBy: updatedAt, orderDirection: asc) { id owner totalFeedback updatedAt } }",
    "variables":{"from":"1770421000","to":"1770422000"}
  }'
```

### Filter feedbacks for one agent

```bash
curl -X POST "https://8004-indexer-production.up.railway.app/v2/graphql" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($agent: ID!) { feedbacks(first: 10, where: { agent: $agent }) { id clientAddress isRevoked } }",
    "variables":{"agent":"sol:FmWeWQYzyt6zoANeqXT8DcNiYAom9ioNh9hXxWr6oxjX"}
  }'
```

Response (example):

```json
{
  "data": {
    "feedbacks": [
      { "id": "sol:ASSET_PUBKEY:CLIENT_WALLET:0", "clientAddress": "CLIENT_WALLET", "isRevoked": false }
    ]
  }
}
```

### Search agents (name, owner, asset pubkey)

```bash
curl -X POST "https://8004-indexer-production.up.railway.app/v2/graphql" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($q: String!) { agentSearch(query: $q, first: 10) { id owner createdAt solana { trustTier qualityScore } } }",
    "variables":{"q":"agent"}
  }'
```

Response (example):

```json
{
  "data": {
    "agentSearch": [
      { "id": "sol:ASSET_PUBKEY", "owner": "OWNER_WALLET", "createdAt": "1700000000", "solana": { "trustTier": 2, "qualityScore": 8400 } }
    ]
  }
}
```

### Fetch an agent registration file (service endpoints, skills)

```bash
curl -X POST "https://8004-indexer-production.up.railway.app/v2/graphql" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($id: ID!) { agent(id: $id) { id owner registrationFile { name description image active mcpEndpoint mcpTools a2aEndpoint a2aSkills oasfSkills oasfDomains hasOASF } } }",
    "variables":{"id":"sol:FmWeWQYzyt6zoANeqXT8DcNiYAom9ioNh9hXxWr6oxjX"}
  }'
```

Response (example):

```json
{
  "data": {
    "agent": {
      "id": "sol:ASSET_PUBKEY",
      "owner": "OWNER_WALLET",
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

### Global rollups (tags, totals)

```bash
curl -X POST "https://8004-indexer-production.up.railway.app/v2/graphql" \
  -H "content-type: application/json" \
  --data '{
    "query":"query { protocols { id totalAgents totalFeedback totalValidations tags } }"
  }'
```

Response (example):

```json
{
  "data": {
    "protocols": [
      { "id": "solana-devnet", "totalAgents": "136", "totalFeedback": "420", "totalValidations": "0", "tags": ["tag_a", "tag_b"] }
    ]
  }
}
```

## Docs (GraphQL v2)

- [Agents](docs/agents.md)
- [Feedbacks](docs/feedbacks.md)
- [Responses](docs/responses.md)
- [Metadata](docs/metadata.md)
- [Leaderboard](docs/leaderboard.md)
- [Collections](docs/collections.md)
- [Collection + Parent-Child Examples](docs/examples/collection-parent-child.graphql)
- [Collection + Parent-Child REST Examples](docs/examples/collection-parent-child.rest.sh)
- [Stats](docs/stats.md)
- [Integrity / Hash-Chain](docs/integrity.md)

## Cursor Pagination

- `after` cursor is supported on `agents`, `feedbacks`, `feedbackResponses`, `validations`
- Cursor pagination is only valid with `orderBy: createdAt`
- Do not combine `after` and `skip` in the same query
- Request the `cursor` field in list queries, and pass it back as `after` to fetch the next page

## Legacy REST v1

If you still need PostgREST-compatible endpoints, use:

- [`docs/rest-v1.md`](docs/rest-v1.md)

## Related

- [8004-solana-indexer](https://github.com/QuantuLabs/8004-solana-indexer)
- [8004-solana](https://github.com/QuantuLabs/8004-solana)
- [8004-solana SDK](https://www.npmjs.com/package/8004-solana)
- [ERC-8004 Specification](https://eips.ethereum.org/EIPS/eip-8004)
