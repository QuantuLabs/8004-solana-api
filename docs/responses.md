# Feedback Responses API

List feedback responses (agent/owner replies to client feedback).

## Endpoint

```
GET /rest/v1/feedback_responses
```

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | string | Filter by agent asset ID |
| `client_address` | string | Filter by original feedback client |
| `feedback_index` | string | Filter by feedback index |
| `responder` | string | Filter by responder wallet |
| `status` | string | Verification status filter |
| `limit` | number | Max results (default: 100) |
| `offset` | number | Pagination offset |

## Response Schema

```typescript
interface FeedbackResponse {
  id: string;                    // Unique response ID
  asset: string;                 // Agent asset pubkey
  client_address: string;        // Original feedback client
  feedback_index: string;        // Parent feedback index (BigInt as string)
  responder: string;             // Who responded (owner/agent wallet)
  response_uri: string | null;   // Response content URI
  response_hash: string | null;  // SHA-256 of response (hex)
  running_digest: string | null; // Hash-chain digest (hex) - see [SEAL](https://github.com/QuantuLabs/8004-solana/blob/main/docs/SEAL.md)
  block_slot: string;            // Solana slot (BigInt as string)
  tx_index: number | null;       // Transaction index for ordering
  tx_signature: string;          // Transaction signature
  created_at: string;            // ISO timestamp
  status: string;                // PENDING | FINALIZED | ORPHANED
  verified_at: string | null;    // When verified
}
```

## Examples

### Get responses for a specific feedback
```bash
curl -H "apikey: $SUPABASE_KEY" \
  "$BASE_URL/feedback_responses?asset=eq.Agent&client_address=eq.Client&feedback_index=eq.0"
```

### Get all responses for an agent
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/feedback_responses?asset=eq.AgentPubkey"
```

### Get responses by a specific responder
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/feedback_responses?responder=eq.ResponderWallet"
```

## Response Example

```json
[
  {
    "id": "8Rz4Nqk...:5FHwkrd...:0:7YmP3kL...:6Uz0yL...",
    "asset": "8Rz4NqkPsXdVNgmSi2wYBRJbT123...",
    "client_address": "5FHwkrdxntdK4N6Z4gXQ...",
    "feedback_index": "0",
    "responder": "7YmP3kL2nQwR...",
    "response_uri": "ipfs://QmResponse...",
    "response_hash": "b2c3d4e5...",
    "running_digest": null,
    "block_slot": "123456800",
    "tx_index": 0,
    "tx_signature": "6Uz0yL...",
    "created_at": "2024-01-15T10:30:00.000Z",
    "status": "FINALIZED",
    "verified_at": "2024-01-15T11:00:00.000Z"
  }
]
```

## Multiple Responses

ERC-8004 allows multiple responses per responder to the same feedback. The unique constraint is on `(asset, client_address, feedback_index, responder, tx_signature)`, allowing different transactions to add responses.
