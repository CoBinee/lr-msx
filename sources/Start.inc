; Start.inc : スタート
;


; マクロの定義
;

; スタート
START_STATE                     =   0x00
START_FLAG                      =   0x01
START_FRAME                     =   0x02
START_COUNT                     =   0x03
START_HELI_POSITION_X           =   0x04
START_HELI_POSITION_Y           =   0x05
START_HELI_ANIMATION            =   0x06
START_THIEF_POSITION_X          =   0x07
START_THIEF_POSITION_Y          =   0x08
START_THIEF_ANIMATION           =   0x09
START_ROPE_POSITION_X           =   0x0a
START_ROPE_POSITION_Y           =   0x0b
START_ROPE_LENGTH               =   0x0c
START_LENGTH                    =   0x0d

; 状態
START_STATE_NULL                =   0x00
START_STATE_IN                  =   0x10
START_STATE_DOWN                =   0x20
START_STATE_UP                  =   0x30
START_STATE_OUT                 =   0x40

; フラグ
START_FLAG_NULL                 =   0x00
START_FLAG_HELI_BIT             =   0x00
START_FLAG_HELI                 =   (1 << START_FLAG_HELI_BIT)
START_FLAG_THIEF_BIT            =   0x01
START_FLAG_THIEF                =   (1 << START_FLAG_THIEF_BIT)
START_FLAG_ROPE_BIT             =   0x02
START_FLAG_ROPE                 =   (1 << START_FLAG_ROPE_BIT)
START_FLAG_BLIND_L_BIT          =   0x03
START_FLAG_BLIND_L              =   (1 << START_FLAG_BLIND_L_BIT)

; フレーム
START_FRAME_NULL                =   0x00

; カウント
START_COUNT_NULL                =   0x00

; ヘリの位置
START_HELI_POSITION_NULL        =   0x00

; ヘリのアニメーション
START_HELI_ANIMATION_NULL       =   0x00

; 怪盗の位置
START_THIEF_POSITION_NULL       =   0x00

; 怪盗のアニメーション
START_THIEF_ANIMATION_NULL      =   0x00

; ロープの位置
START_ROPE_POSITION_NULL        =   0x00

; ロープの長さ
START_ROPE_LENGTH_NULL          =   0x00

; 外部関数宣言
;

    .globl  _StartInitialize
    .globl  _StartUpdate
    .globl  _StartRender
    .globl  _StartIsDone

; 外部変数宣言
;

    .globl  _start
