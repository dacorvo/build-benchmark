$(SRC) ?= $(CURDIR)
$(OUT) ?= $(CURDIR)/output

all: $(OUT)/foo

include $(CURDIR)/Makefile.subdir

$(OUT)/foo: $(OBJS)
	$(CC) -o $@ $^
