; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER              =   0x00
GAME_SPRITE_ENEMY               =   0x10
GAME_SPRITE_TREASURE            =   0x30

; ゲーム
GAME_STATE                      =   0x00
GAME_FLAG                       =   0x01
GAME_FRAME                      =   0x02
GAME_COUNT                      =   0x03
GAME_SCORE_L                    =   0x04
GAME_SCORE_H                    =   0x05
GAME_SCORE_10000_00             =   0x06
GAME_SCORE_01000_00             =   0x07
GAME_SCORE_00100_00             =   0x08
GAME_SCORE_00010_00             =   0x09
GAME_SCORE_00001_00             =   0x0a
GAME_SCORE_00000_10             =   0x0b
GAME_SCORE_00000_01             =   0x0c
GAME_TIME_L                     =   0x0d
GAME_TIME_H                     =   0x0e
GAME_TIME_10000                 =   0x0f
GAME_TIME_01000                 =   0x10
GAME_TIME_00100                 =   0x11
GAME_TIME_00010                 =   0x12
GAME_TIME_00001                 =   0x13
GAME_LENGTH                     =   0x14

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_PLAY                 =   0x20
GAME_STATE_OVER                 =   0x30
GAME_STATE_CLEAR                =   0x40

; フラグ
GAME_FLAG_NULL                  =   0x00
GAME_FLAG_TOP_BIT               =   0x00
GAME_FLAG_TOP                   =   (1 << GAME_FLAG_TOP_BIT)

; フレーム
GAME_FRAME_NULL                 =   0x00

; カウント
GAME_COUNT_NULL                 =   0x00

; スコア
GAME_SCORE_NULL                 =   0x00
GAME_SCORE_MAXIMUM              =   10000
GAME_SCORE_LENGTH               =   0x07

; タイム
GAME_TIME_NULL                  =   0x00
GAME_TIME_MAXIMUM               =   10000
GAME_TIME_LENGTH                =   0x05

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GameTransferSpriteGenerator
    .globl  _GameTransferPatternName
    .globl  _GameGetLRtoXY
    .globl  _GameAddScore
    .globl  _GameIsTimeUp

; 外部変数宣言
;

    .globl  _game
