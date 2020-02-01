
TF_FILES = $(wildcard *.tf) $(wildcard mcserver/*.tf)

PROJECT_ROOT:=$(CURDIR)

init:
	terraform init -backend-config="bucket=${INFRA_BACKEND_BUCKET}"
.PHONY: init


infra.plan: $(shell find . -name '*.tf') $(shell find ./service -name '*.py')
	terraform plan -out $@


apply: infra.plan
	terraform apply $< && openssl dgst -sha256 -out $@ $<

portal/build: $(shell find portal/src -name '*.js')
	cd portal; npm run build && touch build

portal/upload: portal/build
	cd portal; aws s3 sync --delete --exclude '**/*.map' build/ ${HOSTING_BUCKET}
.PHONY: portal/upload


deploy: apply
.PHONY: deploy

service/.serverless/serverless-state.json: mcserver-out.env service/serverless.yml $(shell find ./service -name '*.py')
	cd service; eval $(shell cat mcserver-out.env | xargs) sls package

package: service/.serverless/serverless-state.json
.PHONY: package

deploy-service: mcserver-out.env service/.serverless/serverless-state.json
	cd service; sls deploy -p .serverless
.PHONY: deploy-service


activate: apply
	aws autoscaling set-desired-capacity \
	  --auto-scaling-group-name $(shell terraform output mc_autoscaling_group_name) \
	  --desired-capacity 1
.PHONY: activate
