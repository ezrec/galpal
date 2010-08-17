
TEST_JEDEC=$(shell echo test/*.jed)
TEST_VERILOG=$(TEST_JEDEC:%.jed=%.v)

all: $(TEST_VERILOG)

%.v: %.jed bin/j2v
	bin/j2v $* $^ >$@

%.jed: %.pld
	galasm -c -f -p $^
