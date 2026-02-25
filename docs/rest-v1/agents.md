# Agents + Hierarchy API (REST v1)

List registered agents and query collection / parent-child relationships.

## Endpoint

```http
GET /rest/v1/agents
```

## Query Parameters (`/agents`)

| Parameter | Type | Description |
|---|---|---|
| `id` | string | Agent asset pubkey |
| `owner` | string | Current owner wallet |
| `creator` | string | Creator wallet |
| `collection` | string | Canonical collection id |
| `agent_wallet` | string | Agent wallet |
| `parent_asset` | string | Parent asset pubkey |
| `parent_creator` | string | Parent creator wallet |
| `col_locked` | boolean | Filter lock state of `collection` |
| `parent_locked` | boolean | Filter lock state of parent link |
| `status` | string | Verification status (`PENDING`, `FINALIZED`, `ORPHANED`) |
| `limit` | number | Max results (default `100`, max `1000`) |
| `offset` | number | Pagination offset |

The API accepts either PostgREST style (`eq.VALUE`) or raw values (`VALUE`).

## Response Schema (`/agents`)

```typescript
interface Agent {
  asset: string;
  owner: string;
  creator: string | null;
  agent_uri: string | null;
  agent_wallet: string | null;
  collection: string | null;
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

### Latest agents

```bash
curl -sS "$BASE_URL/agents?limit=50&offset=0"
```

### Filter by canonical collection scope (`creator + collection`)

```bash
curl -sS "$BASE_URL/agents?creator=eq.CREATOR_WALLET&collection=eq.my-col&limit=50"
```

### Filter children by parent

```bash
curl -sS "$BASE_URL/agents?parent_asset=eq.PARENT_ASSET_PUBKEY&limit=50"
```

## Direct Children

```http
GET /rest/v1/agents/children
```

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `parent_asset` | string | Parent asset pubkey (alias: `parent`) |
| `status` | string | `PENDING`, `FINALIZED`, `ORPHANED` |
| `limit` | number | Page size |
| `offset` | number | Offset |

### Example

```bash
curl -sS "$BASE_URL/agents/children?parent_asset=eq.PARENT_ASSET_PUBKEY&limit=100&offset=0"
```

## Tree Reconstruction

```http
GET /rest/v1/agents/tree
```

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `root_asset` | string | Root asset pubkey (aliases: `root`, `parent_asset`) |
| `max_depth` | number | Max traversal depth (clamped server-side) |
| `include_root` | boolean | Include root node (default `true`) |
| `status` | string | `PENDING`, `FINALIZED`, `ORPHANED` |
| `limit` | number | Page size |
| `offset` | number | Offset |

### Example

```bash
curl -sS "$BASE_URL/agents/tree?root_asset=eq.ROOT_ASSET_PUBKEY&max_depth=5&include_root=true&limit=200"
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

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `asset` | string | Child/leaf asset pubkey |
| `include_self` | boolean | Include leaf node (default `true`) |
| `status` | string | `PENDING`, `FINALIZED`, `ORPHANED` |
| `limit` | number | Page size |
| `offset` | number | Offset |

### Example

```bash
curl -sS "$BASE_URL/agents/lineage?asset=eq.CHILD_ASSET_PUBKEY&include_self=true&limit=100"
```

## Collections Registry

```http
GET /rest/v1/collections
```

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `collection` | string | Canonical collection id |
| `creator` | string | Creator wallet |
| `first_seen_asset` | string | First asset seen for this collection scope |
| `limit` | number | Page size |
| `offset` | number | Offset |

### Response Schema

```typescript
interface Collection {
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
}
```

### Example

```bash
curl -sS "$BASE_URL/collections?creator=eq.CREATOR_WALLET&limit=100"
```

## Collection Asset Count

```http
GET /rest/v1/collection_asset_count
```

### Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `collection` | string | Canonical collection id (required) |
| `creator` | string | Optional creator filter |
| `status` | string | `PENDING`, `FINALIZED`, `ORPHANED` |

### Example

```bash
curl -sS "$BASE_URL/collection_asset_count?collection=eq.my-col&creator=eq.CREATOR_WALLET"
```

### Response

```json
{
  "collection": "my-col",
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
| `collection` | string | Canonical collection id (required) |
| `creator` | string | Optional creator filter |
| `status` | string | `PENDING`, `FINALIZED`, `ORPHANED` |
| `limit` | number | Page size |
| `offset` | number | Offset |

### Example

```bash
curl -sS "$BASE_URL/collection_assets?collection=eq.my-col&creator=eq.CREATOR_WALLET&limit=100&offset=0"
```
