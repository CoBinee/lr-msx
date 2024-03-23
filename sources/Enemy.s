; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Player.inc"
    .include    "Treasure.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;
    .globl  _patternTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存
    
    ; エネミーの初期化
    ld      hl, #enemyDefault
    ld      de, #_enemy
    ld      bc, #(ENEMY_LENGTH * ENEMY_ENTRY)
    ldir
    
    ; スプライトの初期化
    ld      hl, #0x0000
    ld      (enemySpriteRotate), hl

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; 種類別の処理
    ld      a, ENEMY_TYPE(ix)
    or      a
    jr      z, 190$
    ld      hl, #101$
    push    hl
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
101$:

    ; アニメーションの更新
    bit     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)
    jr      z, 110$
    inc     ENEMY_ANIMATION(ix)
110$:

    ; 位置の更新
    ld      e, ENEMY_POSITION_L_H(ix)
    ld      d, ENEMY_POSITION_R_H(ix)
    call    _GameGetLRtoXY
    ld      ENEMY_POSITION_X(ix), e
    ld      ENEMY_POSITION_Y(ix), d

    ; プレイヤの逮捕
    bit     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)
    jr      z, 129$
    ld      e, ENEMY_POSITION_L_H(ix)
    ld      a, ENEMY_POSITION_R_H(ix)
    add     a, ENEMY_HIT_OR(ix)
    ld      d, a
    ld      c, ENEMY_HIT_SIZE_L(ix)
    ld      b, ENEMY_HIT_SIZE_R(ix)
    call    _PlayerIsCaught
    jr      nc, 129$
    cp      #PLAYER_HIT_CAUGHT
    jr      nz, 120$
    ld      a, #ENEMY_STATE_CATCH
    jr      121$
120$:
    ld      a, #ENEMY_STATE_ESCAPE
;   jr      121$
121$:
    ld      ENEMY_STATE(ix), a
;   jr      129$
129$:

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      de, #(_sprite + GAME_SPRITE_ENEMY)
    ld      l, a
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; 描画の確認
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      z, 19$
    bit     #0x04, ENEMY_BLINK(ix)
    jr      nz, 19$

    ; スプライトの描画
    ld      bc, #0x0000
    ld      a, ENEMY_PATTERN_L(ix)
    or      ENEMY_PATTERN_H(ix)
    jr      z, 11$
    ld      a, ENEMY_POSITION_L_H(ix)
    add     a, #0x08
    and     #0xf0
    rrca
    rrca
    ld      c, a
11$:
    ld      l, ENEMY_SPRITE_L(ix)
    ld      h, ENEMY_SPRITE_H(ix)
    add     hl, bc
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, ENEMY_POSITION_X(ix)
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
;   inc     hl
    inc     de

    ; 次のエネミーへ
19$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; VRAM へ転送する
;
_EnemyTransfer::

    ; レジスタの保存
    push    de

    ; d < ポート #0
    ; e < ポート #1

    ; スプライトジェネレータの転送
    ld      ix, #_enemy
    ld      bc, #0x0040
    ld      a, #ENEMY_ENTRY
10$:
    push    af
    ld      l, ENEMY_PATTERN_L(ix)
    ld      h, ENEMY_PATTERN_H(ix)
    ld      a, h
    or      l
    jr      z, 11$
    push    bc
    call    _GameTransferSpriteGenerator
    pop     bc
11$:
    ld      hl, #0x0020
    add     hl, bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    ld      c, l
    ld      b, h
    pop     af
    dec     a
    jr      nz, 10$

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 何もしない
;
EnemyNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを逮捕した
;
EnemyCatch:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; ヒットの解除
    res     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; アニメーションの停止
    res     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤに逃げられた
;
EnemyEscape:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 速度の設定
    ld      hl, #ENEMY_SPEED_JUMP
    ld      ENEMY_SPEED_R_L(ix), l
    ld      ENEMY_SPEED_R_H(ix), h

    ; ヒットの解除
    res     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; アニメーションの停止
    res     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 回転の設定
    set     #ENEMY_FLAG_ROTATE_BIT, ENEMY_FLAG(ix)

    ; スコアの加算
    ld      a, #0x01
    call    _GameAddScore

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; ジャンプ
    call    EnemyJump

    ; 回転の更新
    bit     #ENEMY_FLAG_ROTATE_BIT, ENEMY_FLAG(ix)
    jr      z, 10$
    ld      a, ENEMY_ROTATE(ix)
    add     a, #0x10
    ld      ENEMY_ROTATE(ix), a
    jr      nz, 19$
    res     #ENEMY_FLAG_ROTATE_BIT, ENEMY_FLAG(ix)
