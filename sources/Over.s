; Over.s : オーバー
;


; モジュール宣言
;
    .module Over

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Over.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; オーバーを初期化する
;
_OverInitialize::
    
    ; レジスタの保存
    
    ; オーバーの初期化
    ld      hl, #overDefault
    ld      de, #_over
    ld      bc, #OVER_LENGTH
    ldir

    ; 状態の設定
    ld      a, #OVER_STATE_STAY
    ld      (_over + OVER_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; オーバーを更新する
;
_OverUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_over + OVER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #overProc
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
    ld      a, #OVER_STATE_NULL
    ld      (_over + OVER_STATE), a
;   jr      29$
29$:

    ; レジスタの復帰

    ; 終了
    ret

; オーバーを描画する
;
_OverRender::

    ; レジスタの保存

    ; 怪盗の描画
    ld      hl, #overThiefSprite
    ld      de, #_sprite
    ld      bc, #0x0008
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
OverNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 待機する
;
OverStay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_over + OVER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 背景の表示
    call    OverPrintBack

    ; 初期化の完了
    ld      hl, #(_over + OVER_STATE)
    inc     (hl)
09$:

    ; レジスタの復帰
    
    ; 終了
    ret

; オーバーが完了したかどうかを判定する
;
_OverIsDone::

    ; レジスタの保存

    ; cf > 1 = 完了した

    ; ステータスの監視
    ld      a, (_over + OVER_STATE)
    or      a
    jr      nz, 19$
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 背景を表示する
;
OverPrintBack:

    ; レジスタの保存

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; 牢屋の表示
    ld      hl, #(overJailPatternName)
    ld      de, #(_patternName + 0x014d)
    ld      b, #0x03
10$:
    push    bc
    ld      bc, #0x0007
    ldir
    ex      de, hl
    ld      bc, #(0x0020 - 0x0007)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    10$

    ; スコアの表示
    ld      hl, #(_game + GAME_SCORE_10000_00)
    ld      de, #(_patternName + 0x00ac)
    ld      b, #GAME_SCORE_LENGTH
    call    _AppPrintScore

    ; トップスコアの表示
    ld      a, (_game + GAME_FLAG)
    bit     #GAME_FLAG_TOP_BIT, a
    jr      z, 39$
    ld      hl, #overTopPatternName
    ld      de, #(_patternName + 0x022b)
    ld      bc, #0x0009
    ldir
39$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
overProc:

    .dw     OverNull
    .dw     OverStay

; オーバーの初期値
;
overDefault:

    .db     OVER_STATE_NULL
    .db     OVER_FLAG_NULL
    .db     OVER_FRAME_NULL
    .db     OVER_COUNT_NULL

; 牢屋
overJailPatternName:

    .db     0xec, 0xec, 0xec, 0xec, 0xec, 0xec, 0xed
    .db     0xed, 0xed, 0xed, 0xed, 0xed, 0xed, 0xed
    .db     0xee, 0xee, 0xee, 0xee, 0xee, 0xee, 0xed

; 怪盗
;
overThiefSprite:

    .db     0x54 - 0x01, 0x78, 0xa4, VDP_COLOR_LIGHT_YELLOW
    .db     0x54 - 0x01, 0x78, 0xac, VDP_COLOR_LIGHT_RED

; トップスコア
overTopPatternName:

    .db     0x34, 0x2f, 0x30, 0x00, 0x33, 0x23, 0x2f, 0x32, 0x25


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; オーバー
;
_over::
    
    .ds     OVER_LENGTH

