#!/usr/bin/env bash

REPO_ROOT=".."
SCHEMA_ROOT="${REPO_ROOT}/schema"
POLICY_ROOT="${REPO_ROOT}/policy"
ENTITY_ROOT="${REPO_ROOT}/entities"
CONTEXT_ROOT="${REPO_ROOT}/context"

CAPE_SCHEMA="${SCHEMA_ROOT}/cape-schema.cedarschema"
ENTITIES="${ENTITY_ROOT}/entities.json"

echo -e "Checking that all files parse...\n"

echo -e "\nChecking schema ${CAPE_SCHEMA}"
cedar check-parse --schema "${CAPE_SCHEMA}"

echo -e "\nChecking policies"
for f in "${POLICY_ROOT}"/*; do
    echo -e "\tChecking policy ${f}"
    cedar check-parse --policies "${f}"
done

echo -e "\nChecking entities ${ENTITIES}"
cedar check-parse --entities "${ENTITIES}"

echo -e "\nValidating policies against schema...\n"
for f in "${POLICY_ROOT}"/*; do
    echo -e "\tChecking policy ${f}"
    cedar validate --policies "${f}" --schema "${CAPE_SCHEMA}"
done

echo -e "\nRunning authorize tests..."

echo -e "\nALLOW ObjectStorage access?"
cedar authorize -v \
    --principal 'CAPE::User::"user-id-micah"' \
    --action 'CAPE::Action::"readRaw"' \
    --resource 'CAPE::ObjectStorage::"bckt-id-hairaw"' \
    --policies "${POLICY_ROOT}/hai-read-raw.cedar" \
    --entities "${ENTITIES}" \
    --schema "${CAPE_SCHEMA}"

echo -e "\nDENY ObjectStorage access?"
cedar authorize -v \
    --principal 'CAPE::User::"user-id-drew"' \
    --action 'CAPE::Action::"readRaw"' \
    --resource 'CAPE::ObjectStorage::"bckt-id-hairaw"' \
    --policies "${POLICY_ROOT}/hai-read-raw.cedar" \
    --entities "${ENTITIES}" \
    --schema "${CAPE_SCHEMA}"

echo -e "\nALLOW API Endpoint access?"
cedar authorize -v \
    --principal 'CAPE::User::"user-id-drew"' \
    --action 'CAPE::Action::"getPipelineExecutors"' \
    --resource 'CAPE::APIEndpoint::"apiep-id-dap-getexecutors"' \
    --policies "${POLICY_ROOT}/get-pipelineexecutors.cedar" \
    --entities "${ENTITIES}" \
    --schema "${CAPE_SCHEMA}" \
    --context "${CONTEXT_ROOT}"/get.json

echo -e "\nDENY API Endpoint access?"
cedar authorize -v \
    --principal 'CAPE::User::"user-id-drew"' \
    --action 'CAPE::Action::"getPipelineExecutors"' \
    --resource 'CAPE::APIEndpoint::"apiep-id-dap-getexecutors"' \
    --policies "${POLICY_ROOT}/get-pipelineexecutors.cedar" \
    --entities "${ENTITIES}" \
    --schema "${CAPE_SCHEMA}" \
    --context "${CONTEXT_ROOT}"/post.json

echo -e "\nDENY API Endpoint access?"
cedar authorize -v \
    --principal 'CAPE::User::"user-id-micah"' \
    --action 'CAPE::Action::"getPipelineExecutors"' \
    --resource 'CAPE::APIEndpoint::"apiep-id-dap-getexecutors"' \
    --policies "${POLICY_ROOT}/get-pipelineexecutors.cedar" \
    --entities "${ENTITIES}" \
    --schema "${CAPE_SCHEMA}" \
    --context "${CONTEXT_ROOT}"/get.json

echo -e "\nDENY API Endpoint access?"
cedar authorize -v \
    --principal 'CAPE::User::"user-id-drew"' \
    --action 'CAPE::Action::"postPipelineRun"' \
    --resource 'CAPE::APIEndpoint::"apiep-id-dap-postpipelinerun"' \
    --policies "${POLICY_ROOT}/get-pipelineexecutors.cedar" \
    --entities "${ENTITIES}" \
    --schema "${CAPE_SCHEMA}" \
    --context "${CONTEXT_ROOT}"/get.json

echo "DONE"
