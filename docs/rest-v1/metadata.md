# Metadata API

Read on-chain metadata key/value entries for agents.

All examples below assume:

```bash
BASE_URL="https://your-indexer.example.com/rest/v1"
```

## Endpoint

```http
GET /rest/v1/metadata
```

## Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `asset` | string | Filter by agent asset pubkey |
| `key` | string | Filter by metadata key |
| `status` | string | Status filter (`eq.<STATUS>` or `neq.<STATUS>`) |
| `includeOrphaned` | boolean | Include orphaned rows |
| `limit` | number | Page size (default `100`, hard max `100`) |
| `offset` | number | Pagination offset (max `10000`) |

Notes:
- Metadata endpoint has a lower `limit` cap (`100`) than other REST lists.
- Default behavior excludes orphaned rows.

## Response Schema

```typescript
interface MetadataRow {
  id: string;                 // "<asset>:<key>"
  asset: string;
  key: string;
  value: string;              // local API mode: decompressed bytes re-encoded as base64
  immutable: boolean;
  status: "PENDING" | "FINALIZED" | "ORPHANED";
  verified_at: string | null;
}
```

## Pagination + Ordering

Rows are returned in deterministic order:

1. `slot DESC`
2. `txIndex DESC`
3. `eventOrdinal DESC`
4. `agentId ASC`
5. `key ASC`
6. `id ASC`

If `Prefer: count=exact` is sent, a `Content-Range` header is returned.

## Payload Safety

- Values are returned as base64 after storage decompression.
- In local API mode, the handler decompresses stored bytes then returns `value` as base64.
- In REST proxy mode, `/metadata` is upstream passthrough and can return raw PostgREST shape/columns.
- Responses are truncated if aggregate decompressed payload exceeds server safety limits.
- Keys with `_uri:` prefix are reserved for indexer-derived data.

## Examples

```bash
curl -sS "$BASE_URL/metadata?asset=eq.AGENT_ASSET&limit=50&offset=0"
curl -sS "$BASE_URL/metadata?asset=eq.AGENT_ASSET&key=eq.website&status=neq.ORPHANED"
```

With total count:

```bash
curl -sS -H "Prefer: count=exact" "$BASE_URL/metadata?asset=eq.AGENT_ASSET&limit=10&offset=20"
# Content-Range header returned
```
