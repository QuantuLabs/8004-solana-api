#!/usr/bin/env bash
set -euo pipefail

: "${BASE_URL:?Set BASE_URL, e.g. https://your-indexer.example.com/rest/v1}"

# 1) List canonical collections
curl -sS "$BASE_URL/collections?limit=100&offset=0"

# 2) Count assets in one scope (creator + collection)
curl -sS "$BASE_URL/collection_asset_count?collection=eq.my-col&creator=eq.CREATOR_WALLET"

# 3) List assets in one scope (paginated)
curl -sS "$BASE_URL/collection_assets?collection=eq.my-col&creator=eq.CREATOR_WALLET&limit=100&offset=0"

# 4) Direct children of a parent asset
curl -sS "$BASE_URL/agents/children?parent_asset=eq.PARENT_ASSET_PUBKEY&limit=100&offset=0"

# 5) Full tree from root asset
curl -sS "$BASE_URL/agents/tree?root_asset=eq.ROOT_ASSET_PUBKEY&max_depth=5&include_root=true&limit=200&offset=0"

# 6) Lineage of one asset
curl -sS "$BASE_URL/agents/lineage?asset=eq.CHILD_ASSET_PUBKEY&include_self=true&limit=100&offset=0"

# 7) Equivalent /agents filters
curl -sS "$BASE_URL/agents?creator=eq.CREATOR_WALLET&collection=eq.my-col&limit=50"
curl -sS "$BASE_URL/agents?parent_asset=eq.PARENT_ASSET_PUBKEY&limit=50"
