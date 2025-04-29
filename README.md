# CAPE Cedar PaC Test

Our repo has some assets to play around cargo with. These are in `assets/pac/`
and are divided into entities, schema and policies.

## Setup

- make sure you have `rust` and `cargo` installed (tested on 1.86.0 of both,
  which was the latest available with `rustup` at time of writing)
- Install the Cedar CLI
  ```sh
  cargo install cedar-policy-cli
  ```

## Repo Structure

This repo contains the following subdirectories:

- `context` - Contains context files for testing authorizations. Context is
  extra data passed to the authorize calls (e.g. the method an API
  endpoint is being hit for). In practice (when using the AVP
  authorize endpoint) this will be built up and passed to the
  endpoint if needed.
- `entities` - Contains `entities.json` which is a listing of all entities that
  will be considered when evaluating an authorize call. In practice
  (when using the AVP authorize endpoint) this will be built up and
  passed to the endpoint if needed (this is not loaded a priori as
  far as i can tell)
- `policy` - Contains `cedar` policies used in this repo.
- `schema` - Contains the rudimentary `cape` `cedar` schema used in the repo.

## Testing Things

### Checking Files Parse

```sh
# schema
cedar check-parse --schema schema/cape.cedarschema

# policy
cedar check-parse --policies policy/hai-read-raw.cedar

# entities
cedar check-parse --entities entities/entities.json
```

## Checking Policies Validate Against a Schema

```sh
cedar validate \
    --policies policy/hai-read-raw.cedar \
    --schema schema/cape.cedarschema
```

## Test an Authorization

### for bucket access

```sh
# gives allow
cedar authorize -v \
    --principal 'CAPE::User::"user-id-micah"' \
    --action 'CAPE::Action::"readRaw"' \
    --resource 'CAPE::Bucket::"bckt-id-hairaw"' \
    --policies policy/hai-read-raw.cedar \
    --entities entities/entities.json \
    --schema schema/cape.cedarschema

# gives deny
cedar authorize -v \
    --principal 'CAPE::User::"user-id-drew"' \
    --action 'CAPE::Action::"readRaw"' \
    --resource 'CAPE::Bucket::"bckt-id-hairaw"' \
    --policies policy/hai-read-raw.cedar \
    --entities entities/entities.json \
    --schema schema/cape.cedarschema
```

### for api access

```sh
# gives allow  (drew has get perms on endpoint)
cedar authorize -v \
    --principal 'CAPE::User::"user-id-drew"' \
    --action 'CAPE::Action::"getPipelineExecutors"' \
    --resource 'CAPE::APIEndpoint::"apiep-id-dap-getexecutors"' \
    --policies policy/get-pipelineexecutors.cedar \
    --entities entities/entities.json \
    --schema schema/cape.cedarschema \
    --context context/get.json

# gives deny  (drew has get perms on endpoint, but not post)
cedar authorize -v \
    --principal 'CAPE::User::"user-id-drew"' \
    --action 'CAPE::Action::"getPipelineExecutors"' \
    --resource 'CAPE::APIEndpoint::"apiep-id-dap-getexecutors"' \
    --policies policy/get-pipelineexecutors.cedar \
    --entities entities/entities.json \
    --schema schema/cape.cedarschema \
    --context context/post.json

# gives deny (micah has no perms on endpoint)
cedar authorize -v \
    --principal 'CAPE::User::"user-id-micah"' \
    --action 'CAPE::Action::"getPipelineExecutors"' \
    --resource 'CAPE::APIEndpoint::"apiep-id-dap-getexecutors"' \
    --policies policy/get-pipelineexecutors.cedar \
    --entities entities/entities.json \
    --schema schema/cape.cedarschema \
    --context context/get.json

# gives deny  (drew has no perms on endpoint)
cedar authorize -v \
    --principal 'CAPE::User::"user-id-drew"' \
    --action 'CAPE::Action::"postPipelineRun"' \
    --resource 'CAPE::APIEndpoint::"apiep-id-dap-postpipelinerun"' \
    --policies policy/get-pipelineexecutors.cedar \
    --entities entities/entities.json \
    --schema schema/cape.cedarschema
```
