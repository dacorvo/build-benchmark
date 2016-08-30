OUT ?= $(CURDIR)/output

TARGETS := kbuild nrecur static cmake boilermake ninja

all: $(TARGETS)

ifeq ($(wildcard $(OUT)/src),)
$(error Please launch gen_src_tree.sh first)
endif

define add_target

$(1)_clean:
	rm -rf $(OUT)/$(1)

$(1):
	$$(MAKE) -C $(CURDIR)/$(1) \
		SRC=$(OUT)/src \
		OUT=$(OUT)/$(1)

endef

$(eval $(foreach target,$(TARGETS),$(call add_target,$(target))))

clean:
	rm -rf $(OUT)

.PHONY: clean $(TARGETS)
