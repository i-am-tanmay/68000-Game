*   UPDATE PLAYER X-POSITION & OBSTACLE-SPEED
UPDATE_PLAYER

*   GET POSITION FROM MOUSE
    JSR     GET_MOUSEPOS
    MOVE.L  d1,d0
*   THIS POSITION IS FOR CENTER OF PLAYER SPRITE
*   MOVE IT TO LEFT
    SUBI.L  #PLAYER_POS_X_OFFSET,d0
    
    CMP.L   #PLAYAREA_MIN,d0                            ; CHECK IF WITHIN PLAY-AREA
    BGE     MINLIMITSET
    
    MOVE.L  #PLAYAREA_MIN,d0
    
MINLIMITSET

    CMP.L   #(PLAYAREA_MAX-PLAYER_POS_X_OFFSET<<1),d0   ; CHECK IF WITHIN PLAY-AREA
    BLE     MAXLIMITSET
    
    MOVE.L  #(PLAYAREA_MAX-PLAYER_POS_X_OFFSET<<1),d0
    
MAXLIMITSET

*   SET PLAYER POSITION
    MOVE.L  d0,player_x
    
*   UPDATE SPEED
    MOVE.L  player_speed,d0
    ADD.L   #PLAYER_ACCEL,d0
    CMP.L   #PLAYER_SPEED_MAX,d0    ; CHECK IF SPEED WITHIN MAX-LIMIT
    BLE     SPEEDLIMITSET
    MOVE.L  #PLAYER_SPEED_MAX,d0
SPEEDLIMITSET
    MOVE.L  d0,player_speed

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

*   DRAW PLAYER USING PIXEL-BY-PIXEL DATA
*       > EVERY PIXEL IS STORED AS 0 or 1
*           > 0 means don't draw
*           > 1 means draw
*       > OBSTACLE SIZE IS 40x55
*       > 40-bits = 5 Bytes, SO EVERY ROW IS 5 BYTES
*       > SO EVERY BYTE's FIRST BIT IS CHECKED AND SHIFTED TO DRAW OR NOT-DRAW PIXEL
*   COLLISION CHECK : EVERY PIXEL IS CHECKED FOR COLOR
*       > IF COLOR IS BLACK OR WHITE : NO COLLISION
*       > IF COLOR IS ANYTHING ELSE  : COLLIDED
DRAW_PLAYER

*   SET PEN COLOR
    MOVEQ   #80,d0
    MOVE.L  #COLOR_PLAYER,d1
    TRAP    #15
    MOVEQ   #81,d0
    TRAP    #15

*   GET PLAYER-SPRITE ARRAY START
    LEA     PLAYER_SPRITE,a2
    
*   SET PLAYER Y-POS START
    MOVEQ   #PLAYER_POS_Y,d2
    
    CLR.L   d3
    CLR.L   d4
    
*   d1 : PLAYER DRAW X-POS START
*   d2 : PLAYER DRAW Y-POS START
*   d7 : 5-BYTES ITERATOR FOR ROW
DRAW_PLAYER_Y

    MOVE.L  player_x,d1
    
    MOVEQ   #5,d7
DRAW_PLAYER_ROW

    JSR     CHECK_DRAW_PIXEL

    SUBI.L  #1,d7
    BNE     DRAW_PLAYER_ROW


    ADD.W   #1,d2
    CMP.W   #PLAYER_POS_Y_MAX,d2
    BNE     DRAW_PLAYER_Y
        
    RTS
    
******************    

*   d3 : GET CURRENT BYTE PIXEL-DATA
*   d4 : CURRENT PIXEL VALUE CHECKER (first bit of d3)
CHECK_DRAW_PIXEL

*   GET CURRENT ROW PIXEL DATA
    MOVE.B  (a2)+,d3

*   INIT OBSTACLE X-POS
*   WE START TO PRINT FROM RIGHT SIDE AS PIXEL DATA BIT-by-BIT IS PROCESSED FROM THE RIGHT, SO WE READ FROM THE RIGHT    
    MOVE.L  d1,d5
    ADD.W   #7,d1
    
CHECK_DRAW_PIXEL_LOOP
    
*   SHIFT AND CHECK FIRST BIT to DRAW OR NOT-DRAW
    MOVE.B  d3,d4
    LSR.B   #1,d3
    AND.B   #1,d4
    BEQ     SKIPPIXELDRAW
    JSR     PIXEL_DRAW_AND_CHECK_COLLISION
SKIPPIXELDRAW
    SUBI.W  #1,d1
    CMP.W   d5,d1                   ; CHECK IF BYTE-COMPLETE
    BGE     CHECK_DRAW_PIXEL_LOOP
    
    ADD.W   #7,d1                   ; PUT COUNTER BACK TO END OF CURRENT BYTE

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

PIXEL_DRAW_AND_CHECK_COLLISION
    
*   GET CURRENT PIXEL COLOR
    MOVEQ   #83,d0
    TRAP    #15
    
    CMP.L   #COLOR_PLAYER,d0    ; CHECK IF COLOR NOT OF PLAYER
    BEQ     DRAW_PIXEL
    CMP.L   #0,d0               ; CHECK IF COLOR NOT BACKGROUND
    BEQ     DRAW_PIXEL
    MOVE.B  #1,gameover         ; GAME OVER IF COLLIDED
    
DRAW_PIXEL
    MOVEQ   #82,d0
    TRAP    #15
    
    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

PLAYER_SPRITE   DC.L	$30
				DC.L	$0
				DC.L	$7C000000
				DC.L	$7C0000
				DC.L	$3E00
				DC.L	$1F
				DC.L	$3E00
				DC.L	$1F8001FF
				DC.L	$1FC003
				DC.L	$FF801FC0
				DC.L	$1FF803F
				DC.L	$800007C0
				DC.L	$3F000007
				DC.L	$C07E0000
				DC.L	$7E0FE00
				DC.L	$7E1FC
				DC.L	$3E3
				DC.L	$FC000003
				DC.L	$F3F80000
				DC.L	$1FFF800
				DC.L	$1FFF0
				DC.L	$1FF
				DC.L	$E0000001
				DC.L	$FFE00000
				DC.L	$1FFC000
				DC.L	$FF80
				DC.L	$FF
				DC.L	$C0000000
				DC.L	$FFF00000
				DC.L	$7FF800
				DC.L	$7FFC
				DC.L	$3F
				DC.L	$FF000400
				DC.L	$3FFF8006
				DC.L	$1FFFC0
				DC.L	$6000FFF
				DC.L	$C0060007
				DC.L	$FFE08700
				DC.L	$7FFE0E3
				DC.L	$8007FFE0
				DC.L	$F1E007FF
				DC.L	$E078F803
				DC.L	$FFE01E7C
				DC.L	$3FFE00F
				DC.L	$3F03FFF0
				DC.L	$7FFC7FF
				DC.L	$FC03FFFF
				DC.L	$FFFE00FF
				DC.L	$FFFFFE00
				DC.L	$7FFFFFFE
				DC.L	$1FFFFF
				DC.L	$FE0003FF
				DC.L	$FFFE0003
				DC.L	$FFFFFC00
				DC.L	$FFFFFFC
				DC.L	$10FFFF
				DC.L	$FC00207F
				DC.L	$FFF80040
				DC.L	$7FFFF000
				DC.L	$427FFFE0
				DC.L	$40FFFF
				DC.L	$E00061FF
				DC.L	$FFC0007F
				DC.L	$F9FFC000
				DC.L	$7FF03F80
				DC.L	$3FE03F
				DC.L	$1FE0
				DC.L	$3000000F
				DC.L	$800000
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
