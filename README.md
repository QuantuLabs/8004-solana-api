# 8004 Solana API

REST API for querying the 8004 Agent Registry on Solana. Compatible with PostgREST/Supabase query format.

> **Self-Hosted**: Run your own indexer instance.
> See [8004-solana-indexer](https://github.com/QuantuLabs/8004-solana-indexer) for setup instructions.

## Architecture

The 8004 Agent Registry uses a **sharded architecture** where the global registry is composed of multiple **sub-registries**, each represented as a Metaplex Core collection:

```
┌─────────────────────────────────────────────────────┐
│              8004 Agent Registry Program            │
│                                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
│  │ BASE        │  │ USER #1     │  │ USER #2     │ │
│  │ Collection  │  │ Collection  │  │ Collection  │ │
│  │ (default)   │  │ (custom)    │  │ (custom)    │ │
│  └─────────────┘  └─────────────┘  └─────────────┘ │
│        │                │                │         │
│        └────────────────┼────────────────┘         │
│                         ▼                          │
│              Unified Agent Registry                │
└─────────────────────────────────────────────────────┘
```

- **BASE**: Default sub-registry created during program initialization
- **USER**: Custom sub-registries created by users for organizing agents

All sub-registries belong to the same on-chain program and form a single logical registry.

## Base URL

| Network | URL | Status |
|---------|-----|--------|
| **Devnet** | `https://uhjytdjxvfbppgjicfly.supabase.co/rest/v1` | Live |
| **Mainnet** | *Coming soon* | - |

**API Key** (anon/public - required header for Supabase):
```
apikey: sb_publishable_i-ycBRGiolBr8GMdiVq1rA_nwt7N2bq
```

**Self-Hosted** ([setup guide](https://github.com/QuantuLabs/8004-solana-indexer)):
```
https://your-indexer.example.com/rest/v1
```

## Authentication

Public read-only API. Requires `apikey` header for Supabase hosted instance:

```bash
curl -H "apikey: sb_publishable_i-ycBRGiolBr8GMdiVq1rA_nwt7N2bq" \
  "https://uhjytdjxvfbppgjicfly.supabase.co/rest/v1/agents"
```

Self-hosted instances may not require authentication.

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
| [`/feedback_responses`](docs/responses.md) | List feedback responses | [View](docs/responses.md) |
| [`/validations`](docs/validations.md) | List validation requests | [View](docs/validations.md) |
| [`/collections`](docs/registries.md) | List sub-registries | [View](docs/registries.md) |
| [`/metadata`](docs/metadata.md) | Agent metadata key-value pairs | [View](docs/metadata.md) |
| [`/leaderboard`](docs/leaderboard.md) | Top agents by [ATOM](https://github.com/QuantuLabs/8004-solana/blob/main/programs/atom-engine/README.md) trust score | [View](docs/leaderboard.md) |
| [`/global_stats`](docs/stats.md) | Global statistics | [View](docs/stats.md) |
| [`/collection_stats`](docs/stats.md) | Per-collection statistics | [View](docs/stats.md) |
| [`/verification_stats`](docs/stats.md) | Verification status breakdown | [View](docs/stats.md) |

## Quick Examples

```bash
# Devnet configuration
export SUPABASE_KEY="sb_publishable_i-ycBRGiolBr8GMdiVq1rA_nwt7N2bq"
export BASE_URL="https://uhjytdjxvfbppgjicfly.supabase.co/rest/v1"
```

### Get all agents in a collection
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/agents?collection=eq.ABC123"
```

### Get feedbacks for an agent
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/feedbacks?asset=eq.AgentAssetId123"
```

### Get leaderboard (top 10)
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/leaderboard?limit=10"
```

### Get only finalized data
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/agents?status=eq.FINALIZED"
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

- [8004-solana-indexer](https://github.com/QuantuLabs/8004-solana-indexer) - Self-hosted indexer
- [8004-solana](https://github.com/QuantuLabs/8004-solana) - On-chain programs (Anchor)
- [8004-solana SDK](https://www.npmjs.com/package/8004-solana) - TypeScript SDK
- [ERC-8004 Specification](https://eips.ethereum.org/EIPS/eip-8004) - Standard spec
