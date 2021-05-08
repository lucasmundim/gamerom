VERSION:=$(shell cat lib/gamerom/version.rb |grep VERSION|cut -d\" -f2)
IMAGE=lucasmundim/gamerom:${VERSION}
DOCKER_OPTS=--rm -it -v ${HOME}/.gamerom:/root/.gamerom ${IMAGE}
LOCAL_VOLUME_OPTS=-v ${CURDIR}:/app
DOCKER_DEVELOPMENT_OPTS=${LOCAL_VOLUME_OPTS} --entrypoint '' ${DOCKER_OPTS}

version:
	@echo ${VERSION}

build:
	@docker build -t ${IMAGE} .

console:
	@docker run ${DOCKER_DEVELOPMENT_OPTS} ./bin/console

push: build
	@docker push ${IMAGE}

# If the first argument is "run"...
ifeq (run,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif

run:
	@docker run ${LOCAL_VOLUME_OPTS} ${DOCKER_OPTS} $(RUN_ARGS)

shell:
	@docker run ${DOCKER_DEVELOPMENT_OPTS} sh

spec:
	@docker run ${DOCKER_DEVELOPMENT_OPTS} bundle exec rake spec

update_bundle:
	@docker run ${DOCKER_DEVELOPMENT_OPTS} sh -c "bundle config unset frozen && bundle"

.PHONY: build push run shell spec update_bundle
