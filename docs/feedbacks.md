# Feedbacks (GraphQL v2)

List feedback events (client reviews of agents).

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004-api.qnt.sh/v2/graphql"
```

## IDs

- Agent: `<asset_pubkey>`
- Feedback entity id (`Feedback.id`): `<feedback_id>` (sequential)

Lookup note:
- `feedback(id:)` accepts canonical `<asset>:<client>:<feedback_index>` (and sequential `<feedback_id>`).

## Queries

- `feedback(id: ID!): Feedback`
- `feedbacks(first, skip, after, where, orderBy, orderDirection): [Feedback!]!`

## Filters

The `feedbacks(where: FeedbackFilter)` input supports:

- `agent` (Agent ID)
- `feedbackId`, `feedbackId_gt`, `feedbackId_gte`, `feedbackId_lt`, `feedbackId_lte`
- `clientAddress`
- `tag1`, `tag2`
- `endpoint`
- `isRevoked`
- `createdAt_gt`, `createdAt_lt` (unix seconds)

## Ordering

Use `orderBy: FeedbackOrderBy`:

- `createdAt` (default)
- `feedbackId`
- `value`
- `feedbackIndex`

## Examples

### Feedbacks for one agent

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($agent: ID!) { feedbacks(first: 20, where: { agent: $agent }, orderBy: createdAt, orderDirection: desc) { id clientAddress feedbackIndex value isRevoked createdAt solana { score valueRaw valueDecimals txSignature blockSlot runningDigest verificationStatus } } }",
    "variables": { "agent": "ASSET_PUBKEY" }
  }'
```

Response (example):

```json
{
  "data": {
    "feedbacks": [
      {
        "id": "42",
        "clientAddress": "CLIENT_WALLET",
        "feedbackIndex": "0",
        "value": "95.00",
        "isRevoked": false,
        "createdAt": "1700000000",
        "solana": {
          "score": 85,
          "valueRaw": "9500",
          "valueDecimals": 2,
          "txSignature": "TX_SIGNATURE",
          "blockSlot": "123456",
          "runningDigest": "ab12cd34...",
          "verificationStatus": "FINALIZED"
        }
      }
    ]
  }
}
```

### Feedbacks by endpoint

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($endpoint: String!) { feedbacks(first: 20, where: { endpoint: $endpoint }, orderBy: createdAt, orderDirection: desc) { id agent { id } clientAddress tag1 tag2 createdAt } }",
    "variables": { "endpoint": "https://example.com/api" }
  }'
```

Response (example):

```json
{
  "data": {
    "feedbacks": [
      {
        "id": "42",
        "agent": { "id": "ASSET_PUBKEY" },
        "clientAddress": "CLIENT_WALLET",
        "tag1": "tag_a",
        "tag2": "tag_b",
        "createdAt": "1700000000"
      }
    ]
  }
}
```

### Get one feedback (and first page of responses)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($id: ID!) { feedback(id: $id) { id agent { id } clientAddress feedbackIndex value tag1 tag2 endpoint feedbackURI feedbackHash isRevoked createdAt revokedAt responses(first: 10) { id responder responseUri createdAt } solana { score txSignature blockSlot runningDigest } } }",
    "variables": { "id": "ASSET:CLIENT:0" }
  }'
```

Response (example):

```json
{
  "data": {
    "feedback": {
      "id": "42",
      "agent": { "id": "ASSET_PUBKEY" },
      "clientAddress": "CLIENT_WALLET",
      "feedbackIndex": "0",
      "value": "95.00",
      "tag1": "tag_a",
      "tag2": "tag_b",
      "endpoint": "https://example.com/api",
      "feedbackURI": "ipfs://bafy...",
      "feedbackHash": "cd34ef56...",
      "isRevoked": false,
      "createdAt": "1700000000",
      "revokedAt": null,
      "responses": [
        { "id": "7", "responder": "RESPONDER_WALLET", "responseUri": "ipfs://bafy...", "createdAt": "1700000001" }
      ],
      "solana": { "score": 85, "txSignature": "TX_SIGNATURE", "blockSlot": "123456", "runningDigest": "ef56ab78..." }
    }
  }
}
```
