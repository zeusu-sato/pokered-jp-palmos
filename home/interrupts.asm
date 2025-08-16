IF DEF(CH_MASK) || DEF(STRICT_MUTE) || DEF(RUNTIME_MASK) || DEF(SOFT_PAN) || DEF(SHOW_MASK)
    INCLUDE "engine/channel_mask.inc"
    INCLUDE "engine/soft_pan.asm"
    INCLUDE "engine/show_mask.asm"
    INCLUDE "engine/ch2_only.asm"
ENDC
