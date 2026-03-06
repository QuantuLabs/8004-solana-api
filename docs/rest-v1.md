# REST v1 (PostgREST-Compatible)

REST v1 remains available as a compatibility surface for PostgREST-style clients.

Default 8004 deployments use GraphQL (`/v2/graphql`).
If REST is disabled, `/rest/v1/*` returns `410 Gone`.
If REST proxy is enabled but server credentials are missing (`SUPABASE_KEY` / `POSTGREST_TOKEN`), `/rest/v1/*` can return `503`.

REST v1 has two execution paths:
- `local API mode`: native handlers in the indexer (`src/api/server.ts`) with local mapping logic.
- `REST proxy mode`: read-only passthrough to Supabase/PostgREST (`GET`/`HEAD` only, allowlisted paths).
- Unless noted otherwise, endpoint schemas/examples in this docs folder describe local API mode.
- In REST proxy mode, response column names/types can follow upstream PostgREST tables/views.

Proxy caveats:
- Some local endpoints are not guaranteed in proxy mode (`/agents/children`, `/agents/tree`, `/agents/lineage`, replay/integrity helpers) and can return `403`.
- Allowlisted paths like `/collections` are still upstream-dependent in proxy mode and may differ from local mapped shape.

## Base URL (REST v1)

| Deployment Type | Base URL |
|---|---|
| Mainnet (preferred) | `https://8004-indexer-main.qnt.sh/rest/v1` |
| Devnet (preferred) | `https://8004-indexer-dev.qnt.sh/rest/v1` |
| Legacy devnet proxy (may lag behind primary) | `https://8004-indexer-production.up.railway.app/rest/v1` |
| Legacy mainnet proxy (may lag behind primary) | `https://8004-api.qnt.sh/rest/v1` |
| Self-hosted indexer | `https://your-indexer.example.com/rest/v1` |
| Direct Supabase/PostgREST | `https://<project>.supabase.co/rest/v1` or `https://your-postgrest.example.com` |

All examples below assume:

```bash
BASE_URL="https://8004-indexer-main.qnt.sh/rest/v1"
```

## Authentication

Reference deployments are public read-only.

Self-hosted/Supabase/PostgREST deployments may require API key or bearer headers.

Supabase example:

```bash
curl -sS \
  -H "apikey: sb_publishable_..." \
  -H "Authorization: Bearer sb_publishable_..." \
  "$BASE_URL/agents?limit=1"
```

## Endpoint Reference

| Endpoint | Description | Documentation |
|---|---|---|
| `/agents` | List registered agents | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/agents/children` | Direct children for a parent asset (local API mode; REST proxy may return `403`) | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/agents/tree` | Parent-children tree reconstruction (local API mode; REST proxy may return `403`) | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/agents/lineage` | Ancestor chain for one asset (local API mode; REST proxy may return `403`) | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/feedbacks` | List feedback events | [docs/rest-v1/feedbacks.md](rest-v1/feedbacks.md) |
| `/feedback_responses` | List feedback responses | [docs/rest-v1/responses.md](rest-v1/responses.md) |
| `/responses` | Alias for feedback responses | [docs/rest-v1/responses.md](rest-v1/responses.md) |
| `/revocations` | List feedback revocation events | [docs/rest-v1/responses.md](rest-v1/responses.md) |
| `/metadata` | Agent metadata key-value pairs | [docs/rest-v1/metadata.md](rest-v1/metadata.md) |
| `/leaderboard` | Top agents by trust score | [docs/rest-v1/leaderboard.md](rest-v1/leaderboard.md) |
| `/collections` | Canonical collections (unique by same minting creator + same collection pointer) (proxy behavior depends on upstream exposure) | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/collection_asset_count` | Asset count for one collection scope (same minting creator + same collection pointer) | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/collection_assets` | Paginated assets for one collection scope (same minting creator + same collection pointer) | [docs/rest-v1/agents.md](rest-v1/agents.md) |
| `/stats` and `/global_stats` | Global statistics | [docs/rest-v1/stats.md](rest-v1/stats.md) |
| `/collection_stats` | Legacy registry/raw collection aggregates | [docs/rest-v1/stats.md](rest-v1/stats.md) |
| `/stats/verification` | Verification status breakdown | [docs/rest-v1/stats.md](rest-v1/stats.md) |
| `/validations` | Archived endpoint (always `410`) | [docs/rest-v1/stats.md](rest-v1/stats.md) |
| `/checkpoints/:asset` | Hash-chain checkpoints (local API mode; REST proxy may return `403`) | [docs/integrity.md](integrity.md) |
| `/checkpoints/:asset/latest` | Latest checkpoint per chain (local API mode; REST proxy may return `403`) | [docs/integrity.md](integrity.md) |
| `/verify/replay/:asset` | Replay verification helper (local API mode; `1 req/30s/IP`; REST proxy may return `403`) | [docs/integrity.md](integrity.md) |
| `/events/:asset/replay-data` | Replay/event reconstruction data (local API mode; REST proxy may return `403`) | [docs/integrity.md](integrity.md) |

## Pagination

| Parameter | Description | Default | Max |
|---|---|---|---|
| `limit` | Items per page | `100` | `1000` (`/metadata` max is `100`) |
| `offset` | Skip N items | `0` | `10000` |

When supported, request total count with:

```bash
Prefer: count=exact
```

## Verification Status Filters

Status values:

- `PENDING` - ingested, waiting verification
- `FINALIZED` - verified on-chain
- `ORPHANED` - invalidated by reorg

Behavior:

- Default: orphaned rows are excluded (`status=neq.ORPHANED` behavior)
- Explicit status filter: `?status=eq.FINALIZED`, `?status=eq.PENDING`, `?status=neq.ORPHANED`
- Include everything: `?includeOrphaned=true`

## PostgREST Operators

| Operator | Example | Description |
|---|---|---|
| `eq` | `?owner=eq.ABC` | Equals |
| `neq` | `?status=neq.ORPHANED` | Not equals |
| `in` | `?feedback_index=in.(1,2,3)` | In list |
| `gt` / `gte` / `lt` / `lte` | `?revocation_id=gte.10` | Numeric bounds (where supported) |

## Archived Validation Endpoints

Validation indexing is archived on-chain (`agent-registry-8004` `v0.5.0+`).

`GET /rest/v1/validations` is intentionally retired and returns `410 Gone`:

```json
{
  "error": "Validation endpoints are archived and no longer exposed. /rest/v1/validations has been retired."
}
```

## Notes

- REST proxy mode is read-only (`GET`/`HEAD` only).
- `GET /verify/replay/:asset` is throttled to `1` request per `30s` per IP.
- New integrations should prefer GraphQL for long-term compatibility.
