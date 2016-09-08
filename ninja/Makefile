OUT ?= $(CURDIR)/output
SRC ?= $(CURDIR)

$(OUT)/foo: $(OUT)/build.ninja .FORCE
	ninja -C $(OUT)

FRAGMENTS := \
	$(shell find $(SRC) -name Makefile -cnewer $(OUT)/build.ninja 2>/dev/null)

$(OUT)/build.ninja: $(FRAGMENTS)
	mkdir -p $(OUT)
	python $(CURDIR)/ninja_gen.py $(SRC)/Makefile $(OUT)

.FORCE:
