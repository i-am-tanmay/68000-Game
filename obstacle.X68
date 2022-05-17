*   UPDATE OBSTACLE POSITION
*       > MOVE OBSTACLE UP BY CURRENT SPEED (speed includes acceleration)
*       > RESET OBSTACLE IF OUT-OF-SCREEN
*       > ADD TO SCORE WHEN OBSTACLE IS RESET
UPDATE_OBSTACLES

    MOVE.L  num_obstacles,a0
    LEA     obstacle_pos_y,a6
    MOVE.L  player_speed,d2
    LSR.L   #PLAYER_SPEED_FxPt,d2   ; SHIFT PLAYER SPEED
    LSR.L   #PLAYER_SPEED_FxPt2,d2  ;   TO REMOVE DECIMAL VALUE

*   a0 : CURRENT OBSTACLE ITERATOR (Current-Max-Obstacles to 0)
*   a6 : OBSTACLE Y-POSITION ARRAY
*   d2 : CURRENT SPEED to MOVE POSITION BY
*   d3 : CURRENT OBSTACLE Y-POSITION HOLDER
*   d7 : OBSTACLE-NUM PARAMETER for RESET_OBSTACLE
LOOP_UPDATE_OBSTACLES
    
    MOVE.L  (a6),d3
    SUB.L   d2,d3
    MOVE.L  d3,(a6)+
    CMP.L   #-28,d3             ; CHECK IF OBSTACLE IS OUT-OF-SCREEN
    BGT     DONTRESETOBSTACLE
    
    MOVE.L  num_obstacles,d7
    SUB.L   a0,d7
    JSR     RESET_OBSTACLE
    JSR     UPDATE_SCORE
    
DONTRESETOBSTACLE
    
    SUB.L   #1,a0
    CMP.L   #0,a0               ; CHECK IF ALL ACTIVE OBSTACLES PROCESSED
    BGE     LOOP_UPDATE_OBSTACLES

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

*   DRAW OBSTACLES USING PIXEL-BY-PIXEL DATA
*       > EVERY PIXEL IS STORED AS 0 or 1
*           > 0 means don't draw
*           > 1 means draw
*       > OBSTACLE COLOR IS RANDOM EVERY FRAME
*       > OBSTACLE SIZE IS 32x28
*       > 32-BITS FIT IN A LONG, SO EVERY ROW IS STORED AS 1 LONG
*       > SO EVERY LONG's FIRST BIT IS CHECKED AND SHIFTED TO DRAW OR NOT-DRAW PIXEL
DRAW_OBSTACLES

    MOVE.L  num_obstacles,a0
    LEA     obstacle_pos_x,a5
    LEA     obstacle_pos_y,a6

