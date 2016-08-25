OUT ?= $(CURDIR)/output
SRC ?= $(CURDIR)

$(OUT)/foo: $(OUT)/Makefile .FORCE
	$(MAKE) -C $(OUT)

$(OUT)/Makefile:
	mkdir -p $(OUT)
	cd $(OUT) && cmake -Wno-dev $(SRC)

.FORCE:
