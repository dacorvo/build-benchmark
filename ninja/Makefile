OUT ?= $(CURDIR)/output
SRC ?= $(CURDIR)

$(OUT)/foo: $(OUT)/build.ninja .FORCE
	ninja -C $(OUT)

# Note that the build.ninja is able to regenerate itself
$(OUT)/build.ninja:
	mkdir -p $(OUT)
	python $(CURDIR)/ninja_gen.py $(SRC) $(OUT)

.FORCE:
