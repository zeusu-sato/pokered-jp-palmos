IF DEF(CH2_ONLY)
ForceCH2Only::
    ld a,$22
    ldh [rNR51],a
    ret
ENDC
