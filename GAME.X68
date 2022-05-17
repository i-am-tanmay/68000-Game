*      ___           ___                                       ___           ___       ___ 
*     /  /\         /  /\          __            ___          /  /\         /  /\     /  /\
*    /  /::\       /  /:/         |  |\         /  /\        /  /::\       /  /:/    /  /:/
*   /__/:/\:\     /  /:/          |  |:|       /  /::\      /  /:/\:\     /  /:/    /  /:/ 
*  _\_ \:\ \:\   /  /::\____      |  |:|      /  /:/\:\    /  /::\ \:\   /  /:/    /  /:/  
* /__/\ \:\ \:\ /__/:/\:::::\     |__|:|__   /  /::\ \:\  /__/:/\:\_\:\ /__/:/    /__/:/   
* \  \:\ \:\_\/ \__\/~|:|~~~~     /  /::::\ /__/:/\:\ \:\ \__\/  \:\/:/ \  \:\    \  \:\   
*  \  \:\_\:\      |  |:|        /  /:/~~~~ \__\/  \:\_\/      \__\::/   \  \:\    \  \:\  
*   \  \:\/:/      |  |:|       /__/:/           \  \:\        /  /:/     \  \:\    \  \:\ 
*    \  \::/       |__|:|       \__\/             \__\/       /__/:/       \  \:\    \  \:\
*     \__\/         \__\|                                     \__\/         \__\/     \__\/
*
*
*   TANMAY ARORA
*
*   ps - you're not falling in space (duh.), the asteroids are coming towards you
*   jk the sky is falling
*
*
*   > INPUT   :   Use mouse to control
*
*   > Score being displayed on top-right using 7-Segment Display
*
*   > Asteroids spawn randomly
*
*   > Asteroids speeds are Accelerating every frame, using fixed-point math
*
*   > If you collide with asteroids, G A M E   O V E R
*

*   SCREEN DIMENSIONS       *
SCREEN_WIDTH        EQU     640
SCREEN_HEIGHT       EQU     480

*   7-SEGMENT DIMENSIONS    *
SEG7_LENGTH         EQU     15
SEG7_THIC           EQU     3
SEG7_X              EQU     569
SEG7_Y              EQU     20
SEG7_SPACING        EQU     5
SEG7_COLOR          EQU     $00FF00

*   PLAY-AREA DIMENSIONS    *
PLAYAREA_MIN        EQU     100
PLAYAREA_MAX        EQU     540

*   PLAYER SPEED VALUES     *
PLAYER_SPEED_FxPt   EQU     7
PLAYER_SPEED_FxPt2  EQU     1
PLAYER_POS_Y        EQU     20
PLAYER_POS_X_OFFSET EQU     20
PLAYER_SPEED_INIT   EQU     10<<(PLAYER_SPEED_FxPt+PLAYER_SPEED_FxPt2)
PLAYER_ACCEL        EQU     5
PLAYER_SPEED_MAX    EQU     30<<(PLAYER_SPEED_FxPt+PLAYER_SPEED_FxPt2)

* Player/Astronaut color-change microtransaction for 5 USD
* jk this has to be white for collision
COLOR_PLAYER        EQU     $FFFFFF

*   OBSTACLES AMOUNT & LEVELS   *
MAX_OBSTACLES       EQU     7
OBSTACLE_STAGE_1    EQU     3
OBSTACLE_STAGE_2    EQU     20
OBSTACLE_STAGE_3    EQU     40
OBSTACLE_STAGE_4    EQU     75
OBSTACLE_STAGE_5    EQU     150
OBSTACLE_STAGE_6    EQU     300

***   CONSTANTS   ***
BMP_COLORSTART      EQU     $36
SEG7_X_MAX          EQU     SEG7_X+SEG7_LENGTH<<1+SEG7_LENGTH+SEG7_SPACING<<1
SEG7_Y_MAX          EQU     SEG7_Y+SEG7_THIC<<1+SEG7_LENGTH<<1+SEG7_THIC
PLAYER_POS_Y_MAX    EQU     PLAYER_POS_Y+55-1

*******************************************************************************
    *******************************************************************************
*******************************************************************************

    ORG     $1000
START

*   DISPLAY LOADING SCREEN & INIT GAMEPLAY VARIABLES
    JSR INIT_GAME

GAMELOOP

*   CLEAR PLAY AREA
    JSR     BG_CLEARPLAYAREA

*   UPDATE OBSTACLE POSITIONS & DRAW OBSTACLES
    JSR     UPDATE_OBSTACLES
    JSR     DRAW_OBSTACLES

*   UPDATE PLAYER POSITION & DRAW PLAYER
    JSR     UPDATE_PLAYER
    JSR     DRAW_PLAYER

*   CLEAR SCORE AREA IN BITMAP & DRAW SCORE AS 7-SEGMENT
    JSR     BG_CLEARRECT
    JSR     PRINT_7SEG
    
    JSR     SWAP_BUFFER
 