10$:

    ; 逃走の監視
    ld      a, ENEMY_POSITION_R_L(ix)
    or      ENEMY_POSITION_R_H(ix)
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_DEFAULT
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 警部が行動する
;
EnemyInspector:

    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, ENEMY_STATE(ix)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyInspectorProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; パターンの設定
    call    EnemyGetPattern
    ld      de, #(_patternTable + 0x1800)
    add     hl, de
    ld      ENEMY_PATTERN_L(ix), l
    ld      ENEMY_PATTERN_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

; 状態別の処理
enemyInspectorProc:

    .dw     EnemyInspectorIn
    .dw     EnemyInspectorTurn
    .dw     EnemyInspectorWalk
    .dw     EnemyInspectorRun
    .dw     EnemyInspectorThrow
    .dw     EnemyCatch
    .dw     EnemyEscape

; 警部が出現する
EnemyInspectorIn:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 宝石の監視
    ld      a, #TREASURE_TYPE_JEWELRY
    call    _TreasureGetHitCount
    cp      ENEMY_PARAM_0(ix)
    jr      c, 90$

    ; 位置の設定
    call    _PlayerGetFarPosition
    ld      ENEMY_POSITION_L_H(ix), a
    xor     a
    ld      ENEMY_POSITION_L_L(ix), a
    ld      ENEMY_POSITION_R_L(ix), a
    ld      ENEMY_POSITION_R_H(ix), a

    ; 向きの設定
    call    _SystemGetRandom
    and     #0x04
    call    nz, EnemyTurn

    ; 点滅の設定
    ld      ENEMY_BLINK(ix), #ENEMY_BLINK_START

    ; ヒットの解除
    res     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; アニメーションの停止
    res     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 点滅の更新
    dec     ENEMY_BLINK(ix)
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_INSPECTOR_TURN
;   jr      19$
19$:

    ; 出現の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 警部が方向転換する
EnemyInspectorTurn:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    call    _SystemGetRandom
    and     #0x20
    add     a, #0x81
    ld      ENEMY_FRAME_L(ix), a
    ld      ENEMY_FRAME_H(ix), #0x00

    ; ヒットの設定
    set     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; アニメーションの停止
    res     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; フレームの更新
    call    EnemyDownFrame
    ld      a, l
    and     #0x1f
    jr      nz, 19$

    ; 方向転換
    call    EnemyTurn

    ; プレイヤの発見
    ld      e, ENEMY_POSITION_L_H(ix)
    ld      d, ENEMY_SPEED_L_H(ix)
    ld      c, #ENEMY_FIND_INSPECTOR_THROW
    call    _PlayerIsFind
    jr      nc, 11$

    ; 手錠を投げる
    cp      #ENEMY_FIND_INSPECTOR_RUN
    jr      c, 10$
    call    _SystemGetRandom
    and     #0x30
    jr      z, 10$
    ld      ENEMY_STATE(ix), #ENEMY_STATE_INSPECTOR_THROW
    jr      19$

    ; 追跡する
10$:
    ld      ENEMY_STATE(ix), #ENEMY_STATE_INSPECTOR_RUN
    jr      19$

    ; フレームの更新の完了
