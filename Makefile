PROJECT = arb
VERSION = 1.0

PREFIX ?= /usr
INITDIR_SYSTEMD = /usr/lib/systemd/user
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/arb
MANDIR = $(PREFIX)/share/man/man1

INSTALL_DIR = install -p -d
INSTALL_PROGRAM = install -p -m755
INSTALL_DATA = install -p -m644

common/$(PROJECT):
	@echo -e '\033[1;32mRun make install...\033[0m'

install:
	@echo -e '\033[1;32mInstalling program...\033[0m'
	$(INSTALL_DIR) "$(DESTDIR)$(BINDIR)"
	$(INSTALL_PROGRAM) arb "$(DESTDIR)$(BINDIR)"
	$(INSTALL_DIR) "$(DESTDIR)$(SHAREDIR)"
	$(INSTALL_DATA) config "$(DESTDIR)$(SHAREDIR)"
	$(INSTALL_DATA) ignore "$(DESTDIR)$(SHAREDIR)"

	@echo -e '\033[1;32mInstalling manpage...\033[0m'
	$(INSTALL_DIR) "$(DESTDIR)$(MANDIR)"
	$(INSTALL_DATA) doc/arb.1 "$(DESTDIR)$(MANDIR)/arb.1"

	@echo -e '\033[1;32mInstalling systemd files...\033[0m'
	$(INSTALL_DIR) "$(DESTDIR)$(INITDIR_SYSTEMD)"
	$(INSTALL_DATA) arb.service "$(DESTDIR)$(INITDIR_SYSTEMD)"
	$(INSTALL_DATA) arb.timer "$(DESTDIR)$(INITDIR_SYSTEMD)"

uninstall:
	@echo -e '\033[1;32mUninstalling program...\033[0m'
	rm "$(DESTDIR)$(BINDIR)/arb"
	rm "$(DESTDIR)$(SHAREDIR)/config"
	rm "$(DESTDIR)$(SHAREDIR)/ignore"
	rmdir "$(DESTDIR)$(SHAREDIR)"

	@echo -e '\033[1;32mUninstalling manpage...\033[0m'
	rm -f "$(DESTDIR)$(MANDIR)/arb.1"

	@echo -e '\033[1;32mUninstalling systemd files...\033[0m'
	rm "$(DESTDIR)$(INITDIR_SYSTEMD)/arb.service"
	rm "$(DESTDIR)$(INITDIR_SYSTEMD)/arb.timer"

.PHONY: install uninstall
