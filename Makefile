SRCDIR = $(shell pwd)

# where to install
PREFIX = $(CAMLLIB_INSTALL)
LIBDIR = $(PREFIX)/lib

CSLC = ocamlc.opt
CSLOPT = ocamlopt.opt
CSLDEP = ocamldep

OCAMLDOC = ocamldoc.opt

CSLFLAGS = -g
CSLOPTFLAGS = -inline 20

FILES = print sette mappe hashhe \
	setteI mappeI hashheI hashheIB \
	dMappe dHashhe \
	setList multiSetList \
	ilist sGraph sHGraph symbol union \
	statistic time rational

SRC = $(FILES:%=%.mli) $(FILES:%=%.ml)

INT = $(FILES:%=%.cmi)
OBJS = $(FILES:%=%.cmo)
OBJSx = $(FILES:%=%.cmx)

LIB_TOINSTALL = $(INT) $(FILES:%=%.mli) camllib.cma
LIB_TOINSTALLx = $(OBJSx) camllib.a camllib.cmxa

all: $(LIB_TOINSTALL)
opt: $(INT) $(OBJSx) camllib.cmxa

camllib.cma: $(OBJS)
	$(CSLC)	-a $(CSLFLAGS) $^ -o $@

camllib.cmxa: $(OBJSx)
	$(CSLOPT) -a $(CSLOPTFLAGS) $^ -o $@

install:
	cp -f $(LIB_TOINSTALL) $(LIB_TOINSTALLx) $(LIBDIR)
clean:
	/bin/rm -f *.cm[ioxa] *.o *.a *.cmxa *.html *.ps *.pdf *.dvi *.out
	/bin/rm -f *.aux *.bbl *.blg *.dvi *.pdf *.log *.toc *.idx *.ilg *.ind ocamldoc*.tex ocamldoc.sty
	/bin/rm -fr html
distclean: clean
	(cd $(LIBDIR); rm -f $(LIB_TOINSTALL) $(LIB_TOINSTALLx))

wc: $(SRC)
	wc $^

tar: $(SRC) Makefile camllib.tex camllib.pdf README 
	@echo "*** Archiving source files in ~/camllib.tgz ***"
	(cd ..; tar zcf $(HOME)/camllib.tgz $(^:%=camllib/%))
	@echo "*** Files archived in ~/camllib.tgz ***"

# TEX rules
.PHONY: camllib.dvi camllib.pdf html

camllib.pdf: camllib.dvi
	dvipdf camllib.dvi camllib.pdf

camllib.dvi: $(INT) $(FILES:%=%.mli) $(FILES:%=%.ml)
	ocamldoc.opt -latextitle 1,chapter -latextitle 2,section -latextitle 3,subsection -latextitle 4,subsubsection -latextitle 5,paragraph -noheader -notrailer -latex -o ocamldoc.tex $(FILES:%=%.mli) $(FILES:%=%.ml)
	latex camllib
	makeindex camllib
	latex camllib
	latex camllib

camllibcode.dvi: $(INT) $(FILES:%=%.mli) $(FILES:%=%.ml)
	ocamldoc.opt -latextitle 1,chapter -latextitle 2,section -latextitle 3,subsection -latextitle 4,subsubsection -latextitle 5,paragraph -noheader -notrailer -inv-merge-ml-mli -keep-code -latex -o ocamldoc.tex $(FILES:%=%.mli)  $(FILES:%=%.ml)
	latex camllib
	makeindex camllib
	latex camllib
	latex camllib

html: $(INT) $(FILES:%=%.mli) $(FILES:%=%.ml)
	mkdir -p html
	$(OCAMLDOC) -html -d html -colorize-code $(FILES:%=%.ml) $(FILES:%=%.mli)

dot: $(INT) $(FILES:%=%.mli)
	$(OCAMLDOC) -dot $(FILES:%=%.mli)
	dot -Tps ocamldoc.out >ocamldoc.ps

.SUFFIXES: .ml .mli .cmo .cmi .cmx .mll .mly .dvi .tex .ps

%.cmi: %.mli
	$(CSLC) $(CSLFLAGS) -c $(SRCDIR)/$<
%.cmo: %.ml %.cmi
	$(CSLC) $(CSLFLAGS) -c $(SRCDIR)/$<
%.cmx: %.ml %.cmi
	$(CSLOPT) $(CSLOPTFLAGS) -c $(SRCDIR)/$<

%.ps: %.dvi
	/usr/bin/dvips $^ -o

%.pdf: %.ps
	ps2pdf $^

depend: $(SRC)
	$(CSLDEP) $^ > Makefile.depend

Makefile.depend:
	touch Makefile.depend

include Makefile.depend
