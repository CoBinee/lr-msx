; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Player.inc"

; 外部変数宣言
;
    .globl  _patternTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir

    ; 状態の設定
    ld      a, #PLAYER_STATE_PLAY
    ld      (_player + PLAYER_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; 位置の更新
    ld      a, (_player + PLAYER_POSITION_L_H)
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_R_H)
    ld      d, a
    call    _GameGetLRtoXY
    ld      (_player + PLAYER_POSITION_X), de

    ; 点滅の更新
    ld      a, (_player + PLAYER_BLINK)
    or      a
    jr      z, 20$
    dec     a
    ld      (_player + PLAYER_BLINK), a
20$:

    ; 逃走の更新
    ld      hl, (_player + PLAYER_ESCAPE_L)
    ld      a, h
    or      l
    jr      z, 39$
    dec     hl
    ld      (_player + PLAYER_ESCAPE_L), hl
    ld      a, h
    or      l
    jr      nz, 30$
    ld      (_player + PLAYER_JEWELRY), a
    jr      39$
30$:
    ld      de, #PLAYER_ESCAPE_BLINK
    or      a
    sbc     hl, de
    jr      nz, 39$
    ld      a, #PLAYER_ESCAPE_BLINK
    ld      (_player + PLAYER_BLINK), a
;   jr      39$
39$:

    ; パターンの設定
    ld      hl, #(_patternTable + 0x1000)
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_CC_BIT, a
    jr      z, 40$
    ld      de, #0x0400
    add     hl, de
40$:
    and     #(PLAYER_FLAG_JUMP | PLAYER_FLAG_REVERSE)
    jr      nz, 41$
    ld      a, (_player + PLAYER_ANIMATION)
    and     #0x10
    jr      z, 42$
41$:
    ld      de, #0x0200
    add     hl, de
42$:
    ld      a, (_player + PLAYER_ROTATE)
    ld      e, a
    and     #0x80
    rlca
    ld      d, a
    ld      a, e
    and     #0x70
    ld      e, a
    add     hl, de
    ld      (_player + PLAYER_PATTERN_L), hl

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    jr      z, 19$
    ld      a, (_player + PLAYER_BLINK)
    and     #0x08
    jr      nz, 19$
    ld      a, (_player + PLAYER_ROTATE)
    and     #0xf0
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, (_player + PLAYER_SPRITE_L)
    add     hl, de
    ld      de, #(_sprite + GAME_SPRITE_PLAYER)
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_POSITION_X)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (_player + PLAYER_ESCAPE_L)
    and     #0x06
    rrca
    ld      c, a
    ld      b, #0x00
    ld      hl, #playerColor
    add     hl, bc
    ld      a, (hl)
    ld      (de), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; VRAM へ転送する
