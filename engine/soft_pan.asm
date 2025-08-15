IF DEF(SOFT_PAN)
SECTION "SoftPan", ROM0

; SetChannelMaskSmooth: smoothly update NR51 by muting master volume
; Temporarily zeroes NR50, writes new mask to NR51, then restores volume
; a = new channel mask
SetChannelMaskSmooth::
    push af
    ldh  a,[rNR50]      ; FF24 Master Vol
    ld   b,a            ; Save master volume
    and  %10001000      ; Keep Vin bits, zero left/right volumes
    ldh  [rNR50],a      ; Temporarily mute
    pop  af             ; New mask
    ldh  [rNR51],a      ; FF25 update
    ldh  a,[rNR50]
    ld   a,b            ; Restore master volume
    ldh  [rNR50],a
    ret
ENDC

