; Altered source code from blog article:
; https://namelessalgorithm.com/genesis/blog/genesis/

RomHeader:
    dc.l   $00FFFFFE        ; Initial stack pointer value
    dc.l   EntryPoint       ; Start of program
    dc.l   ignore_handler   ; Bus error
    dc.l   ignore_handler   ; Address error
    dc.l   ignore_handler   ; Illegal instruction
    dc.l   ignore_handler   ; Division by zero
    dc.l   ignore_handler   ; CHK exception
    dc.l   ignore_handler   ; TRAPV exception
    dc.l   ignore_handler   ; Privilege violation
    dc.l   ignore_handler   ; TRACE exception
    dc.l   ignore_handler   ; Line-A emulator
    dc.l   ignore_handler   ; Line-F emulator
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Spurious exception
    dc.l   ignore_handler   ; IRQ level 1
    dc.l   ignore_handler   ; IRQ level 2
    dc.l   ignore_handler   ; IRQ level 3
    dc.l   ignore_handler   ; IRQ level 4 (horizontal retrace interrupt)
    dc.l   ignore_handler   ; IRQ level 5
    dc.l   ignore_handler   ; IRQ level 6 (vertical retrace interrupt)
    dc.l   ignore_handler   ; IRQ level 7
    dc.l   ignore_handler   ; TRAP #00 exception
    dc.l   ignore_handler   ; TRAP #01 exception
    dc.l   ignore_handler   ; TRAP #02 exception
    dc.l   ignore_handler   ; TRAP #03 exception
    dc.l   ignore_handler   ; TRAP #04 exception
    dc.l   ignore_handler   ; TRAP #05 exception
    dc.l   ignore_handler   ; TRAP #06 exception
    dc.l   ignore_handler   ; TRAP #07 exception
    dc.l   ignore_handler   ; TRAP #08 exception
    dc.l   ignore_handler   ; TRAP #09 exception
    dc.l   ignore_handler   ; TRAP #10 exception
    dc.l   ignore_handler   ; TRAP #11 exception
    dc.l   ignore_handler   ; TRAP #12 exception
    dc.l   ignore_handler   ; TRAP #13 exception
    dc.l   ignore_handler   ; TRAP #14 exception
    dc.l   ignore_handler   ; TRAP #15 exception
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)
    dc.l   ignore_handler   ; Unused (reserved)

    dc.b "SEGA GENESIS    " ; Console name
    dc.b "(C) NAMELESS    " ; Copyrght holder and release date
    dc.b "VERY MINIMAL GENESIS CODE BY NAMELESS ALGORITHM   " ; Domest. name
    dc.b "VERY MINIMAL GENESIS CODE BY NAMELESS ALGORITHM   " ; Intern. name
    dc.b "2018-07-02    "   ; Version number
    dc.w $0000              ; Checksum
    dc.b "J               " ; I/O support
    dc.l $00000000          ; Start address of ROM
    dc.l __end              ; End address of ROM
    dc.l $00FF0000          ; Start address of RAM
    dc.l $00FFFFFF          ; End address of RAM
    dc.l $00000000          ; SRAM enabled
    dc.l $00000000          ; Unused
    dc.l $00000000          ; Start address of SRAM
    dc.l $00000000          ; End address of SRAM
    dc.l $00000000          ; Unused
    dc.l $00000000          ; Unused
    dc.b "                                        " ; Notes (unused)
    dc.b "JUE             "                         ; Country codes

vdp_control_port     = $C00004 ; From Sega manual
vdp_data_port        = $C00000 ; From Sega manual

EntryPoint:
DisableTMSS:
    move.b  $00A10001,d0  ; Move Megadrive hardware version to d0
    andi.b  #$0F,d0       ; The version is stored in last four bits,
                          ; so mask it with 0F
    beq     PrepareToFillVDPRegisters         ; If version is equal to 0,skip TMSS signature
    move.l  #'SEGA',$00A14000 ; Move the string "SEGA" to TMSS IO Port

