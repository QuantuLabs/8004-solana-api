# Agents + Hierarchy API (REST v1)

List registered agents and query collection / parent-child relationships.

All examples below assume:

```bash
BASE_URL="https://your-indexer.example.com/rest/v1"
```

## Endpoint

```http
GET /rest/v1/agents
```

## Query Parameters (`/agents`)

| Parameter | Type | Description |
|---|---|---|
| `id` / `asset` | string | Agent asset pubkey |
| `agent_id` / `agentId` | string | Sequential registration ID |
| `owner` | string | Current owner wallet |
| `creator` | string | Creator wallet |
| `collection` | string | Collection label on agent |
| `collection_pointer` / `canonical_col` | string | Canonical collection pointer (`c1:<cid>`). `collection_pointer` is the preferred public parameter; `canonical_col` remains accepted as a backward-compatible alias |
| `agent_wallet` | string | Agent wallet |
| `parent_asset` | string | Parent asset pubkey |
| `parent_creator` | string | Parent creator wallet |
| `col_locked` | boolean | Filter lock state of `collection` |
| `parent_locked` | boolean | Filter lock state of parent link |
| `updated_at` | string | Timestamp filter (`eq`, `gt`, `gte`, `lt`, `lte`) |
| `updated_at_gt` | string | Strict lower bound timestamp |
| `updated_at_lt` | string | Strict upper bound timestamp |
| `status` | string | Status filter (`eq.<STATUS>` or `neq.<STATUS>`) |
| `includeOrphaned` | boolean | Include orphaned rows (default excludes them) |
| `limit` | number | Max results (default `100`, max `1000`) |
| `offset` | number | Pagination offset (max `10000`) |

Notes:
- The API accepts PostgREST-style values (`eq.VALUE`) and raw values (`VALUE`).
- Invalid `agent_id` or timestamp filters return `400`.
- `collection_pointer` is the preferred public filter; `canonical_col` remains accepted for backward compatibility and some upstream PostgREST views.
- CIDv1 compatibility: `collection_pointer=eq.<bare_cid>` and `collection_pointer=eq.c1:<cid>` are normalized to match legacy rows stored as either `c1:<cid>` or bare CID.

## Response Schema (`/agents`)

Schema below describes local API mode mapping.
In REST proxy mode, `/agents` returns upstream PostgREST rows (for example with `canonical_col`, `block_slot`, `tx_index`, `event_ordinal`).

```typescript
interface Agent {
  asset: string;
  agent_id: string | null;
  owner: string;
  creator: string | null;
  agent_uri: string | null;
  agent_wallet: string | null;
  collection: string | null;
  collection_pointer: string | null;
  col_locked: boolean;
  parent_asset: string | null;
  parent_creator: string | null;
  parent_locked: boolean;
  nft_name: string | null;
  atom_enabled: boolean;
  trust_tier: number | null;
  quality_score: number | null;
  confidence: number | null;
  risk_score: number | null;
  diversity_ratio: number | null;
  feedback_count: number;
  raw_avg_score: number | null;
  status: "PENDING" | "FINALIZED" | "ORPHANED";
  verified_at: string | null;
  created_at: string;
  updated_at: string;
}
```

## Examples (`/agents`)

### Latest agents (default excludes orphaned)

```bash
curl -sS "$BASE_URL/agents?limit=50&offset=0"
```

### Filter by canonical collection scope (same minting creator + same collection pointer)

```bash
curl -sS "$BASE_URL/agents?creator=eq.CREATOR_WALLET&collection_pointer=eq.c1:CID&status=neq.ORPHANED&limit=50"
```

`canonical_col=eq.c1:CID` remains accepted as a backward-compatible alias.

### Incremental sync by update time

```bash
curl -sS "$BASE_URL/agents?updated_at_gt=1770500000&updated_at_lt=1770600000&limit=100"
```

## Direct Children

```http
GET /rest/v1/agents/children
```

`/agents/children` is implemented as a local handler. In REST proxy mode it is not guaranteed and can return `403`.

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `parent_asset` / `parent` | string | Parent asset pubkey (required) |
| `status` | string | `eq.<STATUS>` or `neq.<STATUS>` |
| `includeOrphaned` | boolean | Include orphaned rows |
| `limit` | number | Page size |
| `offset` | number | Offset |

### Example

```bash
curl -sS "$BASE_URL/agents/children?parent_asset=eq.PARENT_ASSET_PUBKEY&status=neq.ORPHANED&limit=100&offset=0"
```

## Tree Reconstruction

```http
GET /rest/v1/agents/tree
```

