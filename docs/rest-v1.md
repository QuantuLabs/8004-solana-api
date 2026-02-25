# REST v1 (Legacy)

This document keeps the legacy PostgREST-compatible API reference.

Default 8004 deployments now use GraphQL (`/v2/graphql`).
On GraphQL-only deployments, `/rest/v1/*` returns `410 Gone`.

## Base URL (REST v1)

| Deployment Type | Base URL |
|---|---|
| Legacy Supabase-hosted | `https://uhjytdjxvfbppgjicfly.supabase.co/rest/v1` |
| Self-hosted REST mode | `https://your-indexer.example.com/rest/v1` |

## Authentication

For the legacy Supabase-hosted endpoint, include an API key:

```bash
apikey: sb_publishable_...
```

Example:

```bash
curl -H "apikey: sb_publishable_..." \
  "https://uhjytdjxvfbppgjicfly.supabase.co/rest/v1/agents"
```

## Endpoint Reference

| Endpoint | Description | Documentation |
|---|---|---|
| `/agents` | List registered agents | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/agents/children` | Direct children for a parent asset | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/agents/tree` | Parent-children tree reconstruction | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/agents/lineage` | Ancestor chain for one asset | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/feedbacks` | List feedback events | [docs/rest-v1/feedbacks.md](rest-v1/feedbacks.md) |
| `/feedback_responses` | List feedback responses | [docs/rest-v1/responses.md](rest-v1/responses.md) |
| `/responses` | Alias for feedback responses | [docs/rest-v1/responses.md](rest-v1/responses.md) |
| `/revocations` | List feedback revocation events | [docs/rest-v1/responses.md](rest-v1/responses.md) |
| `/validations` | Deprecated compatibility endpoint (returns `410`) | [docs/rest-v1/stats.md](rest-v1/stats.md) |
| `/metadata` | Agent metadata key-value pairs | [docs/rest-v1/metadata.md](rest-v1/metadata.md) |
| `/leaderboard` | Top agents by trust score | [docs/rest-v1/leaderboard.md](rest-v1/leaderboard.md) |
| `/collections` | Canonical collections (`creator+collection`) | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/collection_asset_count` | Asset count for one collection scope | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/collection_assets` | Paginated assets for one collection scope | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/stats` and `/global_stats` | Global statistics | [docs/rest-v1/stats.md](rest-v1/stats.md) |
| `/collection_stats` | Per-collection statistics | [docs/rest-v1/stats.md](rest-v1/stats.md) |
| `/stats/verification` | Verification status breakdown | [docs/rest-v1/stats.md](rest-v1/stats.md) |
| `/checkpoints/:asset` | Hash-chain checkpoints | [docs/integrity.md](integrity.md) |
| `/checkpoints/:asset/latest` | Latest checkpoint per chain | [docs/integrity.md](integrity.md) |
| `/verify/replay/:asset` | Replay verification helper | [docs/integrity.md](integrity.md) |
| `/events/:asset/replay-data` | Replay/event reconstruction data | [docs/integrity.md](integrity.md) |

## Pagination

| Parameter | Description | Default | Max |
|---|---|---|---|
| `limit` | Items per page | `100` | `1000` |
| `offset` | Skip N items | `0` | `10000` |

For total count (when supported), send:

```bash
Prefer: count=exact
```

## Verification Status Filters

- `PENDING` - ingested, waiting verification
- `FINALIZED` - verified on-chain
- `ORPHANED` - invalidated by reorg

Common query patterns:

- `?status=eq.FINALIZED`
- `?status=eq.PENDING`
- `?includeOrphaned=true` (to include orphaned rows)

## PostgREST Operators

| Operator | Example | Description |
|---|---|---|
| `eq` | `?owner=eq.ABC` | Equals |
| `neq` | `?status=neq.ORPHANED` | Not equals |
| `in` | `?feedback_index=in.(1,2,3)` | In list |

## Migration Recommendation

For new integrations, migrate to GraphQL:

- [`../README.md`](../README.md)
