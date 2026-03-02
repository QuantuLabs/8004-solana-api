# 8004 Solana API

Default public API is **GraphQL**.

> **REST v1 (PostgREST-compatible)** documentation is available in [`docs/rest-v1.md`](docs/rest-v1.md).
> GraphQL remains the default for new deployments.

> **Self-hosted**: run your own indexer instance with
> [8004-solana-indexer](https://github.com/QuantuLabs/8004-solana-indexer).
> Set `INDEX_COLLECTION_METADATA=true` to ingest collection metadata from CID JSON.

## Architecture

The 8004 Agent Registry is indexed as a set of Metaplex Core assets under the same Solana program.

## Base URLs

| Environment | GraphQL Endpoint | Health | Status |
|---|---|---|---|
| Mainnet (production) | `https://8004.qnt.sh/v2/graphql` | `https://8004.qnt.sh/health` | Live |
| Devnet (reference deployment) | `https://8004-indexer-production.up.railway.app/v2/graphql` | `https://8004-indexer-production.up.railway.app/health` | Live |
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
- `revocation(id: ID!)`
- `revocations(first, skip, after, where, orderBy, orderDirection)`
- `agentMetadatas(first, skip, where)`
- `agentStats(id: ID!)`
- `protocol(id: ID!)`
- `protocols(first, skip)`
- `globalStats`
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
- Validation indexing is archived on-chain (`agent-registry-8004` v0.5.0+).
- Public API surfaces no longer expose `validation` / `validations`; REST `/rest/v1/validations` returns `410 Gone`.

## ID Formats

GraphQL IDs use:

- Agent: `<asset_pubkey>`
- Feedback entity id (`Feedback.id`): `<feedback_id>` (sequential)
- Response entity id (`FeedbackResponse.id`): `<response_id>` (sequential)

Lookup note:
- `feedback(id:)` accepts canonical `<asset>:<client>:<feedback_index>` (and sequential `<feedback_id>`).
- `feedbackResponse(id:)` expects canonical `<asset>:<client>:<feedback_index>:<responder>:<signature_or_count>`.
- Legacy `sol:<...>` inputs are still accepted for backward compatibility.

## Quick Start

### Health Check

```bash
curl "https://8004.qnt.sh/health"
```

Response (example):

```json
{ "status": "ok" }
```

### Basic GraphQL query

```bash
curl -X POST "https://8004.qnt.sh/v2/graphql" \
  -H "content-type: application/json" \
  --data '{"query":"{ __typename }"}'
```

Response (example):

```json
{ "data": { "__typename": "Query" } }
```

### List agents

```bash
curl -X POST "https://8004.qnt.sh/v2/graphql" \
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
      { "id": "ASSET_PUBKEY", "owner": "OWNER_WALLET", "totalFeedback": "12", "solana": { "assetPubkey": "ASSET_PUBKEY" } }
    ]
  }
}
```

### Incremental agent sync (updatedAt window)

```bash
curl -X POST "https://8004.qnt.sh/v2/graphql" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($from: BigInt!, $to: BigInt!) { agents(first: 100, where: { updatedAt_gt: $from, updatedAt_lt: $to }, orderBy: updatedAt, orderDirection: asc) { id owner totalFeedback updatedAt } }",
    "variables":{"from":"1770421000","to":"1770422000"}
  }'
```

### Filter feedbacks for one agent

```bash
curl -X POST "https://8004.qnt.sh/v2/graphql" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($agent: ID!) { feedbacks(first: 10, where: { agent: $agent }) { id clientAddress isRevoked } }",
    "variables":{"agent":"FmWeWQYzyt6zoANeqXT8DcNiYAom9ioNh9hXxWr6oxjX"}
  }'
```

Response (example):

```json
{
  "data": {
    "feedbacks": [
      { "id": "42", "clientAddress": "CLIENT_WALLET", "isRevoked": false }
    ]
  }
}
```

### Search agents (name, owner, asset pubkey)

```bash
curl -X POST "https://8004.qnt.sh/v2/graphql" \
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
      { "id": "ASSET_PUBKEY", "owner": "OWNER_WALLET", "createdAt": "1700000000", "solana": { "trustTier": 2, "qualityScore": 8400 } }
    ]
  }
}
```

### Fetch an agent registration file (service endpoints, skills)

```bash
curl -X POST "https://8004.qnt.sh/v2/graphql" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($id: ID!) { agent(id: $id) { id owner registrationFile { name description image active mcpEndpoint mcpTools a2aEndpoint a2aSkills oasfSkills oasfDomains hasOASF } } }",
    "variables":{"id":"FmWeWQYzyt6zoANeqXT8DcNiYAom9ioNh9hXxWr6oxjX"}
  }'
```

Response (example):

```json
{
  "data": {
    "agent": {
      "id": "ASSET_PUBKEY",
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
curl -X POST "https://8004.qnt.sh/v2/graphql" \
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

- `after` cursor is supported on `agents`, `feedbacks`, `feedbackResponses`, `revocations`
- Cursor pagination is only valid with `orderBy: createdAt`
- Do not combine `after` and `skip` in the same query
- Request the `cursor` field in list queries, and pass it back as `after` to fetch the next page

## REST v1 Compatibility

If you need PostgREST-compatible endpoints, use:

- [`docs/rest-v1.md`](docs/rest-v1.md)

## Related

- [8004-solana-indexer](https://github.com/QuantuLabs/8004-solana-indexer)
- [8004-solana](https://github.com/QuantuLabs/8004-solana)
- [8004-solana SDK](https://www.npmjs.com/package/8004-solana)
- [ERC-8004 Specification](https://eips.ethereum.org/EIPS/eip-8004)
