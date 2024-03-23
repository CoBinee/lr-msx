; Clear.s : クリア
;


; モジュール宣言
;
    .module Clear

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Clear.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; クリアを初期化する
;
_ClearInitialize::
    
    ; レジスタの保存
    
    ; クリアの初期化
    ld      hl, #clearDefault
    ld      de, #_clear
    ld      bc, #CLEAR_LENGTH
    ldir

    ; 状態の設定
    ld      a, #CLEAR_STATE_WALK
    ld      (_clear + CLEAR_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; クリアを更新する
;
_ClearUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_clear + CLEAR_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #clearProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; キー入力の監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 29$

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 状態の更新
    ld      a, #CLEAR_STATE_NULL
    ld      (_clear + CLEAR_STATE), a
;   jr      29$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; クリアを描画する
;
_ClearRender::

    ; レジスタの保存

    ; スプライトの取得
    ld      de, #_sprite

    ; 怪盗の描画
    ld      a, (_clear + CLEAR_THIEF_ANIMATION)
    and     #0xfc
    ld      c, a
    ld      b, #0x00
    ld      hl, #clearThiefSprite
    add     hl, bc
    ld      bc, (_clear + CLEAR_THIEF_POSITION_X)
    call    80$

    ; レディの描画
    ld      a, (_clear + CLEAR_LADY_ANIMATION)
    and     #0xfc
    ld      c, a
    ld      b, #0x00
    ld      hl, #clearLadySprite
    add     hl, bc
    ld      bc, (_clear + CLEAR_LADY_POSITION_X)
    call    80$

    ; ハートの描画
    ld      a, (_clear + CLEAR_HEART_LENGTH)
    or      a
    jr      z, 39$
    push    af
    ld      a, (_clear + CLEAR_HEART_ANIMATION)
    ld      c, a
    ld      b, #0x00
    ld      hl, #clearHeartSprite
    add     hl, bc
    ld      bc, #0x0000
    pop     af
30$:
    push    af
    call    80$
    pop     af
    dec     a
    jr      nz, 30$
39$:
    jr      90$

    ; スプライトの描画
80$:
    ld      a, (hl)
    add     a, b
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ret

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
ClearNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 二人が歩く
;
ClearWalk:

    ; レジスタの保存

    ; 初期化
    ld      a, (_clear + CLEAR_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 背景の表示
    call    ClearPrintBack

    ; 初期化の完了
    ld      hl, #(_clear + CLEAR_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_clear + CLEAR_FRAME)
    inc     (hl)

    ; 移動
    ld      c, #0x00
    ld      a, (hl)
    and     #0x01
    jr      z, 19$
    ld      hl, #(_clear + CLEAR_THIEF_POSITION_X)
    ld      a, (hl)
    cp      #0x7e
    jr      c, 10$
    dec     (hl)
    ld      hl, #(_clear + CLEAR_THIEF_ANIMATION)
    ld      a, (hl)
    inc     a
    and     #0x07
    ld      (hl), a
    jr      11$
10$:
    inc     c
11$:
    ld      hl, #(_clear + CLEAR_LADY_POSITION_X)
    ld      a, (hl)
    cp      #0x72
    jr      nc, 12$
    inc     (hl)
    ld      hl, #(_clear + CLEAR_LADY_ANIMATION)
    ld      a, (hl)
    inc     a
    and     #0x07
    ld      (hl), a
    jr      13$
12$:
    inc     c
13$:
    ld      a, c
    cp      #0x02
    jr      c, 19$

    ; 状態の更新
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_TOP_BIT, a
    jr      nz, 14$
    ld      a, #CLEAR_STATE_MORE
    ld      (_clear + CLEAR_STATE), a
    jr      19$
14$:
    ld      a, #CLEAR_STATE_BETTER
    ld      (_clear + CLEAR_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; トップスコアは更新されなかった
;
ClearMore:

    ; レジスタの保存

    ; 初期化
    ld      a, (_clear + CLEAR_STATE)
    and     #0x0f
    jr      nz, 09$

    ; ハートの設定
    xor     a
    ld      (_clear + CLEAR_HEART_ANIMATION), a
    ld      a, #0x01
    ld      (_clear + CLEAR_HEART_LENGTH), a

    ; フレームの設定
    ld      a, #0x10
    ld      (_clear + CLEAR_FRAME), a

    ; 初期化の完了
    ld      hl, #(_clear + CLEAR_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_clear + CLEAR_FRAME)
    dec     (hl)
    jr      nz, 90$

    ; 0x01 : キック１
10$:
    ld      a, (_clear + CLEAR_STATE)
    and     #0x0f
    dec     a
    jr      nz, 20$

    ; レディの設定
    ld      a, #0x08
    ld      (_clear + CLEAR_LADY_ANIMATION), a
    jr      80$

    ; 0x02 : キック２
20$:
    dec     a
    jr      nz, 30$

    ; レディの設定
    ld      a, #0x0c
    ld      (_clear + CLEAR_LADY_ANIMATION), a
    jr      80$

    ; 0x03 : 倒れる
30$:
    dec     a
    jr      nz, 90$

    ; 怪盗の設定
    ld      a, #0x08
    ld      (_clear + CLEAR_THIEF_ANIMATION), a

    ; ハートの設定
    ld      a, #0x04
    ld      (_clear + CLEAR_HEART_ANIMATION), a
;   ld      a, #0x01
;   ld      (_clear + CLEAR_HEART_LENGTH), a

    ; 更新なしの表示
    call    ClearPrintMore
    jr      80$

    ; シーンの更新
80$:

    ; フレームの設定
    ld      a, #0x10
    ld      (_clear + CLEAR_FRAME), a

    ; 状態の更新
    ld      hl, #(_clear + CLEAR_STATE)
    inc     (hl)
;   jr      90$

    ; 更新の完了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; トップスコアは更新された
;
ClearBetter:

    ; レジスタの保存

    ; 初期化
    ld      a, (_clear + CLEAR_STATE)
    and     #0x0f
    jr      nz, 09$

    ; ハートの設定
    ld      a, #0x08
    ld      (_clear + CLEAR_HEART_ANIMATION), a
    ld      a, #0x02
    ld      (_clear + CLEAR_HEART_LENGTH), a

    ; フレームの設定
    ld      a, #0x10
    ld      (_clear + CLEAR_FRAME), a

    ; 初期化の完了
    ld      hl, #(_clear + CLEAR_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_clear + CLEAR_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; ハートの増加
    ld      hl, #(_clear + CLEAR_HEART_LENGTH)
    ld      a, (hl)
    cp      #0x06
    jr      nc, 10$
    add     a, #0x02
    ld      (hl), a

    ; フレームの設定
    ld      a, #0x10
    ld      (_clear + CLEAR_FRAME), a
    jr      19$

    ; 更新ありの表示
10$:
    ld      hl, #(_clear + CLEAR_STATE)
    ld      a, (hl)
    and     #0x0f
    dec     a
    jr      nz, 19$
    inc     (hl)
    call    ClearPrintBetter
;   jr      19$

    ; 更新の完了
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; クリアが完了したかどうかを判定する
;
_ClearIsDone::

    ; レジスタの保存

    ; cf > 1 = 完了した

    ; ステータスの監視
    ld      a, (_clear + CLEAR_STATE)
    or      a
    jr      nz, 19$
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 背景を表示する
;
ClearPrintBack:

    ; レジスタの保存

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; 木の表示
    ld      de, #(_patternName + 0x0121)
    call    10$
    ld      de, #(_patternName + 0x013d)
    call    10$
    jr      19$
10$:
    ld      hl, #(clearTreePatternName)
    ld      b, #0x05
11$:
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    push    bc
    ex      de, hl
    ld      bc, #(0x0020 - 0x0002)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    11$
    ret
19$:

    ; スコアの表示
    ld      hl, #(_game + GAME_SCORE_10000_00)
    ld      de, #(_patternName + 0x00ac)
    ld      b, #GAME_SCORE_LENGTH
    call    _AppPrintScore

    ; レジスタの復帰

    ; 終了
    ret

; トップスコア更新なしを表示する
;
ClearPrintMore:

    ; レジスタの保存

    ; メッセージの表示
    ld      hl, #clearMorePatternName
    ld      de, #(_patternName + 0x0228)
    ld      bc, #0x000f
    ldir

    ; レジスタの復帰

    ; 終了
    ret  

; トップスコア更新ありを表示する
;
ClearPrintBetter:

    ; レジスタの保存

    ; メッセージの表示
    ld      hl, #clearBetterPatternName
    ld      de, #(_patternName + 0x0226)
    ld      bc, #0x0013
    ldir

    ; レジスタの復帰

    ; 終了
    ret  

; 定数の定義
;

; 状態別の処理
;
clearProc:

    .dw     ClearNull
    .dw     ClearWalk
    .dw     ClearMore
    .dw     ClearBetter

; クリアの初期値
;
clearDefault:

    .db     CLEAR_STATE_NULL
    .db     CLEAR_FLAG_NULL
    .db     CLEAR_FRAME_NULL
    .db     CLEAR_COUNT_NULL
    .db     0xd8 ; CLEAR_THIEF_POSITION_NULL
    .db     0x60 ; CLEAR_THIEF_POSITION_NULL
    .db     CLEAR_THIEF_ANIMATION_NULL
    .db     0x18 ; CLEAR_LADY_POSITION_NULL
    .db     0x60 ; CLEAR_LADY_POSITION_NULL
    .db     CLEAR_LADY_ANIMATION_NULL
    .db     CLEAR_HEART_ANIMATION_NULL
    .db     CLEAR_HEART_LENGTH_NULL

; 木
clearTreePatternName:

    .db     0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x98, 0x99, 0x9a, 0x9b

; 怪盗
;
clearThiefSprite:

    .db     0x00 - 0x01, 0x00, 0xa8, VDP_COLOR_LIGHT_RED
    .db     0x00 - 0x01, 0x00, 0xac, VDP_COLOR_LIGHT_RED
    .db     0x00 - 0x01, 0x00, 0xb0, VDP_COLOR_LIGHT_RED

; レディ
;
clearLadySprite:

    .db     0x00 - 0x01, 0x00, 0xb4, VDP_COLOR_MAGENTA
    .db     0x00 - 0x01, 0x00, 0xb8, VDP_COLOR_MAGENTA
    .db     0x00 - 0x01, 0x00, 0xbc, VDP_COLOR_MAGENTA
    .db     0x00 - 0x01, 0x00, 0xc0, VDP_COLOR_MAGENTA

; ハート
;
clearHeartSprite:

    .db     0x54 - 0x01, 0x7d, 0xc4, VDP_COLOR_MEDIUM_RED
    .db     0x54 - 0x01, 0x7d, 0xc8, VDP_COLOR_MEDIUM_RED
    .db     0x54 - 0x01, 0x7d, 0xc4, VDP_COLOR_MEDIUM_RED
    .db     0x54 - 0x01, 0x72, 0xc4, VDP_COLOR_MEDIUM_RED
    .db     0x4c - 0x01, 0x85, 0xc4, VDP_COLOR_MEDIUM_RED
    .db     0x4c - 0x01, 0x6a, 0xc4, VDP_COLOR_MEDIUM_RED
    .db     0x44 - 0x01, 0x8d, 0xc4, VDP_COLOR_MEDIUM_RED
    .db     0x44 - 0x01, 0x62, 0xc4, VDP_COLOR_MEDIUM_RED

; トップスコアの更新なし
;
clearMorePatternName:

    .db     0x22, 0x32, 0x29, 0x2e, 0x27, 0x00, 0x2d, 0x25, 0x00, 0x2d, 0x2f, 0x32, 0x25, 0x00, 0x01

; トップスコアの更新あり
;
clearBetterPatternName:

    .db     0x24, 0x21, 0x32, 0x2c, 0x29, 0x2e, 0x27, 0x00, 0x29, 0x00, 0x2c, 0x2f, 0x36, 0x25, 0x00, 0x39, 0x2f, 0x35, 0x01


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; クリア
;
_clear::
    
    .ds     CLEAR_LENGTH

