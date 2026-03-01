# Leaderboard API

Rank agents by average feedback score.

All examples below assume:

```bash
BASE_URL="https://your-indexer.example.com/rest/v1"
```

## Endpoint

```http
GET /rest/v1/leaderboard
```

## Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `collection` | string | Optional collection filter |
| `includeOrphaned` | boolean | Include orphaned rows |
| `limit` | number | Max results (default `100`, max `1000`) |

## Response Schema

```typescript
interface LeaderboardEntry {
  asset: string;
  owner: string;
  collection: string;
  trust_score: number;    // rounded AVG(score)
  feedback_count: number; // scored, non-revoked feedback count
}
```

## Examples

```bash
curl -sS "$BASE_URL/leaderboard?limit=10"
curl -sS "$BASE_URL/leaderboard?collection=eq.COLLECTION_PUBKEY&limit=50"
curl -sS "$BASE_URL/leaderboard?includeOrphaned=true&limit=20"
```

## Notes

- Ranking order: `trust_score DESC`, then `feedback_count DESC`.
- Only agents with at least one scored non-revoked feedback appear.
