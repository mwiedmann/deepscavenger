.ifndef WAIT_S
WAIT_S = 1

wc: .byte 0
wc_temp: .byte 0

; wait_count:
;     lda wc
;     sta wc_temp
; @next:
;     cmp #0
;     beq @done
; @waiting:
;     lda waitflag
;     cmp #0
;     beq @waiting
;     lda #0
;     sta waitflag
;     lda wc_temp
;     sec
;     sbc #1
;     sta wc_temp
;     bra @next
; @done:
;     rts

last_time: .byte 0

wait_count:
@start:
    lda #0
    sta wc_temp
@loop:
    jsr RDTIM
    cmp last_time ; Compare current jiffy in A to previous jiffy in GAME_TIMER
    beq @loop ; If not different then loop
    sta last_time ; update our timing variable
    lda wc_temp
    inc
    sta wc_temp
    cmp wc
    bne @loop
    rts
    
.endif
