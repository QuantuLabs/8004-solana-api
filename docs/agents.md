# Agents API

List registered AI agents (Metaplex Core NFTs) with [ATOM](https://github.com/QuantuLabs/8004-solana/blob/main/programs/atom-engine/README.md) reputation stats.

## Endpoint

```
GET /rest/v1/agents
```

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | string | Filter by agent asset ID (Metaplex Core asset pubkey) |
| `owner` | string | Filter by owner wallet address |
| `collection` | string | Filter by collection address |
| `agent_wallet` | string | Filter by agent's signing wallet |
| `trust_tier` | number | Filter by trust tier (0-4) |
| `status` | string | Verification status filter |
| `limit` | number | Max results (default: 100, max: 1000) |
| `offset` | number | Pagination offset (max: 10000) |

## Response Schema

```typescript
interface Agent {
  asset: string;              // Metaplex Core asset pubkey (primary key)
  owner: string;              // Current owner wallet
  agent_uri: string | null;   // Metadata URI (IPFS/Arweave)
  agent_wallet: string | null; // Agent's signing wallet
  collection: string;         // Collection pubkey
  nft_name: string | null;    // NFT display name
  atom_enabled: boolean;      // ATOM reputation engine enabled

  // ATOM Reputation Stats (https://github.com/QuantuLabs/8004-solana/blob/main/programs/atom-engine/README.md)
  trust_tier: number;         // 0=Unrated, 1=Bronze, 2=Silver, 3=Gold, 4=Platinum
  quality_score: number;      // 0-10000 (divide by 100 for percentage)
  confidence: number;         // 0-10000 (divide by 100 for percentage)
  risk_score: number;         // 0-100 volatility indicator
  diversity_ratio: number;    // 0-255 unique client ratio
  feedback_count: number;     // Total feedbacks received
  raw_avg_score: number;      // 0-100 simple arithmetic mean (when ATOM disabled)
  sort_key: bigint;           // Computed leaderboard sort key

  // Chain reference
  block_slot: bigint;         // Solana slot when registered
  tx_index: number | null;    // Transaction index for ordering
  tx_signature: string;       // Registration transaction signature

  // Timestamps
  created_at: string;         // ISO timestamp
  updated_at: string;         // ISO timestamp

  // Verification (reorg resilience)
  status: string;             // PENDING | FINALIZED | ORPHANED
  verified_at: string | null; // When verified on-chain
  verified_slot: bigint | null;
}
```

## Trust Tiers

| Tier | Value | Description |
|------|-------|-------------|
| Unrated | 0 | No feedbacks yet |
| Bronze | 1 | Entry level |
| Silver | 2 | Established |
| Gold | 3 | High quality |
| Platinum | 4 | Top tier |

## Examples

### List all agents
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/agents"
```

### Get agents by owner
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/agents?owner=eq.WalletPubkey123"
```

### Get agents in a collection
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/agents?collection=eq.CollectionPubkey"
```

### Get single agent by asset
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/agents?asset=eq.AgentAssetPubkey"
```

### Get Gold+ agents only
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/agents?trust_tier=gte.3"
```

### Only finalized agents
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/agents?status=eq.FINALIZED"
```

## Response Example

```json
[
  {
    "asset": "8Rz4NqkPsXdVNgmSi2wYBRJbT123...",
    "owner": "5FHwkrdxntdK4N6Z4gXQ...",
    "agent_uri": "https://arweave.net/abc123",
    "agent_wallet": "7YmP3kL2nQwR...",
    "collection": "9KmLpQwR5tYz...",
    "nft_name": "My AI Agent #42",
    "atom_enabled": true,
    "trust_tier": 3,
    "quality_score": 8542,
    "confidence": 7890,
    "risk_score": 12,
    "diversity_ratio": 180,
    "feedback_count": 247,
    "raw_avg_score": 85,
    "sort_key": "3854279012345678",
    "block_slot": "312456789",
    "tx_index": null,
    "tx_signature": "5Kx7YnM...",
    "created_at": "2024-01-15T10:00:00.000Z",
    "updated_at": "2024-01-15T10:30:00.000Z",
    "status": "FINALIZED",
    "verified_at": "2024-01-15T10:30:00.000Z",
    "verified_slot": "312456800"
  }
]
```

## Global Agent IDs

For gamification, agents have sequential global IDs via the `agent_global_ids` view:

```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/agent_global_ids?asset=eq.AgentAssetPubkey"
```

Returns:
```json
[
  {
    "asset": "8Rz4NqkPsXdVNgmSi2wYBRJbT123...",
    "collection": "9KmLpQwR5tYz...",
    "owner": "5FHwkrdxntdK4N6Z4gXQ...",
    "nft_name": "My AI Agent #42",
    "global_id": 42,
    "block_slot": 312456789,
    "tx_index": 0,
    "tx_signature": "5Kx7YnM...",
    "created_at": "2024-01-15T10:00:00.000Z"
  }
]
```
