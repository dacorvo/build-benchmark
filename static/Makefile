$(SRC) ?= $(CURDIR)
$(OUT) ?= $(CURDIR)/output

all: $(OUT)/foo

$(OUT)/foo: $(OUT)/Makefile .FORCE
	$(MAKE) -C $(OUT)

FRAGMENTS := \
	$(shell find $(SRC) -name Makefile -cnewer $(OUT)/Makefile 2>/dev/null)

$(OUT)/Makefile: $(FRAGMENTS)
	mkdir -p $(OUT)
	$(MAKE) -C $(SRC) -f $(CURDIR)/Makefile.gen \
		SRC=$(SRC) \
		OUT=$(OUT)

.FORCE:
