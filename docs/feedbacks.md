# Feedbacks API

List feedback events (client reviews of agents).

## Endpoint

```
GET /rest/v1/feedbacks
```

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | string | Filter by agent asset ID |
| `client_address` | string | Filter by client wallet |
| `feedback_index` | string | Filter by specific index |
| `feedback_index` | `in.(1,2,3)` | Filter by multiple indices |
| `is_revoked` | boolean | Filter revoked/active feedbacks |
| `tag1` | string | Filter by primary tag |
| `tag2` | string | Filter by secondary tag |
| `endpoint` | string | Filter by service endpoint |
| `or` | string | OR filter: `(tag1.eq.X,tag2.eq.X)` |
| `status` | string | Verification status filter |
| `limit` | number | Max results (default: 100) |
| `offset` | number | Pagination offset |

## Response Schema

```typescript
interface Feedback {
  id: string;                    // Composite ID: asset:client:index
  asset: string;                 // Agent asset pubkey
  client_address: string;        // Client wallet
  feedback_index: string;        // Sequential index (BigInt as string)
  value: string;                 // Raw metric value (i64 as string)
  value_decimals: number;        // Decimal precision (0-6)
  score: number | null;          // ATOM score (0-100), null if skipped
  tag1: string;                  // Primary tag (e.g., "latency")
  tag2: string;                  // Secondary tag (e.g., "gpt-4")
  endpoint: string;              // Service endpoint URL
  feedback_uri: string | null;   // Extended feedback metadata URI
  feedback_hash: string | null;  // SHA-256 of feedback content (hex)
  is_revoked: boolean;           // Has been revoked
  revoked_at: string | null;     // When revoked (ISO timestamp)
  status: string;                // PENDING | FINALIZED | ORPHANED
  verified_at: string | null;    // When verified
  block_slot: string;            // Solana slot (BigInt as string)
  tx_index: number | null;       // Transaction index for ordering
  tx_signature: string;          // Transaction signature
  created_at: string;            // ISO timestamp
}
```

## Examples

### Get all feedbacks for an agent
```bash
curl "https://api.example.com/rest/v1/feedbacks?asset=eq.AgentPubkey123"
```

### Get feedbacks by client
```bash
curl "https://api.example.com/rest/v1/feedbacks?client_address=eq.ClientWallet"
```

### Get non-revoked feedbacks only
```bash
curl "https://api.example.com/rest/v1/feedbacks?is_revoked=eq.false"
```

### Filter by tag (in either tag1 or tag2)
```bash
curl "https://api.example.com/rest/v1/feedbacks?or=(tag1.eq.latency,tag2.eq.latency)"
```

### Get specific feedback indices
```bash
curl "https://api.example.com/rest/v1/feedbacks?asset=eq.Agent&feedback_index=in.(0,1,2)"
```

### With total count
```bash
curl -H "Prefer: count=exact" "https://api.example.com/rest/v1/feedbacks?asset=eq.Agent"
# Response header: Content-Range: 0-99/1234
```

## Response Example

```json
[
  {
    "id": "8Rz4Nqk...:5FHwkrd...:0",
    "asset": "8Rz4NqkPsXdVNgmSi2wYBRJbT123...",
    "client_address": "5FHwkrdxntdK4N6Z4gXQ...",
    "feedback_index": "0",
    "value": "1500000",
    "value_decimals": 3,
    "score": 85,
    "tag1": "latency",
    "tag2": "inference",
    "endpoint": "https://api.myagent.com/chat",
    "feedback_uri": "ipfs://Qm...",
    "feedback_hash": "a1b2c3d4...",
    "is_revoked": false,
    "revoked_at": null,
    "status": "FINALIZED",
    "verified_at": "2024-01-15T10:30:00.000Z",
    "block_slot": "123456789",
    "tx_index": 0,
    "tx_signature": "5Tz9xK...",
    "created_at": "2024-01-15T10:00:00.000Z"
  }
]
```

## Notes

- `feedback_index` is returned as string to preserve BigInt precision
- `value` represents raw measurement (e.g., latency in microseconds)
- `value_decimals` indicates decimal places (1500000 with decimals=3 = 1500.000)
- `score` is null if ATOM scoring was skipped for this feedback
