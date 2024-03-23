; Treasure.inc : 宝
;


; マクロの定義
;

; 宝
TREASURE_TYPE                   =   0x00
TREASURE_STATE                  =   0x01
TREASURE_FLAG                   =   0x02
TREASURE_POSITION_L_L           =   0x03
TREASURE_POSITION_L_H           =   0x04
TREASURE_POSITION_R_L           =   0x05
TREASURE_POSITION_R_H           =   0x06
TREASURE_POSITION_X             =   0x07
TREASURE_POSITION_Y             =   0x08
TREASURE_COUNT                  =   0x09
TREASURE_FRAME                  =   0x0a
TREASURE_ANIMATION              =   0x0b
TREASURE_BLINK                  =   0x0c
TREASURE_SPRITE_L               =   0x0d
TREASURE_SPRITE_H               =   0x0e
TREASURE_COLOR_L                =   0x0f
TREASURE_COLOR_H                =   0x10
TREASURE_LENGTH                 =   0x11

; 種類
TREASURE_TYPE_NULL              =   0x00
TREASURE_TYPE_DOLLAR            =   0x01
TREASURE_TYPE_JEWELRY           =   0x02
TREASURE_TYPE_LENGTH            =   0x03

; 状態
TREASURE_STATE_NULL             =   0x00
TREASURE_STATE_START            =   0x10
TREASURE_STATE_STAY             =   0x20
TREASURE_STATE_HIT              =   0x30

; フラグ
TREASURE_FLAG_NULL              =   0x00
TREASURE_FLAG_HIT_BIT           =   0x00
TREASURE_FLAG_HIT               =   (1 << TREASURE_FLAG_HIT_BIT)
TREASURE_FLAG_XY_BIT            =   0x01
TREASURE_FLAG_XY                =   (1 << TREASURE_FLAG_XY_BIT)

; 位置
TREASURE_POSITION_NULL          =   0x00

; カウント
TREASURE_COUNT_NULL             =   0x00

; フレーム
TREASURE_FRAME_NULL             =   0x00
TREASURE_FRAME_HIT              =   0x20

; アニメーション
TREASURE_ANIMATION_NULL         =   0x00

; 点滅
TREASURE_BLINK_NULL             =   0x00
TREASURE_BLINK_START            =   0x20

; スプライト
TREASURE_SPRITE_NULL            =   0x00

; 色
TREASURE_COLOR_NULL             =   0x00

; エントリ
TREASURE_ENTRY                  =   0x04

; ヒット
TREASURE_HIT_OR                 =   0x08
TREASURE_HIT_SIZE_L             =   0x08
TREASURE_HIT_SIZE_R             =   0x08
TREASURE_HIT_SIZE_X             =   0x08
TREASURE_HIT_SIZE_Y             =   0x08

; 外部関数宣言
;

    .globl  _TreasureInitialize
    .globl  _TreasureUpdate
    .globl  _TreasureRender
    .globl  _TreasureGetHitCount

; 外部変数宣言
;

    .globl  _treasure
