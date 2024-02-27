#!/usr/bin/env bash

set -eufo pipefail

## Project specific data
#PROJECT_PACKAGE=github.com/slok/kube-code-generator/example
#CLIENT_GENERATOR_OUT=${PROJECT_PACKAGE}/client
#APIS_ROOT=${PROJECT_PACKAGE}/apis
#
## Ugly but needs to be relative if we want to use k8s.io/code-generator
## as it is without touching/sed-ing the code/scripts
#RELATIVE_ROOT_PATH=$(realpath --relative-to="${PWD}" /)
#CODEGEN_PKG=${RELATIVE_ROOT_PATH}${GOPATH}/src/k8s.io/code-generator
#

PROJECT_PACKAGE="${PROJECT_PACKAGE:-""}"
CLIENT_GENERATOR_OUT="${CLIENT_GENERATOR_OUT:-""}"
APIS_ROOT="${APIS_ROOT:-""}"

[ -z "$PROJECT_PACKAGE" ] && echo "PROJECT_PACKAGE env var is required" && exit 1
[ -z "$CLIENT_GENERATOR_OUT" ] && echo "CLIENT_GENERATOR_OUT env var is required" && exit 1
[ -z "$APIS_ROOT" ] && echo "APIS_ROOT env var is required" && exit 1

# From >=1.16 we use gomod, so we need to execute from the project directory.
cd "${GOPATH}/src/${PROJECT_PACKAGE}"

# Ugly but needs to be relative if we want to use k8s.io/code-generator
# as it is without touching/sed-ing the code/scripts
RELATIVE_ROOT_PATH=$(realpath --relative-to="${PWD}" /)
CODEGEN_PKG=${RELATIVE_ROOT_PATH}${GOPATH}/src/k8s.io/code-generator

BOILERPLATE_PATH=/tmp/fake-boilerplate.txt
touch "${BOILERPLATE_PATH}"

source "${CODEGEN_PKG}/kube_codegen.sh"

kube::codegen::gen_helpers \
  --input-pkg-root "${APIS_ROOT}" \
  --output-base "${GOPATH}/src" \
  --boilerplate "${BOILERPLATE_PATH}"

kube::codegen::gen_client \
  --input-pkg-root "${APIS_ROOT}" \
  --output-base "${GOPATH}/src" \
  --output-pkg-root "${CLIENT_GENERATOR_OUT}" \
  --boilerplate "${BOILERPLATE_PATH}" \
  --with-watch
