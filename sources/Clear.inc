; Clear.inc : クリア
;


; マクロの定義
;

; クリア
CLEAR_STATE                     =   0x00
CLEAR_FLAG                      =   0x01
CLEAR_FRAME                     =   0x02
CLEAR_COUNT                     =   0x03
CLEAR_THIEF_POSITION_X          =   0x04
CLEAR_THIEF_POSITION_Y          =   0x05
CLEAR_THIEF_ANIMATION           =   0x06
CLEAR_LADY_POSITION_X           =   0x07
CLEAR_LADY_POSITION_Y           =   0x08
CLEAR_LADY_ANIMATION            =   0x09
CLEAR_HEART_ANIMATION           =   0x0a
CLEAR_HEART_LENGTH              =   0x0b
CLEAR_LENGTH                    =   0x0c

; 状態
CLEAR_STATE_NULL                =   0x00
CLEAR_STATE_WALK                =   0x10
CLEAR_STATE_MORE                =   0x20
CLEAR_STATE_BETTER              =   0x30

; フラグ
CLEAR_FLAG_NULL                 =   0x00

; フレーム
CLEAR_FRAME_NULL                =   0x00

; カウント
CLEAR_COUNT_NULL                =   0x00

; 怪盗の位置
CLEAR_THIEF_POSITION_NULL       =   0x00

; 怪盗のアニメーション
CLEAR_THIEF_ANIMATION_NULL      =   0x00

; レディの位置
CLEAR_LADY_POSITION_NULL        =   0x00

; レディのアニメーション
CLEAR_LADY_ANIMATION_NULL       =   0x00

; ハートのアニメーション
CLEAR_HEART_ANIMATION_NULL      =   0x00

; ハートの数
CLEAR_HEART_LENGTH_NULL         =   0x00

; 外部関数宣言
;

    .globl  _ClearInitialize
    .globl  _ClearUpdate
    .globl  _ClearRender
    .globl  _ClearIsDone

; 外部変数宣言
;

    .globl  _clear
