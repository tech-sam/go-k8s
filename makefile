SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)

# ==============================================================================
# CLASS NOTES
#
# Kind
# 	For full Kind v0.24 release notes: https://github.com/kubernetes-sigs/kind/releases/tag/v0.24.0


# ==============================================================================
# Install dependencies


GOLANG          := golang:1.23
ALPINE          := alpine:3.20
KIND            := kindest/node:v1.31.0



KIND_CLUSTER    := tech-sam-starter-cluster
NAMESPACE       := sales-system
SALES_APP       := sales
BASE_IMAGE_NAME := ardanlabs/service
SERVICE_NAME	:= sales-api
VERSION         := 0.0.1
SERVICE_IMAGE   := $(BASE_IMAGE_NAME)/$(SERVICE_NAME):$(VERSION)



dev-brew:
	brew update
	brew list kind || brew install kind
	brew list kubectl || brew install kubectl
	brew list kustomize || brew install kustomize
	brew list pgcli || brew install pgcli
	brew list watch || brew install watch
	brew list datawire/blackbird/telepresence-arm64 || brew install datawire/blackbird/telepresence-arm64

dev-docker:
	docker pull $(GOLANG) & \
	docker pull $(ALPINE) & \
	docker pull $(KIND) & \
	wait;



# ==============================================================================
# Running from within k8s/kind


dev-up-local:
	kind create cluster \
		--image ${KIND} \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/dev/kind-config.yaml
	
	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner
	
dev-up: dev-up-local

dev-down-local:
	kind delete cluster --name $(KIND_CLUSTER)

dev-down:
	kind delete cluster --name $(KIND_CLUSTER)

dev-load:
	kind load docker-image $(SERVICE_IMAGE) --name $(KIND_CLUSTER) 

dev-apply:
	kustomize build zarf/k8s/dev/sales | kubectl apply -f -
	kubectl wait pods --namespace=$(NAMESPACE) --selector app=$(SALES_APP) --for=condition=Ready

	
# ==============================================================================


dev-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

dev-restart:
	kubectl rollout restart deployment $(SALES_APP) --namespace=$(NAMESPACE)

dev-update: all dev-load dev-restart

dev-update-apply: all dev-load dev-apply		

# ==============================================================================

dev-logs:
	kubectl logs --namespace=$(NAMESPACE) -l app=$(SALES_APP) --all-containers=true -f --tail=100


dev-describe-deployment:
	kubectl describe deployment --namespace=$(NAMESPACE) $(SALES_APP)

dev-describe-sales:
	kubectl describe pod --namespace=$(NAMESPACE) -l app=$(SALES_APP)
# ==============================================================================
# Building containers

# Example: $(shell git rev-parse --short HEAD)
VERSION := 1.0

all: sales

sales:
	docker build \
		-f zarf/docker/dockerfile.service \
		-t $(SERVICE_IMAGE) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

run-local:
	go run app/services/sales-api/main.go
tidy:
	go mod tidy
	go mod vendor