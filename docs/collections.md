# Collections + Parent-Child (GraphQL v2)

8004 exposes both raw Metaplex collection info and canonical on-chain grouping fields:

- `collection`: raw Metaplex collection pubkey (`agent.solana.collection`)
- `collectionPointer`: canonical collection id on the agent
- `creator`: creator wallet associated with the agent
- `colLocked`: whether `collectionPointer` is locked
- `parentAsset`: parent asset pubkey (for hierarchy)
- `parentCreator`: creator wallet of parent relation
- `parentLocked`: whether parent relation is locked

## Endpoint

```http
POST /v2/graphql
```

All examples below assume:

```bash
GRAPHQL_URL="https://8004-indexer-production.up.railway.app/v2/graphql"
```

## Collection Queries

### List canonical collections

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($first: Int!, $skip: Int!) { collections(first: $first, skip: $skip) { collection creator firstSeenAsset firstSeenAt firstSeenSlot assetCount } }",
    "variables": { "first": 20, "skip": 0 }
  }'
```

### Count assets for one collection scope

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($collection: String!, $creator: String) { collectionAssetCount(collection: $collection, creator: $creator) }",
    "variables": { "collection": "my-col", "creator": "CREATOR_WALLET" }
  }'
```

### List assets in one collection scope (paginated)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($collection: String!, $creator: String, $first: Int!, $skip: Int!) { collectionAssets(collection: $collection, creator: $creator, first: $first, skip: $skip, orderBy: createdAt, orderDirection: desc) { id owner creator collectionPointer colLocked parentAsset parentCreator parentLocked createdAt } }",
    "variables": { "collection": "my-col", "creator": "CREATOR_WALLET", "first": 50, "skip": 0 }
  }'
```

## Parent-Child Queries

`parent`, `root`, and `asset` arguments accept:

- namespaced IDs: `sol:<asset_pubkey>`
- raw asset pubkeys

### Direct children

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($parent: ID!) { agentChildren(parent: $parent, first: 50, skip: 0) { id owner parentAsset parentCreator parentLocked } }",
    "variables": { "parent": "sol:PARENT_ASSET_PUBKEY" }
  }'
```

### Lineage (ancestors)

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($asset: ID!) { agentLineage(asset: $asset, includeSelf: true, first: 50, skip: 0) { id parentAsset creator } }",
    "variables": { "asset": "sol:CHILD_ASSET_PUBKEY" }
  }'
```

### Full tree from a root

```bash
curl -sS "$GRAPHQL_URL" \
  -H "content-type: application/json" \
  --data '{
    "query":"query($root: ID!) { agentTree(root: $root, maxDepth: 5, includeRoot: true, first: 200, skip: 0) { depth path parentAsset agent { id owner creator collectionPointer parentAsset } } }",
    "variables": { "root": "sol:ROOT_ASSET_PUBKEY" }
  }'
```

## REST Equivalents

When REST is enabled (`API_MODE=hybrid`):

- `GET /rest/v1/collections`
- `GET /rest/v1/collection_asset_count?collection=eq.<collection>&creator=eq.<creator>`
- `GET /rest/v1/collection_assets?collection=eq.<collection>&creator=eq.<creator>&limit=100&offset=0`
- `GET /rest/v1/agents/children?parent_asset=eq.<asset>`
- `GET /rest/v1/agents/tree?root_asset=eq.<asset>&max_depth=5`
- `GET /rest/v1/agents/lineage?asset=eq.<asset>`

## Collection Document Digestion Policy

Collection CID document ingestion is controlled by `INDEX_COLLECTION_METADATA`.

When `INDEX_COLLECTION_METADATA=true`, indexers ingest only these fields from the CID JSON:

- `version`
- `name`
- `symbol`
- `description`
- `image`
- `banner_image`
- `social_website`
- `social_x`
- `social_discord`

Collection hierarchy still comes from canonical on-chain data:

- `parent` is not ingested from CID JSON
- parent-child linkage remains sourced from on-chain canonical fields

## Example Files

- GraphQL examples: [examples/collection-parent-child.graphql](examples/collection-parent-child.graphql)
- REST examples: [examples/collection-parent-child.rest.sh](examples/collection-parent-child.rest.sh)
