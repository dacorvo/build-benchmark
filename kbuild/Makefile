$(SRC) ?= $(CURDIR)
$(OUT) ?= $(CURDIR)/output

all: $(OUT)/foo

$(OUT)/foo: $(OUT)/built-in.a
	$(CC) -o $@ $^

$(OUT)/built-in.a: .FORCE
	mkdir -p $(OUT)
	$(MAKE) -C $(SRC) -f $(CURDIR)/Makefile.kbuild \
		SRC=. \
		OUT=$(OUT)

.FORCE:
