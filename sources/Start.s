; Start.s : スタート
;


; モジュール宣言
;
    .module Start

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Start.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; スタートを初期化する
;
_StartInitialize::
    
    ; レジスタの保存
    
    ; スタートの初期化
    ld      hl, #startDefault
    ld      de, #_start
    ld      bc, #START_LENGTH
    ldir

    ; 状態の設定
    ld      a, #START_STATE_IN
    ld      (_start + START_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; スタートを更新する
;
_StartUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_start + START_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #startProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; ヘリの更新
    ld      a, (_start + START_FLAG)
    bit     #START_FLAG_HELI_BIT, a
    jr      z, 29$
    ld      hl, #(_start + START_HELI_ANIMATION)
    inc     (hl)
29$:

    ; レジスタの復帰

    ; 終了
    ret

; スタートを描画する
;
_StartRender::

    ; レジスタの保存

    ; スプライトの取得
    ld      de, #_sprite

    ; 目隠しの描画
    ld      hl, #(startBlindSprite + 0x0000)
    ld      a, (_start + START_FLAG)
    bit     #START_FLAG_BLIND_L_BIT, a
    jr      z, 10$
    ld      hl, #(startBlindSprite + 0x0008)
10$:
    ld      bc, #0x0000
    call    80$
    call    80$

    ; ヘリの描画
    ld      a, (_start + START_FLAG)
    bit     #START_FLAG_HELI_BIT, a
    jr      z, 29$
    ld      a, (_start + START_HELI_ANIMATION)
    and     #0x02
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #startHeliSprite
    add     hl, bc
    ld      bc, (_start + START_HELI_POSITION_X)
    ld      a, c
    cp      #0x20
    jr      c, 20$
    call    80$
    jr      21$
20$:
    inc     hl
    inc     hl
    inc     hl
    inc     hl
21$:
    ld      a, c
    cp      #0xc9
    call    c, 80$
29$:

    ; 怪盗の描画
    ld      a, (_start + START_FLAG)
    bit     #START_FLAG_THIEF_BIT, a
    jr      z, 39$
    ld      a, (_start + START_THIEF_ANIMATION)
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #startThiefSprite
    add     hl, bc
    ld      bc, (_start + START_THIEF_POSITION_X)
    call    80$
39$:

    ; ロープの描画
    ld      a, (_start + START_FLAG)
    bit     #START_FLAG_ROPE_BIT, a
    jr      z, 49$
    ld      bc, (_start + START_ROPE_POSITION_X)
    ld      a, (_start + START_ROPE_LENGTH)
40$:
    sub     #0x10
    jr      c, 41$
    ld      hl, #(startRopeSprite + 0x000c)
    push    af
    call    80$
    ld      a, b
    add     a, #0x10
    ld      b, a
    pop     af
    jr      40$
41$:
    add     a, #0x10
    jr      z, 49$
    push    bc
    and     #0x0c
    ld      c, a
    ld      b, #0x00
    ld      hl, #(startRopeSprite - 0x0004)
    add     hl, bc
    pop     bc
    call    80$
49$:
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
StartNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ヘリをフレームインさせる
;
StartIn:

    ; レジスタの保存

    ; 初期化
    ld      a, (_start + START_STATE)
    and     #0x0f
    jr      nz, 09$

    ; ヘリの設定
    ld      hl, #(_start + START_FLAG)
    set     #START_FLAG_HELI_BIT, (hl)

    ; SE の再生
    ld      a, #SOUND_SE_HELI_IN
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_start + START_STATE)
    inc     (hl)
