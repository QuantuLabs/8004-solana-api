# Metadata API

Read on-chain metadata key/value entries for agents.

## Endpoint

```http
GET /rest/v1/metadata
```

## Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `asset` | string | Filter by agent asset pubkey |
| `key` | string | Filter by metadata key |
| `status` | string | Verification status (`PENDING`, `FINALIZED`, `ORPHANED`) |
| `limit` | number | Max results (server-enforced cap) |

## Response Schema

```typescript
interface MetadataRow {
  id: string;                 // "<asset>:<key>"
  asset: string;
  key: string;
  value: string;              // decoded bytes, base64-encoded
  immutable: boolean;
  status: "PENDING" | "FINALIZED" | "ORPHANED";
  verified_at: string | null;
}
```

Notes:
- Values are returned as base64 after storage decompression.
- Keys with `_uri:` prefix are reserved for indexer-derived data.

## Examples

```bash
curl -sS "$BASE_URL/metadata?asset=eq.AGENT_ASSET"
curl -sS "$BASE_URL/metadata?asset=eq.AGENT_ASSET&key=eq.website"
```
