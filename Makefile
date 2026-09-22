TOOLS_MAIN := tools/main.sh

.DEFAULT_GOAL := help

.PHONY: help clone build \
	collect install push% status clean\:dist clean\:all claude

help:
	@sh "$(TOOLS_MAIN)" help

clone:
	@sh "$(TOOLS_MAIN)" clone $(filter-out $@,$(MAKECMDGOALS))

build:
	@sh "$(TOOLS_MAIN)" build $(filter-out $@,$(MAKECMDGOALS))

collect:
	@sh "$(TOOLS_MAIN)" collect

install:
	@sh "$(TOOLS_MAIN)" install

push%:
	@sh "$(TOOLS_MAIN)" push "$*"

status:
	@sh "$(TOOLS_MAIN)" status

clean\:dist:
	@sh "$(TOOLS_MAIN)" clean:dist

clean\:all:
	@sh "$(TOOLS_MAIN)" clean:all

claude:
	@sh "$(TOOLS_MAIN)" claude

# GNU Make treats positional modes and project names as independent goals.
# Consume only those supplied alongside clone or build.
ifneq ($(filter clone build,$(MAKECMDGOALS)),)
.PHONY: $(filter-out clone build,$(MAKECMDGOALS))
$(filter-out clone build,$(MAKECMDGOALS)):
	@:
endif
