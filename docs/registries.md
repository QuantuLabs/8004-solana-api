# Sub-Registries API

List sub-registries (Metaplex collections) that form the unified Agent Registry.

## Architecture

The 8004 Agent Registry uses a **sharded architecture** where the global registry is split into multiple **sub-registries**, each represented as a Metaplex Core collection:

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
- **USER**: Custom sub-registries created by users

All sub-registries belong to the same on-chain program and form a single logical registry.

## Endpoint

```
GET /rest/v1/collections
```

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `collection` | string | Filter by collection address |
| `registry_type` | string | Filter by type: `BASE` or `USER` |
| `authority` | string | Filter by authority wallet |
| `status` | string | Verification status filter |
| `limit` | number | Max results (default: 100) |
| `offset` | number | Pagination offset |

## Response Schema

```typescript
interface SubRegistry {
  collection: string;         // Metaplex collection pubkey (primary key)
  registry_type: string;      // "BASE" or "USER"
  authority: string | null;   // Sub-registry authority wallet
  created_at: string;         // ISO timestamp
  status: string;             // PENDING | FINALIZED | ORPHANED
  verified_at: string | null; // When verified
}
```

## Sub-Registry Types

| Type | Description |
|------|-------------|
| `BASE` | Default sub-registry created during program initialization |
| `USER` | Custom sub-registries created by users |

## Examples

### List all sub-registries
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/collections"
```

### Get the BASE sub-registry
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/collections?registry_type=eq.BASE"
```

### Get USER sub-registries only
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/collections?registry_type=eq.USER"
```

### Get sub-registries by authority
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/collections?authority=eq.WalletPubkey"
```

## Response Example

```json
[
  {
    "collection": "9KmLpQwR5tYz...",
    "registry_type": "BASE",
    "authority": "5FHwkrdxntdK4N6Z4gXQ...",
    "created_at": "2024-01-10T00:00:00.000Z",
    "status": "FINALIZED",
    "verified_at": "2024-01-10T00:00:00.000Z"
  },
  {
    "collection": "7YmP3kL2nQwR...",
    "registry_type": "USER",
    "authority": "8Rz4NqkPsXdV...",
    "created_at": "2024-01-12T00:00:00.000Z",
    "status": "FINALIZED",
    "verified_at": "2024-01-12T00:00:00.000Z"
  }
]
```

