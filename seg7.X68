PRINT_7SEG

*   GET RANDOM COLOR
    MOVE.L  #29297,d2
    JSR     RANDOM_COLOR
*   SET PEN COLOR
    MOVEQ   #80,d0
    TRAP    #15
*   SET FILL COLOR
    MOVEQ   #81,d0
    TRAP    #15
    
*   GET 100's place VALUE
    MOVE.L  score,d5
    DIVU    #100,d5
    AND.L   #$FFFF,d5
    MOVE.L  d5,a1
    
    MOVE.L  #SEG7_X,d5
    MOVE.L  #SEG7_Y,d6
    JSR     DRAW_SEGMENT
    
*   GET 10's place VALUE
    MOVE.L  score,d5
    DIVU    #100,d5
    CLR.W   d5
    SWAP.W  d5
    DIVU    #10,d5
    AND.L   #$FFFF,d5
    MOVE.L  d5,a1

    MOVE.L  #(SEG7_X+SEG7_LENGTH+SEG7_SPACING),d5
    MOVE.L  #(SEG7_Y),d6
    JSR     DRAW_SEGMENT
    
*   GET 1's place VALUE
    MOVE.L  score,d5
    DIVU    #10,d5
    CLR.W   d5
    SWAP.W  d5
    MOVE.L  d5,a1
    
    MOVE.L  #(SEG7_X+SEG7_LENGTH<<1+SEG7_SPACING<<1),d5
    MOVE.L  #(SEG7_Y),d6
    JSR     DRAW_SEGMENT
    
    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

*                    N7654321
SEG_NUM     DC.B    %00111111   ;0
            DC.B    %00110000   ;1
            DC.B    %01101101   ;2
            DC.B    %01111001   ;3
            DC.B    %01110010   ;4
            DC.B    %01011011   ;5
            DC.B    %01011111   ;6
            DC.B    %00110001   ;7
            DC.B    %01111111   ;8
            DC.B    %01111011   ;9

*       7-SEGMENT
*
*        1111111
*       2       6
*       2       6
*       2       6
*        7777777
*       3       5
*       3       5
*       3       5
*        4444444

*   EVERY SEGMENT IS SEPERATE AND NOT ALL IN ONE LOOP
*   IN ORDER TO MINIMIZE POSITION ASSIGNMENTS
*   FOR EACH SEPERATE SEGMENT
*   AS EVERY SEGMENT IS NOT REQUIRED TO UPDATE ALL POSITION VALUES
*   SEGMENTS ARE BEING ASSIGNED AND DRAWN IN AN OPTIMIZED WAY AND NOT IN A SEQUENCE
DRAW_SEGMENT

    MOVE.L  #88,d0

    LEA     SEG_NUM,a0
    CLR.L   d7
    MOVE.B  (a0,a1),d7
    MOVE.L  d7,a1
    
*   RECTANGLE COORDINATES
*   d1 : LEFT   / X-MIN
*   d2 : UP     / Y-MIN
*   d3 : RIGHT  / X-MAX
*   d4 : BOTTOM / Y-MAX

    ;SEGMENT 7
    MOVE.W  d5,d1
    MOVE.W  d5,d3
    ADD.W  #(SEG7_LENGTH),d3
    MOVE.W  d6,d2
    ADD.W  #(SEG7_THIC+SEG7_LENGTH),d2
    MOVE.W  d6,d4
    ADD.W  #(SEG7_THIC<<1+SEG7_LENGTH),d4
    
    MOVE.L  a1,d7
    AND.B   #1<<6,d7
    BEQ     SKIP7
    
    TRAP    #15
SKIP7
   
    ;SEGMENT 4
    MOVE.W  d6,d2
    ADD.W  #(SEG7_THIC<<1+SEG7_LENGTH<<1),d2
    MOVE.W  d6,d4
    ADD.W  #(SEG7_THIC<<1+SEG7_LENGTH<<1+SEG7_THIC),d4
    
    MOVE.L  a1,d7
    AND.B   #1<<3,d7
    BEQ     SKIP4
    
    TRAP    #15
SKIP4
    
    ;SEGMENT 1
    MOVE.W  d6,d2
    MOVE.W  d6,d4
    ADD.W  #(SEG7_THIC),d4
    
    MOVE.L  a1,d7
    AND.B   #1,d7
    BEQ     SKIP1
    
    TRAP    #15
SKIP1
    
    ;SEGMENT 2
    MOVE.W  d5,d3
    ADD.W  #(SEG7_THIC),d3
    MOVE.W  d6,d4
    ADD.W  #(SEG7_THIC<<1+SEG7_LENGTH),d4
    
    MOVE.L  a1,d7
    AND.B   #1<<1,d7
    BEQ     SKIP2
    
    TRAP    #15
SKIP2
    
    ;SEGMENT 6
    MOVE.W  d5,d1
    ADD.W  #(SEG7_LENGTH-SEG7_THIC),d1
    MOVE.W  d5,d3
    ADD.W  #(SEG7_LENGTH),d3
    
    MOVE.L  a1,d7
    AND.B   #1<<5,d7
    BEQ     SKIP6
    
    TRAP    #15
SKIP6
    
    ;SEGMENT 5
    MOVE.W  d6,d2
    ADD.W  #(SEG7_THIC+SEG7_LENGTH),d2
    MOVE.W  d6,d4
    ADD.W  #(SEG7_THIC<<1+SEG7_LENGTH<<1+SEG7_THIC),d4
    
    MOVE.L  a1,d7
    AND.B   #1<<4,d7
    BEQ     SKIP5
    
    TRAP    #15
SKIP5
    
    ;SEGMENT 3
    MOVE.W  d5,d1
    MOVE.W  d5,d3
    ADD.W  #(SEG7_THIC),d3
    
    MOVE.L  a1,d7
    AND.B   #1<<2,d7
    BEQ     SKIP3
    
    TRAP    #15
SKIP3

    RTS

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
