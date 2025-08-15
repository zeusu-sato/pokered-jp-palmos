SECTION "MaskHRAM", HRAM[$FFF4]
hCH_MASK:: ds 1

IF DEF(CH_MIXING)
    ; 互換のため空
ENDC

SECTION "ChannelMaskRoutine", ROM0
ForceChannelMask::
IF DEF(RUNTIME_MASK)
    ; a = new channel mask
IF DEF(SOFT_PAN)
    call SetChannelMaskSmooth
    ld  [hCH_MASK], a
ELSE
    ldh [rNR51], a
    ld  [hCH_MASK], a
ENDC
    ret
ELSE
    ld  a, [hCH_MASK]
    ldh [rNR51], a
    ret
ENDC

; EnforceStrictMute: 非許可chの音量/DACを毎フレーム落とす
EnforceStrictMute::
IF !ALLOW_CH1
    xor a        ; a=0
    ldh [rNR12], a   ; CH1 volume=0
ENDC
IF !ALLOW_CH3
    xor a
    ldh [rNR30], a   ; CH3 DAC off
ENDC
IF !ALLOW_CH4
    xor a
    ldh [rNR42], a   ; CH4 volume=0
ENDC
    ret
