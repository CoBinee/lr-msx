#! make -f
#
# makefile - start
#


# option
#

# directory
#

# source file directory
SRCDIR			=	sources

# include file directory
INCDIR			=	sources

# object file directory
OBJDIR			=	objects

# binary file directory
BINDIR			=	bin

# output file directory
OUTDIR			=	rom

# tool directory
TOOLDIR			=	tools

# vpath search directories
VPATH			=	$(SRCDIR):$(INCDIR):$(OBJDIR):$(BINDIR)

# assembler
#

# assembler command
AS				=	sdasz80

# assembler flags
ASFLAGS			=	-ls -I$(INCDIR) -I.

# c compiler
#

# c compiler command
CC				=	sdcc

# c compiler flags
CFLAGS			=	-mz80 --opt-code-speed -I$(INCDIR) -I.

# linker
#

# linker command
LD				=	sdcc

# linker flags
LDFLAGS			=	-mz80 --no-std-crt0 --nostdinc --nostdlib --code-loc 0x4020 --data-loc 0xc000

# suffix rules
#
.SUFFIXES:			.s .c .rel

# assembler source suffix
.s.rel:
	$(AS) $(ASFLAGS) -o $(OBJDIR)/$@ $<

# c source suffix
.c.rel:
	$(CC) $(CFLAGS) -o $(OBJDIR)/$@ -c $<

# project files
#

# target name
TARGET			=	LR

# assembler source files
ASSRCS			=	crt0.s \
					main.s System.s \
					Sound.s \
					App.s \
					Title.s \
					Game.s Player.s Enemy.s Treasure.s Back.s Start.s Over.s Clear.s \
					rtable.s \
					pattern.s

# c source files
CSRCS			=	

# object files
OBJS			=	$(ASSRCS:.s=.rel) $(CSRCS:.c=.rel)


# build project target
#
$(TARGET).com:		$(OBJS)
	$(LD) $(LDFLAGS) -o $(BINDIR)/$(TARGET).ihx $(foreach file,$(OBJS),$(OBJDIR)/$(file))
	$(TOOLDIR)/ihx2rom32k -o $(OUTDIR)/$(TARGET).ROM $(BINDIR)/$(TARGET).ihx

# clean project
#
clean:
	@rm -f $(OBJDIR)/*
	@rm -f $(BINDIR)/*
##	@rm -f makefile.depend

# build depend file
#
depend:
##	ifneq ($(strip $(CSRCS)),)
##		$(CC) $(CFLAGS) -MM $(foreach file,$(CSRCS),$(SRCDIR)/$(file)) > makefile.depend
##	endif

# build resource file
#
resource:
	@$(TOOLDIR)/bin2s -n patternTable -o sources/pattern.s resources/pattern.chr
	@$(TOOLDIR)/rtable -r 96 -l 256 -x 128 -y 96 -n rTable -o sources/rtable.s

# build tools
#
tool:
	@gcc -o $(TOOLDIR)/bin2s $(TOOLDIR)/bin2s.cpp
	@gcc -o $(TOOLDIR)/ihx2bload $(TOOLDIR)/ihx2bload.cpp
	@gcc -o $(TOOLDIR)/ihx2rom32k $(TOOLDIR)/ihx2rom32k.cpp
	@gcc -o $(TOOLDIR)/rtable $(TOOLDIR)/rtable.cpp

# phony targets
#
.PHONY:				clean depend

# include depend file
#
-include makefile.depend


# makefile - end
