ROOTDIR          := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PRTBUFFILEDIR    := $(ROOTDIR)/protobufFiles
PRTBUFGENDIR     := $(ROOTDIR)/protobufGen
PRTBUFSRCDIR     := $(PRTBUFGENDIR)/src
PRTBUFINCDIR     := $(PRTBUFGENDIR)/include
PRTBUFOBJDIR     := $(ROOTDIR)/build
PRTBUFLIBDIR     := $(ROOTDIR)/lib

PRTBUFFILES     := $(wildcard $(PRTBUFFILEDIR)/*.proto)
PRTBUFSRCFILES  := $(addprefix $(PRTBUFSRCDIR)/, $(notdir $(PRTBUFFILES:.proto=.pb-c.c))) 
PRTBUFINCFILES  := $(addprefix $(PRTBUFINCDIR)/, $(notdir $(PRTBUFFILES:.proto=.pb-c.h)))
PRTBUFOBJFILES  := $(addprefix $(PRTBUFOBJDIR)/, $(notdir $(PRTBUFFILES:.proto=.pb-c.o)))
PRTBUFLIBFILE   := $(PRTBUFLIBDIR)/libNFCGateprtbuf.a

PRTBUFC         := protoc-c
PRTBUFCFLAGS    += --error_format=gcc --c_out=$(PRTBUFFILEDIR) --proto_path=$(PRTBUFFILEDIR)

PRTBUFINCFLAGS  := -I$(INCDIR)
PRTBUFLDFLAGS   := -lprotobuf-c #Included in PRX3-Makefile?

PRTBUFCC	:= gcc
PRTBUFCCFLAGS   := -c -I$(PRTBUFINCDIR)/

PRTBUFAR        := ar
PRTBUFARFLAGS   := rcs



.PHONY: prtbuffiles prtbuftarget  all clean

all:
	mkdir -p $(PRTBUFLIBDIR)
	make prtbuffiles
	make prtbuftarget

prtbuftarget: $(PRTBUFLIBFILE)

$(PRTBUFLIBFILE): $(PRTBUFOBJFILES)
	$(PRTBUFAR) $(PRTBUFARFLAGS) $@ $^  

$(PRTBUFOBJDIR)/%.o: $(PRTBUFSRCDIR)/%.c $(PRTBUFINCDIR)/%.h
	$(PRTBUFCC) $(PRTBUFCCFLAGS) $< -o $@

$(PRTBUFSRCFILES):
	make prtbuffiles

prtbuffiles: $(PRTBUFFILES)
	$(PRTBUFC) $(PRTBUFCFLAGS) $(PRTBUFFILES)
	mkdir -p $(PRTBUFSRCDIR) $(PRTBUFINCDIR) $(PRTBUFOBJDIR)
	mv $(PRTBUFFILEDIR)/*.c	$(PRTBUFSRCDIR)
	mv $(PRTBUFFILEDIR)/*.h	$(PRTBUFINCDIR)

clean:
	rm -f $(PRTBUFLIBFILE) $(PRTBUFSRCFILES) $(PRTBUFINCFILES)
