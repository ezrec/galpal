PERL=perl
GALASM=galasm

TEST_JEDEC=$(wildcard *.jed)
TEST_PLD=$(wildcard *.pld)
TEST_JED=$(TEST_PLD:%.pld=%.jed)
TEST_VERILOG=$(TEST_JEDEC:%.jed=%.v) $(TEST_JED:%.jed=%.v)

all: $(TEST_VERILOG)

clean: FORCE
	$(RM) $(TEST_VERILOG) $(TEST_JED)

test_jed: $(TEST_JED)

%.v: %.jed ../galpal.pl
	$(PERL) ../galpal.pl $* $< >$@

%.jed: %.pld
	$(GALASM) -c -f -p $<

FORCE:
	@
