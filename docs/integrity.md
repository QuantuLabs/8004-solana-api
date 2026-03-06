# Integrity / Hash-Chain (GraphQL v2)

These operations are used by the SDK to verify indexer integrity against on-chain digests.

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004-api.qnt.sh/v2/graphql"
```

## Concepts

- **Heads**: last known running digest + count for each chain (`feedback`, `response`, `revoke`).
- **Replay data**: paged events in deterministic order so a client can recompute the hash-chain.
- **Checkpoints**: optional performance optimization for replay. A checkpoint is the digest after `eventCount` events.

Notes:

- `fromCount` and `toCount` use **0-based event indices** (like an array slice): `[fromCount, toCount)`.
- `hashChainReplayData.nextFromCount` is the next `fromCount` to continue paging.

## Queries

- `hashChainHeads(agent: ID!): HashChainHeads!`
- `hashChainLatestCheckpoints(agent: ID!): HashChainCheckpointSet!`
- `hashChainReplayData(agent: ID!, chainType: HashChainType!, fromCount, toCount, first): HashChainReplayPage!`

## Examples

### Get hash-chain heads (digest + count)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($agent: ID!) { hashChainHeads(agent: $agent) { feedback { digest count } response { digest count } revoke { digest count } } }",
    "variables": { "agent": "ASSET_PUBKEY" }
  }'
```

Response (example):

```json
{
  "data": {
    "hashChainHeads": {
      "feedback": { "digest": "deadbeef...", "count": "420" },
      "response": { "digest": "...", "count": "12" },
      "revoke": { "digest": "...", "count": "3" }
    }
  }
}
```

### Get replay data (one page)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($agent: ID!, $from: BigInt!, $to: BigInt!) { hashChainReplayData(agent: $agent, chainType: FEEDBACK, fromCount: $from, toCount: $to, first: 1000) { hasMore nextFromCount events { client feedbackIndex slot runningDigest feedbackHash } } }",
    "variables": { "agent": "ASSET_PUBKEY", "from": "0", "to": "1000" }
  }'
```

Response (example):

```json
{
  "data": {
    "hashChainReplayData": {
      "hasMore": true,
      "nextFromCount": "1000",
      "events": [
        {
          "client": "CLIENT_WALLET",
          "feedbackIndex": "0",
          "slot": "310000000",
          "runningDigest": "...",
          "feedbackHash": "..."
        }
      ]
    }
  }
}
```

### Get latest checkpoints

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($agent: ID!) { hashChainLatestCheckpoints(agent: $agent) { feedback { eventCount digest createdAt } response { eventCount digest createdAt } revoke { eventCount digest createdAt } } }",
    "variables": { "agent": "ASSET_PUBKEY" }
  }'
```

Response (example):

```json
{
  "data": {
    "hashChainLatestCheckpoints": {
      "feedback": { "eventCount": "1000", "digest": "...", "createdAt": "1700000000" },
      "response": null,
      "revoke": null
    }
  }
}
```
