IF DEF(SHOW_MASK)
SECTION "ShowMask", ROM0

HexDigits: db "0123456789ABCDEF"

ShowMaskHUD::
    ; a = hCH_MASK
    ldh  a,[hCH_MASK]
    ld   b,a
    ; 上位4bit
    swap a
    and  $0F
    ld   hl,HexDigits
    add  l
    ld   l,a
    jr   nc,+
    inc  h
+   ld   a,[hl]
    ; BG左上(0,0)へ
    ld   hl,$9800
    ld   [hl],a
    ; 下位4bit
    ld   a,b
    and  $0F
    ld   hl,HexDigits
    add  l
    ld   l,a
    jr   nc,+
    inc  h
+   ld   a,[hl]
    ld   hl,$9801
    ld   [hl],a
    ret
ENDC
