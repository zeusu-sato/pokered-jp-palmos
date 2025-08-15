VBlank::

	push af
	push bc
	push de
	push hl

	ld a, [H_LOADEDROMBANK]
	ld [wVBlankSavedROMBank], a

	ld a, [hSCX]
	ld [rSCX], a
	ld a, [hSCY]
	ld [rSCY], a

	ld a, [wDisableVBlankWYUpdate]
	and a
	jr nz, .ok
	ld a, [hWY]
	ld [rWY], a
.ok

	call AutoBgMapTransfer
	call VBlankCopyBgMap
	call RedrawRowOrColumn
	call VBlankCopy
	call VBlankCopyDouble
	call UpdateMovingBgTiles
	call $ff80 ; hOAMDMA
	ld a, BANK(PrepareOAMData)
	ld [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a
	call PrepareOAMData

	; VBlank-sensitive operations end.

	call Random

	ld a, [H_VBLANKOCCURRED]
	and a
	jr z, .skipZeroing
	xor a
	ld [H_VBLANKOCCURRED], a

.skipZeroing
	ld a, [H_FRAMECOUNTER]
	and a
	jr z, .skipDec
	dec a
	ld [H_FRAMECOUNTER], a

.skipDec
	call FadeOutAudio

	ld a, [wAudioROMBank] ; music ROM bank
	ld [H_LOADEDROMBANK], a
	ld [MBC1RomBank], a

	cp BANK(Audio1_UpdateMusic)
	jr nz, .checkForAudio2
.audio1
	call Audio1_UpdateMusic
	jr .afterMusic
.checkForAudio2
	cp BANK(Audio2_UpdateMusic)
	jr nz, .audio3
.audio2
	call Music_DoLowHealthAlarm
	call Audio2_UpdateMusic
	jr .afterMusic
.audio3
	call Audio3_UpdateMusic
.afterMusic

	callba TrackPlayTime ; keep track of time played

	ld a, [wVBlankSavedROMBank]
        ld [H_LOADEDROMBANK], a
        ld [MBC1RomBank], a

IF DEF(RUNTIME_MASK)
        ldh a, [hJoyInput]
        ld b, a
        and SELECT | D_LEFT
        cp SELECT | D_LEFT
        jr z, .ch1
        ld a, b
        and SELECT | D_RIGHT
        cp SELECT | D_RIGHT
        jr z, .ch2
        ld a, b
        and SELECT | D_UP
        cp SELECT | D_UP
        jr z, .ch3
        ld a, b
        and SELECT | D_DOWN
        cp SELECT | D_DOWN
        jr z, .ch4
        ld a, b
        and SELECT | START
        cp SELECT | START
        jr z, .mute
        ld a, b
        and SELECT | A_BUTTON
        cp SELECT | A_BUTTON
        jr z, .all
        jr .after
.ch1
        ld a, $11
        jr .set
.ch2
        ld a, $22
        jr .set
.ch3
        ld a, $44
        jr .set
.ch4
        ld a, $88
        jr .set
.mute
        xor a
        jr .set
.all
        ld a, $ff
.set
        call ForceChannelMask
.after
ENDC

IF DEF(RUNTIME_MASK)
        ; ForceChannelMask called only on change
ELSE
        call ForceChannelMask
ENDC
IF DEF(STRICT_MUTE)
IF !DEF(RUNTIME_MASK)
        call EnforceStrictMute
ENDC
ENDC

        pop hl
        pop de
        pop bc
        pop af
        reti


DelayFrame::
; Wait for the next vblank interrupt.
; As a bonus, this saves battery.

NOT_VBLANKED EQU 1

	ld a, NOT_VBLANKED
	ld [H_VBLANKOCCURRED], a
.halt
	halt
	ld a, [H_VBLANKOCCURRED]
	and a
	jr nz, .halt
	ret
