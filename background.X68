*   PRINT BACKGROUND BITMAP IMAGE
BG_PRINT

*   a0 : BG-FILE ADDRESS
*   d0 : (TRAP CODES)
*   d1 : (DRAW PIXEL) X-pos
*   d2 : (DRAW PIXEL) Y-pos
*   d6 : IMAGE Y (MAX to 0)
*   d7 : IMAGE X (0 to MAX)

    CLR.L   d7
    MOVE.L  #SCREEN_HEIGHT,d6
    
    LEA     bg_file,a0
    ADD.L   #BMP_COLORSTART,a0

BG_PRINT_LOOP

*   SET PEN COLOR
    MOVE.L  #80,d0
    MOVE.L  (a0)+,d1
    LSR.L   #8,d1
    TRAP    #15
    
*   DRAW PIXEL
    MOVE.L  #82,d0
    MOVE.W  d7,d1       ; X pos / width
    MOVE.W  d6,d2       ; Y pos / height
    TRAP    #15
    
    ADDI.L  #1,d7
    CMP.L   #SCREEN_WIDTH,d7    ; CHECK IF ROW PRINTED COMPLETELY
    BLT     BG_PRINT_LOOP

    CLR.L   d7
    
    SUBI.L  #1,d6
    BNE     BG_PRINT_LOOP       ; CHECK IF ALL ROWS PRINTED
    

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

*   CLEAR BITMAP BACKGROUND BEHIND 7-SEGMENT LED
BG_CLEARRECT

*   a0 : BG-FILE ADDRESS
*   d0 : (TRAP CODES)
*   d1 : (DRAW PIXEL) X-pos
*   d2 : (DRAW PIXEL) Y-pos
*   d6 : 7-SEGMENT Pos Y (MAX to 0)
*   d7 : 7-SEGMENT Pos X (0 to MAX)

    MOVE.L  #SEG7_X,d7
    MOVE.L  #SEG7_Y_MAX,d6
    
    LEA     bg_file,a0
    ADD.L   #BMP_COLORSTART,a0
    
*   SKIP TO PRINT-START POSITION IN BMP FILE
    MOVE.L  #SCREEN_HEIGHT,d5
    SUB.L   #SEG7_Y_MAX,d5
BG_INITPOS
    ADD.L   #SCREEN_WIDTH<<2,a0
    SUBI.L  #1,d5
    BNE     BG_INITPOS
    
    ADD.L   #SEG7_X<<2,a0

*   START PRINTING BITMAP-PIXELS
BG_CLEAR_LOOP

*   SET PEN COLOR
    MOVE.L  #80,d0
    MOVE.L  (a0)+,d1
    LSR.L   #8,d1
    TRAP    #15
    
*   DRAW PIXEL
    MOVE.L  #82,d0
    MOVE.W  d7,d1       ; X pos / width
    MOVE.W  d6,d2       ; Y pos / height
    TRAP    #15
    
    ADDI.L  #1,d7
    CMP.L   #SEG7_X_MAX,d7  ; CHECK IF ROW PRINTED COMPLETELY
    BLE     BG_CLEAR_LOOP
    
*   MOVE POSITION IN BITMAP-FILE TO NEXT (UP) ROW
    MOVE.L  #SEG7_X,d7
    ADD.L   #SCREEN_WIDTH<<2,a0
    SUB.L   #(SEG7_X_MAX-SEG7_X+1)<<2,a0
    
    SUBI.L  #1,d6
    CMP.L   #SEG7_Y,d6      ; CHECK IF ALL ROWS PRINTED
    BGE     BG_CLEAR_LOOP

    RTS

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
