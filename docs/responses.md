# Feedback Responses (GraphQL v2)

List feedback responses (agent/owner replies to client feedback).

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004-api.qnt.sh/v2/graphql"
```

## IDs

- FeedbackResponse entity id (`FeedbackResponse.id`): `<response_id>` (sequential)

Lookup note:
- `feedbackResponses(where: { feedback: ... })` expects canonical feedback reference `<asset>:<client>:<feedback_index>`.
- `feedbackResponse(id:)` expects canonical response reference `<asset>:<client>:<feedback_index>:<responder>:<signature_or_count>`.

## Queries

- `feedbackResponse(id: ID!): FeedbackResponse`
- `feedbackResponses(first, skip, after, where, orderBy, orderDirection): [FeedbackResponse!]!`

## Filters

The `feedbackResponses(where: FeedbackResponseFilter)` input supports:

- `feedback` (canonical feedback reference: `<asset>:<client>:<feedback_index>`)
- `responseId`, `responseId_gt`, `responseId_gte`, `responseId_lt`, `responseId_lte`
- `responder`
- `createdAt_gt`, `createdAt_lt` (unix seconds)

Scoped filter note:
- `responseId*` filters require a feedback scope (`where.feedback`).
- On public deployments, prefer scoped queries (`where.feedback`) to avoid complexity-limit rejections on broad scans.

## Ordering

Use `orderBy: FeedbackResponseOrderBy`:

- `createdAt` (default)
- `responseId`

## Examples

### Responses for one feedback

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($feedback: ID!) { feedbackResponses(first: 50, where: { feedback: $feedback }, orderBy: createdAt, orderDirection: asc) { id responder responseUri responseHash createdAt solana { txSignature blockSlot runningDigest verificationStatus } } }",
    "variables": { "feedback": "ASSET:CLIENT:0" }
  }'
```

Response (example):

```json
{
  "data": {
    "feedbackResponses": [
      {
        "id": "7",
        "responder": "RESPONDER_WALLET",
        "responseUri": "ipfs://bafy...",
        "responseHash": "ab12cd34...",
        "createdAt": "1700000001",
        "solana": {
          "txSignature": "TX_SIGNATURE",
          "blockSlot": "123457",
          "runningDigest": "cd34ef56...",
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
    "variables": { "id": "ASSET:CLIENT:0:RESPONDER:TX_SIGNATURE" }
  }'
```

Response (example):

```json
{
  "data": {
    "feedbackResponse": {
      "id": "7",
      "feedback": { "id": "42" },
      "responder": "RESPONDER_WALLET",
      "responseUri": "ipfs://bafy...",
      "responseHash": "ef56ab78...",
      "createdAt": "1700000001"
    }
  }
}
```
