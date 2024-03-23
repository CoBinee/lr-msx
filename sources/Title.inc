; Title.inc : タイトル
;


; マクロの定義
;

; スプライト
TITLE_SPRITE_NULL               =   0x00
TITLE_SPRITE_CAR                =   0x00

; タイトル
TITLE_STATE                     =   0x00
TITLE_FLAG                      =   0x01
TITLE_FRAME                     =   0x02
TITLE_COUNT                     =   0x03
TITLE_BLINK                     =   0x04
TITLE_CAR_POSITION_X            =   0x05
TITLE_CAR_POSITION_Y            =   0x06
TITLE_CAR_ANIMATION             =   0x07
TITLE_LENGTH                    =   0x08

; 状態
TITLE_STATE_NULL                =   0x00
TITLE_STATE_STAY                =   0x10
TITLE_STATE_START               =   0x20

; フラグ
TITLE_FLAG_NULL                 =   0x00

; フレーム
TITLE_FRAME_NULL                =   0x00

; カウント
TITLE_COUNT_NULL                =   0x00

; 点滅
TITLE_BLINK_NULL                =   0x00

; 車の位置
TITLE_CAR_POSITION_NULL         =   0x00

; 車のアニメーション
TITLE_CAR_ANIMATION_NULL        =   0x00

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate

; 外部変数宣言
;

    .globl  _title
