# Metadata API

List agent metadata key-value pairs.

## Endpoint

```
GET /rest/v1/metadata
```

## Query Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `asset` | string | Filter by agent asset ID |
| `key` | string | Filter by metadata key |
| `status` | string | Verification status filter |
| `limit` | number | Max results (default: 100, max: 100) |

**Note:** Metadata has a stricter limit (100 vs 1000) because values can be large.

## Response Schema

```typescript
interface Metadata {
  id: string;              // Composite: asset:key_hash
  asset: string;           // Agent asset pubkey
  key: string;             // Metadata key (max 32 chars)
  key_hash: string;        // Hash of key for indexing
  value: string;           // Hex-encoded binary with \\x prefix (e.g., "\\x00746578742076616c7565")
  immutable: boolean;      // Cannot be changed after first set
  block_slot: string;      // Solana slot (BigInt as string)
  tx_index: number | null; // Transaction index for ordering
  tx_signature: string;    // Transaction signature
  created_at: string;      // ISO timestamp
  updated_at: string;      // ISO timestamp
  status: string;          // PENDING | FINALIZED | ORPHANED
  verified_at: string | null;
}
```

## Value Encoding

Values are stored as binary with a compression prefix byte:
- `0x00` - Raw UTF-8 data follows
- `0x01` - ZSTD compressed data follows

The raw `value` column returns hex-encoded binary with `\x` prefix. Use the `metadata_decoded` views for convenience.

## Decoded Views

### metadata_decoded (all formats)

Returns all metadata with automatic decoding:

```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/metadata_decoded?asset=eq.AgentPubkey"
```

```typescript
interface MetadataDecoded {
  // ... same fields as Metadata ...
  value_text: string | null;  // Decoded value (or "_compressed:base64..." for ZSTD)
  encoding: "raw" | "zstd" | "legacy" | "empty";
}
```

### metadata_decoded_raw (raw only, JSON-safe)

Returns only raw (uncompressed) metadata, guaranteed to be valid UTF-8:

```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/metadata_decoded_raw?asset=eq.AgentPubkey"
```

## Examples

### Get all metadata for an agent
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/metadata?asset=eq.AgentPubkey"
```

### Get specific key
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/metadata?asset=eq.AgentPubkey&key=eq.description"
```

### Get decoded metadata (recommended)
```bash
curl -H "apikey: $SUPABASE_KEY" "$BASE_URL/metadata_decoded_raw?asset=eq.AgentPubkey"
```

## Response Example (metadata_decoded_raw)

```json
[
  {
    "id": "8Rz4Nqk...:a1b2c3d4",
    "asset": "8Rz4NqkPsXdVNgmSi2wYBRJbT123...",
    "key": "description",
    "key_hash": "a1b2c3d4e5f6...",
    "immutable": false,
    "block_slot": "312456789",
    "tx_signature": "5Kx7YnM...",
    "created_at": "2024-01-15T10:00:00.000Z",
    "updated_at": "2024-01-15T10:00:00.000Z",
    "value_text": "This is my AI agent"
  },
  {
    "id": "8Rz4Nqk...:e5f6g7h8",
    "asset": "8Rz4NqkPsXdVNgmSi2wYBRJbT123...",
    "key": "model",
    "key_hash": "e5f6g7h8i9j0...",
    "immutable": true,
    "block_slot": "312456789",
    "tx_signature": "5Kx7YnM...",
    "created_at": "2024-01-15T10:00:00.000Z",
    "updated_at": "2024-01-15T10:00:00.000Z",
    "value_text": "gpt-4"
  }
]
```

## Decoding Values (Client-side)

For raw `metadata` table responses:

```javascript
// Decode hex string (remove \x prefix)
const hexString = metadata.value.slice(2); // remove "\\x"
const binary = new Uint8Array(hexString.match(/.{2}/g).map(byte => parseInt(byte, 16)));

// Check prefix byte
if (binary[0] === 0x00) {
  // Raw UTF-8
  const text = new TextDecoder().decode(binary.slice(1));
} else if (binary[0] === 0x01) {
  // ZSTD compressed - requires zstd library
  const decompressed = zstd.decompress(binary.slice(1));
  const text = new TextDecoder().decode(decompressed);
}
```

## Reserved Keys

Keys starting with `_uri:` are reserved for system-derived metadata from URI fetching:

| Key | Description |
|-----|-------------|
| `_uri:status` | URI fetch status |
| `_uri:name` | Extracted name |
| `_uri:description` | Extracted description |
| `_uri:image` | Extracted image URL |

## Size Limits

- **Key**: Max 32 bytes
- **Value**: Max 256 bytes on-chain (compressed, can decompress to ~100KB)
