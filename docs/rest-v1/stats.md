# Stats + System Endpoints (REST v1)

Global rollups, collection aggregates, verification counters, and archived validation behavior.

All examples below assume:

```bash
BASE_URL="https://your-indexer.example.com/rest/v1"
```

Unless noted otherwise, schemas/examples below describe local API mode.
In REST proxy mode, upstream PostgREST views can expose a different aggregate shape.

## Endpoints

| Endpoint | Description |
|---|---|
| `/rest/v1/stats` | Global stats (alias of `/global_stats`) |
| `/rest/v1/global_stats` | Global stats |
| `/rest/v1/collection_stats` | Registry/raw-collection aggregates |
| `/rest/v1/stats/verification` | Verification status counts by dataset |
| `/rest/v1/validations` | Archived endpoint (always `410`) |

## Global Stats

```http
GET /rest/v1/stats
GET /rest/v1/global_stats
```

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `includeOrphaned` | boolean | Include orphaned rows in totals |

### Response Schema

```typescript
interface GlobalStats {
  total_agents: number;
  total_feedbacks: number;
  total_collections: number;
}
```

`total_collections` corresponds to GraphQL `globalStats.totalCollections` and counts canonical collection scopes (`creator + collection_pointer`), not registries or raw Metaplex collection pubkeys.

### Example

```bash
curl -sS "$BASE_URL/global_stats"
```

### Response

```json
[
  {
    "total_agents": 12547,
    "total_feedbacks": 2345678,
    "total_collections": 89
  }
]
```

## Collection Stats (legacy registry/raw collection view)

```http
GET /rest/v1/collection_stats
```

This endpoint remains registry/raw-collection-centric. For canonical collection reads keyed by `creator + collection_pointer`, use:

- `GET /rest/v1/collections`
- `GET /rest/v1/collection_asset_count?collection=eq.<collection_pointer>&creator=eq.<creator>`
- `GET /rest/v1/collection_assets?collection=eq.<collection_pointer>&creator=eq.<creator>`

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `collection` | string | Optional raw collection pubkey filter |
| `order` | string | `agent_count.desc` to sort by size |
| `includeOrphaned` | boolean | Include orphaned rows |

### Response Schema

```typescript
interface CollectionStats {
  collection: string;
  registry_type: string;
  authority: string | null;
  agent_count: number;
  total_feedbacks: number;
  avg_score: number | null;
}
```

### Examples

```bash
curl -sS "$BASE_URL/collection_stats?order=agent_count.desc"
curl -sS "$BASE_URL/collection_stats?collection=eq.COLLECTION_PUBKEY"
```

## Verification Status Stats

```http
GET /rest/v1/stats/verification
```

### Response Schema

```typescript
interface VerificationMap {
  PENDING: number;
  FINALIZED: number;
  ORPHANED: number;
}

interface VerificationStats {
  agents: VerificationMap;
  feedbacks: VerificationMap;
  registries: VerificationMap;
  metadata: VerificationMap;
  feedback_responses: VerificationMap;
}
```

### Example

```bash
curl -sS "$BASE_URL/stats/verification"
```

### Response

```json
{
  "agents": { "PENDING": 2, "FINALIZED": 12505, "ORPHANED": 3 },
  "feedbacks": { "PENDING": 10, "FINALIZED": 2345522, "ORPHANED": 12 },
  "registries": { "PENDING": 0, "FINALIZED": 89, "ORPHANED": 0 },
  "metadata": { "PENDING": 7, "FINALIZED": 45678, "ORPHANED": 5 },
  "feedback_responses": { "PENDING": 1, "FINALIZED": 89012, "ORPHANED": 2 }
}
```

## Validations (Archived)

```http
GET /rest/v1/validations
```

Validation indexing is archived on-chain (`agent-registry-8004` `v0.5.0+`).
This endpoint is retired and returns `410 Gone`:

```json
{
  "error": "Validation endpoints are archived and no longer exposed. /rest/v1/validations has been retired."
}
```
