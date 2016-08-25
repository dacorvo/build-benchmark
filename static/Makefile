$(SRC) ?= $(CURDIR)
$(OUT) ?= $(CURDIR)/output

all: $(OUT)/foo

-include $(OUT)/Makefile

$(OUT)/foo: $(OBJS)
	$(CC) -o $@ $^

$(OUT)/Makefile:
	mkdir -p $(OUT)
	$(MAKE) -C $(SRC) -f $(CURDIR)/Makefile.gen \
		SRC=$(SRC) \
		OUT=$(OUT)
