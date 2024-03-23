; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; BGM を再生する
;
_SoundPlayBgm::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < BGM

    ; 現在再生している BGM の取得
    ld      bc, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_HEAD)

    ; サウンドの再生
    add     a, a
    ld      e, a
    add     a, a
    add     a, e
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundBgm
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      a, e
    cp      c
    jr      nz, 10$
    ld      a, d
    cp      b
    jr      z, 19$
10$:
    ld      (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST), de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST), de
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; SE を再生する
;
_SoundPlaySe::

    ; レジスタの保存
    push    hl
    push    de

    ; a < SE

    ; サウンドの再生
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST), de

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; BGM が再生中かどうかを判定する
;
_SoundIsPlayBgm::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; SE が再生中かどうかを判定する
;
_SoundIsPlaySe::

    ; レジスタの保存
    push    hl

    ; cf > 0/1 = 停止/再生中

    ; サウンドの監視
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_REQUEST)
    ld      a, h
    or      l
    jr      nz, 10$
    ld      hl, (_soundChannel + SOUND_CHANNEL_D + SOUND_CHANNEL_PLAY)
    ld      a, h
    or      l
    jr      nz, 10$
    or      a
    jr      19$
10$:
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; BGM
;
soundBgm:

    .dw     soundNull, soundNull, soundNull
    .dw     soundBgmPart1A, soundBgmPart1B, soundBgmPart1C

; その１
soundBgmPart1A:

    .ascii  "T3@1V15,5"
    .ascii  "L3O4DD6DD6DD6DD6"
    .ascii  "L3R7O4DD5DF+6DR7"
    .ascii  "L3R7O4DD5DF+6AR7"
    .ascii  "L3O4BF+6O5C+O4A6BF+6O5C+O4A6"
    .ascii  "L3R7O4BB5BB6BR7"
    .ascii  "L3R7O4BB5BB6BR7"
    .db     0xff

soundBgmPart1B:

    .ascii  "T3S0N2"
    .ascii  "@7V13,8L7O3BA+AG+"
    .ascii  "@0V16L5M5XX@7V13,8L3R7O4C+6O3AR7"
    .ascii  "@0V16L5M5XX@7V13,8L3R7O4C+6F+R7"
    .ascii  "@7V13,8L7O4F+AF+A"
    .ascii  "@0V16L5M5XX@7V13,8L3R7O4G+6F+R7"
    .ascii  "@0V16L5M5XX@7V13,8L3R7O4G+6G+R7"
    .db     0xff

soundBgmPart1C:

    .ascii  "T3@7V13,8"
    .ascii  "L7O3F+F+FE"
    .ascii  "L3R7R7O3A6F+R7"
    .ascii  "L3R7R7O3A6O4C+R7"
    .ascii  "L7O4DF+DF+"
    .ascii  "L3R7R7O4E6D+R7"
    .ascii  "L3R7R7O4E6ER7"
    .db     0xff

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeJump
    .dw     soundSeCoin
    .dw     soundSeHeliIn
    .dw     soundSeHeliOut

; ブート
soundSeBoot:

    .ascii  "T2@0V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2@0V15O4B0"
    .db     0x00

; ジャンプ
soundSeJump:

    .ascii  "T1@0V15L0O4A1O3ABO4C+D+FGABO5C+D+FGA"
    .db     0x00

; コイン
soundSeCoin:

    .ascii  "T1@0V15,4O5B3O6E9"
    .db     0x00

; ヘリ
soundSeHeliIn:

    .ascii  "T1@0V12O3L1BR"
    .db     0xff

soundSeHeliOut:

    .ascii  "T1@0V11O3L1BR"
    .db     0xff


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
