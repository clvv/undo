PREFIX?= /usr/local
BINDIR?= ${PREFIX}/bin
MANDIR?= ${PREFIX}/share/man
INSTALL?= install
INSTALLDIR= ${INSTALL} -d
INSTALLBIN= ${INSTALL} -m 755
INSTALLMAN= ${INSTALL} -m 644

all: undo.1

uninstall:
	rm -f ${DESTDIR}${BINDIR}/undo
	rm -f ${DESTDIR}${MANDIR}/man1/undo.1

install:
	${INSTALLDIR} ${DESTDIR}${BINDIR}
	${INSTALLBIN} undo ${DESTDIR}${BINDIR}
	${INSTALLDIR} ${DESTDIR}${MANDIR}/man1
	${INSTALLMAN} undo.1 ${DESTDIR}${MANDIR}/man1

man: undo.1

undo.1: README
	pandoc -s -w man README -o undo.1

.PHONY: all install uninstall man