*   CHECK IF GAME ENDED *
    CMP.B   #0,gameover
    BEQ     GAMELOOP
    
*   DISPLAY GAME END TEXT
    JSR     END_GAME

*   WAIT FOR SPACEBAR INPUT TO RESET GAME    
    JSR     INPUT_WAITFORRESET

*   CLEAR SCREEN AND RESET GAME
    MOVEQ   #11,d0
    MOVE.W  #$FF00,d1
    TRAP    #15
    JMP     START

    SIMHALT

*******************************************************************************
    *******************************************************************************
*******************************************************************************

INIT_GAME

*   SET WINDOW RESOLUTION   *
    MOVEQ   #33,d0
    MOVE.L  #(SCREEN_WIDTH<<16 + SCREEN_HEIGHT),d1
    TRAP    #15
    
*   ENABLE DOUBLE BUFFER    *
    MOVEQ   #92,d0
    MOVEQ   #17,d1
    TRAP    #15
    
*   DISPLAY TITLE TEXT    *
    ;SET FILL COLOR
    MOVEQ   #81,d0
    MOVE.L  #0,d1
    TRAP    #15
    ;SET FONT PROPERTIES
    MOVEQ   #21,d0
    MOVE.L  #$FFFFFF,d1     ;COLOR
    MOVE.L  #$03080000,d2   ;FONT & SIZE
    TRAP    #15
    
    ; SET CURSOR POSITION
    MOVEQ   #11,d0
    MOVE.L  #((40-(88/2))<<8 + 3),d1
    TRAP    #15
    ; DISPLAY TITLE
    MOVEQ   #14,d0
    LEA     t_title,a1
    TRAP    #15
    
*   DISPLAY LOADING & EPILEPSY TEXT    *
    ; SET FONT PROPERTIES
    MOVEQ   #21,d0
    MOVE.L  #$FFFFFF,d1 ;COLOR
    MOVE.L  #0,d2       ;NO-STYE
    TRAP    #15
    
    ; SET CURSOR POSITION AND DISPLAY LOADING TEXT
    MOVEQ   #11,d0
    MOVE.L  #((40-((t_loading_end-t_loading)/2))<<8 + 17),d1
    TRAP    #15
    MOVEQ   #14,d0
    LEA     t_loading,a1
    TRAP    #15
   
    ; SET CURSOR POSITION
    MOVEQ   #11,d0
    MOVE.L  #((40-((t_epilepsy_end-t_epilepsy)/2))<<8 + 26),d1
    TRAP    #15
    ; DISPLAY EPILEPSY WARNING TEXT
    MOVEQ   #14,d0
    LEA     t_epilepsy,a1
    TRAP    #15
    
    JSR     SWAP_BUFFER
    
*   INIT VARIABLES  *
    MOVE.B  #0,gameover
    MOVE.L  #0,score
    MOVE.L  #PLAYER_SPEED_INIT,player_speed
    MOVE.L  #0,num_obstacles
    
*   INIT OBSTACLES  *
    MOVEQ   #MAX_OBSTACLES,d2
    CLR.L   d3
    ; RESET ALL OBSTACLE'S POSITIONS
RESETOBSTACLELOOP

    MOVE.L  d3,d7
    JSR     RESET_OBSTACLE
    ADDI.L  #1,d3
    
    SUBI.L  #1,d2
    BNE     RESETOBSTACLELOOP
    
*   PRINT INIT bmp file *
    JSR     BG_PRINT
    
    ; SET CURSOR POSITION
    MOVEQ   #11,d0
    MOVE.L  #(72<<8),d1
    TRAP    #15
    ; DISPLAY SCORE TEXT
    MOVEQ   #14,d0
    LEA     t_score,a1
    TRAP    #15
        
    JSR     SWAP_BUFFER

    RTS
    
*******************************************************************************
    *******************************************************************************
*******************************************************************************
    
BG_CLEARPLAYAREA

*   SET FILL COLOR & PEN COLOR
    MOVEQ   #80,d0
    CLR.L   d1
    TRAP    #15
    MOVEQ   #81,d0
    TRAP    #15

*   CLEAR PLAY-AREA RECT
    MOVEQ   #87,d0
    MOVE.L  #PLAYAREA_MIN,d1
    MOVE.L  #PLAYAREA_MAX,d3
    CLR.L   d2
    MOVE.L  #SCREEN_HEIGHT,d4
    TRAP    #15

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************
    
SWAP_BUFFER

    MOVEQ   #94,d0
    TRAP    #15

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************
    
END_GAME

    JSR     BG_CLEARRECT
    
*   SET FILL COLOR & PEN COLOR
    MOVEQ   #80,d0
    CLR.L   d1
    TRAP    #15
    MOVEQ   #81,d0
    TRAP    #15
