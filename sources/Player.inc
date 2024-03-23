; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_STATE                    =   0x00
PLAYER_FLAG                     =   0x01
PLAYER_POSITION_L_L             =   0x02
PLAYER_POSITION_L_H             =   0x03
PLAYER_POSITION_R_L             =   0x04
PLAYER_POSITION_R_H             =   0x05
PLAYER_POSITION_X               =   0x06
PLAYER_POSITION_Y               =   0x07
PLAYER_SPEED_L_L                =   0x08
PLAYER_SPEED_L_H                =   0x09
PLAYER_SPEED_R_L                =   0x0a
PLAYER_SPEED_R_H                =   0x0b
PLAYER_ESCAPE_L                 =   0x0c
PLAYER_ESCAPE_H                 =   0x0d
PLAYER_LOOP                     =   0x0e
PLAYER_JEWELRY                  =   0x0f
PLAYER_FRAME                    =   0x10
PLAYER_ROTATE                   =   0x11
PLAYER_ANIMATION                =   0x12
PLAYER_BLINK                    =   0x13
PLAYER_SPRITE_L                 =   0x14
PLAYER_SPRITE_H                 =   0x15
PLAYER_PATTERN_L                =   0x16
PLAYER_PATTERN_H                =   0x17
PLAYER_LENGTH                   =   0x18

; 状態
PLAYER_STATE_NULL               =   0x00
PLAYER_STATE_START              =   0x10
PLAYER_STATE_PLAY               =   0x20
PLAYER_STATE_CAUGHT             =   0x30
PLAYER_STATE_FINISH             =   0x40

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_CC_BIT              =   0x00
PLAYER_FLAG_CC                  =   (1 << PLAYER_FLAG_CC_BIT)
PLAYER_FLAG_JUMP_BIT            =   0x01
PLAYER_FLAG_JUMP                =   (1 << PLAYER_FLAG_JUMP_BIT)
PLAYER_FLAG_REVERSE_BIT         =   0x02
PLAYER_FLAG_REVERSE             =   (1 << PLAYER_FLAG_REVERSE_BIT)
PLAYER_FLAG_HIT_BIT             =   0x03
PLAYER_FLAG_HIT                 =   (1 << PLAYER_FLAG_HIT_BIT)
PLAYER_FLAG_LOOP_0300_BIT       =   0x05
PLAYER_FLAG_LOOP_0300           =   (1 << PLAYER_FLAG_LOOP_0300_BIT)
PLAYER_FLAG_LOOP_1200_BIT       =   0x06
PLAYER_FLAG_LOOP_1200           =   (1 << PLAYER_FLAG_LOOP_1200_BIT)
PLAYER_FLAG_LOOP_0900_BIT       =   0x07
PLAYER_FLAG_LOOP_0900           =   (1 << PLAYER_FLAG_LOOP_0900_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00
PLAYER_POSITION_REVERSE         =   0xb000

; 速度
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_L_MAXIMUM          =   0x01
PLAYER_SPEED_R_MAXIMUM          =   0x10
PLAYER_SPEED_ACCEL              =   0x0020
PLAYER_SPEED_BRAKE              =   0x0010
PLAYER_SPEED_JUMP               =   0x0300
PLAYER_SPEED_REVERSE_JUMP       =   -0x0300
PLAYER_SPEED_REVERSE_FALL       =   -0x0a00
PLAYER_SPEED_GRAVITY            =   0x0030

; 逃走
PLAYER_ESCAPE_NULL              =   0x0000
PLAYER_ESCAPE_LENGTH            =   (10 * 60)
PLAYER_ESCAPE_BLINK             =   (3 * 60)

; ループ
PLAYER_LOOP_NULL                =   0x00
PLAYER_LOOP_0600_L              =   0x00
PLAYER_LOOP_0300_L              =   0x40
PLAYER_LOOP_1200_L              =   0x80
PLAYER_LOOP_0900_L              =   0xc0
PLAYER_LOOP_HIT_OR              =   0x10
PLAYER_LOOP_HIT_SIZE_L          =   0x08
PLAYER_LOOP_HIT_SIZE_R          =   0x18

; 宝石
PLAYER_JEWELRY_NULL             =   0x00
PLAYER_JEWELRY_MAXIMUM          =   0x03

; フレーム
PLAYER_FRAME_NULL               =   0x00

; 回転
PLAYER_ROTATE_NULL              =   0x00
PLAYER_ROTATE_SPEED             =   0x08

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00

; 点滅
PLAYER_BLINK_NULL               =   0x00
PLAYER_BLINK_START              =   0x60
PLAYER_BLINK_CAUGHT             =   0xc0

; スプライト
PLAYER_SPRITE_NULL              =   0x00

; パターン
PLAYER_PATTERN_NULL             =   0x00

; ヒット
PLAYER_HIT_NULL                 =   0x00
PLAYER_HIT_CAUGHT               =   0x01
PLAYER_HIT_ESCAPE               =   0x02
PLAYER_HIT_OR                   =   0x08
PLAYER_HIT_OY                   =   0x08

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerTransfer
    .globl  _PlayerGetFarPosition
    .globl  _PlayerGetLoopCount
    .globl  _PlayerGetJewelryCount
    .globl  _PlayerAddJewelry
    .globl  _PlayerIsHitLR
    .globl  _PlayerIsHitXY
    .globl  _PlayerIsCaught
    .globl  _PlayerIsFind
    .globl  _PlayerIsPlay
    .globl  _PlayerIsLive

; 外部変数宣言
;

    .globl  _player