11$:
    ld      a, ENEMY_FRAME_L(ix)
    or      ENEMY_FRAME_H(ix)
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_INSPECTOR_WALK
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 警部が移動する
EnemyInspectorWalk:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 速度の設定
    ld      hl, #ENEMY_SPEED_INSPECTOR_WALK
    call    EnemyChangeSpeedL

    ; フレームの設定
    call    _SystemGetRandom
    and     #0x3f
    add     a, #0x40
    ld      ENEMY_FRAME_L(ix), a
    ld      ENEMY_FRAME_H(ix), #0x00

    ; アニメーションの開始
    set     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyWalk

    ; フレームの更新
    call    EnemyDownFrame
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_INSPECTOR_TURN
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 警部が追跡する
EnemyInspectorRun:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 速度の設定
    ld      hl, #ENEMY_SPEED_INSPECTOR_RUN
    call    EnemyChangeSpeedL

    ; フレームの設定
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x10
    ld      ENEMY_FRAME_L(ix), a
    ld      ENEMY_FRAME_H(ix), #0x00

    ; アニメーションの開始
    set     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyWalk

    ; プレイヤの発見
    ld      e, ENEMY_POSITION_L_H(ix)
    ld      d, ENEMY_SPEED_L_H(ix)
    ld      c, #(ENEMY_FIND_INSPECTOR_RUN + 0x10)
    call    _PlayerIsFind
    jr      c, 19$

    ; フレームの更新
    call    EnemyDownFrame
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_INSPECTOR_TURN
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 警部が手錠を投げる
EnemyInspectorThrow:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 投げる
    call    EnemyThrowHandcuff

    ; フレームの設定
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x40
    ld      ENEMY_FRAME_L(ix), a
    ld      ENEMY_FRAME_H(ix), #0x00

    ; アニメーションの停止
    res     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; フレームの更新
    call    EnemyDownFrame
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_INSPECTOR_WALK
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 警官が行動する
;
EnemyOfficer:

    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, ENEMY_STATE(ix)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyOfficerProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; パターンの設定
    call    EnemyGetPattern
    ld      de, #(_patternTable + 0x2000)
    add     hl, de
    ld      ENEMY_PATTERN_L(ix), l
    ld      ENEMY_PATTERN_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

; 状態別の処理
enemyOfficerProc:

    .dw     EnemyOfficerIn
    .dw     EnemyOfficerWalk
    .dw     EnemyOfficerTurn
    .dw     EnemyNull
    .dw     EnemyNull
    .dw     EnemyCatch
    .dw     EnemyEscape

; 警官が出現する
EnemyOfficerIn:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; スコアの監視
    ld      e, ENEMY_PARAM_0(ix)
    ld      d, #0x00
    ld      hl, (_game + GAME_SCORE_L)
    or      a
    sbc     hl, de
    jp      c, 90$

    ; 位置の設定
    call    _PlayerGetFarPosition
    ld      ENEMY_POSITION_L_H(ix), a
    xor     a
    ld      ENEMY_POSITION_L_L(ix), a
    ld      ENEMY_POSITION_R_L(ix), a
    ld      ENEMY_POSITION_R_H(ix), a

    ; 向きの設定
    call    _SystemGetRandom
    and     #0x04
    call    nz, EnemyTurn

    ; 点滅の設定
    ld      ENEMY_BLINK(ix), #ENEMY_BLINK_START

    ; ヒットの解除
    res     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; アニメーションの停止
    res     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 点滅の更新
    dec     ENEMY_BLINK(ix)
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_OFFICER_WALK
;   jr      19$
19$:

    ; 出現の完了
90$:

    ; レジスタの復帰

    ;終了
    ret

; 警官が移動する
EnemyOfficerWalk:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    call    _SystemGetRandom
    ld      e, a
    ld      d, #0x00
    ld      hl, #0x00c0
    add     hl, de
    ld      ENEMY_FRAME_L(ix), l
    ld      ENEMY_FRAME_H(ix), h

    ; ヒットの設定
    set     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; アニメーションの開始
    set     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyWalk

    ; フレームの更新
    call    EnemyDownFrame
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_OFFICER_TURN
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 警官が方向転換する
EnemyOfficerTurn:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    call    _SystemGetRandom
    and     #0x20
    add     a, #0x81
    ld      ENEMY_FRAME_L(ix), a
    ld      ENEMY_FRAME_H(ix), #0x00

    ; アニメーションの停止
    res     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 方向転換の開始
    inc     ENEMY_STATE(ix)
09$:

    ; フレームの更新
    call    EnemyDownFrame
    jr      z, 10$

    ; 方向転換
    ld      a, l
    and     #0x1f
    call    z, EnemyTurn
    jr      19$

    ; 状態の更新
10$:
    ld      ENEMY_STATE(ix), #ENEMY_STATE_OFFICER_WALK
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 警察犬が行動する
;
EnemyDog:

    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, ENEMY_STATE(ix)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDogProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; パターンの設定
    call    EnemyGetPattern
    ld      de, #(_patternTable + 0x2800)
    add     hl, de
    ld      ENEMY_PATTERN_L(ix), l
    ld      ENEMY_PATTERN_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

