RANDOM_COLOR

*   d2 : SEED
    MOVEQ   #8,d0
    TRAP    #15
    AND.L   #$1FF,d1
    MULU    d2,d1
    AND.L   #$FFFFFF,d1 ; COLOR is 00BBGGRR, so NEED ONLY 3-BYTES

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

RANDOM_POS
    
*   d7 : SEED
*   (a4) current value : SEED
    MOVEQ   #8,d0
    TRAP    #15

    ADD.L   #17,d7
    MULU    d7,d1
    SUB.L   #17,d7
    
    AND.L   #$1FF,d1
    MULU    d5,d1
    
    MOVE.L  (a4),d0
    AND.L   #%11111,d0
    ADDI.L  #1,d0
RAND_ROTATE
    ROL.L   #3,d1
    SWAP.W  d1
    ROL.W   #5,d1
    SUBI.L  #1,d0
    BNE     RAND_ROTATE

    RTS

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
