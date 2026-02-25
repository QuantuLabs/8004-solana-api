# Feedbacks API

List feedback events (client reviews of agents).

## Endpoint

```http
GET /rest/v1/feedbacks
```

## Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `asset` | string | Filter by agent asset pubkey |
| `client_address` | string | Filter by client wallet |
| `feedback_index` | string | Filter by one feedback index (`eq.<n>` or raw) |
| `feedback_index` | `in.(1,2,3)` | Filter by multiple indices |
| `is_revoked` | boolean | Filter revoked/active feedbacks |
| `tag1` | string | Filter by primary tag |
| `tag2` | string | Filter by secondary tag |
| `endpoint` | string | Filter by endpoint |
| `or` | string | OR filter: `(tag1.eq.X,tag2.eq.X)` |
| `status` | string | Verification status (`PENDING`, `FINALIZED`, `ORPHANED`) |
| `limit` | number | Max results (default `100`) |
| `offset` | number | Pagination offset |

## Response Schema

```typescript
interface Feedback {
  id: string;
  asset: string;
  client_address: string;
  feedback_index: string;      // bigint string
  value: string;               // i128 raw value string
  value_decimals: number;      // decimal precision (0-18)
  score: number | null;
  tag1: string;
  tag2: string;
  endpoint: string;
  feedback_uri: string | null;
  feedback_hash: string | null;
  running_digest: string | null;
  is_revoked: boolean;
  revoked_at: string | null;
  status: "PENDING" | "FINALIZED" | "ORPHANED";
  verified_at: string | null;
  block_slot: number;
  tx_signature: string;
  created_at: string;
}
```

## Examples

```bash
curl -sS "$BASE_URL/feedbacks?asset=eq.AGENT_ASSET"
curl -sS "$BASE_URL/feedbacks?client_address=eq.CLIENT_WALLET"
curl -sS "$BASE_URL/feedbacks?asset=eq.AGENT_ASSET&feedback_index=in.(0,1,2)"
curl -sS "$BASE_URL/feedbacks?is_revoked=eq.false"
curl -sS "$BASE_URL/feedbacks?or=(tag1.eq.latency,tag2.eq.latency)"
```

With total count:

```bash
curl -sS -H "Prefer: count=exact" "$BASE_URL/feedbacks?asset=eq.AGENT_ASSET"
# Content-Range header returned
```
