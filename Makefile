TOOLS_MAIN := .tools/main.sh

.DEFAULT_GOAL := help

.PHONY: help clone build \
	collect install zip zip-all status \
	clean\:dist clean\:all claude

help:
	@sh "$(TOOLS_MAIN)" help

clone:
	@sh "$(TOOLS_MAIN)" clone $(filter-out $@,$(MAKECMDGOALS))

build:
	@sh "$(TOOLS_MAIN)" build $(filter-out $@,$(MAKECMDGOALS))

collect:
	@sh "$(TOOLS_MAIN)" collect

zip:
	@sh "$(TOOLS_MAIN)" zip $(filter-out $@,$(MAKECMDGOALS))

zip-all:
	@sh "$(TOOLS_MAIN)" zip-all

install:
	@sh "$(TOOLS_MAIN)" install $(filter-out $@,$(MAKECMDGOALS))

status:
	@sh "$(TOOLS_MAIN)" status

clean\:dist:
	@sh "$(TOOLS_MAIN)" clean:dist

clean\:all:
	@sh "$(TOOLS_MAIN)" clean:all

codex:
	@sh "$(TOOLS_MAIN)" codex

claude:
	@sh "$(TOOLS_MAIN)" claude

opencode:
	@sh "$(TOOLS_MAIN)" opencode

# GNU Make treats positional modes and project names as independent goals.
# Consume only those supplied alongside clone, build, install, or zip.
ifneq ($(filter clone build install zip,$(MAKECMDGOALS)),)
.PHONY: $(filter-out clone build install zip,$(MAKECMDGOALS))
$(filter-out clone build install zip,$(MAKECMDGOALS)):
	@:
endif

# Branch goals carry the branch in the goal name, as in 'make push:main'.
#
# These cannot be ordinary targets or pattern rules. A target name cannot hold
# an unescaped ':', and GNU Make splits a goal on '/' before matching it
# against a pattern, so 'make push:feature/x' matches no pattern rule. Both
# cases fall through to .DEFAULT, which dispatches them by name.
#
# Note the .PHONY declarations are deliberately absent: a goal of this shape
# can never name an existing file, and declaring one would not add anything.
.DEFAULT:
	@case "$@" in \
		push:*|checkout:*|switch:*) \
			set -- $$(printf '%s' '$@' | tr ':' ' '); \
			cmd=$$1; \
			branch=$$2; \
			if [ -z "$$branch" ]; then \
				echo "Error: branch name is required; usage: make $$cmd:<BRANCH>" >&2; \
				exit 2; \
			fi; \
			sh "$(TOOLS_MAIN)" "$$cmd" "$$branch" ;; \
		push|checkout|switch) \
			echo "Error: branch name is required; usage: make $@:<BRANCH>" >&2; \
			exit 2 ;; \
		*) \
			echo "make: *** No rule to make target '$@'.  Stop." >&2; \
			exit 2 ;; \
	esac