; 状態別の処理
enemyDogProc:

    .dw     EnemyDogIn
    .dw     EnemyDogStay
    .dw     EnemyDogWalk
    .dw     EnemyDogRun
    .dw     EnemyNull
    .dw     EnemyCatch
    .dw     EnemyEscape

; 警察犬が出現する
EnemyDogIn:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; スコアの監視
    ld      e, ENEMY_PARAM_0(ix)
    ld      d, #0x00
    ld      hl, (_game + GAME_SCORE_L)
    or      a
    sbc     hl, de
    jp      c, 90$

    ; 位置の設定
    call    _PlayerGetFarPosition
    ld      ENEMY_POSITION_L_H(ix), a
    xor     a
    ld      ENEMY_POSITION_L_L(ix), a
    ld      ENEMY_POSITION_R_L(ix), a
    ld      ENEMY_POSITION_R_H(ix), a

    ; 向きの設定
    call    _SystemGetRandom
    and     #0x04
    call    nz, EnemyTurn

    ; 点滅の設定
    ld      ENEMY_BLINK(ix), #ENEMY_BLINK_START

    ; ヒットの解除
    res     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; アニメーションの停止
    res     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 点滅の更新
    dec     ENEMY_BLINK(ix)
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_DOG_STAY
;   jr      19$
19$:

    ; 出現の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 警察犬が待機する
EnemyDogStay:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    call    _SystemGetRandom
    and     #0x7f
    add     a, #0x40
    ld      ENEMY_FRAME_L(ix), a
    ld      ENEMY_FRAME_H(ix), #0x00

    ; アニメーションの停止
    res     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 停止の開始
    inc     ENEMY_STATE(ix)
09$:

    ; フレームの更新
    call    EnemyDownFrame
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_DOG_WALK
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 警察犬が移動する
EnemyDogWalk:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 速度の設定
    ld      hl, #ENEMY_SPEED_DOG_WALK
    call    EnemyChangeSpeedL

    ; 向きの設定
    call    _SystemGetRandom
    and     #0x04
    call    nz, EnemyTurn

    ; フレームの設定
    call    _SystemGetRandom
    ld      e, a
    ld      d, #0x00
    ld      hl, #0x00c0
    add     hl, de
    ld      ENEMY_FRAME_L(ix), l
    ld      ENEMY_FRAME_H(ix), h

    ; ヒットの設定
    set     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; アニメーションの開始
    set     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyWalk

    ; プレイヤの発見
    ld      e, ENEMY_POSITION_L_H(ix)
    ld      d, ENEMY_SPEED_L_H(ix)
    ld      c, #ENEMY_FIND_DOG_RUN
    call    _PlayerIsFind
    jr      nc, 10$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_DOG_RUN
    jr      19$

    ; フレームの更新
10$:
    call    EnemyDownFrame
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_DOG_STAY
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 警察犬が追跡する
EnemyDogRun:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    and     #0x0f
    jr      nz, 09$

    ; 速度の設定
    ld      hl, #ENEMY_SPEED_DOG_RUN
    call    EnemyChangeSpeedL

    ; フレームの設定
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x20
    ld      ENEMY_FRAME_L(ix), a
    ld      ENEMY_FRAME_H(ix), #0x00

    ; アニメーションの開始
    set     #ENEMY_FLAG_ANIMATION_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 移動
    call    EnemyWalk

    ; プレイヤの発見
    ld      e, ENEMY_POSITION_L_H(ix)
    ld      d, ENEMY_SPEED_L_H(ix)
    ld      c, #(ENEMY_FIND_DOG_RUN + 0x08)
    call    _PlayerIsFind
    jr      c, 19$

    ; フレームの更新
    call    EnemyDownFrame
    jr      nz, 19$

    ; 状態の更新
    ld      ENEMY_STATE(ix), #ENEMY_STATE_DOG_STAY
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 手錠が行動する
;
EnemyHandcuff:

    ; レジスタの保存

    ; リクエストの監視
    bit     #ENEMY_FLAG_REQUEST_BIT, ENEMY_FLAG(ix)
    jr      z, 99$

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; フレームの設定
    ld      hl, #(0xa000 / ENEMY_SPEED_HANDCUFF)
    ld      ENEMY_FRAME_L(ix), l
    ld      ENEMY_FRAME_H(ix), h

    ; ヒットの設定
    set     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; 初期化の完了
    ld      ENEMY_STATE(ix), #0x10
