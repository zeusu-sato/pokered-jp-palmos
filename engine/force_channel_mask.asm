IF DEF(CH_MIXING)
    ; 互換のため空
ENDC

IF !DEF(CH_MASK)
    DEF CH_MASK EQU $22  ; 既定: CH2のみ L/R
ENDC

SECTION "ChannelMaskRoutine", ROM0
ForceChannelMask::
    ld  a, CH_MASK
    ldh [rNR51], a
    ret
