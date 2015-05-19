.DEFAULT_GOAL:=test
.PHONY: node test deploy

TEMP_IMAGE:="hydra-temp:$(shell echo $$RANDOM)"
REPO_IMAGE:="esselius/hydra:$(shell git rev-parse --short HEAD)"


# Build, run interactive thing and clean up
listen:
	@$(MAKE)  build  IMAGE=$(TEMP_IMAGE) REDIR=">/dev/null"
	@-$(MAKE) run    IMAGE=$(TEMP_IMAGE) COMMAND="listen $(SQS)"
	@$(MAKE)  clean  IMAGE=$(TEMP_IMAGE)

irb:
	@$(MAKE)  build  IMAGE=$(TEMP_IMAGE) REDIR=">/dev/null"
	@-$(MAKE) run    IMAGE=$(TEMP_IMAGE) OPTS="-t" COMMAND="irb"
	@$(MAKE)  clean  IMAGE=$(TEMP_IMAGE)

# Build, run tests and clean up
test:
	@$(MAKE)  build  IMAGE=$(TEMP_IMAGE) REDIR=">/dev/null"
	@-$(MAKE) run    IMAGE=$(TEMP_IMAGE) OPTS="--net=none" COMMAND="test"
	@$(MAKE)  clean  IMAGE=$(TEMP_IMAGE)

# Pull base image, build, run tests, push to registry and clean up
deploy:
	@$(MAKE) build   IMAGE=$(REPO_IMAGE) OPTS="--pull"
	@$(MAKE) run     IMAGE=$(REPO_IMAGE) OPTS="--net=none" COMMAND="test"
	@$(MAKE) publish IMAGE=$(REPO_IMAGE)
	@$(MAKE) clean   IMAGE=$(REPO_IMAGE)


# These targets are not intended for direct use
run:
	@docker run $(OPTS) -i --rm $(IMAGE) $(COMMAND)

build:
	@docker build $(OPTS) --force-rm -t $(IMAGE) . $(REDIR)

publish:
	docker push $(IMAGE)

clean:
	@docker rmi -f $(IMAGE) > /dev/null
