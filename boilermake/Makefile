$(SRC) ?= $(CURDIR)
$(OUT) ?= $(CURDIR)/output

all: $(OUT)/Makefile $(OUT)/main.mk .FORCE
	$(MAKE) -C $(OUT)

$(OUT)/Makefile: $(CURDIR)/boilermake/Makefile
	mkdir -p $(OUT)
	cp $< $@

$(OUT)/main.mk:
	mkdir -p $(OUT)
	echo "SUBMAKEFILES := $(SRC)/boilermake.mk" > $@

.FORCE:
