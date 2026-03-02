# Feedback Responses (GraphQL v2)

List feedback responses (agent/owner replies to client feedback).

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004.qnt.sh/v2/graphql"
```

## IDs

- Feedback: `sol:<asset>:<client>:<feedback_index>`
- Response: `sol:<asset>:<client>:<feedback_index>:<responder>:<tx_signature>`

## Queries

- `feedbackResponse(id: ID!): FeedbackResponse`
- `feedbackResponses(first, skip, after, where, orderBy, orderDirection): [FeedbackResponse!]!`

## Filters

The `feedbackResponses(where: FeedbackResponseFilter)` input supports:

- `feedback` (Feedback ID)
- `responder`
- `createdAt_gt`, `createdAt_lt` (unix seconds)

## Examples

### Responses for one feedback

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($feedback: ID!) { feedbackResponses(first: 50, where: { feedback: $feedback }, orderBy: createdAt, orderDirection: asc) { id responder responseUri responseHash createdAt solana { txSignature blockSlot runningDigest verificationStatus } } }",
    "variables": { "feedback": "sol:ASSET:CLIENT:0" }
  }'
```

Response (example):

```json
{
  "data": {
    "feedbackResponses": [
      {
        "id": "sol:ASSET_PUBKEY:CLIENT_WALLET:0:RESPONDER_WALLET:TX_SIGNATURE",
        "responder": "RESPONDER_WALLET",
        "responseUri": "ipfs://bafy...",
        "responseHash": "0x...",
        "createdAt": "1700000001",
        "solana": {
          "txSignature": "TX_SIGNATURE",
          "blockSlot": "123457",
          "runningDigest": "0x...",
          "verificationStatus": "FINALIZED"
        }
      }
    ]
  }
}
```

### Get one response by ID

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($id: ID!) { feedbackResponse(id: $id) { id feedback { id } responder responseUri responseHash createdAt } }",
    "variables": { "id": "sol:ASSET:CLIENT:0:RESPONDER:TX_SIGNATURE" }
  }'
```

Response (example):

```json
{
  "data": {
    "feedbackResponse": {
      "id": "sol:ASSET_PUBKEY:CLIENT_WALLET:0:RESPONDER_WALLET:TX_SIGNATURE",
      "feedback": { "id": "sol:ASSET_PUBKEY:CLIENT_WALLET:0" },
      "responder": "RESPONDER_WALLET",
      "responseUri": "ipfs://bafy...",
      "responseHash": "0x...",
      "createdAt": "1700000001"
    }
  }
}
```