09$:

    ; 移動
    call    EnemyWalk

    ; フレームの更新
    call    EnemyDownFrame
    jr      nz, 90$
    
    ; ヒットの解除
    res     #ENEMY_FLAG_HIT_BIT, ENEMY_FLAG(ix)

    ; リクエストの終了
    res     #ENEMY_FLAG_REQUEST_BIT, ENEMY_FLAG(ix)

    ; 状態の更新
    ld      ENEMY_STATE(ix), #0x00
    jr      99$

    ; 更新
90$:

    ; スプライトの取得
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x03
    add     a, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemySpriteHandcuff
    add     hl, de
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; 完了
99$:

    ; レジスタの復帰

    ; 終了
    ret

; 手錠を投げる
;
EnemyThrowHandcuff:

    ; レジスタの保存

    ; ix < 投げるエネミー
    ; cf > 1 = 投げた

    ; 手錠の取得
    ld      a, #ENEMY_TYPE_HANDCUFF
    call    EnemyFindByType
    jr      nc, 19$
    bit     #ENEMY_FLAG_REQUEST_BIT, ENEMY_FLAG(iy)
    jr      nz, 19$

    ; 位置の設定
    ld      a, ENEMY_POSITION_L_H(ix)
    ld      ENEMY_POSITION_L_H(iy), a
    xor     a
    ld      ENEMY_POSITION_L_L(iy), a
    ld      ENEMY_POSITION_R_L(iy), a
    ld      ENEMY_POSITION_R_H(iy), #0x08

    ; 速度の設定
    ld      hl, #ENEMY_SPEED_HANDCUFF
    bit     #0x07, ENEMY_SPEED_L_H(ix)
    jr      z, 10$
    ld      hl, #-ENEMY_SPEED_HANDCUFF
10$:
    ld      ENEMY_SPEED_L_L(iy), l
    ld      ENEMY_SPEED_L_H(iy), h

    ; リクエストの設定
    set     #ENEMY_FLAG_REQUEST_BIT, ENEMY_FLAG(iy)

    ; 投げるの完了
    scf
19$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを取得する
;
EnemyFindByType:

    ; レジスタの保存
    push    bc
    push    de

    ; a  < エネミーの種類
    ; iy > エネミー
    ; cf > 1 = エネミーが存在

    ; エネミーの検索
    ld      iy, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
10$:
    cp      ENEMY_TYPE(iy)
    jr      z, 11$
    add     iy, de
    djnz    10$
    or      a
    jr      19$
11$:
    scf
19$:

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; エネミーを移動させる
;
EnemyWalk:

    ; レジスタの保存

    ; L 位置の更新
    ld      l, ENEMY_POSITION_L_L(ix)
    ld      h, ENEMY_POSITION_L_H(ix)
    ld      e, ENEMY_SPEED_L_L(ix)
    ld      d, ENEMY_SPEED_L_H(ix)
    add     hl, de
    ld      ENEMY_POSITION_L_L(ix), l
    ld      ENEMY_POSITION_L_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

EnemyJump:

    ; レジスタの保存

    ; R 位置の更新
    ld      l, ENEMY_SPEED_R_L(ix)
    ld      h, ENEMY_SPEED_R_H(ix)
    ld      de, #ENEMY_SPEED_GRAVITY
    add     hl, de
    ex      de, hl
    ld      l, ENEMY_POSITION_R_L(ix)
    ld      h, ENEMY_POSITION_R_H(ix)
    xor     a
    adc     hl, de
    jp      p, 10$
    ld      l, a
    ld      h, a
    ld      e, a
    ld      d, a
10$:
    ld      ENEMY_POSITION_R_L(ix), l
    ld      ENEMY_POSITION_R_H(ix), h
    ld      ENEMY_SPEED_R_L(ix), e
    ld      ENEMY_SPEED_R_H(ix), d

    ; レジスタの復帰

    ; 終了
    ret

; エネミーの向きを変える
;
EnemyTurn:

    ; レジスタの保存

    ; L 速度の反転
    ld      a, ENEMY_SPEED_L_L(ix)
    cpl
    ld      l, a
    ld      a, ENEMY_SPEED_L_H(ix)
    cpl
    ld      h, a
    inc     hl
    ld      ENEMY_SPEED_L_L(ix), l
    ld      ENEMY_SPEED_L_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

