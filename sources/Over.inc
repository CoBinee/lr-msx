; Over.inc : オーバー
;


; マクロの定義
;

; オーバー
OVER_STATE                      =   0x00
OVER_FLAG                       =   0x01
OVER_FRAME                      =   0x02
OVER_COUNT                      =   0x03
OVER_LENGTH                     =   0x04

; 状態
OVER_STATE_NULL                 =   0x00
OVER_STATE_STAY                 =   0x10

; フラグ
OVER_FLAG_NULL                  =   0x00

; フレーム
OVER_FRAME_NULL                 =   0x00

; カウント
OVER_COUNT_NULL                 =   0x00

; 外部関数宣言
;

    .globl  _OverInitialize
    .globl  _OverUpdate
    .globl  _OverRender
    .globl  _OverIsDone

; 外部変数宣言
;

    .globl  _over
