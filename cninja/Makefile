OUT ?= $(CURDIR)/output
SRC ?= $(CURDIR)

$(OUT)/foo: $(OUT)/build.ninja .FORCE
	ninja -C $(OUT)

$(OUT)/build.ninja:
	mkdir -p $(OUT)
	cd $(OUT) && cmake -GNinja -Wno-dev $(SRC)

.FORCE:
