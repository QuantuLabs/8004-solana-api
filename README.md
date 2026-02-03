# 8004 Solana Graph API

REST API for querying the 8004 Agent Registry on Solana. Compatible with PostgREST/Supabase query format.

> **Self-Hosted**: You can run your own indexer instance.
> See [8004-solana-indexer](https://github.com/CasterCorp/8004-solana-indexer) for setup instructions.

## Base URL

**Devnet (Public)**:
```
https://YOUR_SUPABASE_PROJECT.supabase.co/rest/v1
```

**Self-Hosted**:
```
https://your-indexer.example.com/rest/v1
```

## Authentication

Public read-only API. No authentication required.

## Rate Limiting

- **100 requests/minute** per IP
- Returns `429 Too Many Requests` when exceeded

## Response Format

All endpoints return JSON arrays (PostgREST compatible).

## Pagination

| Parameter | Description | Default | Max |
|-----------|-------------|---------|-----|
| `limit` | Items per page | 100 | 1000 |
| `offset` | Skip N items | 0 | 10000 |

For total count, add header: `Prefer: count=exact`

Response includes `Content-Range: 0-99/1234` header.

## Status Filtering (Reorg Resilience)

All data has a verification status:
- `PENDING` - Ingested, awaiting verification
- `FINALIZED` - Verified on-chain
- `ORPHANED` - Invalidated by reorg

| Parameter | Description |
|-----------|-------------|
| `status=eq.FINALIZED` | Only verified data |
| `status=eq.PENDING` | Only pending data |
| `includeOrphaned=true` | Include all (incl. orphaned) |
| *(default)* | PENDING + FINALIZED |

## Endpoints

| Endpoint | Description | Documentation |
|----------|-------------|---------------|
| [`/agents`](docs/agents.md) | List registered agents | [View](docs/agents.md) |
| [`/feedbacks`](docs/feedbacks.md) | List feedback events | [View](docs/feedbacks.md) |
| [`/responses`](docs/responses.md) | List feedback responses | [View](docs/responses.md) |
| [`/revocations`](docs/revocations.md) | List revoked feedbacks | [View](docs/revocations.md) |
| [`/validations`](docs/validations.md) | List validation requests | [View](docs/validations.md) |
| [`/registries`](docs/registries.md) | List collections/registries | [View](docs/registries.md) |
| [`/metadata`](docs/metadata.md) | Agent metadata key-value pairs | [View](docs/metadata.md) |
| [`/leaderboard`](docs/leaderboard.md) | Top agents by trust score | [View](docs/leaderboard.md) |
| [`/stats`](docs/stats.md) | Global & collection statistics | [View](docs/stats.md) |

## Quick Examples

### Get all agents in a collection
```bash
curl "https://api.example.com/rest/v1/agents?collection=eq.ABC123"
```

### Get feedbacks for an agent
```bash
curl "https://api.example.com/rest/v1/feedbacks?asset=eq.AgentAssetId123"
```

### Get leaderboard (top 10)
```bash
curl "https://api.example.com/rest/v1/leaderboard?limit=10"
```

### Get only finalized data
```bash
curl "https://api.example.com/rest/v1/agents?status=eq.FINALIZED"
```

## PostgREST Query Operators

| Operator | Example | Description |
|----------|---------|-------------|
| `eq` | `?owner=eq.ABC` | Equals |
| `neq` | `?status=neq.ORPHANED` | Not equals |
| `in` | `?feedback_index=in.(1,2,3)` | In list |

## Health Check

```bash
curl "https://api.example.com/health"
# {"status":"ok"}
```

## Related

- [8004 Solana Programs](https://github.com/CasterCorp/8004-solana) - On-chain programs
- [8004 TypeScript SDK](https://www.npmjs.com/package/8004-solana) - Client SDK
- [ERC-8004 Specification](https://eips.ethereum.org/EIPS/eip-8004) - Standard spec
