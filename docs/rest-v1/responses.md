# Feedback Responses + Revocations API

Read response events and revocation events.

All examples below assume:

```bash
BASE_URL="https://your-indexer.example.com/rest/v1"
```

## Feedback Responses Endpoints

```http
GET /rest/v1/feedback_responses
GET /rest/v1/responses  # alias
```

## Query Parameters (`feedback_responses` / `responses`)

| Parameter | Type | Description |
|---|---|---|
| `asset` | string | Filter by agent asset pubkey |
| `client_address` | string | Filter by feedback client |
| `feedback_index` | string | Feedback index (`eq.<n>` or raw integer) |
| `feedback_id` | string | Sequential feedback ID (requires `asset`) |
| `response_id` | string | Sequential response ID (requires canonical feedback scope) |
| `order` | string | `response_count.asc` or `response_count.desc` |
| `status` | string | Status filter (`eq.<STATUS>` or `neq.<STATUS>`) |
| `includeOrphaned` | boolean | Include orphaned rows |
| `limit` | number | Max results (default `100`, max `1000`) |
| `offset` | number | Pagination offset (max `10000`) |

Canonical feedback scope for `response_id`:
- `asset + feedback_id`, or
- `asset + client_address + feedback_index`

## Response Schema

```typescript
interface FeedbackResponse {
  id: string | null;
  response_id: string | null;
  feedback_id: string | null;
  asset: string;
  client_address: string;
  feedback_index: string;
  responder: string;
  response_uri: string | null;
  response_hash: string | null;
  running_digest: string | null;
  response_count: string | null;
  status: "PENDING" | "FINALIZED" | "ORPHANED";
  verified_at: string | null;
  block_slot: number;
  tx_signature: string;
  created_at: string;
}
```

Notes:
- Orphan responses can return `id`, `response_id`, and `feedback_id` as `null`.
- Numeric IDs are serialized as strings to preserve precision.

## Examples (`feedback_responses` / `responses`)

### Responses for one canonical feedback (asset + client + feedback index)

```bash
curl -sS "$BASE_URL/feedback_responses?asset=eq.AGENT_ASSET&client_address=eq.CLIENT_WALLET&feedback_index=eq.0&status=neq.ORPHANED"
```

### Responses for one canonical feedback (asset + sequential feedback_id)

```bash
curl -sS "$BASE_URL/responses?asset=eq.AGENT_ASSET&feedback_id=eq.42"
```

### Filter by response_id (requires canonical scope)

```bash
curl -sS "$BASE_URL/responses?asset=eq.AGENT_ASSET&feedback_id=eq.42&response_id=eq.7"
```

### Order by response_count

```bash
curl -sS "$BASE_URL/responses?asset=eq.AGENT_ASSET&order=response_count.desc&limit=100"
```

## Revocations Endpoint

```http
GET /rest/v1/revocations
```

## Query Parameters (`revocations`)

| Parameter | Type | Description |
|---|---|---|
| `asset` | string | Filter by agent asset pubkey |
| `client_address` / `client` | string | Filter by client wallet |
| `feedback_index` | string | Feedback index (`eq.<n>` or raw integer) |
| `revocation_id` | string | Sequential revocation ID (`eq`, `gt`, `gte`, `lt`, `lte`); requires `asset` |
| `revoke_count` | string | Integer filter (`eq.<n>` or raw integer) |
| `revoke_count` | `in.(1,2,3)` | Multiple revoke counts |
| `order` | string | `revoke_count.asc` or `revoke_count.desc` |
| `status` | string | Status filter (`eq.<STATUS>` or `neq.<STATUS>`) |
| `includeOrphaned` | boolean | Include orphaned rows |
| `limit` | number | Max results (default `100`, max `1000`) |
| `offset` | number | Pagination offset (max `10000`) |

## Revocation Response Schema

```typescript
interface Revocation {
  id: string | null;
  revocation_id: string | null;
  asset: string;
  client_address: string;
  feedback_index: string;
  feedback_hash: string | null;
  slot: number;
  original_score: number | null;
  atom_enabled: boolean;
  had_impact: boolean;
  running_digest: string | null;
  revoke_count: number;
  tx_signature: string;
  status: "PENDING" | "FINALIZED" | "ORPHANED";
  verified_at: string | null;
  created_at: string;
}
```

## Examples (`revocations`)

```bash
curl -sS "$BASE_URL/revocations?asset=eq.AGENT_ASSET&status=neq.ORPHANED"
curl -sS "$BASE_URL/revocations?asset=eq.AGENT_ASSET&revocation_id=gte.10&limit=20"
curl -sS "$BASE_URL/revocations?asset=eq.AGENT_ASSET&revoke_count=in.(1,2,3)&order=revoke_count.desc"
```

With total count:

```bash
curl -sS -H "Prefer: count=exact" "$BASE_URL/revocations?asset=eq.AGENT_ASSET&limit=25&offset=0"
# Content-Range header returned
```
