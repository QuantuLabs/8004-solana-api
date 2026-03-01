#!/usr/bin/env bash
set -euo pipefail

: "${BASE_URL:?Set BASE_URL, e.g. https://your-indexer.example.com/rest/v1}"

COLLECTION_POINTER="c1:CID"
CREATOR="CREATOR_WALLET"

# 1) List canonical collections
curl -sS "$BASE_URL/collections?limit=100&offset=0"

# 2) Count assets in one scope (creator + collection pointer)
curl -sS "$BASE_URL/collection_asset_count?collection=eq.${COLLECTION_POINTER}&creator=eq.${CREATOR}&status=neq.ORPHANED"

# 3) List assets in one scope (paginated)
curl -sS "$BASE_URL/collection_assets?collection=eq.${COLLECTION_POINTER}&creator=eq.${CREATOR}&status=neq.ORPHANED&limit=100&offset=0"

# 4) Direct children of a parent asset
curl -sS "$BASE_URL/agents/children?parent_asset=eq.PARENT_ASSET_PUBKEY&status=neq.ORPHANED&limit=100&offset=0"

# 5) Full tree from root asset
curl -sS "$BASE_URL/agents/tree?root_asset=eq.ROOT_ASSET_PUBKEY&max_depth=5&include_root=true&status=neq.ORPHANED&limit=200&offset=0"

# 6) Lineage of one asset
curl -sS "$BASE_URL/agents/lineage?asset=eq.CHILD_ASSET_PUBKEY&include_self=true&status=neq.ORPHANED&limit=100&offset=0"

# 7) Equivalent /agents filters
curl -sS "$BASE_URL/agents?creator=eq.${CREATOR}&collection_pointer=eq.${COLLECTION_POINTER}&status=neq.ORPHANED&limit=50"
curl -sS "$BASE_URL/agents?parent_asset=eq.PARENT_ASSET_PUBKEY&status=neq.ORPHANED&limit=50"
