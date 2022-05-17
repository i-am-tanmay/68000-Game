GET_MOUSEPOS

    ;SET WRITE POSITION
    MOVE.L  #11,d0
    CLR.L   d1
    TRAP    #15
    
    ;READ MOUSE
    MOVE.L  #61,d0
    TRAP    #15
    AND.L   #$FFFF,d1

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

INPUT_WAITFORRESET

*   DISPLAY RESET TEXT    *
    ;SET FILL COLOR
    MOVEQ   #81,d0
    MOVE.L  #0,d1
    TRAP    #15
    ;SET FONT PROPERTIES
    MOVE.L  #29297,d2
    JSR     RANDOM_COLOR
    MOVEQ   #21,d0
    MOVE.L  #0,d2
    TRAP    #15
    
*   PRINT RESET TEXT
    MOVEQ   #11,d0
    MOVE.L  #((40-((t_gameoverreset_end-t_gameoverreset)/2) + 0)<<8 + 18),d1
    TRAP    #15
    MOVEQ   #14,d0
    LEA     t_gameoverreset,a1
    TRAP    #15

    JSR     SWAP_BUFFER

*   CHECK IF SPACEBAR IS PRESSED
    MOVEQ   #19,d0
    MOVEQ   #$20,d1
    TRAP    #15
    
    CMP.B   #$FF,d1
    BNE     INPUT_WAITFORRESET
    
    RTS

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
