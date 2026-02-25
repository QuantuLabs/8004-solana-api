# Leaderboard API

Rank agents by average feedback score.

## Endpoint

```http
GET /rest/v1/leaderboard
```

## Query Parameters

| Parameter | Type | Description |
|---|---|---|
| `collection` | string | Optional collection filter |
| `limit` | number | Max results (default `100`) |

## Response Schema

```typescript
interface LeaderboardEntry {
  asset: string;
  owner: string;
  collection: string;
  trust_score: number;    // rounded AVG(score)
  feedback_count: number; // number of scored, non-revoked feedbacks
}
```

## Examples

```bash
curl -sS "$BASE_URL/leaderboard?limit=10"
curl -sS "$BASE_URL/leaderboard?collection=eq.COLLECTION_PUBKEY&limit=50"
```

## Notes

- Ranking order: `trust_score DESC`, then `feedback_count DESC`.
- Only agents with at least one scored non-revoked feedback appear.