;
_PlayerTransfer::

    ; レジスタの保存
    push    de

    ; d < ポート #0
    ; e < ポート #1

    ; スプライトジェネレータの転送
    ld      hl, (_player + PLAYER_PATTERN_L)
    ld      bc, #0x0020
    call    _GameTransferSpriteGenerator

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを開始する
;
PlayerStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 点滅の設定
    ld      a, #PLAYER_BLINK_START
    ld      (_player + PLAYER_BLINK), a

    ; スプライトの設定
    ld      hl, #playerSprite
    ld      (_player + PLAYER_SPRITE_L), hl

    ; ヒットの解除
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_HIT_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 点滅の監視
    ld      a, (_player + PLAYER_BLINK)
    or      a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #PLAYER_STATE_PLAY
    ld      (_player + PLAYER_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを操作する
;
PlayerPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; スプライトの設定
    ld      hl, #playerSprite
    ld      (_player + PLAYER_SPRITE_L), hl

    ; ヒットの設定
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_HIT_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 左右の操作
    ld      a, (_player + PLAYER_FLAG)
;   and     #(PLAYR_FLAG_JUMP | PLAYER_FLAG_REVERSE)
    bit     #PLAYER_FLAG_REVERSE_BIT, a
    jp      nz, 190$
    ld      a, (_input + INPUT_KEY_LEFT)
    or      a
    jr      nz, 110$
    ld      a, (_input + INPUT_KEY_RIGHT)
    or      a
    jr      nz, 120$

    ; 停止
100$:
    ld      hl, (_player + PLAYER_SPEED_L_L)
    ld      de, #PLAYER_SPEED_BRAKE
    ld      a, h
    or      l
    jr      z, 109$
    ld      a, h
    or      h
    jp      p, 101$
;   or      a
    adc     hl, de
    jp      m, 109$
    ld      hl, #0x0000
    jr      109$
101$:
;   or      a
    sbc     hl, de
    jp      p, 109$
102$:
    ld      hl, #0x0000
109$:
    ld      (_player + PLAYER_SPEED_L_L), hl
    jr      130$

    ; 左へ移動
110$:
    ld      hl, (_player + PLAYER_SPEED_L_L)
    ld      de, #PLAYER_SPEED_ACCEL
    or      a
    sbc     hl, de
    jp      p, 111$
    ld      a, h
    cp      #-PLAYER_SPEED_L_MAXIMUM
    jr      nc, 111$
    ld      hl, #-(PLAYER_SPEED_L_MAXIMUM << 8)
111$:
    ld      (_player + PLAYER_SPEED_L_L), hl
    ld      hl, #(_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_JUMP_BIT, (hl)
    jr      nz, 112$
    res     #PLAYER_FLAG_CC_BIT, (hl)
112$:
    jr      130$

    ; 右へ移動
120$:
    ld      hl, (_player + PLAYER_SPEED_L_L)
    ld      de, #PLAYER_SPEED_ACCEL
    or      a
    adc     hl, de
    jp      m, 121$
    jr      z, 121$
    ld      a, h
    cp      #PLAYER_SPEED_L_MAXIMUM
    jr      c, 121$
    ld      hl, #(PLAYER_SPEED_L_MAXIMUM << 8)
121$:
    ld      (_player + PLAYER_SPEED_L_L), hl
    ld      hl, #(_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_JUMP_BIT, (hl)
    jr      nz, 122$
    set     #PLAYER_FLAG_CC_BIT, (hl)
122$:
;   jr      130$

    ; 左右の移動
130$:
    call    PlayerMove

    ; 左右の操作の完了
190$:

    ; 反転の操作
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_JUMP_BIT, a
    jr      nz, 290$
    bit     #PLAYER_FLAG_REVERSE_BIT, a
    jr      nz, 210$
    ld      a, (_input + INPUT_KEY_UP)
    dec     a
    jr      nz, 290$

    ; 反転の開始
200$:
    ld      a, (_player + PLAYER_POSITION_L_H)
    add     a, #0x80
    ld      (_player + PLAYER_POSITION_L_H), a
    ld      hl, #PLAYER_POSITION_REVERSE
    ld      (_player + PLAYER_POSITION_R_L), hl
    ld      hl, #0x0000
    ld      (_player + PLAYER_SPEED_L_L), hl
    ld      hl, #PLAYER_SPEED_REVERSE_JUMP
    ld      (_player + PLAYER_SPEED_R_L), hl
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_REVERSE_BIT, (hl)
 
    ;　SE の再生
    ld      a, #SOUND_SE_JUMP
    call    _SoundPlaySe

    ; 反転
210$:
    ld      hl, (_player + PLAYER_SPEED_R_L)
    ld      de, #PLAYER_SPEED_GRAVITY
    or      a
    adc     hl, de
    ld      (_player + PLAYER_SPEED_R_L), hl
    ld      de, (_player + PLAYER_POSITION_R_L)
    jp      p, 211$
    add     hl, de
    ld      (_player + PLAYER_POSITION_R_L), hl
    jr      290$
211$:
    ld      hl, #PLAYER_SPEED_REVERSE_FALL
    ld      (_player + PLAYER_SPEED_R_L), hl
    ld      hl, #(_player + PLAYER_FLAG)
;   res     #PLAYER_FLAG_REVERSE_BIT, (hl)
    set     #PLAYER_FLAG_JUMP_BIT, (hl)
;   jr      290$

    ; 反転の操作の完了
290$:

    ; ジャンプの操作
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_JUMP_BIT, a
    jr      nz, 310$
    bit     #PLAYER_FLAG_REVERSE_BIT, a
    jr      nz, 390$
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 390$

    ; ジャンプの開始
300$:
    ld      hl, #PLAYER_SPEED_JUMP
    ld      (_player + PLAYER_SPEED_R_L), hl
    ld      hl, #0x0000
    ld      (_player + PLAYER_SPEED_L_L), hl
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_JUMP_BIT, (hl)
 
    ;　SE の再生
    ld      a, #SOUND_SE_JUMP
    call    _SoundPlaySe

    ; ジャンプ
310$:
    call    PlayerJump
    jr      nc, 311$
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_JUMP_BIT, (hl)
    res     #PLAYER_FLAG_REVERSE_BIT, (hl)
311$:
;   jr      390$

    ; ジャンプの操作の完了
390$:

    ; 操作の完了
900$:

    ; ループのカウント
910$:
    ld      hl, #(_player + PLAYER_FLAG)
    ld      bc, #((PLAYER_LOOP_HIT_SIZE_R << 8) | PLAYER_LOOP_HIT_SIZE_L)
    ld      a, (hl)
    and     #(PLAYER_FLAG_LOOP_0300 | PLAYER_FLAG_LOOP_1200 | PLAYER_FLAG_LOOP_0900)
    cp      #(PLAYER_FLAG_LOOP_0300 | PLAYER_FLAG_LOOP_1200 | PLAYER_FLAG_LOOP_0900)
    jr      nz, 911$
    ld      de, #((PLAYER_LOOP_HIT_OR << 8) | PLAYER_LOOP_0600_L)
    call    _PlayerIsHitLR
    jr      nc, 919$
    ld      a, (hl)
    and     #~(PLAYER_FLAG_LOOP_0300 | PLAYER_FLAG_LOOP_1200 | PLAYER_FLAG_LOOP_0900)
    ld      (hl), a
    ld      hl, #(_player + PLAYER_LOOP)
    inc     (hl)
    jr      919$
911$:
    bit     #PLAYER_FLAG_LOOP_0300_BIT, (hl)
    jr      nz, 912$
    ld      de, #((PLAYER_LOOP_HIT_OR << 8) | PLAYER_LOOP_0300_L)
    call    _PlayerIsHitLR
    jr      nc, 912$
    set     #PLAYER_FLAG_LOOP_0300_BIT, (hl)
    jr      919$
912$:
    bit     #PLAYER_FLAG_LOOP_1200_BIT, (hl)
    jr      nz, 913$
    ld      de, #((PLAYER_LOOP_HIT_OR << 8) | PLAYER_LOOP_1200_L)
    call    _PlayerIsHitLR
    jr      nc, 913$
    set     #PLAYER_FLAG_LOOP_1200_BIT, (hl)
    jr      919$
913$:
    bit     #PLAYER_FLAG_LOOP_0900_BIT, (hl)
    jr      nz, 919$
    ld      de, #((PLAYER_LOOP_HIT_OR << 8) | PLAYER_LOOP_0900_L)
    call    _PlayerIsHitLR
    jr      nc, 919$
    set     #PLAYER_FLAG_LOOP_0900_BIT, (hl)
;   jr      919$
919$:

    ; 回転の更新
920$:
    ld      a, (_player + PLAYER_POSITION_L_H)
    add     a, #0x08
    and     #0xf8
    ld      e, a
    ld      a, (_player + PLAYER_ROTATE)
    cp      e
    jr      z, 929$
    jp      p, 921$
    add     a, #0x08
    jr      922$
921$:
    sub     #0x08
922$:
    ld      (_player + PLAYER_ROTATE), a
929$:

    ; アニメーションの更新
930$:
    ld      hl, #(_player + PLAYER_ANIMATION)
    inc     (hl)

    ; タイムアップの監視
    call    _GameIsTimeUp
    jr      nc, 940$
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_HIT_BIT, (hl)

    ; 着地の監視
    ld      hl, (_player + PLAYER_POSITION_R_L)
    ld      a, h
    or      l
    jr      nz, 940$

    ; 状態の更新
    ld      a, #PLAYER_STATE_FINISH
    ld      (_player + PLAYER_STATE), a
940$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが捕まった
;
PlayerCaught:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; 点滅の設定
    ld      a, #PLAYER_BLINK_CAUGHT
    ld      (_player + PLAYER_BLINK), a

    ; ヒットの解除
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_HIT_BIT, (hl)

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; 点滅の監視
    ld      a, (_player + PLAYER_BLINK)
    or      a
    jr      nz, 19$

    ; 状態の更新
    ld      a, #PLAYER_STATE_NULL
    ld      (_player + PLAYER_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが仕事を終えた
;
PlayerFinish:

    ; レジスタの保存

    ; 初期化
    ld      a, (_player + PLAYER_STATE)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    ld      a, #0x08
    ld      (_player + PLAYER_FRAME), a

    ; ヒットの解除
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_HIT_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_player + PLAYER_STATE)
    inc     (hl)
09$:

    ; ジャンプの開始
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_JUMP_BIT, a
    jr      nz, 10$
    ld      hl, #PLAYER_SPEED_JUMP
    ld      (_player + PLAYER_SPEED_R_L), hl
    ld      hl, #0x0000
    ld      (_player + PLAYER_SPEED_L_L), hl
    ld      hl, #(_player + PLAYER_FLAG)
    set     #PLAYER_FLAG_JUMP_BIT, (hl)

    ;　SE の再生
    ld      a, #SOUND_SE_JUMP
    call    _SoundPlaySe
10$:

    ; ジャンプ
    call    PlayerJump
    jr      nc, 19$
    ld      hl, #(_player + PLAYER_FLAG)
    res     #PLAYER_FLAG_JUMP_BIT, (hl)

    ; フレームの更新
    ld      hl, #(_player + PLAYER_FRAME)
    dec     (hl)
    jr      nz, 19$

    ; 状態の更新
    ld      a, #PLAYER_STATE_NULL
    ld      (_player + PLAYER_STATE), a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが左右に移動する
;
PlayerMove:

    ; レジスタの保存

    ; 左右の移動
    ld      hl, (_player + PLAYER_POSITION_L_L)
    ld      de, (_player + PLAYER_SPEED_L_L)
    add     hl, de
    ld      (_player + PLAYER_POSITION_L_L), hl

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがジャンプする
;
PlayerJump:

    ; レジスタの保存

    ; cf > 1 = 着地した

    ; ジャンプ
    ld      hl, (_player + PLAYER_SPEED_R_L)
    ld      de, #PLAYER_SPEED_GRAVITY
    or      a
    sbc     hl, de
    ld      (_player + PLAYER_SPEED_R_L), hl
    ld      de, (_player + PLAYER_POSITION_R_L)
    jp      m, 10$
    add     hl, de
    jr      11$
10$:
    ld      a, l
    cpl
    ld      l, a
    ld      a, h
    cpl
    ld      h, a
    inc     hl
    ex      de, hl
    or      a
    sbc     hl, de
    jr      nc, 11$
    ld      hl, #0x0000
    ld      (_player + PLAYER_SPEED_R_L), hl
11$:
    ld      (_player + PLAYER_POSITION_R_L), hl
    ld      a, h
    or      l
    jr      nz, 12$
    scf
12$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤから遠い位置を取得する
;
_PlayerGetFarPosition::

    ; レジスタの保存
    push    de

    ; a > L 位置

    ; 位置の取得
    call    _SystemGetRandom
    cp      #0xc1
    jr      nc, 10$
    add     a, #0x20
    jr      11$
10$:
    call    _SystemGetRandom
    and     #0x7f
    add     a, #0x40
11$:
    ld      e, a
    ld      a, (_player + PLAYER_POSITION_L_H)
    add     a, e

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; プレイヤがループした回数を取得する
;
_PlayerGetLoopCount::

    ; レジスタの保存

    ; a > ジャンプした回数

    ; 回数の取得
    ld      a, (_player + PLAYER_LOOP)

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが持っている宝石の個数を取得する
;
_PlayerGetJewelryCount::

    ; レジスタの保存

    ; a > 宝石の数

    ; 宝石の取得
    ld      a, (_player + PLAYER_JEWELRY)

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤに宝石を加える
;
_PlayerAddJewelry::

    ; レジスタの保存

    ; 宝石の加算
    ld      hl, #(_player + PLAYER_JEWELRY)
    ld      a, (hl)
    cp      #PLAYER_JEWELRY_MAXIMUM
    jr      nc, 10$
    inc     a
    ld      (hl), a
    cp      #PLAYER_JEWELRY_MAXIMUM
    jr      c, 10$

    ; 逃走の設定
    ld      hl, #PLAYER_ESCAPE_LENGTH
    ld      (_player + PLAYER_ESCAPE_L), hl
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤとヒットしたかどうかを判定する
;
_PlayerIsHitLR::

    ; レジスタの保存

    ; de < R/L 位置
    ; bc < R/L の距離
    ; cf > 1 = ヒットした

    ; ヒット判定
    ld      a, (_player + PLAYER_FLAG)
    and     #PLAYER_FLAG_HIT
    jr      z, 19$
    ld      a, (_player + PLAYER_POSITION_L_H)
    sub     e
    jp      p, 10$
    neg
10$:
    cp      c
    jr      nc, 19$
    ld      a, (_player + PLAYER_POSITION_R_H)
    add     a, #PLAYER_HIT_OR
    sub     d
    jp      p, 11$
    neg
11$:
    cp      b
;   jr      nc, 19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

_PlayerIsHitXY::

    ; レジスタの保存

    ; de < Y/X 位置
    ; bc < Y/X の距離
    ; cf > 1 = ヒットした

    ; ヒット判定
    ld      a, (_player + PLAYER_FLAG)
    and     #PLAYER_FLAG_HIT
    jr      z, 19$
    ld      a, (_player + PLAYER_POSITION_X)
    sub     e
    jp      p, 10$
    neg
10$:
    cp      c
    jr      nc, 19$
    ld      a, (_player + PLAYER_POSITION_Y)
    add     a, #PLAYER_HIT_OY
    sub     d
    jp      p, 11$
    neg
11$:
    cp      b
;   jr      nc, 19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが捕まったかどうかを判定する
;
_PlayerIsCaught::

    ; レジスタの保存

    ; de < R/L 位置
    ; bc < R/L の距離
    ; cf > 1 = ヒットした
    ; a  > ヒットの結果

    ; ヒット判定
    call    _PlayerIsHitLR
    jr      nc, 19$

    ; 逮捕された
    ld      hl, (_player + PLAYER_ESCAPE_L)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      a, #PLAYER_STATE_CAUGHT
    ld      (_player + PLAYER_STATE), a
    ld      a, #PLAYER_HIT_CAUGHT
    jr      11$

    ; 逃走した
10$:
    ld      a, #PLAYER_HIT_ESCAPE
;   jr      11$

    ; ヒット
11$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを見つけたかどうかを判定する
;
_PlayerIsFind::

    ; レジスタの保存
    push    bc

    ; e  < L 位置
    ; d  < L 速度
    ; c  < 距離
    ; cf > 1 = 見つけた
    ; a  > 見つけた距離

    ; プレイヤの存在
    ld      a, (_player + PLAYER_FLAG)
    bit     #PLAYER_FLAG_HIT_BIT, a
    jr      nz, 10$
    ld      a, #0xff
    or      a
    jr      19$

    ; プレイヤとの位置関係の判定
10$:
    ld      a, (_player + PLAYER_POSITION_L_H)
    sub     e
    ld      b, a
    xor     d
    and     #0x80
    jr      nz, 19$
    ld      a, b
    or      a
    jp      p, 11$
    neg
11$:
    cp      c
19$:

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; プレイヤが行動しているかどうかを判定する
;
_PlayerIsPlay::

    ; レジスタの保存

    ; cf > 1 = 行動している

    ; 状態の監視
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    cp      #PLAYER_STATE_PLAY
    jr      z, 10$
    or      a
    jr      19$
10$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが存在しているかどうかを判定する
;
_PlayerIsLive::

    ; レジスタの保存

    ; cf > 1 = 存在している

    ; 状態の監視
    ld      a, (_player + PLAYER_STATE)
    and     #0xf0
    jr      z, 19$
    scf
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
playerProc:
    
    .dw     PlayerNull
    .dw     PlayerStart
    .dw     PlayerPlay
    .dw     PlayerCaught
    .dw     PlayerFinish

; プレイヤの初期値
;
playerDefault:

    .db     PLAYER_STATE_NULL
    .db     PLAYER_FLAG_CC ; PLAYER_FLAG_NULL
    .dw     0x0000 ; PLAYER_POSITION_NULL
    .dw     0x0000 ; PLAYER_POSITION_NULL
    .db     PLAYER_POSITION_NULL
    .db     PLAYER_POSITION_NULL
    .dw     PLAYER_SPEED_NULL
    .dw     PLAYER_SPEED_NULL
    .dw     PLAYER_ESCAPE_NULL
    .db     PLAYER_LOOP_NULL
    .db     PLAYER_JEWELRY_NULL
    .db     PLAYER_FRAME_NULL
    .db     PLAYER_ROTATE_NULL
    .db     PLAYER_ANIMATION_NULL
    .db     PLAYER_BLINK_NULL
    .dw     PLAYER_SPRITE_NULL
    .dw     PLAYER_PATTERN_NULL

; スプライト
;
playerSprite:

    .db     -0x10 - 0x01, -0x08, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x0e - 0x01, -0x0c, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x0e - 0x01, -0x0e, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x0c - 0x01, -0x0e, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01, -0x10, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x04 - 0x01, -0x0e, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x02 - 0x01, -0x0e, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x02 - 0x01, -0x0c, 0x04, VDP_COLOR_MEDIUM_RED
    .db      0x01 - 0x01, -0x08, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x02 - 0x01, -0x04, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x02 - 0x01, -0x02, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x04 - 0x01, -0x02, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x08 - 0x01,  0x01, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x0c - 0x01, -0x02, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x0e - 0x01, -0x02, 0x04, VDP_COLOR_MEDIUM_RED
    .db     -0x0e - 0x01, -0x04, 0x04, VDP_COLOR_MEDIUM_RED

; 色
;
playerColor:

    .db     VDP_COLOR_LIGHT_RED
    .db     VDP_COLOR_LIGHT_GREEN
    .db     VDP_COLOR_LIGHT_BLUE
    .db     VDP_COLOR_LIGHT_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH

