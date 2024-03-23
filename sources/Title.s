; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName
    
    ; タイトルの初期化
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 状態の設定
    ld      a, #TITLE_STATE_STAY
    ld      (_title + TITLE_STATE), a
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_title + TITLE_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; タイトルで待機する
;
TitleStay:

    ; レジスタの保存

    ; 初期化の開始
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 背景の表示
    call    TitlePrintBack

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; 車の移動
    call    TitleMoveCar

    ; HIT SPACE BAR の点滅
    ld      c, #0x01
    call    TitleBlinkHitSpaceBar

    ; スペースキーの監視
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #TITLE_STATE_START
    ld      (_title + TITLE_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
TitleStart:

    ; レジスタの保存

    ; 初期化の開始
    ld      a, (_title + TITLE_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x60
    ld      (_title + TITLE_FRAME), a

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; 車の移動
    call    TitleMoveCar

    ; HIT SPACE BAR の点滅
    ld      c, #0x08
    call    TitleBlinkHitSpaceBar

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 車が移動する
;
TitleMoveCar:

    ; レジスタの保存

    ; アニメーションの更新
    ld      hl, #(_title + TITLE_CAR_ANIMATION)
    inc     (hl)

    ; 移動
    ld      a, (hl)
    and     #0x01
    jr      nz, 10$
    ld      hl, #(_title + TITLE_CAR_POSITION_X)
    dec     (hl)
10$:

    ; スプライトの描画
    ld      de, #(_sprite + TITLE_SPRITE_CAR)
    ld      a, (_title + TITLE_CAR_ANIMATION)
    and     #0x04
    add     a, a
    add     a, a
    ld      c, a
    ld      b, #0x00
    ld      hl, #titleCarSprite
    add     hl, bc
    ld      bc, (_title + TITLE_CAR_POSITION_X)
    call    20$
    call    20$
    call    20$
    call    20$
    jr      29$
20$:
    ld      a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, c
    add     a, (hl)
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
29$:

    ; レジスタの復帰

    ; 終了
    ret

; HIT SPACE BAR が点滅する
;
TitleBlinkHitSpaceBar:

    ; レジスタの保存

    ; c < 点滅の速度

    ; 点滅
    ld      hl, #(_title + TITLE_BLINK)
    ld      a, (hl)
    add     a, c
    ld      (hl), a

    ; パターンネームの表示
    and     #0x20
    rrca
    ld      c, a
    ld      b, #0x00
    ld      hl, #titleHitSpaceBarPatternName
    add     hl, bc
    ld      de, #(_patternName + 0x0268)
    ld      bc, #0x0010
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 背景を表示する
;
TitlePrintBack:

    ; レジスタの保存

    ; ロゴの表示
    ld      hl, #titleBackPatternName
    ld      de, #(_patternName + 0x00e0)
    ld      bc, #0x0100
    ldir

    ; スコアの表示
    ld      hl, #(_app + APP_SCORE_10000_00)
    ld      de, #(_patternName + 0x002c)
    ld      b, #APP_SCORE_LENGTH
    call    _AppPrintScore

    ; SCC の表示
    ld      a, (_slot + SLOT_SCC)
    inc     a
    jr      z, 39$
    ld      hl, #(_patternName + 0x02c1)
    ld      de, #0x001c
    ld      a, #0x58
    ld      c, #0x02
30$:
    ld      b, #0x04
31$:
    ld      (hl), a
    inc     a
    inc     hl
    djnz    31$
    add     hl, de
    dec     c
    jr      nz, 30$
39$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
titleProc:
    
    .dw     TitleNull
    .dw     TitleStay
    .dw     TitleStart

; タイトルの初期値
;
titleDefault:

    .db     TITLE_STATE_NULL
    .db     TITLE_FLAG_NULL
    .db     TITLE_FRAME_NULL
    .db     TITLE_COUNT_NULL
    .db     TITLE_BLINK_NULL
    .db     0xe0 ; TITLE_CAR_POSITION_NULL
    .db     0x68 ; TITLE_CAR_POSITION_NULL
    .db     TITLE_CAR_ANIMATION_NULL

; 背景
;
titleBackPatternName:

    .db     0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x41, 0x41, 0x41, 0x42, 0x40, 0x40, 0x40
    .db     0x41, 0x41, 0x41, 0x41, 0x41, 0x43, 0x44, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
    .db     0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x45, 0x41, 0x46, 0x47, 0x40, 0x40, 0x40
    .db     0x45, 0x41, 0x46, 0x48, 0x49, 0x41, 0x4a, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
    .db     0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x4b, 0x41, 0x4c, 0x40, 0x40, 0x40, 0x40
    .db     0x4b, 0x41, 0x4c, 0x40, 0x4d, 0x41, 0x4a, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
    .db     0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x4b, 0x41, 0x4c, 0x40, 0x40, 0x40, 0x40
    .db     0x4b, 0x41, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
    .db     0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x4b, 0x41, 0x4c, 0x40, 0x40, 0x40, 0x40
    .db     0x4b, 0x41, 0x46, 0x48, 0x49, 0x43, 0x44, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
    .db     0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x4b, 0x41, 0x4c, 0x40, 0x4b, 0x41, 0x4c
    .db     0x4b, 0x41, 0x4c, 0x40, 0x4d, 0x41, 0x4a, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
    .db     0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x53, 0x41, 0x4e, 0x4f, 0x53, 0x41, 0x4c
    .db     0x53, 0x41, 0x4c, 0x40, 0x4d, 0x41, 0x54, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
    .db     0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x4c
    .db     0x41, 0x41, 0x4c, 0x40, 0x55, 0x41, 0x41, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40

; 車
;
titleCarSprite:

    .db     0x00 - 0x01, 0x00 - 0x00, 0xcc, VDP_COLOR_BLACK
    .db     0x00 - 0x01, 0x10 - 0x00, 0xd0, VDP_COLOR_BLACK
    .db     0x00 - 0x01, 0x00 + 0x20, 0xcc, VDP_COLOR_BLACK | 0x80
    .db     0x00 - 0x01, 0x10 + 0x20, 0xd0, VDP_COLOR_BLACK | 0x80
    .db     0x00 - 0x01, 0x00 - 0x00, 0xd4, VDP_COLOR_BLACK
    .db     0x00 - 0x01, 0x10 - 0x00, 0xd8, VDP_COLOR_BLACK
    .db     0x00 - 0x01, 0x00 + 0x20, 0xd4, VDP_COLOR_BLACK | 0x80
    .db     0x00 - 0x01, 0x10 + 0x20, 0xd8, VDP_COLOR_BLACK | 0x80

; HIT SPACE BAR
;
titleHitSpaceBarPatternName:

    .db     0x00, 0x28, 0x29, 0x34, 0x00, 0x33, 0x30, 0x21, 0x23, 0x25, 0x00, 0x22, 0x21, 0x32, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::

    .ds     TITLE_LENGTH