PrepareToFillVDPRegisters:
    move.l  #VDPRegisters,a0 ; Load address of register *initial settings* table into a0
    move.l  #$18,d0          ; 24 registers to write (counter)
    move.l  #$00008000,d1    ; (Set command) Enable write register mode for VDP control port interface, first bit enables writing to registry (1000 0000 0000 0000 (bin) = 8000 (HEX))

FillInitialStateForVDPRegistersLoop:
    move.b  (a0)+,d1         ; (Set data) Set register initial value from initial settings table into d1 interface
    move.w  d1,vdp_control_port     ; Send command + data to VDP Control Port
    add.w   #$0100,d1        ; Increment registry index +1 (by "binary adding" hex 100 (VDP control port registry mask))
    dbra    d0,FillInitialStateForVDPRegistersLoop ; Decrement until done

VDPControlPortEnableCRAMWriteAccessGreenColorAtIndex0:
    move.l  #$C0000000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #228,d0; Green color
    move.w  d0,vdp_data_port;

VDPControlPortEnableCRAMWriteAccessGreenColorAtIndex127:
  move.l  #$C07f0000,vdp_control_port ; Asking to VDP access CRAM at byte 127 (bits from sega manual) ; #$C07f0000 last color index 127
  move.w  #69,d0; Some color
  move.w  d0,vdp_data_port;

Stuck:
    jmp Stuck

; EXCEPTION AND INTERRUPT HANDLERS
; ----------------------------------------------------------------------------
    align 2 ; word-align code

ignore_handler
    rte ; return from exception (seems to restore PC)

    align 2 ; word-align code

VDPRegisters:
VDPReg0:   dc.b $14 ;  0: H interrupt on, palettes on
VDPReg1:   dc.b $74 ;  1: V interrupt on, display on, DMA on, Genesis mode on
VDPReg2:   dc.b $30 ;  2: Pattern table for Scroll Plane A at VRAM $C000
                    ;     (bits 3-5 = bits 13-15)
VDPReg3:   dc.b $00 ;  3: Pattern table for Window Plane at VRAM $0000
                    ;     (disabled) (bits 1-5 = bits 11-15)
VDPReg4:   dc.b $07 ;  4: Pattern table for Scroll Plane B at VRAM $E000
                    ;     (bits 0-2 = bits 11-15)
VDPReg5:   dc.b $78 ;  5: Sprite table at VRAM $F000 (bits 0-6 = bits 9-15)
VDPReg6:   dc.b $00 ;  6: Unused
VDPReg7:   dc.b $00 ;  7: Background colour - bits 0-3 = colour,
                    ;     bits 4-5 = palette
VDPReg8:   dc.b $00 ;  8: Unused
VDPReg9:   dc.b $00 ;  9: Unused
VDPRegA:   dc.b $FF ; 10: Frequency of Horiz. interrupt in Rasters
                    ;     (number of lines travelled by the beam)
VDPRegB:   dc.b $00 ; 11: External interrupts off, V scroll fullscreen,
                    ;     H scroll fullscreen
VDPRegC:   dc.b $81 ; 12: Shadows and highlights off, interlace off,
                    ;     H40 mode (320 x 224 screen res)
VDPRegD:   dc.b $3F ; 13: Horiz. scroll table at VRAM $FC00 (bits 0-5)
VDPRegE:   dc.b $00 ; 14: Unused
VDPRegF:   dc.b $02 ; 15: Autoincrement 2 bytes
VDPReg10:  dc.b $01 ; 16: Vert. scroll 32, Horiz. scroll 64
VDPReg11:  dc.b $00 ; 17: Window Plane X pos 0 left
                    ;     (pos in bits 0-4, left/right in bit 7)
VDPReg12:  dc.b $00 ; 18: Window Plane Y pos 0 up
                    ;     (pos in bits 0-4, up/down in bit 7)
VDPReg13:  dc.b $FF ; 19: DMA length lo byte
VDPReg14:  dc.b $FF ; 20: DMA length hi byte
VDPReg15:  dc.b $00 ; 21: DMA source address lo byte
VDPReg16:  dc.b $00 ; 22: DMA source address mid byte
VDPReg17:  dc.b $80 ; 23: DMA source address hi byte,
                    ;     memory-to-VRAM mode (bits 6-7)
__end:
