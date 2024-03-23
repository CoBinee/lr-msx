; Treasure.s : 宝
;


; モジュール宣言
;
    .module Treasure

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Player.inc"
    .include	"Treasure.inc"

; 外部変数宣言
;
    .globl  _patternTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 宝を初期化する
;
_TreasureInitialize::
    
    ; レジスタの保存
    
    ; 宝の初期化
    ld      hl, #treasureDefault
    ld      de, #_treasure
    ld      bc, #(TREASURE_LENGTH * TREASURE_ENTRY)
    ldir

    ; ヒットの初期化
    ld      hl, #(treasureHit + 0x0000)
    ld      de, #(treasureHit + 0x0001)
    ld      bc, #(TREASURE_TYPE_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; 宝を更新する
;
_TreasureUpdate::
    
    ; レジスタの保存

    ; 宝の走査
    ld      ix, #_treasure
    ld      b, #TREASURE_ENTRY
10$:
    push    bc
    ld      a, TREASURE_TYPE(ix)
    or      a
    jr      z, 19$

    ; 状態別の処理
    ld      hl, #11$
    push    hl
    ld      a, TREASURE_STATE(ix)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #treasureProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
11$:

    ; 位置の更新
    ld      e, TREASURE_POSITION_L_H(ix)
    ld      d, TREASURE_POSITION_R_H(ix)
    call    _GameGetLRtoXY
    ld      TREASURE_POSITION_X(ix), e
    ld      TREASURE_POSITION_Y(ix), d

    ; アニメーションの更新
    inc     TREASURE_ANIMATION(ix)

    ; ヒット判定
    bit     #TREASURE_FLAG_HIT_BIT, TREASURE_FLAG(ix)
    jr      z, 14$
    bit     #TREASURE_FLAG_XY_BIT, TREASURE_FLAG(ix)
    jr      nz, 12$
    ld      e, TREASURE_POSITION_L_H(ix)
    ld      a, TREASURE_POSITION_R_H(ix)
    add     a, #TREASURE_HIT_OR
    ld      d, a
    ld      bc, #((TREASURE_HIT_SIZE_R << 8) | #TREASURE_HIT_SIZE_L)
    call    _PlayerIsHitLR
    jr      nc, 14$
    jr      13$
12$:
    ld      e, TREASURE_POSITION_X(ix)
    ld      d, TREASURE_POSITION_Y(ix)
    ld      bc, #((TREASURE_HIT_SIZE_Y << 8) | #TREASURE_HIT_SIZE_X)
    call    _PlayerIsHitXY
    jr      nc, 14$
;   jr      13$
13$:
    ld      TREASURE_STATE(ix), #TREASURE_STATE_HIT
14$:

    ; 次の宝へ
19$:
    ld      bc, #TREASURE_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; 宝を描画する
;
_TreasureRender::

    ; レジスタの保存

    ; 宝の走査
    ld      ix, #_treasure
    ld      de, #(_sprite + GAME_SPRITE_TREASURE)
    ld      b, #TREASURE_ENTRY
10$:
    push    bc

    ; 描画の確認
    ld      a, TREASURE_STATE(ix)
    cp      #0x11
    jr      c, 19$
    bit     #0x02, TREASURE_BLINK(ix)
    jr      nz, 19$

    ; スプライトの描画
    ld      a, TREASURE_POSITION_L_H(ix)
    and     #0xe0
    rrca
    rrca
    rrca
    ld      c, a
    ld      b, #0x00
    ld      l, TREASURE_SPRITE_L(ix)
    ld      h, TREASURE_SPRITE_H(ix)
    add     hl, bc
    ld      a, TREASURE_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, TREASURE_POSITION_X(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      l, TREASURE_COLOR_L(ix)
    ld      h, TREASURE_COLOR_H(ix)
    ld      a, TREASURE_ANIMATION(ix)
    rrca
    rrca
    and     #0x03
    ld      c, a
    ld      b, #0x00
    add     hl, bc
    ld      a, (hl)
    ld      (de), a
    inc     de

    ; 次の宝へ
19$:
    ld      bc, #TREASURE_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
TreasureNull:

    ; レジスタの保存

    ; ループ回数の取得
    call    _PlayerGetLoopCount
    ld      TREASURE_COUNT(ix), a

    ; 状態の更新
    ld      TREASURE_STATE(ix), #TREASURE_STATE_START

    ; レジスタの復帰

    ; 終了
    ret

; 宝が出現する
;
TreasureStart:

    ; レジスタの保存

    ; 初期化
    ld      a, TREASURE_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの更新
    ld      a, TREASURE_FRAME(ix)
    or      a
    jr      z, 00$
    dec     TREASURE_FRAME(ix)
    jr      90$
00$:

    ; ドル袋の設定
    ld      a, TREASURE_TYPE(ix)
    cp      #TREASURE_TYPE_JEWELRY
    jr      z, 04$
    ld      TREASURE_POSITION_L_H(ix), #0xff
    call    _PlayerGetFarPosition
    and     #0xe0
01$:
    ld      hl, #(_treasure + TREASURE_POSITION_L_H)
    ld      de, #TREASURE_LENGTH
    ld      b, #TREASURE_ENTRY
02$:
    cp      (hl)
    jr      nz, 03$
    add     a, #0x20
    jr      01$
03$:
    add     hl, de
    djnz    02$
    ld      TREASURE_POSITION_L_H(ix), a
    xor     a
    ld      TREASURE_POSITION_L_L(ix), a
    ld      TREASURE_POSITION_R_L(ix), a
    ld      TREASURE_POSITION_R_H(ix), a
    jr      05$

    ; 宝石の設定
04$:
    call    _PlayerGetLoopCount
    sub     TREASURE_COUNT(ix)
    cp      #0x03
    jr      c, 90$
    xor     a
    ld      TREASURE_POSITION_L_L(ix), a
    ld      TREASURE_POSITION_L_H(ix), a
    ld      TREASURE_POSITION_R_L(ix), a
    ld      TREASURE_POSITION_R_H(ix), #0x60
;   jr      05$

    ; 点滅の設定
05$:
    ld      TREASURE_BLINK(ix), #TREASURE_BLINK_START

    ; 初期化の完了
    inc     TREASURE_STATE(ix)
09$:

    ; 点滅の更新
    dec     TREASURE_BLINK(ix)
    jr      nz, 19$

    ; 状態の更新
    ld      TREASURE_STATE(ix), #TREASURE_STATE_STAY
;   jr      19$
19$:

    ; 出現の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 宝が待機する
;
TreasureStay:

    ; レジスタの保存

    ; 初期化
    ld      a, TREASURE_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; ヒットの設定
    set     #TREASURE_FLAG_HIT_BIT, TREASURE_FLAG(ix)

    ; 初期化の完了
    inc     TREASURE_STATE(ix)
09$:

    ; レジスタの復帰

    ; 終了
    ret

; 宝がヒットした
;
TreasureHit:

    ; レジスタの保存

    ; 初期化
    ld      a, TREASURE_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; ヒットの解除
    res     #TREASURE_FLAG_HIT_BIT, TREASURE_FLAG(ix)

    ; フレームの設定
    ld      TREASURE_FRAME(ix), #TREASURE_FRAME_HIT

    ; スコアの加算
    ld      e, TREASURE_TYPE(ix)
    ld      d, #0x00
    ld      hl, #treasureScore
    add     hl, de
    ld      a, (hl)
    call    _GameAddScore

    ; 宝石の加算
    ld      a, TREASURE_TYPE(ix)
    cp      #TREASURE_TYPE_JEWELRY
    call    z, _PlayerAddJewelry

    ; ヒットの更新
    ld      hl, #treasureHit
    add     hl, de
    inc     (hl)

    ; SE の再生
    ld      a, #SOUND_SE_COIN
    call    _SoundPlaySe

    ; 初期化の完了
    inc     TREASURE_STATE(ix)
09$:

    ; 移動
    ld      l, TREASURE_POSITION_R_L(ix)
    ld      h, TREASURE_POSITION_R_H(ix)
    ld      de, #0x0080
    add     hl, de
    ld      TREASURE_POSITION_R_L(ix), l
    ld      TREASURE_POSITION_R_H(ix), h

    ; 点滅の更新
    inc     TREASURE_BLINK(ix)

    ; フレームの更新
    dec     TREASURE_FRAME(ix)
    jr      nz, 19$

    ; 状態の更新
    ld      TREASURE_STATE(ix), #TREASURE_STATE_NULL
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 宝がヒットした回数を取得する
;
_TreasureGetHitCount::

    ; レジスタの保存
    push    hl
    push    de

    ; a < 宝の種類
    ; a > ヒットした回数

    ; ヒットの取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #treasureHit
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
treasureProc:
    
    .dw     TreasureNull
    .dw     TreasureStart
    .dw     TreasureStay
    .dw     TreasureHit

; 宝の初期値
;
treasureDefault:

    ; ドル袋 1
    .db     TREASURE_TYPE_DOLLAR ; TREASURE_TYPE_NULL
    .db     TREASURE_STATE_NULL
    .db     TREASURE_FLAG_NULL
    .dw     TREASURE_POSITION_NULL
    .dw     TREASURE_POSITION_NULL
    .db     TREASURE_POSITION_NULL
    .db     TREASURE_POSITION_NULL
    .db     TREASURE_COUNT_NULL
    .db     0x00 ; TREASURE_FRAME_NULL
    .db     TREASURE_ANIMATION_NULL
    .db     TREASURE_BLINK_NULL
    .dw     treasureSpriteDollar ; TREASURE_SPRITE_NULL
    .dw     treasureColorDollar ; TREASURE_COLOR_NULL

    ; ドル袋 2
    .db     TREASURE_TYPE_DOLLAR ; TREASURE_TYPE_NULL
    .db     TREASURE_STATE_NULL
    .db     TREASURE_FLAG_NULL
    .dw     TREASURE_POSITION_NULL
    .dw     TREASURE_POSITION_NULL
    .db     TREASURE_POSITION_NULL
    .db     TREASURE_POSITION_NULL
    .db     TREASURE_COUNT_NULL
    .db     0x30 ; TREASURE_FRAME_NULL
    .db     TREASURE_ANIMATION_NULL
    .db     TREASURE_BLINK_NULL
    .dw     treasureSpriteDollar ; TREASURE_SPRITE_NULL
    .dw     treasureColorDollar ; TREASURE_COLOR_NULL

    ; ドル袋 3
    .db     TREASURE_TYPE_DOLLAR ; TREASURE_TYPE_NULL
    .db     TREASURE_STATE_NULL
    .db     TREASURE_FLAG_NULL
    .dw     TREASURE_POSITION_NULL
    .dw     TREASURE_POSITION_NULL
    .db     TREASURE_POSITION_NULL
    .db     TREASURE_POSITION_NULL
    .db     TREASURE_COUNT_NULL
    .db     0x60 ; TREASURE_FRAME_NULL
    .db     TREASURE_ANIMATION_NULL
    .db     TREASURE_BLINK_NULL
    .dw     treasureSpriteDollar ; TREASURE_SPRITE_NULL
    .dw     treasureColorDollar ; TREASURE_COLOR_NULL

    ; 宝石
    .db     TREASURE_TYPE_JEWELRY ; TREASURE_TYPE_NULL
    .db     TREASURE_STATE_NULL
    .db     TREASURE_FLAG_XY ; TREASURE_FLAG_NULL
    .dw     TREASURE_POSITION_NULL
    .dw     TREASURE_POSITION_NULL
    .db     TREASURE_POSITION_NULL
    .db     TREASURE_POSITION_NULL
    .db     TREASURE_COUNT_NULL
    .db     TREASURE_FRAME_NULL
    .db     TREASURE_ANIMATION_NULL
    .db     TREASURE_BLINK_NULL
    .dw     treasureSpriteJewelry ; TREASURE_SPRITE_NULL
    .dw     treasureColorJewelry ; TREASURE_COLOR_NULL

; スコア
;
treasureScore:

    .db     0
    .db     1
    .db     10

; スプライト
;
treasureSpriteDollar:

    .db     -0x10 - 0x01, -0x08, 0x20, VDP_COLOR_LIGHT_YELLOW
    .db     -0x0d - 0x01, -0x0d, 0x24, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01, -0x10, 0x28, VDP_COLOR_LIGHT_YELLOW
    .db     -0x02 - 0x01, -0x0d, 0x2c, VDP_COLOR_LIGHT_YELLOW
    .db      0x01 - 0x01, -0x08, 0x30, VDP_COLOR_LIGHT_YELLOW
    .db     -0x02 - 0x01, -0x02, 0x34, VDP_COLOR_LIGHT_YELLOW
    .db     -0x08 - 0x01,  0x01, 0x38, VDP_COLOR_LIGHT_YELLOW
    .db     -0x0d - 0x01, -0x02, 0x3c, VDP_COLOR_LIGHT_YELLOW

treasureSpriteJewelry:

    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT

    .db     -0x10 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x0d - 0x01, -0x0d, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01, -0x10, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x02 - 0x01, -0x0d, 0x40, VDP_COLOR_TRANSPARENT
    .db      0x01 - 0x01, -0x08, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x02 - 0x01, -0x02, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x08 - 0x01,  0x01, 0x40, VDP_COLOR_TRANSPARENT
    .db     -0x0d - 0x01, -0x02, 0x40, VDP_COLOR_TRANSPARENT

; 色
;
treasureColorDollar:

    .db     VDP_COLOR_LIGHT_YELLOW
    .db     VDP_COLOR_LIGHT_YELLOW
    .db     VDP_COLOR_LIGHT_YELLOW
    .db     VDP_COLOR_LIGHT_YELLOW

treasureColorJewelry:

    .db     VDP_COLOR_DARK_RED
    .db     VDP_COLOR_DARK_GREEN
    .db     VDP_COLOR_DARK_BLUE
    .db     VDP_COLOR_DARK_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 宝
;
_treasure::
    
    .ds     TREASURE_LENGTH * TREASURE_ENTRY

; ヒット
;
treasureHit:

    .ds     TREASURE_TYPE_LENGTH
