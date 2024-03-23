; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_FLAG                      =   0x02
ENEMY_POSITION_L_L              =   0x03
ENEMY_POSITION_L_H              =   0x04
ENEMY_POSITION_R_L              =   0x05
ENEMY_POSITION_R_H              =   0x06
ENEMY_POSITION_X                =   0x07
ENEMY_POSITION_Y                =   0x08
ENEMY_SPEED_L_L                 =   0x09
ENEMY_SPEED_L_H                 =   0x0a
ENEMY_SPEED_R_L                 =   0x0b
ENEMY_SPEED_R_H                 =   0x0c
ENEMY_FRAME_L                   =   0x0d
ENEMY_FRAME_H                   =   0x0e
ENEMY_ROTATE                    =   0x0f
ENEMY_ANIMATION                 =   0x10
ENEMY_BLINK                     =   0x11
ENEMY_SPRITE_L                  =   0x12
ENEMY_SPRITE_H                  =   0x13
ENEMY_PATTERN_L                 =   0x14
ENEMY_PATTERN_H                 =   0x15
ENEMY_HIT_OR                    =   0x16
ENEMY_HIT_SIZE_L                =   0x17
ENEMY_HIT_SIZE_R                =   0x18
ENEMY_PARAM_0                   =   0x19
ENEMY_PARAM_1                   =   0x1a
ENEMY_PARAM_2                   =   0x1b
ENEMY_PARAM_3                   =   0x1c
ENEMY_LENGTH                    =   0x1d

; 種類
ENEMY_TYPE_NULL                 =   0x00
ENEMY_TYPE_INSPECTOR            =   0x01
ENEMY_TYPE_OFFICER              =   0x02
ENEMY_TYPE_DOG                  =   0x03
ENEMY_TYPE_HANDCUFF             =   0x04

; 状態
ENEMY_STATE_NULL                =   0x00
ENEMY_STATE_DEFAULT             =   0x10
ENEMY_STATE_CATCH               =   0x50
ENEMY_STATE_ESCAPE              =   0x60
ENEMY_STATE_INSPECTOR_IN        =   0x00
ENEMY_STATE_INSPECTOR_TURN      =   0x10
ENEMY_STATE_INSPECTOR_WALK      =   0x20
ENEMY_STATE_INSPECTOR_RUN       =   0x30
ENEMY_STATE_INSPECTOR_THROW     =   0x40
ENEMY_STATE_OFFICER_IN          =   0x00
ENEMY_STATE_OFFICER_WALK        =   0x10
ENEMY_STATE_OFFICER_TURN        =   0x20
ENEMY_STATE_DOG_IN              =   0x00
ENEMY_STATE_DOG_STAY            =   0x10
ENEMY_STATE_DOG_WALK            =   0x20
ENEMY_STATE_DOG_RUN             =   0x30

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_CC_BIT               =   0x00
ENEMY_FLAG_CC                   =   (1 << ENEMY_FLAG_CC_BIT)
ENEMY_FLAG_JUMP_BIT             =   0x01
ENEMY_FLAG_JUMP                 =   (1 << ENEMY_FLAG_JUMP_BIT)
ENEMY_FLAG_HIT_BIT              =   0x02
ENEMY_FLAG_HIT                  =   (1 << ENEMY_FLAG_HIT_BIT)
ENEMY_FLAG_ANIMATION_BIT        =   0x03
ENEMY_FLAG_ANIAMTION            =   (1 << ENEMY_FLAG_ANIMATION_BIT)
ENEMY_FLAG_ROTATE_BIT           =   0x04
ENEMY_FLAG_ROTATE               =   (1 << ENEMY_FLAG_ROTATE_BIT)
ENEMY_FLAG_REQUEST_BIT          =   0x07
ENEMY_FLAG_REQUEST              =   (1 << ENEMY_FLAG_REQUEST_BIT)

; 位置
ENEMY_POSITION_NULL             =   0x00

; 速度
ENEMY_SPEED_NULL                =   0x00
ENEMY_SPEED_JUMP                =   0x0300
ENEMY_SPEED_GRAVITY             =   -0x0060
ENEMY_SPEED_INSPECTOR_WALK      =   0x0060
ENEMY_SPEED_INSPECTOR_RUN       =   0x00e0
ENEMY_SPEED_OFFICER_SLOW        =   0x0080
ENEMY_SPEED_OFFICER_FAST        =   0x00c0
ENEMY_SPEED_DOG_WALK            =   0x0040
ENEMY_SPEED_DOG_RUN             =   0x00c0
ENEMY_SPEED_HANDCUFF            =   0x0100

; フレーム
ENEMY_FRAME_NULL                =   0x00

; 回転
ENEMY_ROTATE_NULL               =   0x00

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00

; 点滅
ENEMY_BLINK_NULL                =   0x00
ENEMY_BLINK_START               =   0x60

; スプライト
ENEMY_SPRITE_NULL               =   0x00

; パターン
ENEMY_PATTERN_NULL              =   0x00

; ヒット
ENEMY_HIT_NULL                  =   0x00

; パラメータ
ENEMY_PARAM_NULL                =   0x00

; エントリ
ENEMY_ENTRY                     =   0x06

; 発見
ENEMY_FIND_INSPECTOR_RUN        =   0x30
ENEMY_FIND_INSPECTOR_THROW      =   0x50
ENEMY_FIND_DOG_RUN              =   0x30

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyTransfer

; 外部変数宣言
;

    .globl  _enemy
