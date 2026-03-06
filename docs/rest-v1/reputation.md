# Reputation / RPC Read Compatibility

These endpoints are useful for REST clients that need reputation-style summaries on proxy deployments.

They are not native local REST handlers in `8004-solana-indexer`.
They work when `API_MODE=both` (or REST proxy mode) is backed by an upstream PostgREST-compatible surface and the deployment includes the matching proxy allowlist patches.
Public DNS can lag behind local/self-hosted deployments until those patches are deployed there too.

Unless noted otherwise, examples below assume:

```bash
BASE_URL="https://8004-indexer-main.qnt.sh/rest/v1"
```

## `GET /rest/v1/agent_reputation`

Read one reputation summary by asset.

Example:

```bash
curl -sS "$BASE_URL/agent_reputation?asset=eq.ASSET_PUBKEY"
```

Response shape:

```typescript
interface AgentReputationRow {
  asset: string;
  owner: string;
  collection: string;
  nft_name: string | null;
  agent_uri: string | null;
  feedback_count: number;
  avg_score: number | null;
  positive_count: number;
  negative_count: number;
  validation_count: number;
}
```

## `GET /rest/v1/rpc/get_collection_agents`

Read reputation rows for one canonical collection scope.

Query parameters:

| Parameter | Type | Description |
|---|---|---|
| `collection_id` | string | Sequential collection ID |
| `page_limit` | number | Page size |
| `page_offset` | number | Page offset |

Example:

```bash
curl -sS "$BASE_URL/rpc/get_collection_agents?collection_id=38&page_limit=20&page_offset=0"
```

Response rows follow the same `AgentReputationRow` shape as `/agent_reputation`.

## `POST /rest/v1/rpc/get_leaderboard`

Read leaderboard rows via the PostgREST RPC compatibility path.

Example:

```bash
curl -sS "$BASE_URL/rpc/get_leaderboard" \
  -H "content-type: application/json" \
  --data '{
    "p_collection": null,
    "p_min_tier": 0,
    "p_limit": 10,
    "p_cursor_sort_key": null
  }'
```

Notes:

- This is the only public REST proxy endpoint that uses `POST` while remaining read-only.
- In local API mode, prefer `GET /rest/v1/leaderboard`.