*   a0 : CURRENT OBSTACLE ITERATOR (Current-Max-Obstacles to 0)
*   a1 : CURRENT OBSTACLE Y-POS MAX
*   a3 : OBSTACLE SPRITE ARRAY
*   a5 : OBSTACLE X-POSITION ARRAY
*   a6 : OBSTACLE Y-POSITION ARRAY
*   d0 : (TRAP CODE)
*   d1 : CURRENT OBSTACLE X-POS ITERATOR (X-POS+32{width} to X-POS)
*   d2 : CURRENT OBSTACLE Y-POS HOLDER (Y-POS to Y-POS+28{height})
*   d5 : CURRENT OBSTACLE ROW PIXEL-VALUE (0 or 1 : DON'T DRAW or DRAW)
*   d6 : CURRENT PIXEL VALUE CHECKER (first bit of d5)
*   d7 : CURRENT OBSTACLE X-POS HOLDER
LOOP_DRAW_OBSTACLE

*   GET RANDOM COLOR
    MOVE.L  #31393,d2       ; SEED FOR RANDOM FUNCTION
    JSR     RANDOM_COLOR
*   SET PEN COLOR
    MOVEQ   #80,d0
    TRAP    #15
    
    MOVEQ   #82,d0
    LEA     OBSTACLE_SPRITE,a3
    
*   GET OBSTACLE (X,Y) POS
    MOVE.L  (a5)+,d7
    MOVE.L  (a6)+,d2
*   INIT OBSTACLE MAX Y-POS
    MOVE.L  d2,a1
    ADD.L   #28,a1
    
DRAW_OBSTACLE_Y

*   INIT OBSTACLE X-POS
*   WE START TO PRINT FROM RIGHT SIDE AS PIXEL DATA BIT-by-BIT IS PROCESSED FROM THE RIGHT, SO WE READ FROM THE RIGHT
    MOVE.L  d7,d1
    ADD.L   #31,d1

*   GET CURRENT ROW PIXEL DATA
    MOVE.L  (a3)+,d5
    CLR.L   d6
    
DRAW_OBSTACLE_ROW

*   SHIFT AND CHECK FIRST BIT to DRAW OR NOT-DRAW
    MOVE.B  d5,d6
    LSR.L   #1,d5
    AND.B   #1,d6
    BEQ     DONTDRAWPIXEL
    TRAP    #15
DONTDRAWPIXEL
    SUBI.L  #1,d1
    CMP.L   d7,d1               ; CHECK IF ROW IS COMPELETE
    BGE     DRAW_OBSTACLE_ROW
    
    ADD.W   #1,d2
    CMP.W   a1,d2               ; CHECK IF ALL ROWS ARE DRAWN
    BLT     DRAW_OBSTACLE_Y
    
    SUB.L   #1,a0
    CMP.L   #0,a0               ; CHECK IF ALL OBSTACLES ARE DRAWN
    BGE     LOOP_DRAW_OBSTACLE

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

RESET_OBSTACLE

*   MULTIPLY BY 4 TO GET POSITION IN ARRAY
    LSL.L   #2,d7

*   GET CURRENT OBSTACLE X-POS Position in ARRAY
    LEA     obstacle_pos_x,a4
    ADD.L   d7,a4
    
*   GET RANDOM NUMBER
    MOVE.L  #29917,d5   ;SEED
    JSR     RANDOM_POS
    
*   PUT VALUE IN RANGE 0-404 (255+127+15+7)
    AND.L   #%11111111,d1
    MOVE.L  d1,d0
    LSR.L   #1,d0
    ADD.L   d0,d1
    LSR.L   #3,d0
    ADD.L   d0,d1
    LSR.L   #1,d0
    ADD.L   d0,d1
    ADDI.L  #(PLAYAREA_MIN + 2),d1
    
*   UPDATE VALUE IN ARRAY
    MOVE.L  d1,(a4)
    
*   GET CURRENT OBSTACLE Y-POS Position in ARRAY
    LEA     obstacle_pos_y,a4
    ADD.L   d7,a4
    
*   GET RANDOM NUMBER
    MOVE.L  #29311,d5   ;SEED
    JSR     RANDOM_POS

*   PUT VALUE IN RANGE 0-255
    AND.L   #%11111111,d1
    ADDI.L  #SCREEN_HEIGHT,d1
    
*   UPDATE VALUE IN ARRAY
    MOVE.L  d1,(a4)

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

UPDATE_SCORE

*   ADD TO CURRENT SCORE
    MOVE.L  score,d0
    ADD.L   #1,d0
    CMP.L   #1000,d0
    BLT     MAXSCORESET
    MOVE.L  #999,d0
    MOVE.B  #1,gameover         ; GAME OVER IF SCORE 999
MAXSCORESET
    MOVE.L  d0,score
    
*   CHECK IF NEXT STAGE REACHED
    CMP.L   #OBSTACLE_STAGE_1,d0
    BEQ     ADDOBSTACLE
    CMP.L   #OBSTACLE_STAGE_2,d0
    BEQ     ADDOBSTACLE
    CMP.L   #OBSTACLE_STAGE_3,d0
    BEQ     ADDOBSTACLE
    CMP.L   #OBSTACLE_STAGE_4,d0
    BEQ     ADDOBSTACLE
    CMP.L   #OBSTACLE_STAGE_5,d0
    BEQ     ADDOBSTACLE
    CMP.L   #OBSTACLE_STAGE_6,d0
    BNE     DONTADDOBSTACLE

*   ADD OBSTACLE IF NEW STAGE
ADDOBSTACLE
    MOVE.L  num_obstacles,d1
    ADD.L   #1,d1
    CMP.L   #MAX_OBSTACLES,d1       ; DON'T GO ABOVE MAX OBSTACLES
    BLT     OBSTACLELIMITSET
    MOVE.L  #(MAX_OBSTACLES-1),d1
OBSTACLELIMITSET
*   UPDATE VALUE IN VARIABLE
    MOVE.L  d1,num_obstacles
    
DONTADDOBSTACLE

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

obstacle_pos_x      DS.L    MAX_OBSTACLES
obstacle_pos_y      DS.L    MAX_OBSTACLES

*******************************************************************************
    *******************************************************************************
*******************************************************************************

OBSTACLE_SPRITE     DC.L	$1F000
					DC.L	$FFFE00
					DC.L	$3FFFF00
					DC.L	$7F00FE0
					DC.L	$7E00FF0
					DC.L	$FCF87F0
					DC.L	$F9FC7F8
					DC.L	$1FFFE7F8
					DC.L	$3FFFEFF8
					DC.L	$7FFFFFFC
					DC.L	$FFE3FFFE
					DC.L	$FFE7FFEE
					DC.L	$FFFFFFCE
					DC.L	$F3FFFF8F
					DC.L	$F1FFFF8F
					DC.L	$7807EF8F
					DC.L	$7C03C70F
					DC.L	$3F81CF8E
					DC.L	$1FE1FCFE
					DC.L	$1FE1F81E
					DC.L	$FE1F81C
					DC.L	$7C1FE1C
					DC.L	$7F1FFF8
					DC.L	$3FFFFF8
					DC.L	$1FFFFF0
					DC.L	$3FFF00
					DC.L	$FFE00
					DC.L	$3F800


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
