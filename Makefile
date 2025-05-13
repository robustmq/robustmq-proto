# Copyright 2023 RobustMQ Team
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec
.DEFAULT_GOAL := help
LOG_TARGET=echo -e "\033[0;32m===========> Running $@ ... \033[0m"

# Buf Configuration
BUF = buf-$(BUF_VERSION)
BUF_PATH = $(LOCAL_BIN)/$(BUF)
BUF_VERSION ?= 1.53.0
BUF_OS := $(shell uname -s)
BUF_ARCH := $(shell uname -m)
ifeq ($(BUF_ARCH),x86_64)
BUF_ARCH = amd64
else ifeq ($(BUF_ARCH),aarch64)
BUF_ARCH = arm64
endif

##@ Proto

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: lint
lint: format ## Run buf lint to validate proto files.
	@$(LOG_TARGET)
	@$(BUF_PATH) lint

# excludes paths
# This is generally a dependent external proto file, we do not need to format it
FORMAT_PATHS ?= validate
BUF_FORMAT_FLAGS = $(foreach path,$(FORMAT_PATHS),--exclude-path protos/vendor/$(path))

.PHONY: format
format: buf ## Format proto files with buf.
	@$(LOG_TARGET)
	@$(BUF_PATH) format $(BUF_FORMAT_FLAGS) -w

LOCAL_BIN ?= $(shell pwd)/bin
$(LOCAL_BIN):
	mkdir -p $(LOCAL_BIN)

.PHONY: buf
buf: $(BUF_PATH) ## Download buf CLI locally if necessary.
$(BUF_PATH): $(LOCAL_BIN)
	@$(LOG_TARGET)
	$(call download-buf,$(BUF_PATH),$(BUF_VERSION),$(BUF_OS),$(BUF_ARCH))

define download-buf
@[ -f $(1) ] || { \
set -e ;\
echo "Downloading buf $(2) for $(3)-$(4)" ;\
tmp_file=$$(mktemp) ;\
curl -sSL "https://github.com/bufbuild/buf/releases/download/v$(2)/buf-$(3)-$(4)" -o $$tmp_file || (rm -f $$tmp_file; exit 1) ;\
mv $$tmp_file $(1) ;\
chmod +x $(1) ;\
}
endef