`/agents/tree` is implemented as a local handler. In REST proxy mode it is not guaranteed and can return `403`.

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `root_asset` / `root` / `parent_asset` | string | Root asset pubkey (required) |
| `max_depth` | number | Max traversal depth (default `5`, capped server-side at `8`) |
| `include_root` | boolean | Include root node (default `true`) |
| `status` | string | `eq.<STATUS>` or `neq.<STATUS>` |
| `includeOrphaned` | boolean | Include orphaned rows |
| `limit` | number | Page size |
| `offset` | number | Offset |

### Example

```bash
curl -sS "$BASE_URL/agents/tree?root_asset=eq.ROOT_ASSET_PUBKEY&max_depth=5&include_root=true&status=neq.ORPHANED&limit=200"
```

Each row includes normal agent fields plus:

```typescript
interface AgentTreeRow extends Agent {
  depth: number;
  path: string[];
}
```

## Lineage (Ancestor Chain)

```http
GET /rest/v1/agents/lineage
```

`/agents/lineage` is implemented as a local handler. In REST proxy mode it is not guaranteed and can return `403`.

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `asset` | string | Child/leaf asset pubkey (required) |
| `include_self` | boolean | Include leaf node (default `true`) |
| `status` | string | `eq.<STATUS>` or `neq.<STATUS>` |
| `includeOrphaned` | boolean | Include orphaned rows |
| `limit` | number | Page size |
| `offset` | number | Offset |

### Example

```bash
curl -sS "$BASE_URL/agents/lineage?asset=eq.CHILD_ASSET_PUBKEY&include_self=true&status=neq.ORPHANED&limit=100"
```

## Collections Registry

```http
GET /rest/v1/collections
```

`/collections` is available in local API mode. In REST proxy mode the call is upstream-dependent and can differ in availability/shape from local mapping.

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `collection_id` | string | Sequential collection ID filter (`eq`, `gt`, `gte`, `lt`, `lte`) |
| `collection` | string | Canonical collection pointer |
| `creator` | string | Creator wallet |
| `first_seen_asset` | string | First asset seen for this collection scope (same minting creator + same collection pointer) |
| `limit` | number | Page size |
| `offset` | number | Offset |

### Response Schema

```typescript
interface Collection {
  collection_id: string | null;
  collection: string;
  creator: string;
  first_seen_asset: string;
  first_seen_at: string;
  first_seen_slot: string;
  first_seen_tx_signature: string | null;
  last_seen_at: string;
  last_seen_slot: string;
  last_seen_tx_signature: string | null;
  asset_count: string;
  version: string | null;
  name: string | null;
  symbol: string | null;
  description: string | null;
  image: string | null;
  banner_image: string | null;
  social_website: string | null;
  social_x: string | null;
  social_discord: string | null;
  metadata_status: string | null;
  metadata_hash: string | null;
  metadata_bytes: number | null;
  metadata_updated_at: string | null;
}
```

### Example

```bash
curl -sS "$BASE_URL/collections?creator=eq.CREATOR_WALLET&limit=100"
```

### Example (lookup by sequential `collection_id`)

```bash
curl -sS "$BASE_URL/collections?collection_id=eq.7&limit=1"
```

## Collection Asset Count

```http
GET /rest/v1/collection_asset_count
```

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `collection` | string | Canonical collection pointer (required) |
| `creator` | string | Creator filter (required; scope is creator+collection) |
| `status` | string | `eq.<STATUS>` or `neq.<STATUS>` |
| `includeOrphaned` | boolean | Include orphaned rows |

### Example

```bash
curl -sS "$BASE_URL/collection_asset_count?collection=eq.c1:CID&creator=eq.CREATOR_WALLET&status=neq.ORPHANED"
```

### Response

```json
{
  "collection": "c1:CID",
  "creator": "CREATOR_WALLET",
  "asset_count": 42
}
```

## Collection Assets (Paginated)

```http
GET /rest/v1/collection_assets
```

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `collection` | string | Canonical collection pointer (required) |
| `creator` | string | Creator filter (required; scope is creator+collection) |
| `status` | string | `eq.<STATUS>` or `neq.<STATUS>` |
| `includeOrphaned` | boolean | Include orphaned rows |
| `limit` | number | Page size (default `100`, max `1000`) |
| `offset` | number | Offset |

### Example

```bash
curl -sS "$BASE_URL/collection_assets?collection=eq.c1:CID&creator=eq.CREATOR_WALLET&status=neq.ORPHANED&limit=100&offset=0"
```

### Count Header (optional)

```bash
curl -sS -H "Prefer: count=exact" "$BASE_URL/collection_assets?collection=eq.c1:CID&creator=eq.CREATOR_WALLET&limit=10&offset=0"
```