; エネミーの速度を変更する
;
EnemyChangeSpeedL:

    ; レジスタの保存

    ; hl < 速度

    ; 速度の変更
    ld      a, ENEMY_SPEED_L_H(ix)
    or      a
    jp      p, 10$
    ld      a, l
    cpl
    ld      l, a
    ld      a, h
    cpl
    ld      h, a
    inc     hl
10$:
    ld      ENEMY_SPEED_L_L(ix), l
    ld      ENEMY_SPEED_L_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

; フレームを 1 減らす
;
EnemyDownFrame:

    ; レジスタの保存

    ; hl > フレーム
    ; zf > 0

    ; フレームの更新
    ld      l, ENEMY_FRAME_L(ix)
    ld      h, ENEMY_FRAME_H(ix)
    dec     hl
    ld      ENEMY_FRAME_L(ix), l
    ld      ENEMY_FRAME_H(ix), h
    ld      a, h
    or      l

    ; レジスタの復帰

    ; 終了
    ret

; パターンを取得する
;
EnemyGetPattern:

    ; レジスタの保存

    ; hl > パターン

    ; パターンの取得
    ld      hl, #0x0000
    bit     #0x07, ENEMY_SPEED_L_H(ix)
    jr      nz, 10$
    ld      de, #0x0400
    add     hl, de
10$:
    ld      a, ENEMY_SPEED_R_L(ix)
    or      ENEMY_SPEED_R_H(ix)
    jr      nz, 11$
    ld      a, ENEMY_ANIMATION(ix)
    and     #0x10
    jr      z, 12$
11$:
    ld      de, #0x0200
    add     hl, de
12$:
    ld      a, ENEMY_POSITION_L_H(ix)
    add     a, #0x08
    add     a, ENEMY_ROTATE(ix)
    ld      e, a
    and     #0x80
    rlca
    ld      d, a
    ld      a, e
    and     #0x70
    ld      e, a
    add     hl, de

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 種類別の処理
;
enemyProc:
    
    .dw     EnemyNull
    .dw     EnemyInspector
    .dw     EnemyOfficer
    .dw     EnemyDog
    .dw     EnemyHandcuff

; エネミーの初期値
;
enemyDefault:

    ; 警部
    .db     ENEMY_TYPE_INSPECTOR
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     ENEMY_SPEED_INSPECTOR_WALK ; ENEMY_SPEED_NULL
    .dw     0x0000 ; ENEMY_SPEED_NULL
    .dw     ENEMY_FRAME_NULL
    .db     ENEMY_ROTATE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     enemySprite + 0x0000
    .dw     ENEMY_PATTERN_NULL
    .db     0x08 ; ENEMY_HIT_NULL
    .db     0x04 ; ENEMY_HIT_NULL
    .db     0x06 ; ENEMY_HIT_NULL
    .db     2 ; ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

    ; 警官 1
    .db     ENEMY_TYPE_OFFICER
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     ENEMY_SPEED_OFFICER_SLOW ; ENEMY_SPEED_NULL
    .dw     0x0000 ; ENEMY_SPEED_NULL
    .dw     ENEMY_FRAME_NULL
    .db     ENEMY_ROTATE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     enemySprite + 0x0040
    .dw     ENEMY_PATTERN_NULL
    .db     0x08 ; ENEMY_HIT_NULL
    .db     0x04 ; ENEMY_HIT_NULL
    .db     0x06 ; ENEMY_HIT_NULL
    .db     0 ; ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

    ; 警官 2
    .db     ENEMY_TYPE_OFFICER
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     0x0000 ; ENEMY_POSITION_NULL
    .dw     0x0000 ; ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     ENEMY_SPEED_OFFICER_SLOW ; ENEMY_SPEED_NULL
    .dw     0x0000 ; ENEMY_SPEED_NULL
    .dw     ENEMY_FRAME_NULL
    .db     ENEMY_ROTATE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     enemySprite + 0x0080
    .dw     ENEMY_PATTERN_NULL
    .db     0x08 ; ENEMY_HIT_NULL
    .db     0x04 ; ENEMY_HIT_NULL
    .db     0x06 ; ENEMY_HIT_NULL
    .db     10 ; ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

    ; 警官 3
    .db     ENEMY_TYPE_OFFICER
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     0x0000 ; ENEMY_POSITION_NULL
    .dw     0x0000 ; ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     ENEMY_SPEED_OFFICER_FAST ; ENEMY_SPEED_NULL
    .dw     0x0000 ; ENEMY_SPEED_NULL
    .dw     ENEMY_FRAME_NULL
    .db     ENEMY_ROTATE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     enemySprite + 0x00c0
    .dw     ENEMY_PATTERN_NULL
    .db     0x08 ; ENEMY_HIT_NULL
    .db     0x04 ; ENEMY_HIT_NULL
    .db     0x06 ; ENEMY_HIT_NULL
    .db     100 ; ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

    ; 警察犬
    .db     ENEMY_TYPE_DOG
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     ENEMY_SPEED_DOG_WALK ; ENEMY_SPEED_NULL
    .dw     0x0000 ; ENEMY_SPEED_NULL
    .dw     ENEMY_FRAME_NULL
    .db     ENEMY_ROTATE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     enemySprite + 0x0100
    .dw     ENEMY_PATTERN_NULL
    .db     0x04 ; ENEMY_HIT_NULL
    .db     0x06 ; ENEMY_HIT_NULL
    .db     0x05 ; ENEMY_HIT_NULL
    .db     30 ; ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

    ; 手錠
    .db     ENEMY_TYPE_HANDCUFF
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_ANIAMTION ; ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     ENEMY_SPEED_NULL
    .dw     ENEMY_SPEED_NULL
    .dw     ENEMY_FRAME_NULL
    .db     ENEMY_ROTATE_NULL
    .db     ENEMY_ANIMATION_NULL
    .db     ENEMY_BLINK_NULL
    .dw     ENEMY_SPRITE_NULL
    .dw     ENEMY_PATTERN_NULL
    .db     0x00 ; ENEMY_HIT_NULL
    .db     0x06 ; ENEMY_HIT_NULL
    .db     0x06 ; ENEMY_HIT_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL
    .db     ENEMY_PARAM_NULL