*   CLEAR RECT BEHIND SCORE TEXT
    MOVEQ   #87,d0
    MOVE.L  #569,d1
    MOVE.L  #625,d3
    MOVE.L  #0,d2
    MOVE.L  #15,d4
    TRAP    #15
    
*   DISPLAY GAME OVER TEXT    *
    ;SET FILL COLOR
    MOVEQ   #81,d0
    MOVE.L  #$FF,d1
    TRAP    #15
    ;SET FONT PROPERTIES
    MOVEQ   #21,d0
    MOVE.L  #$FFFFFF,d1 ;COLOR
    MOVE.L  #%1,d2      ;BOLD
    TRAP    #15
    
*   PRINT GAME OVER TEXT
    MOVEQ   #11,d0
    MOVE.L  #((40-((t_gameover_end-t_gameover)/2) - 5)<<8 + 12),d1
    TRAP    #15
    MOVEQ   #14,d0
    LEA     t_gameover,a1
    TRAP    #15
    
    ;SET FILL COLOR
    MOVEQ   #81,d0
    MOVE.L  #$0,d1
    TRAP    #15
    ;SET FONT PROPERTIES
    MOVEQ   #21,d0
    MOVE.L  #$FF,d1     ;COLOR
    MOVE.L  #%1,d2      ;BOLD
    TRAP    #15
    
*   PRINT SCORE TEXT
    MOVEQ   #11,d0
    MOVE.L  #((40-((t_gameoverscore_end-t_gameoverscore)/2) - 7)<<8 + 14),d1
    TRAP    #15
    MOVEQ   #14,d0
    LEA     t_gameoverscore,a1
    TRAP    #15
*   PRINT SCORE
    MOVEQ   #20,d0
    MOVE.L  score,d1
    MOVEQ   #3,d2
    TRAP    #15
    
    JSR     SWAP_BUFFER

    RTS

*******************************************************************************
    *******************************************************************************
*******************************************************************************

*   FILES TO INCLUDE    *
    INCLUDE background.X68
    INCLUDE input.X68
    INCLUDE seg7.X68
    INCLUDE player.X68
    INCLUDE obstacle.X68
    INCLUDE random.X68

*******************************************************************************
    *******************************************************************************
*******************************************************************************

*   VARIABLES   *
*   Background
bg_file         INCBIN  'bg.bmp'

*   Player Position & Asteroid Speed
player_x        DS.L    1
player_speed    DS.L    1

*   Current Max-Obstacles on-screen
num_obstacles   DS.L    1

*   Current Score
score           DS.L    1

*** TEXT VARIABLES  ***
*
*   80 CHARACTERS IN A ROW
*   32 CHARACTERS IN A COLUMN
*   8x15 PIXEL PER CHARACTER

t_title         DC.B	'     ___           ___                                       ___           ___       ___ ',CR,LF
				DC.B	'    /  /\         /  /\          __            ___          /  /\         /  /\     /  /\',CR,LF
				DC.B	'   /  /::\       /  /:/         |  |\         /  /\        /  /::\       /  /:/    /  /:/',CR,LF
				DC.B	'  /__/:/\:\     /  /:/          |  |:|       /  /::\      /  /:/\:\     /  /:/    /  /:/ ',CR,LF
				DC.B	' _\_ \:\ \:\   /  /::\____      |  |:|      /  /:/\:\    /  /::\ \:\   /  /:/    /  /:/  ',CR,LF
				DC.B	'/__/\ \:\ \:\ /__/:/\:::::\     |__|:|__   /  /::\ \:\  /__/:/\:\_\:\ /__/:/    /__/:/   ',CR,LF
				DC.B	'\  \:\ \:\_\/ \__\/~|:|~~~~     /  /::::\ /__/:/\:\ \:\ \__\/  \:\/:/ \  \:\    \  \:\   ',CR,LF
				DC.B	' \  \:\_\:\      |  |:|        /  /:/~~~~ \__\/  \:\_\/      \__\::/   \  \:\    \  \:\  ',CR,LF
				DC.B	'  \  \:\/:/      |  |:|       /__/:/           \  \:\        /  /:/     \  \:\    \  \:\ ',CR,LF
				DC.B	'   \  \::/       |__|:|       \__\/             \__\/       /__/:/       \  \:\    \  \:\',CR,LF
				DC.B	'    \__\/         \__\|                                     \__\/         \__\/     \__\/',0

t_loading       DC.B    'LOADING...',0
t_loading_end

t_epilepsy      DC.B    '~ photosensitive epilepsy seizure warning ~',0
t_epilepsy_end

t_score         DC.B    'SCORE',0

t_gameover      DC.B    'G A M E   O V E R',0
t_gameover_end

t_gameoverscore DC.B    'SCORE : ',0
t_gameoverscore_end

t_gameoverreset DC.B    '~ Press Space To Reset ~',0
t_gameoverreset_end

* GAMEOVER bool
gameover        DS.B    1

CR  EQU $0D
LF  EQU $0A

    END    START



*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
