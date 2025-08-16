				PYTHON := python
		MD5 := md5sum -c --quiet

RGBASMFLAGS += $(if $(CH2_ONLY),-DCH_MASK=0x22,)
RGBASMFLAGS += $(if $(CH_MASK),-DCH_MASK=$(CH_MASK),)
RGBASMFLAGS += $(if $(STRICT_MUTE),-DSTRICT_MUTE,)
RGBASMFLAGS += $(if $(RUNTIME_MASK),-DRUNTIME_MASK,)
RGBASMFLAGS += $(if $(SOFT_PAN),-DSOFT_PAN,)
RGBASMFLAGS += $(if $(SHOW_MASK),-DSHOW_MASK,)

2bpp     := $(PYTHON) extras/pokemontools/gfx.py 2bpp
1bpp     := $(PYTHON) extras/pokemontools/gfx.py 1bpp
pic      := $(PYTHON) extras/pokemontools/pic.py compress

pokeblue_obj := audio_blue.o main_blue.o wram_blue.o

.SUFFIXES:
.SUFFIXES: .asm .o .gbc .png .2bpp .1bpp .pic
.SECONDEXPANSION:
# Suppress annoying intermediate file deletion messages.
.PRECIOUS: %.2bpp
.PHONY: all clean red blue compare

roms := pokered.gbc pokeblue.gbc

all: red
red: pokered.gbc
blue: pokeblue.gbc

# For contributors to make sure a change didn't affect the contents of the rom.
compare: red
	@$(MD5) roms.md5

clean:
	rm -f $(roms) $(RED_OBJS) $(pokeblue_obj) $(roms:.gbc=.sym)
	find . \( -iname '*.1bpp' -o -iname '*.2bpp' -o -iname '*.pic' \) -exec rm {} +

%.asm: ;


$(pokeblue_obj): %_blue.o: %.asm
	rgbasm $(RGBASMFLAGS) -D_BLUE -o $@ $<

pokered_opt  = -sv -k 01 -l 0x33 -m 0x03 -p 0 -r 03 -t "POKEMON RED"
pokeblue_opt = -sv -k 01 -l 0x33 -m 0x03 -p 0 -r 03 -t "POKEMON BLUE"
	
%.gbc: $$(%_obj)
	rgblink -n $*.sym -o $@ $^
		rgbfix $($*_opt) $@

%.png:  ;
	%.2bpp: %.png  ; @$(2bpp) $<
%.1bpp: %.png  ; @$(1bpp) $<
%.pic:  %.2bpp ; @$(pic)  $<

# 出力名とツールの既定
ROM      ?= pokejp.gbc
OUTDIR   ?= build
EMU      ?= sameboy
GB2PDB   ?= gb2pdb.py   # 任意の .gb→.pdb 変換スクリプト/ツールのパス
PDB_TITLE?= PokeJP CHmask
ZIPNAME  ?= pokejp_chmask.zip

$(OUTDIR):
	mkdir -p $(OUTDIR)

md5: $(ROM) | $(OUTDIR)
	md5sum $(ROM) | tee $(OUTDIR)/$(ROM).md5
	cp $(OUTDIR)/$(ROM).md5 $(OUTDIR)/.md5

run: $(ROM)
	@command -v $(EMU) >/dev/null 2>&1 || { echo "エミュ $(EMU) が見つかりません"; exit 1; }
	$(EMU) $(ROM)

# .gb/.gbc → .pdb 変換（Liberty用）
pdb: $(ROM) | $(OUTDIR)
	@command -v python3 >/dev/null 2>&1 || { echo "python3 が必要です"; exit 1; }
	@test -f $(GB2PDB) || { echo "$(GB2PDB) が見つかりません（環境変数で上書き可）"; exit 1; }
	python3 $(GB2PDB) --in $(ROM) --out $(OUTDIR)/$(ROM:.gbc=.pdb) --title "$(PDB_TITLE)"
	cp $(OUTDIR)/$(ROM:.gbc=.pdb) $(OUTDIR)/.pdb

zip: pdb md5 | $(OUTDIR)
	@which zip >/dev/null || { echo "zip コマンドが必要です"; exit 1; }
	rm -f $(OUTDIR)/$(ZIPNAME)
	zip -j $(OUTDIR)/$(ZIPNAME) $(ROM) build/.pdb build/.md5 README.md
	@echo "=> $(OUTDIR)/$(ZIPNAME)"

RED_OBJS := audio_red.o main_red.o wram_red.o

pokered.gbc: $(RED_OBJS)
	rgblink -n pokered.sym -o pokered.gbc $(RED_OBJS)
	rgbfix -v -p 0 pokered.gbc

audio_red.o: audio.asm
	rgbasm $(RGBASMFLAGS) -D_RED -o $@ $<

main_red.o: main.asm
	rgbasm $(RGBASMFLAGS) -D_RED -o $@ $<

wram_red.o: wram.asm
	rgbasm $(RGBASMFLAGS) -D_RED -o $@ $<
