# CAPE Cedar PaC Test

Our repo has some assets to play around cargo with. these are in `assets/pac/`
and are divided into entities, schema and policies.

## Setup
* make sure you have `rust` and `cargo` installed (tested on 1.86.0 of both, 
  which was the latest available with `rustup` at time of writing)
* clone the main cedar repo (`https://github.com/cedar-policy/cedar.git`)
* from `cedar` repo root, `cargo install cedar-policy-cli`
* when running the below `cargo run` commands, you can either be in the `cedar`
  repo root or pass `--manifest-path <PATH>` (where `<PATH>` is the path to the 
  `cedar` repo's `Cargo.toml`) to `cargo run` 

## Repo Structure

This repo contains the following subdirectories:
* `context` - Contains context files for testing authorizations. Context is 
              extra data passed to the authorize calls (e.g. the method an API
              endpoint is being hit for). In practice (when using the AVP 
              authorize endpoint) this will be built up and passed to the 
              endpoint if needed.
* `entities` - Contains `entities.json` which is a listing of all entities that
               will be considered when evaluating an authorize call. In practice
               (when using the AVP authorize endpoint) this will be built up and 
               passed to the endpoint if needed (this is not loaded a priori as 
               far as i can tell)
* `policy` - Contains `cedar` policies used in this repo.
* `schema` - Contains the rudamentary `cape` `cedar` schema used in the repo.

## Testing Things

### Checking Files Parse
```
# schema
cargo run check-parse --schema  <PATH TO THIS REPO>/schema/cape.cedarschema

# policy
cargo run check-parse --policies  <PATH TO THIS REPO>/policy/hai-read-raw.cedar

# entities
cargo run check-parse --entities  <PATH TO THIS REPO>/entities/entities.json
```

## Checking Policies Validate Against a Schema

```
cargo run validate \
  --policies <PATH TO THIS REPO>/policy/hai-read-raw.cedar \
  --schema <PATH TO THIS REPO>/schema/cape.cedarschema
```

## Test an Authorization

### for bucket access

```
# gives allow    
cargo run authorize -v  \
	--principal 'CAPE::User::"user-id-micah"' \
	--action 'CAPE::Action::"readRaw"' \
	--resource 'CAPE::Bucket::"bckt-id-hairaw"' \
	--policies <PATH TO THIS REPO>/policy/hai-read-raw.cedar \
	--entities <PATH TO THIS REPO>/entities/entities.json \
	--schema <PATH TO THIS REPO>/schema/cape.cedarschema

# gives deny	
cargo run authorize -v  \
	--principal 'CAPE::User::"user-id-drew"' \
	--action 'CAPE::Action::"readRaw"' \
	--resource 'CAPE::Bucket::"bckt-id-hairaw"' \
	--policies <PATH TO THIS REPO>/policy/hai-read-raw.cedar \
	--entities <PATH TO THIS REPO>/entities/entities.json \
	--schema <PATH TO THIS REPO>/schema/cape.cedarschema

```

### for api access
```
# gives allow  (drew has get perms on endpoint)
cargo run authorize -v  \
	--principal 'CAPE::User::"user-id-drew"' \
	--action 'CAPE::Action::"getPipelineExecutors"' \
	--resource 'CAPE::APIEndpoint::"apiep-id-dap-getexecutors"' \
	--policies <PATH TO THIS REPO>/policy/get-pipelineexecutors.cedar \
	--entities <PATH TO THIS REPO>/entities/entities.json \
	--schema <PATH TO THIS REPO>/schema/cape.cedarschema \
	--context <PATH TO THIS REPO>/context/get.json

# gives deny  (drew has get perms on endpoint, but not post)
cargo run authorize -v  \
	--principal 'CAPE::User::"user-id-drew"' \
	--action 'CAPE::Action::"getPipelineExecutors"' \
	--resource 'CAPE::APIEndpoint::"apiep-id-dap-getexecutors"' \
	--policies <PATH TO THIS REPO>/policy/get-pipelineexecutors.cedar \
	--entities <PATH TO THIS REPO>/entities/entities.json \
	--schema <PATH TO THIS REPO>/schema/cape.cedarschema \
	--context <PATH TO THIS REPO>/context/post.json

# gives deny (micah has no perms on endpoint)
cargo run authorize -v  \
	--principal 'CAPE::User::"user-id-micah"' \
	--action 'CAPE::Action::"getPipelineExecutors"' \
	--resource 'CAPE::APIEndpoint::"apiep-id-dap-getexecutors"' \
	--policies <PATH TO THIS REPO>/policy/get-pipelineexecutors.cedar \
	--entities <PATH TO THIS REPO>/entities/entities.json \
	--schema <PATH TO THIS REPO>/schema/cape.cedarschema \
	--context <PATH TO THIS REPO>/context/get.json

# gives deny  (drew has no perms on endpoint)
cargo run authorize -v  \
	--principal 'CAPE::User::"user-id-drew"' \
	--action 'CAPE::Action::"postPipelineRun"' \
	--resource 'CAPE::APIEndpoint::"apiep-id-dap-postpipelinerun"' \
	--policies <PATH TO THIS REPO>/policy/get-pipelineexecutors.cedar \
	--entities <PATH TO THIS REPO>/entities/entities.json \
	--schema <PATH TO THIS REPO>/schema/cape.cedarschema
```
