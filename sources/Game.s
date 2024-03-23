; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "Treasure.inc"
    .include    "Back.inc"
    .include    "Start.inc"
    .include    "Over.inc"
    .include    "Clear.inc"

; 外部変数宣言
;
    .globl  _rTablePosition
    .globl  _rTableVector

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName
    
    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; 宝の初期化
    call    _TreasureInitialize

    ; 背景の初期化
    call    _BackInitialize

    ; スタートの初期化
    call    _StartInitialize

    ; オーバーの初期化
    call    _OverInitialize

    ; クリアの初期化
    call    _ClearInitialize

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl
    
    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 状態の設定
    ld      a, #GAME_STATE_START
    ld      (_game + GAME_STATE), a
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_game + GAME_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #gameProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    inc     (hl)

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化の開始
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl
    
    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 背景の更新
    call    _BackUpdate

    ; スタートの更新
    call    _StartUpdate

    ; 背景の描画
    call    _BackRender

    ; スタートの描画
    call    _StartRender

    ; スタートの監視
    call    _StartIsDone
    jr      nc, 19$

    ; 状態の設定
    ld      a, #GAME_STATE_PLAY
    ld      (_game + GAME_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:
    
    ; レジスタの保存
    
    ; 初期化の開始
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 転送の設定
    ld      hl, #GameTransfer
    ld      (_transfer), hl

    ; BGM の再生
    ld      a, #SOUND_BGM_PART1
    call    _SoundPlayBgm
    
    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 宝の更新
    call    _TreasureUpdate

    ; 背景の更新
    call    _BackUpdate

    ; タイムの更新
    call    GameCountTime

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画
    call    _EnemyRender

    ; 宝の描画
    call    _TreasureRender

    ; 背景の描画
    call    _BackRender

    ; ステータスの表示
    call    GamePrintStatus

    ; プレイヤの監視
    call    _PlayerIsLive
    jr      c, 19$

    ; タイムアップ
    ld      hl, (_game + GAME_TIME_L)
    ld      a, h
    or      l
    jr      z, 10$

    ; ゲームーオーバー

    ; 状態の更新
    ld      a, #GAME_STATE_OVER
    ld      (_game + GAME_STATE), a
    jr      19$

    ; ゲームクリア
10$:

    ; 状態の更新
    ld      a, #GAME_STATE_CLEAR
    ld      (_game + GAME_STATE), a
;   jr      19$

    ; プレイの完了
19$:

    ; BGM の停止
    call    _PlayerIsPlay
    ld      a, #SOUND_BGM_NULL
    call    nc, _SoundPlayBgm

    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化の開始
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; スコアの更新
    ld      hl, (_game + GAME_SCORE_L)
    call    _AppUpdateScore
    jr      nc, 00$
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_TOP_BIT, (hl)
00$:

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl
    
    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; オーバーの更新
    call    _OverUpdate

    ; オーバーの描画
    call    _OverRender

    ; オーバーの監視
    call    _OverIsDone
    jr      nc, 19$

    ; 状態の設定
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアした
;
GameClear:

    ; レジスタの保存

    ; 初期化の開始
    ld      a, (_game + GAME_STATE)
    and     #0x0f
    jr      nz, 09$

    ; スコアの更新
    ld      hl, (_game + GAME_SCORE_L)
    call    _AppUpdateScore
    jr      nc, 00$
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_TOP_BIT, (hl)
00$:

    ; 転送の設定
    ld      hl, #_SystemUpdatePatternName
    ld      (_transfer), hl
    
    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; クリアの更新
    call    _ClearUpdate

    ; クリアの描画
    call    _ClearRender

    ; クリアの監視
    call    _ClearIsDone
    jr      nc, 19$

    ; 状態の設定
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; VRAM へ転送する
;
GameTransfer:

    ; レジスタの保存

    ; d < ポート #0
    ; e < ポート #1

    ; プレイヤの転送
    call    _PlayerTransfer

    ; エネミーの転送
    call    _EnemyTransfer

    ; ステータスの転送
    ld      hl, #0x0000
    ld      b, #0x20
    call    _GameTransferPatternName

    ; デバッグとステータスの転送
    ld      hl, #0x02e0
    ld      b, #0x20
    call    _GameTransferPatternName

    ; レジスタの復帰

    ; 終了
    ret

; スプライトジェネレータを VRAM へ転送する
;
_GameTransferSpriteGenerator::

    ; レジスタの保存
    push    de

    ; d  < ポート #0
    ; e  < ポート #1
    ; hl < 転送元アドレス
    ; bc < 転送先アドレス

    ; スプライトジェネレータの取得
    ld      a, (_videoRegister + VDP_R6)
    add     a, a
    add     a, a
    add     a, a
    add     a, b
    ld      b, c
    
    ; VRAM アドレスの設定
    ld      c, e
    out     (c), b
    or      #0b01000000
    out     (c), a
    
    ; スプライトアトリビュートテーブルの転送
    ld      c, d
    ld      b, #0x08
10$:
    outi
    jp      nz, 10$
    ld      de, #0x0078
    add     hl, de
    ld      b, #0x08
11$:
    outi
    jp      nz, 11$
    ld      de, #-0x0080
    add     hl, de
    ld      b, #0x08
12$:
    outi
    jp      nz, 12$
    ld      de, #0x0078
    add     hl, de
    ld      b, #0x08
13$:
    outi
    jp      nz, 13$

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; パターンネームを VRAM へ転送する
;
_GameTransferPatternName::

    ; レジスタの保存
    push    de

    ; d  < ポート #0
    ; e  < ポート #1
    ; hl < 相対アドレス
    ; b  < 転送バイト数

    ; パターンネームテーブルの取得    
    ld      a, (_videoRegister + VDP_R2)
    add     a, a
    add     a, a
    add     a, h

    ; VRAM アドレスの設定
    ld      c, e
    out     (c), l
    or      #0b01000000
    out     (c), a

    ; パターンネームテーブルの転送
    ld      c, d
    ld      de, #_patternName
    add     hl, de
10$:
    outi
    jp      nz, 10$

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; XY 位置を取得する
;
_GameGetLRtoXY::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < R/L 位置
    ; de > Y/X 位置

    ; L 位置の取得
10$:
    ld      a, d
    ld      d, #0x00
    sla     e
    rl      d
    ld      hl, #_rTablePosition
    add     hl, de
    ld      c, (hl)
    inc     hl
    ld      b, (hl)
;   inc     hl

    ; R 位置の取得
200$:
    or      a
    jr      nz, 201$
    ld      e, c
    ld      d, b
    jr      290$
201$:
    ld      hl, #_rTableVector
    add     hl, de
    ld      e, a
    ld      d, #0x00
    ld      a, (hl)
    inc     hl
    call    210$
    add     a, c
    ld      c, a
    ld      a, (hl)
;   inc     hl
    call    210$
    add     a, b
    ld      d, a
    ld      e, c
    jr      290$
210$:
    push    hl
    bit     #0x07, a
    jr      z, 211$
    neg
    call    220$
    ld      a, h
    rl      l
    adc     a, a
    neg
    jr      219$
    ret
211$:
    call    220$
    ld      a, h
    rl      l
    add     a, a
;   jr      219$
219$:
    pop     hl
    ret
220$:
    ld      h, a
    ld      l, #0x00
    add     hl, hl
    jr      nc, 221$
    add     hl, de
221$:
    add     hl, hl
    jr      nc, 222$
    add     hl, de
222$:
    add     hl, hl
    jr      nc, 223$
    add     hl, de
223$:
    add     hl, hl
    jr      nc, 224$
    add     hl, de
224$:
    add     hl, hl
    jr      nc, 225$
    add     hl, de
225$:
    add     hl, hl
    jr      nc, 226$
    add     hl, de
226$:
    add     hl, hl
    jr      nc, 227$
    add     hl, de
227$:
    add     hl, hl
    jr      nc, 228$
    add     hl, de
228$:
    ret
290$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; スコアを加算する
;
_GameAddScore::

    ; レジスタの保存
    push    hl
    push    de

    ; a < スコア

    ; スコアの加算
    ld      e, a
    ld      d, #0x00
    ld      hl, (_game + GAME_SCORE_L)
    add     hl, de
    ld      (_game + GAME_SCORE_L), hl
    ld      de, #GAME_SCORE_MAXIMUM
    or      a
    sbc     hl, de
    jr      c, 10$
    ld      (_game + GAME_SCORE_L), de
10$:

    ; スコアの文字列化
    ld      hl, (_game + GAME_SCORE_L)
    ld      de, #(_game + GAME_SCORE_10000_00)
    call    _AppGetDecimal16

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; タイムを更新する
;
GameCountTime:

    ; レジスタの保存

    ; タイムの更新
    call    _PlayerIsPlay
    jr      nc, 10$
    ld      hl, (_game + GAME_TIME_L)
    ld      a, h
    or      l
    jr      z, 10$
    dec     hl
    ld      (_game + GAME_TIME_L), hl
    ld      de, #(_game + GAME_TIME_10000)
    call    _AppGetDecimal16
10$:

    ; レジスタの復帰

    ; 終了
    ret

; タイムアップしたかどうかを判定する
;
_GameIsTimeUp::

    ; レジスタの保存
    push    hl

    ; cf > 1 = タイムアップ

    ; タイムの監視
    ld      hl, (_game + GAME_TIME_L)
    ld      a, h
    or      l
    jr      nz, 10$
    scf
10$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; ステータスを表示する
;
GamePrintStatus:

    ; レジスタの保存

    ; スコアの表示
    ld      hl, #(_game + GAME_SCORE_10000_00)
    ld      de, #(_patternName + 0x0000)
    ld      b, #GAME_SCORE_LENGTH
    call    _AppPrintScore

    ; タイムの表示
    ld      de, #(_patternName + 0x001a)
    ld      a, #0xd8
    ld      (de), a
    inc     de
    ld      hl, #(_game + GAME_TIME_10000)
    ld      b, #GAME_TIME_LENGTH
    call    GamePrintNumber

    ; 宝石の表示
    ld      de, #(_patternName + 0x02fc)
    call    _PlayerGetJewelryCount
    ld      c, a
    or      a
    jr      z, 31$
    ld      b, a
    ld      a, #0xda
30$:
    ld      (de), a
    inc     de
    djnz    30$
31$:
    ld      a, #PLAYER_JEWELRY_MAXIMUM
    sub     c
    jr      z, 33$
    ld      b, a
    ld      a, #0xd9
32$:
    ld      (de), a
    inc     de
    djnz    32$
33$:

    ; レジスタの復帰

    ; 終了
    ret

; 数値を表示する
;
GamePrintNumber:

    ; レジスタの保存

    ; hl < 数値文字列
    ; de < パターンネームアドレス
    ; b  < 桁数

    ; 数値の表示
    dec     b
10$:
    ld      a, (hl)
    or      a
    jr      nz, 11$
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$
11$:
    inc     b
12$:
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
    inc     hl
    inc     de
    djnz    12$

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
gameProc:
    
    .dw     GameNull
    .dw     GameStart
    .dw     GamePlay
    .dw     GameOver
    .dw     GameClear

; ゲームの初期値
;
gameDefault:

    .db     GAME_STATE_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_FRAME_NULL
    .db     GAME_COUNT_NULL
    .dw     0 ; GAME_SCORE_NULL
    .db     0 ; GAME_SCORE_NULL
    .db     0 ; GAME_SCORE_NULL
    .db     0 ; GAME_SCORE_NULL
    .db     0 ; GAME_SCORE_NULL
    .db     0 ; GAME_SCORE_NULL
    .db     0 ; GAME_SCORE_NULL
    .db     0 ; GAME_SCORE_NULL
    .dw     GAME_TIME_MAXIMUM ; GAME_TIME_NULL
    .db     1 ; GAME_TIME_NULL
    .db     0 ; GAME_TIME_NULL
    .db     0 ; GAME_TIME_NULL
    .db     0 ; GAME_TIME_NULL
    .db     0 ; GAME_TIME_NULL


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::

    .ds     GAME_LENGTH
