PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin

.PHONY: all install uninstall test

all:
	@echo "Run 'make install' to install AdHocMPD to $(BINDIR)"

install:
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 adhocmpd $(DESTDIR)$(BINDIR)/adhocmpd
	ln -sf $(BINDIR)/adhocmpd $(DESTDIR)$(BINDIR)/AdHocMPD
	ln -sf $(BINDIR)/adhocmpd $(DESTDIR)$(BINDIR)/adhoc_mpd

uninstall:
	rm -f $(DESTDIR)$(BINDIR)/adhocmpd
	rm -f $(DESTDIR)$(BINDIR)/AdHocMPD
	rm -f $(DESTDIR)$(BINDIR)/adhoc_mpd

test:
	bash -n adhocmpd
	bash -n install.sh
