# Feedback Responses + Revocations API

Read response events and revocation events.

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
| `feedback_index` | string | Filter by feedback index |
| `responder` | string | Filter by responder wallet |
| `order` | string | `response_count.asc` or `response_count.desc` |
| `status` | string | Verification status (`PENDING`, `FINALIZED`, `ORPHANED`) |
| `limit` | number | Max results (default `100`) |
| `offset` | number | Pagination offset |

## Response Schema

```typescript
interface FeedbackResponse {
  id: string;
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
- `feedback_id` can be `null` for orphan responses (feedback not indexed yet).
- `response_count` is a bigint string.

## Examples

### Responses for a specific feedback

```bash
curl -sS "$BASE_URL/feedback_responses?asset=eq.AGENT_ASSET&client_address=eq.CLIENT_WALLET&feedback_index=eq.0"
```

### Responses ordered by response count

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
| `client` | string | Filter by client wallet |
| `order` | string | `revoke_count.desc` for latest count ranking |
| `status` | string | Verification status (`PENDING`, `FINALIZED`, `ORPHANED`) |
| `limit` | number | Max results |
| `offset` | number | Pagination offset |

## Revocation Response Schema

```typescript
interface Revocation {
  id: string;
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