; スプライト
;
enemySprite:

    ; 警部
    .db     -0x10 - 0x01, -0x08, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x0f - 0x01, -0x0c, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x0e - 0x01, -0x0e, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x0c - 0x01, -0x0f, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x08 - 0x01, -0x10, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x04 - 0x01, -0x0f, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x02 - 0x01, -0x0e, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x01 - 0x01, -0x0c, 0x08, VDP_COLOR_DARK_YELLOW
    .db      0x01 - 0x01, -0x08, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x01 - 0x01, -0x04, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x02 - 0x01, -0x02, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x04 - 0x01, -0x01, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x08 - 0x01,  0x01, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x0c - 0x01, -0x01, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x0e - 0x01, -0x02, 0x08, VDP_COLOR_DARK_YELLOW
    .db     -0x0f - 0x01, -0x04, 0x08, VDP_COLOR_DARK_YELLOW

    ; 警官 1
    .db     -0x10 - 0x01, -0x08, 0x0c, VDP_COLOR_CYAN
    .db     -0x0f - 0x01, -0x0c, 0x0c, VDP_COLOR_CYAN
    .db     -0x0e - 0x01, -0x0e, 0x0c, VDP_COLOR_CYAN
    .db     -0x0c - 0x01, -0x0f, 0x0c, VDP_COLOR_CYAN
    .db     -0x08 - 0x01, -0x10, 0x0c, VDP_COLOR_CYAN
    .db     -0x04 - 0x01, -0x0f, 0x0c, VDP_COLOR_CYAN
    .db     -0x02 - 0x01, -0x0e, 0x0c, VDP_COLOR_CYAN
    .db     -0x01 - 0x01, -0x0c, 0x0c, VDP_COLOR_CYAN
    .db      0x01 - 0x01, -0x08, 0x0c, VDP_COLOR_CYAN
    .db     -0x01 - 0x01, -0x04, 0x0c, VDP_COLOR_CYAN
    .db     -0x02 - 0x01, -0x02, 0x0c, VDP_COLOR_CYAN
    .db     -0x04 - 0x01, -0x01, 0x0c, VDP_COLOR_CYAN
    .db     -0x08 - 0x01,  0x01, 0x0c, VDP_COLOR_CYAN
    .db     -0x0c - 0x01, -0x01, 0x0c, VDP_COLOR_CYAN
    .db     -0x0e - 0x01, -0x02, 0x0c, VDP_COLOR_CYAN
    .db     -0x0f - 0x01, -0x04, 0x0c, VDP_COLOR_CYAN
    
    ; 警官 2
    .db     -0x10 - 0x01, -0x08, 0x10, VDP_COLOR_CYAN
    .db     -0x0f - 0x01, -0x0c, 0x10, VDP_COLOR_CYAN
    .db     -0x0e - 0x01, -0x0e, 0x10, VDP_COLOR_CYAN
    .db     -0x0c - 0x01, -0x0f, 0x10, VDP_COLOR_CYAN
    .db     -0x08 - 0x01, -0x10, 0x10, VDP_COLOR_CYAN
    .db     -0x04 - 0x01, -0x0f, 0x10, VDP_COLOR_CYAN
    .db     -0x02 - 0x01, -0x0e, 0x10, VDP_COLOR_CYAN
    .db     -0x01 - 0x01, -0x0c, 0x10, VDP_COLOR_CYAN
    .db      0x01 - 0x01, -0x08, 0x10, VDP_COLOR_CYAN
    .db     -0x01 - 0x01, -0x04, 0x10, VDP_COLOR_CYAN
    .db     -0x02 - 0x01, -0x02, 0x10, VDP_COLOR_CYAN
    .db     -0x04 - 0x01, -0x01, 0x10, VDP_COLOR_CYAN
    .db     -0x08 - 0x01,  0x01, 0x10, VDP_COLOR_CYAN
    .db     -0x0c - 0x01, -0x01, 0x10, VDP_COLOR_CYAN
    .db     -0x0e - 0x01, -0x02, 0x10, VDP_COLOR_CYAN
    .db     -0x0f - 0x01, -0x04, 0x10, VDP_COLOR_CYAN

    ; 警官 3
    .db     -0x10 - 0x01, -0x08, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x0f - 0x01, -0x0c, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x0e - 0x01, -0x0e, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x0c - 0x01, -0x0f, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x08 - 0x01, -0x10, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x04 - 0x01, -0x0f, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x02 - 0x01, -0x0e, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x01 - 0x01, -0x0c, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db      0x01 - 0x01, -0x08, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x01 - 0x01, -0x04, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x02 - 0x01, -0x02, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x04 - 0x01, -0x01, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x08 - 0x01,  0x01, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x0c - 0x01, -0x01, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x0e - 0x01, -0x02, 0x14, VDP_COLOR_MEDIUM_GREEN
    .db     -0x0f - 0x01, -0x04, 0x14, VDP_COLOR_MEDIUM_GREEN

    ; 警察犬    
    .db     -0x10 - 0x01, -0x08, 0x18, VDP_COLOR_MAGENTA
    .db     -0x0f - 0x01, -0x0c, 0x18, VDP_COLOR_MAGENTA
    .db     -0x0c - 0x01, -0x0c, 0x18, VDP_COLOR_MAGENTA
    .db     -0x0c - 0x01, -0x0f, 0x18, VDP_COLOR_MAGENTA
    .db     -0x08 - 0x01, -0x10, 0x18, VDP_COLOR_MAGENTA
    .db     -0x04 - 0x01, -0x0f, 0x18, VDP_COLOR_MAGENTA
    .db     -0x04 - 0x01, -0x0c, 0x18, VDP_COLOR_MAGENTA
    .db     -0x02 - 0x01, -0x0c, 0x18, VDP_COLOR_MAGENTA
    .db      0x01 - 0x01, -0x08, 0x18, VDP_COLOR_MAGENTA
    .db     -0x02 - 0x01, -0x04, 0x18, VDP_COLOR_MAGENTA
    .db     -0x04 - 0x01, -0x04, 0x18, VDP_COLOR_MAGENTA
    .db     -0x04 - 0x01, -0x02, 0x18, VDP_COLOR_MAGENTA
    .db     -0x08 - 0x01,  0x01, 0x18, VDP_COLOR_MAGENTA
    .db     -0x0c - 0x01, -0x02, 0x18, VDP_COLOR_MAGENTA
    .db     -0x0c - 0x01, -0x04, 0x18, VDP_COLOR_MAGENTA
    .db     -0x0f - 0x01, -0x04, 0x18, VDP_COLOR_MAGENTA

    ; 手錠
enemySpriteHandcuff:

    .db     -0x08 - 0x01, -0x08, 0x60, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x64, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x68, VDP_COLOR_WHITE
    .db     -0x08 - 0x01, -0x08, 0x6c, VDP_COLOR_WHITE
    

; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; スプライト
;
enemySpriteRotate:

    .ds     0x02