09$:

    ; ヘリの移動
    ld      hl, #(_start + START_HELI_POSITION_X)
    dec     (hl)
    ld      a, (hl)
    cp      #0x73
    jr      nc, 19$

    ; 状態の更新
    ld      a, #START_STATE_DOWN
    ld      (_start + START_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ロープを下ろす
;
StartDown:

    ; レジスタの保存

    ; 初期化
    ld      a, (_start + START_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 怪盗の設定
    ld      hl, #(_start + START_FLAG)
    set     #START_FLAG_THIEF_BIT, (hl)

    ; ロープの設定
;   ld      hl, #(_start + START_FLAG)
    set     #START_FLAG_ROPE_BIT, (hl)

    ; フレームの設定
;   xor     a
;   ld      (_start + START_FRAME), a

    ; 初期化の完了
    ld      hl, #(_start + START_STATE)
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #(_start + START_FRAME)
    inc     (hl)

    ; 怪盗の移動
;   ld      a, (_start + START_FRAME)
    ld      a, (hl)
    and     #0x01
    jr      nz, 19$
    ld      hl, #(_start + START_THIEF_POSITION_Y)
    ld      a, (hl)
    add     a, #0x04
    ld      (hl), a
    cp      #0xb0
    jr      c, 19$

    ; 状態の更新
    ld      a, #START_STATE_UP
    ld      (_start + START_STATE), a
19$:

    ; ロープの更新
    ld      a, (_start + START_ROPE_POSITION_Y)
    ld      c, a
    ld      a, (_start + START_THIEF_POSITION_Y)
    sub     c
    ld      (_start + START_ROPE_LENGTH), a

    ; レジスタの復帰
    
    ; 終了
    ret

; ロープを引き上げる
;
StartUp:

    ; レジスタの保存

    ; 初期化
    ld      a, (_start + START_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 怪盗の設定
    ld      hl, #(_start + START_THIEF_ANIMATION)
    inc     (hl)

    ; SE の再生
    ld      a, #SOUND_SE_HELI_OUT
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_start + START_STATE)
    inc     (hl)
09$:

    ; ロープの更新
    ld      hl, #(_start + START_ROPE_LENGTH)
    ld      a, (hl)
    sub     #0x10
    ld      (hl), a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #START_STATE_OUT
    ld      (_start + START_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; ヘリをフレームアウトさせる
;
StartOut:

    ; レジスタの保存

    ; 初期化
    ld      a, (_start + START_STATE)
    and     #0x0f
    jr      nz, 09$

    ; ロープの設定
    ld      hl, #(_start + START_FLAG)
    res     #START_FLAG_ROPE_BIT, (hl)

    ; 目隠しの設定
    ld      hl, #(_start + START_FLAG)
    set     #START_FLAG_BLIND_L_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_start + START_STATE)
    inc     (hl)
09$:

    ; ヘリの移動
    ld      hl, #(_start + START_HELI_POSITION_X)
    dec     (hl)
    ld      a, (hl)
    cp      #0x11
    jr      nc, 19$

    ; サウンドの停止
    call    _SoundStop

    ; 状態の更新
    ld      a, #START_STATE_NULL
    ld      (_start + START_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; スタートが完了したかどうかを判定する
;
_StartIsDone::

    ; レジスタの保存

    ; cf > 1 = 完了した

    ; ステータスの監視
    ld      a, (_start + START_STATE)
    or      a
    jr      nz, 19$
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
startProc:

    .dw     StartNull
    .dw     StartIn
    .dw     StartDown
    .dw     StartUp
    .dw     StartOut

; スタートの初期値
;
startDefault:

    .db     START_STATE_NULL
    .db     START_FLAG_NULL
    .db     START_FRAME_NULL
    .db     START_COUNT_NULL
    .db     0xd0 ; START_HELI_POSITION_NULL
    .db     0x20 ; START_HELI_POSITION_NULL
    .db     START_HELI_ANIMATION_NULL
    .db     0x78 ; START_THIEF_POSITION_NULL
    .db     0x20 ; START_THIEF_POSITION_NULL
    .db     START_THIEF_ANIMATION_NULL
    .db     0x78 ; START_ROPE_POSITION_NULL
    .db     0x20 ; START_ROPE_POSITION_NULL
    .db     START_ROPE_LENGTH_NULL

; ヘリ
;
startHeliSprite:

    .db     0x00 - 0x01, 0x00, 0x70, VDP_COLOR_CYAN
    .db     0x00 - 0x01, 0x10, 0x74, VDP_COLOR_CYAN
    .db     0x00 - 0x01, 0x00, 0x78, VDP_COLOR_CYAN
    .db     0x00 - 0x01, 0x10, 0x7c, VDP_COLOR_CYAN

; 怪盗
;
startThiefSprite:

    .db     0x00 - 0x01, 0x00, 0x80, VDP_COLOR_LIGHT_RED
    .db     0x00 - 0x01, 0x00, 0x84, VDP_COLOR_LIGHT_RED

; ロープ
;
startRopeSprite:

    .db     0x00 - 0x01, 0x00, 0x88, VDP_COLOR_DARK_YELLOW
    .db     0x00 - 0x01, 0x00, 0x8c, VDP_COLOR_DARK_YELLOW
    .db     0x00 - 0x01, 0x00, 0x90, VDP_COLOR_DARK_YELLOW
    .db     0x00 - 0x01, 0x00, 0x94, VDP_COLOR_DARK_YELLOW

; 目隠し
;
startBlindSprite:

    .db     0x20 - 0x01, 0xc8, 0x9c, VDP_COLOR_BLACK
    .db     0x20 - 0x01, 0xd8, 0xa0, VDP_COLOR_BLACK
    .db     0x20 - 0x01, 0x18, 0xa0, VDP_COLOR_BLACK
    .db     0x20 - 0x01, 0x28, 0x98, VDP_COLOR_BLACK


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; スタート
;
_start::
    
    .ds     START_LENGTH

