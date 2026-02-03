# Statistics API

Global and collection-level statistics.

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `/rest/v1/global_stats` | Global statistics |
| `/rest/v1/collection_stats` | Per-collection statistics |
| `/rest/v1/verification_stats` | Verification status breakdown |

---

## Global Stats

```
GET /rest/v1/global_stats
```

### Response Schema

```typescript
interface GlobalStats {
  total_agents: number;      // Total registered agents
  total_collections: number; // Total registries
  total_feedbacks: number;   // Total non-revoked feedbacks
  total_validations: number; // Total validation requests
  platinum_agents: number;   // Agents with trust_tier = 4
  gold_agents: number;       // Agents with trust_tier = 3
  avg_quality: number | null; // Average quality_score (agents with feedbacks)
}
```

### Example

```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/global_stats"
```

### Response

```json
[
  {
    "total_agents": 12547,
    "total_collections": 89,
    "total_feedbacks": 2345678,
    "total_validations": 4521,
    "platinum_agents": 42,
    "gold_agents": 156,
    "avg_quality": 7850
  }
]
```

---

## Collection Stats

```
GET /rest/v1/collection_stats
```

### Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `collection` | string | Specific collection (optional) |
| `order` | string | `agent_count.desc` to sort by size |

### Response Schema

```typescript
interface CollectionStats {
  collection: string;        // Collection pubkey
  registry_type: string;     // "BASE" or "USER"
  authority: string | null;  // Registry authority
  agent_count: number;       // Agents in collection
  top_agents: number;        // Agents with trust_tier >= 3 (Gold+)
  avg_quality: number | null; // Average quality_score (agents with feedbacks)
}
```

### Examples

#### All collections (sorted by agent count)
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/collection_stats?order=agent_count.desc"
```

#### Specific collection
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/collection_stats?collection=eq.CollectionPubkey"
```

### Response

```json
[
  {
    "collection": "9KmLpQwR5tYz...",
    "registry_type": "BASE",
    "authority": "5FHwkrdxntdK4N6Z4gXQ...",
    "agent_count": 8542,
    "top_agents": 312,
    "avg_quality": 7850
  },
  {
    "collection": "7YmP3kL2nQwR...",
    "registry_type": "USER",
    "authority": "4EGvjrcxmtdH5M5Y3fPR...",
    "agent_count": 1205,
    "top_agents": 45,
    "avg_quality": 8230
  }
]
```

---

## Verification Stats

```
GET /rest/v1/verification_stats
```

Breakdown of verification status across all data types (for reorg resilience monitoring).

### Response Schema

```typescript
interface VerificationStatsRow {
  model: string;          // Table name
  pending_count: number;  // Awaiting verification
  finalized_count: number; // Verified on-chain
  orphaned_count: number; // Invalidated by reorg
}
```

### Models Tracked

- `agents`
- `collections`
- `feedbacks`
- `feedback_responses`
- `validations`
- `metadata`

### Example

```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/verification_stats"
```

### Response

```json
[
  {
    "model": "agents",
    "pending_count": 42,
    "finalized_count": 12505,
    "orphaned_count": 3
  },
  {
    "model": "collections",
    "pending_count": 0,
    "finalized_count": 89,
    "orphaned_count": 0
  },
  {
    "model": "feedbacks",
    "pending_count": 156,
    "finalized_count": 2345522,
    "orphaned_count": 12
  },
  {
    "model": "feedback_responses",
    "pending_count": 12,
    "finalized_count": 89012,
    "orphaned_count": 2
  },
  {
    "model": "validations",
    "pending_count": 8,
    "finalized_count": 4513,
    "orphaned_count": 0
  },
  {
    "model": "metadata",
    "pending_count": 23,
    "finalized_count": 45678,
    "orphaned_count": 5
  }
]
```

---

## Notes

- Collection stats use a database VIEW (computed on query)
- All quality scores are 0-10000 (divide by 100 for percentage)
- `avg_quality` is only computed for agents with `feedback_count > 0`
