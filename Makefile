NAME	= rabbitmq-server-on
SPEC	= $(NAME).spec
VERSION	= $(shell sed -e '/Version:/!d' -e 's/[^0-9.]*\([0-9.]*\).*/\1/' $(SPEC))
SRCS	=
AUX	= $(SPEC) Makefile
DISTDIR	= $(NAME)-$(VERSION)

all:	$(SRCS)
	@:
test:	$(SRCS)
	@:

dist:	$(SRCS) $(AUX)
	@echo "Prepare"
	-rm -rf $(DISTDIR)
	@echo "Creating folder $(DISTDIR)"
	mkdir $(DISTDIR)
	@echo "Hardlinking files for tarball"
	ln $(SRCS) $(AUX) $(DISTDIR)
	@echo "Creating tarball $(DISTDIR).tar.gz"
	tar chzfv $(DISTDIR).tar.gz $(DISTDIR)
	@echo "Cleaning up..."
	-rm -rf $(DISTDIR)
	@echo "Finished!"

$(DISTDIR).tar.gz:	dist

rpm:	$(DISTDIR).tar.gz
	rpmbuild -ta $(DISTDIR).tar.gz
