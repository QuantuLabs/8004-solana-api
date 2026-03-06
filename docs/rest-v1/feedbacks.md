# Feedbacks API

List feedback events (client reviews of agents).

All examples below assume:

```bash
BASE_URL="https://your-indexer.example.com/rest/v1"
```

## Endpoint

```http
GET /rest/v1/feedbacks
```

## Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `asset` | string | Filter by agent asset pubkey |
| `client_address` | string | Filter by client wallet |
| `feedback_id` | string | Sequential feedback ID (`eq.<n>` or raw integer) |
| `feedback_index` | string | Feedback index filter (`eq.<n>`, raw integer, or `in.(1,2,3)`) |
| `is_revoked` | boolean | Filter revoked/active feedbacks |
| `tag1` | string | Filter by primary tag |
| `tag2` | string | Filter by secondary tag |
| `endpoint` | string | Filter by endpoint |
| `created_at` | string | Timestamp filter (`eq`, `gt`, `gte`, `lt`, `lte`) |
| `created_at_gt` | string | Strict lower bound timestamp |
| `created_at_lt` | string | Strict upper bound timestamp |
| `or` | string | OR tag filter: `(tag1.eq.X,tag2.eq.X)` |
| `status` | string | Status filter (`eq.<STATUS>` or `neq.<STATUS>`) |
| `includeOrphaned` | boolean | Include orphaned rows |
| `limit` | number | Max results (default `100`, max `1000`) |
| `offset` | number | Pagination offset (max `10000`) |

Notes:
- Invalid `feedback_id` or timestamp filters return `400`.
- Invalid `feedback_index` values return `400`.
- `feedback_id` without `asset` can be ambiguous and may return `400`.

## Response Schema

Schema below describes local API mode mapping.
In REST proxy mode, `/feedbacks` can return upstream PostgREST columns/types.

```typescript
interface Feedback {
  id: string | null;
  feedback_id: string | null;
  asset: string;
  client_address: string;
  feedback_index: string;      // bigint string
  value: string;               // i128 raw value string
  value_decimals: number;      // decimal precision
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
curl -sS "$BASE_URL/feedbacks?asset=eq.AGENT_ASSET&status=neq.ORPHANED"
curl -sS "$BASE_URL/feedbacks?asset=eq.AGENT_ASSET&feedback_index=in.(0,1,2)&limit=50"
curl -sS "$BASE_URL/feedbacks?asset=eq.AGENT_ASSET&created_at_gt=1770500000&created_at_lt=1770600000"
curl -sS "$BASE_URL/feedbacks?or=(tag1.eq.latency,tag2.eq.latency)"
```

With total count:

```bash
curl -sS -H "Prefer: count=exact" "$BASE_URL/feedbacks?asset=eq.AGENT_ASSET&limit=25&offset=0"
# Content-Range header returned
```
