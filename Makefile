REBAR = $(shell pwd)/rebar3
ELVIS = $(shell pwd)/elvis
APP = howl

.PHONY: rel stagedevrel package version all tree

all: version compile

include fifo.mk

version:
	@echo "$(shell git symbolic-ref HEAD 2> /dev/null | cut -b 12-)-$(shell git log --pretty=format:'%h, %ad' -1)" > howl.version

version_header: version
	@echo "-define(VERSION, <<\"$(shell cat howl.version)\">>)." > apps/howl/include/howl_version.hrl

clean:
	$(REBAR) clean
	make -C rel/pkg clean

long-test:
	$(REBAR) as eqc,long eunit

rel: update
	$(REBAR) as prod compile
        # The HOWL-MIB.hlr file needed by this is gitignored, not included with github code
	# sh generate_zabbix_template.sh
	$(REBAR) as prod release

package: rel
	make -C rel/pkg package
