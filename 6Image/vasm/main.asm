; Altered source code from blog article:
; https://namelessalgorithm.com/genesis/blog/genesis/

RomHeader:
    dc.l   $00FFFFFE        ; Initial stack pointer value
    dc.l   EntryPoint       ; Start of program
    dc.l   exception_handler   ; Bus error
    dc.l   exception_handler   ; Address error
    dc.l   exception_handler   ; Illegal instruction
    dc.l   exception_handler   ; Division by zero
    dc.l   exception_handler   ; CHK exception
    dc.l   exception_handler   ; TRAPV exception
    dc.l   exception_handler   ; Privilege violation
    dc.l   exception_handler   ; TRACE exception
    dc.l   exception_handler   ; Line-A emulator
    dc.l   exception_handler   ; Line-F emulator
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Spurious exception
    dc.l   exception_handler   ; IRQ level 1
    dc.l   exception_handler   ; IRQ level 2
    dc.l   exception_handler   ; IRQ level 3
    dc.l   exception_handler   ; IRQ level 4 (horizontal retrace interrupt)
    dc.l   exception_handler   ; IRQ level 5
    dc.l   exception_handler   ; IRQ level 6 (vertical retrace interrupt)
    dc.l   exception_handler   ; IRQ level 7
    dc.l   exception_handler   ; TRAP #00 exception
    dc.l   exception_handler   ; TRAP #01 exception
    dc.l   exception_handler   ; TRAP #02 exception
    dc.l   exception_handler   ; TRAP #03 exception
    dc.l   exception_handler   ; TRAP #04 exception
    dc.l   exception_handler   ; TRAP #05 exception
    dc.l   exception_handler   ; TRAP #06 exception
    dc.l   exception_handler   ; TRAP #07 exception
    dc.l   exception_handler   ; TRAP #08 exception
    dc.l   exception_handler   ; TRAP #09 exception
    dc.l   exception_handler   ; TRAP #10 exception
    dc.l   exception_handler   ; TRAP #11 exception
    dc.l   exception_handler   ; TRAP #12 exception
    dc.l   exception_handler   ; TRAP #13 exception
    dc.l   exception_handler   ; TRAP #14 exception
    dc.l   exception_handler   ; TRAP #15 exception
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)
    dc.l   exception_handler   ; Unused (reserved)

    dc.b "SEGA GENESIS    " ; Console name
    dc.b "(C) Demensdeum  " ; Copyrght holder and release date
    dc.b "Demensdeum Sega Genesis Hello World 2020          " ; Domest. name
    dc.b "Demensdeum Sega Genesis Hello World 2020          " ; Intern. name
    dc.b "2020-07-26    "   ; Version number
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
vdp_vram_write_command = $40000000

EntryPoint:
DisableTMSS:
    move.b  $00A10001,d0  ; Move Megadrive hardware version to d0
    andi.b  #$0F,d0       ; The version is stored in last four bits,
                          ; so mask it with 0F
    beq     PrepareToFillVDPRegisters         ; If version is equal to 0,skip TMSS signature
    move.l  #'SEGA',$00A14000 ; Move the string "SEGA" to TMSS IO Port

;REGISTERS
PrepareToFillVDPRegisters:
    move.l  #VDPRegisters,a0 ; Load address of register *initial settings* table into a0
    move.l  #$18,d0          ; 24 registers to write (counter)
    move.l  #$00008000,d1    ; (Set command) Enable write register mode for VDP control port interface, first bit enables writing to registry (1000 0000 0000 0000 (bin) = 8000 (HEX))

FillInitialStateForVDPRegistersLoop:
    move.b  (a0)+,d1         ; (Set data) Set register initial value from initial settings table into d1 interface
    move.w  d1,vdp_control_port     ; Send command + data to VDP Control Port
    add.w   #$0100,d1        ; Increment registry index +1 (by "binary adding" hex 100 (VDP control port registry mask))
    dbra    d0,FillInitialStateForVDPRegistersLoop ; Decrement until done

VDPCRAMWriteColorAtIndex0:
    move.l  #$C0000000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0000,d0; Black color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex1:
    move.l  #$C0020000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0CCA,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex2:
    move.l  #$C0040000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0CCA,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex3:
    move.l  #$C0060000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0CAA,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex4:
    move.l  #$C0080000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0A86,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex5:
    move.l  #$C00A0000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0C42,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex6:
    move.l  #$C00C0000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0EEE,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex7:
    move.l  #$C00E0000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0444,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex8:
    move.l  #$C0100000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$022C,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex9:
    move.l  #$C0120000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0868,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex10:
    move.l  #$C0140000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0A88,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex11:
    move.l  #$C0160000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0CAC,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex12:
    move.l  #$C0180000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$04AC,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex13:
    move.l  #$C01A0000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$08AC,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex14:
    move.l  #$C01C0000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0484,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex15:
    move.l  #$C01E0000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0AEE,d0; Red color
    move.w  d0,vdp_data_port;

VDPCRAMWriteColorAtIndex16:
    move.l  #$C0200000,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0ACA,d0; Red color
    move.w  d0,vdp_data_port;

ClearVRAM:
  move.l #$40000000,vdp_control_port; write to VRAM command
  move.w #16384,d0 ; counter
ClearVRAMLoop:
  move.l #$00000000,vdp_data_port;
  dbra d0,ClearVRAMLoop

CharactersVRAM:
  lea Characters,a0
  move.l #$40200000,vdp_control_port; write to VRAM command
  move.w #6488,d0 ; counter
CharactersVRAMLoop:
  move.l (a0)+,vdp_data_port;
  dbra d0,CharactersVRAMLoop

FillBackground:
  move.w #0,d0     ; column index
  move.w #1,d1     ; tile index
  move.l #$40000003,(vdp_control_port) ; initial drawing location
  move.l #2500,d7     ; how many tiles to draw (700 total)

FillBackgroundStep:
  cmp.w	#28,d0
	ble.w	FillBackgroundStepFill

FillBackgroundStep2:
  cmp.w	#29,d0
  bge.w	FillBackgroundStepSkip

FillBackgroundStep3:
  add #1,d0
  cmp.w	#64,d0
  bge.w	FillBackgroundStepNewRow

FillBackgroundStep4:
  dbra d7,FillBackgroundStep    ; loop to next tile

Stuck:
  nop
  jmp Stuck

FillBackgroundStepNewRow:
  move.w #0,d0
  jmp FillBackgroundStep4

FillBackgroundStepFill:
  move.w d1,(vdp_data_port)    ; copy the pattern to VPD
  add #1,d1
  jmp FillBackgroundStep2

FillBackgroundStepSkip:
  move.w #0,(vdp_data_port)    ; copy the pattern to VPD
  jmp FillBackgroundStep3

CRAMData:
    dc.l	$0CCA,$0CCA,$0CAA,$0A86,$0C42,$0EEE,$0444,$022C
    dc.l	$0868,$0A88,$0CAC,$04AC,$08AC,$0484,$0AEE,$0ACA

; EXCEPTION AND INTERRUPT HANDLERS
; ----------------------------------------------------------------------------
    align 2 ; word-align code

exception_handler
    nop
    nop
    nop
    nop
    nop
    nop
    jmp exception_handler
    ;rte ; return from exception (seems to restore PC)

    align 2 ; word-align code

VDPRegisters:
  dc.b $14 ; 0x00:  H interrupt on, palettes on
  dc.b $74 ; 0x01:  V interrupt on, display on, DMA on, Genesis mode on
  dc.b $30 ; 0x02:  Pattern table for Scroll Plane A at VRAM 0xC000 (bits 3-5 = bits 13-15)
  dc.b $00 ; 0x03:  Pattern table for Window Plane at VRAM 0x0000 (disabled) (bits 1-5 = bits 11-15)
  dc.b $07 ; 0x04:  Pattern table for Scroll Plane B at VRAM 0xE000 (bits 0-2 = bits 11-15)
  dc.b $78 ; 0x05:  Sprite table at VRAM 0xF000 (bits 0-6 = bits 9-15)
  dc.b $00 ; 0x06:  Unused
  dc.b $00 ; 0x07:  Background colour: bits 0-3 = colour, bits 4-5 = palette
  dc.b $00 ; 0x08:  Unused
  dc.b $00 ; 0x09:  Unused
  dc.b $08 ; 0x0A: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
  dc.b $00 ; 0x0B: External interrupts off, V scroll fullscreen, H scroll fullscreen
  dc.b $81 ; 0x0C: Shadows and highlights off, interlace off, H40 mode (320 x 224 screen res)
  dc.b $3F ; 0x0D: Horiz. scroll table at VRAM 0xFC00 (bits 0-5)
  dc.b $00 ; 0x0E: Unused
  dc.b $02 ; 0x0F: Autoincrement 2 bytes
  dc.b $01 ; 0x10: Scroll plane size: 64x32 tiles
  dc.b $00 ; 0x11: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
  dc.b $00 ; 0x12: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
  dc.b $FF ; 0x13: DMA length lo byte
  dc.b $FF ; 0x14: DMA length hi byte
  dc.b $00 ; 0x15: DMA source address lo byte
  dc.b $00 ; 0x16: DMA source address mid byte
  dc.b $80 ; 0x17: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)

Characters:
  	dc.l	$11111111	; Tile #0
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #1
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #2
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #3
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #4
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #5
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #6
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #7
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #8
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #9
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #10
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #11
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #12
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #13
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$22233221
  	dc.l	$11111111	; Tile #14
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #15
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #16
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #17
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #18
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #19
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #20
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #21
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #22
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #23
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #24
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #25
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #26
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #27
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11000000	; Tile #28
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11111111	; Tile #29
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #30
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #31
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #32
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #33
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #34
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #35
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #36
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #37
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #38
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #39
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #40
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11112344	; Tile #41
  	dc.l	$11124444
  	dc.l	$11111444
  	dc.l	$11111144
  	dc.l	$11111114
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$44444444	; Tile #42
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$24444444
  	dc.l	$13444444
  	dc.l	$44422111	; Tile #43
  	dc.l	$44444443
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$11111111	; Tile #44
  	dc.l	$11111111
  	dc.l	$44311111
  	dc.l	$44444211
  	dc.l	$44444442
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$11111111	; Tile #45
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$42111111
  	dc.l	$44421111
  	dc.l	$44444111
  	dc.l	$11111111	; Tile #46
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #47
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #48
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #49
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #50
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #51
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #52
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #53
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #54
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #55
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111	; Tile #56
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11000000	; Tile #57
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11111111	; Tile #58
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #59
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #60
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #61
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #62
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #63
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #64
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #65
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #66
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #67
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #68
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #69
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #70
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$15444444	; Tile #71
  	dc.l	$11244444
  	dc.l	$11124444
  	dc.l	$11114444
  	dc.l	$11111444
  	dc.l	$15551444
  	dc.l	$55555144
  	dc.l	$55555544
  	dc.l	$44444444	; Tile #72
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #73
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444431	; Tile #74
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$11111111	; Tile #75
  	dc.l	$11111111
  	dc.l	$42511111
  	dc.l	$44351111
  	dc.l	$44441111
  	dc.l	$44444151
  	dc.l	$44444415
  	dc.l	$44444442
  	dc.l	$11111111	; Tile #76
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$15551111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #77
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #78
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #79
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #80
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #81
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #82
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #83
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #84
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11111111	; Tile #85
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$11111111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$11000000	; Tile #86
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$11000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #87
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #88
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #89
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #90
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #91
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #92
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #93
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #94
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #95
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555551
  	dc.l	$55555344
  	dc.l	$55134444
  	dc.l	$55555555	; Tile #96
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555123
  	dc.l	$51134444
  	dc.l	$34444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$55555555	; Tile #97
  	dc.l	$55555555
  	dc.l	$55512333
  	dc.l	$34444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$55555555	; Tile #98
  	dc.l	$55555555
  	dc.l	$33333333
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$55555555	; Tile #99
  	dc.l	$55555555
  	dc.l	$32115555
  	dc.l	$44444332
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$55555514	; Tile #100
  	dc.l	$55555554
  	dc.l	$55555552
  	dc.l	$21555555
  	dc.l	$44432115
  	dc.l	$44444443
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #101
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$24444444
  	dc.l	$14444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #102
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #103
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #104
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$25555555	; Tile #105
  	dc.l	$42555555
  	dc.l	$44255555
  	dc.l	$44425555
  	dc.l	$44442555
  	dc.l	$44444155
  	dc.l	$44444415
  	dc.l	$44444445
  	dc.l	$55555555	; Tile #106
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #107
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #108
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #109
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #110
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #111
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #112
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #113
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #114
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #115
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #116
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #117
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #118
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #119
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #120
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #121
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #122
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555553
  	dc.l	$55555144
  	dc.l	$55555555	; Tile #123
  	dc.l	$55555553
  	dc.l	$55555344
  	dc.l	$55514444
  	dc.l	$55244444
  	dc.l	$14444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$13444444	; Tile #124
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #125
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #126
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #127
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #128
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #129
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #130
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444443
  	dc.l	$44444434
  	dc.l	$44444434
  	dc.l	$44444334
  	dc.l	$44444334
  	dc.l	$44444444	; Tile #131
  	dc.l	$44464444
  	dc.l	$44677644
  	dc.l	$46677764
  	dc.l	$46777776
  	dc.l	$46777777
  	dc.l	$66777777
  	dc.l	$67777777
  	dc.l	$44444444	; Tile #132
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$64444444
  	dc.l	$66444444
  	dc.l	$76644444
  	dc.l	$44444444	; Tile #133
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #134
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$55555555	; Tile #135
  	dc.l	$45555555
  	dc.l	$42555555
  	dc.l	$44155555
  	dc.l	$44455555
  	dc.l	$44435555
  	dc.l	$44441555
  	dc.l	$44444555
  	dc.l	$55555555	; Tile #136
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #137
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #138
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #139
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #140
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #141
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #142
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #143
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #144
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #145
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #146
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #147
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #148
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #149
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #150
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555552
  	dc.l	$55555514
  	dc.l	$55555512
  	dc.l	$55551444	; Tile #151
  	dc.l	$55524444
  	dc.l	$55244444
  	dc.l	$53444444
  	dc.l	$24444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$21222444
  	dc.l	$44444444	; Tile #152
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #153
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #154
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #155
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #156
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #157
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #158
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444344	; Tile #159
  	dc.l	$44443346
  	dc.l	$44444346
  	dc.l	$44444446
  	dc.l	$44444446
  	dc.l	$44444466
  	dc.l	$44444466
  	dc.l	$44444466
  	dc.l	$67777777	; Tile #160
  	dc.l	$67777777
  	dc.l	$67777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77664444	; Tile #161
  	dc.l	$77766444
  	dc.l	$77776644
  	dc.l	$77776644
  	dc.l	$77777664
  	dc.l	$77777766
  	dc.l	$77777766
  	dc.l	$77777766
  	dc.l	$44444444	; Tile #162
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$64444444
  	dc.l	$66444444
  	dc.l	$44444444	; Tile #163
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444255	; Tile #164
  	dc.l	$44444415
  	dc.l	$44444425
  	dc.l	$44444445
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$55555555	; Tile #165
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$21555555
  	dc.l	$44431555
  	dc.l	$44444443
  	dc.l	$44444444
  	dc.l	$55555555	; Tile #166
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$15555555
  	dc.l	$44422555
  	dc.l	$55555555	; Tile #167
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #168
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #169
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #170
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #171
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #172
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #173
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #174
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #175
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #176
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #177
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #178
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #179
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #180
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$12244444	; Tile #181
  	dc.l	$55555144
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$44444444	; Tile #182
  	dc.l	$44444444
  	dc.l	$52444444
  	dc.l	$55551344
  	dc.l	$55555552
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$44444444	; Tile #183
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$34444444
  	dc.l	$55244444
  	dc.l	$55555244
  	dc.l	$55555551
  	dc.l	$44444444	; Tile #184
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #185
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #186
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #187
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444466	; Tile #188
  	dc.l	$44444466
  	dc.l	$44444666
  	dc.l	$44444666
  	dc.l	$44444666
  	dc.l	$44444464
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$77777777	; Tile #189
  	dc.l	$77777777
  	dc.l	$77777666
  	dc.l	$66666644
  	dc.l	$66444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$77777766	; Tile #190
  	dc.l	$77666666
  	dc.l	$66644444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$66444444	; Tile #191
  	dc.l	$66644444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #192
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #193
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #194
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444442	; Tile #195
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$11555555	; Tile #196
  	dc.l	$44435555
  	dc.l	$44444441
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444645
  	dc.l	$55555555	; Tile #197
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$45555555
  	dc.l	$44555555
  	dc.l	$44555555
  	dc.l	$15555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #198
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #199
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #200
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #201
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #202
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #203
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #204
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #205
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #206
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #207
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #208
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #209
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #210
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #211
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #212
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555552
  	dc.l	$55523444
  	dc.l	$55244444	; Tile #213
  	dc.l	$55552444
  	dc.l	$55555524
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555523
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #214
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$24444444
  	dc.l	$55244444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #215
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #216
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #217
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #218
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #219
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #220
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #221
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #222
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #223
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #224
  	dc.l	$44444446
  	dc.l	$44444676
  	dc.l	$44468766
  	dc.l	$44496642
  	dc.l	$49766455
  	dc.l	$96662555
  	dc.l	$66455555
  	dc.l	$44664255	; Tile #225
  	dc.l	$66645555
  	dc.l	$66155555
  	dc.l	$95555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #226
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #227
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #228
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #229
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #230
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #231
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #232
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #233
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #234
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #235
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55551215
  	dc.l	$55555555	; Tile #236
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #237
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #238
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #239
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #240
  	dc.l	$55555524
  	dc.l	$55555524
  	dc.l	$55555554
  	dc.l	$55555553
  	dc.l	$55555553
  	dc.l	$55555519
  	dc.l	$55555519
  	dc.l	$14444444	; Tile #241
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$66555444
  	dc.l	$66555544
  	dc.l	$44444444	; Tile #242
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #243
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #244
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #245
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #246
  	dc.l	$44444444
  	dc.l	$44444466
  	dc.l	$44444666
  	dc.l	$44446669
  	dc.l	$44446625
  	dc.l	$44466455
  	dc.l	$44446555
  	dc.l	$44444444	; Tile #247
  	dc.l	$66444444
  	dc.l	$66699996
  	dc.l	$65555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$44444444	; Tile #248
  	dc.l	$44444444
  	dc.l	$66444444
  	dc.l	$59644444
  	dc.l	$55544444
  	dc.l	$55556444
  	dc.l	$55555444
  	dc.l	$55555564
  	dc.l	$44444444	; Tile #249
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #250
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #251
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444446	; Tile #252
  	dc.l	$44444466
  	dc.l	$44444461
  	dc.l	$44444455
  	dc.l	$44444455
  	dc.l	$44444455
  	dc.l	$44444455
  	dc.l	$44444425
  	dc.l	$64555555	; Tile #253
  	dc.l	$25555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #254
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #255
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #256
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #257
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #258
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #259
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #260
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #261
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #262
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #263
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55512999	; Tile #264
  	dc.l	$55529999
  	dc.l	$55199993
  	dc.l	$55299993
  	dc.l	$55999994
  	dc.l	$51993946
  	dc.l	$55993999
  	dc.l	$55999999
  	dc.l	$21555555	; Tile #265
  	dc.l	$99225555
  	dc.l	$66699155
  	dc.l	$66666691
  	dc.l	$66666669
  	dc.l	$66999366
  	dc.l	$94999994
  	dc.l	$99999969
  	dc.l	$55555555	; Tile #266
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$25555555
  	dc.l	$51115555
  	dc.l	$22222111
  	dc.l	$55555555	; Tile #267
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555551
  	dc.l	$55555512
  	dc.l	$15555129
  	dc.l	$55555155	; Tile #268
  	dc.l	$55511555
  	dc.l	$51292555
  	dc.l	$19999555
  	dc.l	$29999555
  	dc.l	$29991555
  	dc.l	$99995555
  	dc.l	$99995555
  	dc.l	$55555529	; Tile #269
  	dc.l	$55555529
  	dc.l	$55555599
  	dc.l	$55555593
  	dc.l	$55555293
  	dc.l	$55555993
  	dc.l	$55552994
  	dc.l	$55559994
  	dc.l	$64555554	; Tile #270
  	dc.l	$49555553
  	dc.l	$49555552
  	dc.l	$65555552
  	dc.l	$45555555
  	dc.l	$95555555
  	dc.l	$95555552
  	dc.l	$55555552
  	dc.l	$44444444	; Tile #271
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #272
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #273
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #274
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44442555	; Tile #275
  	dc.l	$44445555
  	dc.l	$44495555
  	dc.l	$44455555
  	dc.l	$44455555
  	dc.l	$44355555
  	dc.l	$44555555
  	dc.l	$44555555
  	dc.l	$55555555	; Tile #276
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555524	; Tile #277
  	dc.l	$55555554
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$95555555
  	dc.l	$44444444	; Tile #278
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$54444444
  	dc.l	$54444444
  	dc.l	$54444444
  	dc.l	$51444444
  	dc.l	$44444444	; Tile #279
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #280
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444425	; Tile #281
  	dc.l	$44444445
  	dc.l	$44444442
  	dc.l	$44444442
  	dc.l	$44444441
  	dc.l	$44444449
  	dc.l	$44444446
  	dc.l	$44444446
  	dc.l	$55555555	; Tile #282
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$95555555
  	dc.l	$69555555
  	dc.l	$55555555	; Tile #283
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #284
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #285
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #286
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #287
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #288
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #289
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #290
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #291
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #292
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55593399	; Tile #293
  	dc.l	$55555343
  	dc.l	$55555554
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$99999399	; Tile #294
  	dc.l	$99934922
  	dc.l	$44469229
  	dc.l	$59699299
  	dc.l	$52522999
  	dc.l	$55529994
  	dc.l	$55529966
  	dc.l	$55299466
  	dc.l	$99999922	; Tile #295
  	dc.l	$99999999
  	dc.l	$99999999
  	dc.l	$99999999
  	dc.l	$44499993
  	dc.l	$66499944
  	dc.l	$64399346
  	dc.l	$64493466
  	dc.l	$22222299	; Tile #296
  	dc.l	$99999999
  	dc.l	$99999999
  	dc.l	$99999994
  	dc.l	$344499D4
  	dc.l	$66664934
  	dc.l	$66644444
  	dc.l	$95244444
  	dc.l	$99915555	; Tile #297
  	dc.l	$99455555
  	dc.l	$36955555
  	dc.l	$46529925
  	dc.l	$41299999
  	dc.l	$45999999
  	dc.l	$45939999
  	dc.l	$41999999
  	dc.l	$55529994	; Tile #298
  	dc.l	$55299993
  	dc.l	$5A999949
  	dc.l	$59993362
  	dc.l	$99934465
  	dc.l	$99364695
  	dc.l	$94666491
  	dc.l	$46666999
  	dc.l	$55555519	; Tile #299
  	dc.l	$55555527
  	dc.l	$5555559B
  	dc.l	$555559BB
  	dc.l	$5555197B
  	dc.l	$5555977B
  	dc.l	$551977BB
  	dc.l	$299877BB
  	dc.l	$44444444	; Tile #300
  	dc.l	$74444444
  	dc.l	$BB944444
  	dc.l	$BBBC9444
  	dc.l	$BBBBBC94
  	dc.l	$BBBEBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$44444444	; Tile #301
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$84444444
  	dc.l	$BB444444
  	dc.l	$BBBB4444
  	dc.l	$44444444	; Tile #302
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #303
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$4444449E
  	dc.l	$44555555	; Tile #304
  	dc.l	$44555555
  	dc.l	$44555555
  	dc.l	$44555555
  	dc.l	$44555555
  	dc.l	$44555555
  	dc.l	$99C55555
  	dc.l	$EEBBE555
  	dc.l	$55555556	; Tile #305
  	dc.l	$55555566
  	dc.l	$55555666
  	dc.l	$55556666
  	dc.l	$55556666
  	dc.l	$55566666
  	dc.l	$55FD6666
  	dc.l	$55556666
  	dc.l	$66555555	; Tile #306
  	dc.l	$66555555
  	dc.l	$66555555
  	dc.l	$66555555
  	dc.l	$65555555
  	dc.l	$65555555
  	dc.l	$65555555
  	dc.l	$55555555
  	dc.l	$55444444	; Tile #307
  	dc.l	$55444444
  	dc.l	$55244444
  	dc.l	$55244444
  	dc.l	$55244444
  	dc.l	$55244444
  	dc.l	$55244444
  	dc.l	$55244444
  	dc.l	$44444444	; Tile #308
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #309
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44446444
  	dc.l	$44446444
  	dc.l	$44444266	; Tile #310
  	dc.l	$44444556
  	dc.l	$44445555
  	dc.l	$44445555
  	dc.l	$44435555
  	dc.l	$44469555
  	dc.l	$44469555
  	dc.l	$46664255
  	dc.l	$66955555	; Tile #311
  	dc.l	$66655555
  	dc.l	$66695555
  	dc.l	$66665555
  	dc.l	$56669555
  	dc.l	$56669555
  	dc.l	$56664255
  	dc.l	$56664955
  	dc.l	$55555555	; Tile #312
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #313
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55955555
  	dc.l	$55955555
  	dc.l	$59555555
  	dc.l	$99555555
  	dc.l	$55555555	; Tile #314
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #315
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #316
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #317
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #318
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #319
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #320
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #321
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #322
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55994666	; Tile #323
  	dc.l	$55996666
  	dc.l	$55946666
  	dc.l	$55946666
  	dc.l	$55596666
  	dc.l	$55555999
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$64446645	; Tile #324
  	dc.l	$66666955
  	dc.l	$66669555
  	dc.l	$66955555
  	dc.l	$62555555
  	dc.l	$55555555
  	dc.l	$55555551
  	dc.l	$55555552
  	dc.l	$55444444	; Tile #325
  	dc.l	$55444444
  	dc.l	$54444444
  	dc.l	$54444444
  	dc.l	$24444444
  	dc.l	$44444444
  	dc.l	$44444442
  	dc.l	$44425555
  	dc.l	$43299996	; Tile #326
  	dc.l	$44443249
  	dc.l	$44444445
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44443215
  	dc.l	$555555FE
  	dc.l	$59366666
  	dc.l	$66444399	; Tile #327
  	dc.l	$99444499
  	dc.l	$E9346693
  	dc.l	$19964444
  	dc.l	$49992222
  	dc.l	$55555555
  	dc.l	$55199999
  	dc.l	$49695555
  	dc.l	$994444BB	; Tile #328
  	dc.l	$94444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$15555555
  	dc.l	$55555555
  	dc.l	$99955555
  	dc.l	$55592555
  	dc.l	$BBBBBBBB	; Tile #329
  	dc.l	$9BBBBBBB
  	dc.l	$449BBBBB
  	dc.l	$44449BBB
  	dc.l	$55555EBB
  	dc.l	$55555555
  	dc.l	$55555552
  	dc.l	$55555244
  	dc.l	$BBBBB744	; Tile #330
  	dc.l	$BBBBBBB6
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$9BBBBBBB
  	dc.l	$44BBBBBB
  	dc.l	$44447BBB
  	dc.l	$44444444	; Tile #331
  	dc.l	$44444444
  	dc.l	$B6444444
  	dc.l	$BB744444
  	dc.l	$BBB76444
  	dc.l	$BBBB7664
  	dc.l	$BBBBB776
  	dc.l	$BBBBBB77
  	dc.l	$444446EE	; Tile #332
  	dc.l	$44444EEE
  	dc.l	$44446EEB
  	dc.l	$44446EEB
  	dc.l	$44446EEB
  	dc.l	$44446EBB
  	dc.l	$44446EBB
  	dc.l	$66446EBB
  	dc.l	$EEEEBE55	; Tile #333
  	dc.l	$EEEEEB55
  	dc.l	$BBBEEBB5
  	dc.l	$BB6BEEBC
  	dc.l	$B69BBBBB
  	dc.l	$B65BBBBB
  	dc.l	$735BBBBB
  	dc.l	$615CBBBB
  	dc.l	$5515666D	; Tile #334
  	dc.l	$59D66665
  	dc.l	$56D66D55
  	dc.l	$56DDDF55
  	dc.l	$566D9555
  	dc.l	$C5655555
  	dc.l	$BC555555
  	dc.l	$BBC55555
  	dc.l	$55555555	; Tile #335
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55244444	; Tile #336
  	dc.l	$55244444
  	dc.l	$55244444
  	dc.l	$51944444
  	dc.l	$52944444
  	dc.l	$52944444
  	dc.l	$52444444
  	dc.l	$22444444
  	dc.l	$44444444	; Tile #337
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444446
  	dc.l	$44444664
  	dc.l	$44466444	; Tile #338
  	dc.l	$4466444E
  	dc.l	$446444EB
  	dc.l	$46444CEB
  	dc.l	$66445C76
  	dc.l	$66959699
  	dc.l	$65594999
  	dc.l	$55599999
  	dc.l	$E6666955	; Tile #339
  	dc.l	$E6666955
  	dc.l	$B6666925
  	dc.l	$66666995
  	dc.l	$66666999
  	dc.l	$96666996
  	dc.l	$98666966
  	dc.l	$94666666
  	dc.l	$56664955	; Tile #340
  	dc.l	$56669959
  	dc.l	$56669959
  	dc.l	$66669999
  	dc.l	$66669999
  	dc.l	$66669966
  	dc.l	$66669666
  	dc.l	$66666666
  	dc.l	$55555555	; Tile #341
  	dc.l	$95555555
  	dc.l	$99255555
  	dc.l	$99955555
  	dc.l	$99992555
  	dc.l	$99999955
  	dc.l	$99999995
  	dc.l	$69999995
  	dc.l	$69555555	; Tile #342
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #343
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #344
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #345
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #346
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #347
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #348
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #349
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #350
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #351
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #352
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555554	; Tile #353
  	dc.l	$55555552
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555515
  	dc.l	$55555552
  	dc.l	$42555553	; Tile #354
  	dc.l	$55555366
  	dc.l	$55559346
  	dc.l	$55199466
  	dc.l	$55293466
  	dc.l	$51936666
  	dc.l	$29344666
  	dc.l	$99966666
  	dc.l	$66446666	; Tile #355
  	dc.l	$66666666
  	dc.l	$66666666
  	dc.l	$66666666
  	dc.l	$66666666
  	dc.l	$66666666
  	dc.l	$66667766
  	dc.l	$67777777
  	dc.l	$66649999	; Tile #356
  	dc.l	$66666663
  	dc.l	$66669999
  	dc.l	$66666664
  	dc.l	$66666666
  	dc.l	$66677777
  	dc.l	$77777777
  	dc.l	$66677777
  	dc.l	$99959555	; Tile #357
  	dc.l	$33399555
  	dc.l	$99999555
  	dc.l	$44466B54
  	dc.l	$66667844
  	dc.l	$77778444
  	dc.l	$77774444
  	dc.l	$77744666
  	dc.l	$55524444	; Tile #358
  	dc.l	$55444444
  	dc.l	$34444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$64444444
  	dc.l	$4444447B	; Tile #359
  	dc.l	$44444448
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$BBBBBBB7	; Tile #360
  	dc.l	$BBBBBBBB
  	dc.l	$48BBBBBB
  	dc.l	$4449BBBB
  	dc.l	$44446BBB
  	dc.l	$4444446B
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$76664CBB	; Tile #361
  	dc.l	$776666EB
  	dc.l	$B77766CB
  	dc.l	$B777766C
  	dc.l	$BB777768
  	dc.l	$BBB77744
  	dc.l	$7B777444
  	dc.l	$44776444
  	dc.l	$7555BBBB	; Tile #362
  	dc.l	$B955BBBB
  	dc.l	$B755CBBB
  	dc.l	$B7155BBB
  	dc.l	$BB955CBB
  	dc.l	$9BB955BB
  	dc.l	$49BB955B
  	dc.l	$446BBB99
  	dc.l	$BBBC5555	; Tile #363
  	dc.l	$BBBBB555
  	dc.l	$BBBBBBE5
  	dc.l	$BBBBBBBC
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$55555555	; Tile #364
  	dc.l	$5555555A
  	dc.l	$555555AA
  	dc.l	$5555AEC9
  	dc.l	$BCCECCC9
  	dc.l	$BBBCCCC9
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$22444444	; Tile #365
  	dc.l	$22344466
  	dc.l	$99944666
  	dc.l	$99964666
  	dc.l	$99966666
  	dc.l	$9B76699D
  	dc.l	$BBBB95BD
  	dc.l	$BBBBBEB5
  	dc.l	$44666695	; Tile #366
  	dc.l	$66646255
  	dc.l	$66666555
  	dc.l	$66665555
  	dc.l	$26655555
  	dc.l	$66555555
  	dc.l	$D55E5555
  	dc.l	$55CE5555
  	dc.l	$55555946	; Tile #367
  	dc.l	$55555551
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$66666666	; Tile #368
  	dc.l	$91555599
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$66655946	; Tile #369
  	dc.l	$15555559
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$66699995	; Tile #370
  	dc.l	$96666955
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #371
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #372
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #373
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #374
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #375
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #376
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #377
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #378
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #379
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #380
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #381
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555559
  	dc.l	$55555599	; Tile #382
  	dc.l	$55555999
  	dc.l	$55559336
  	dc.l	$55596666
  	dc.l	$55966667
  	dc.l	$59666677
  	dc.l	$96691977
  	dc.l	$66552967
  	dc.l	$99666677	; Tile #383
  	dc.l	$66667777
  	dc.l	$66777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777	; Tile #384
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77767777	; Tile #385
  	dc.l	$76767777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777778	; Tile #386
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$CA555555
  	dc.l	$52934444	; Tile #387
  	dc.l	$55555534
  	dc.l	$C5555515
  	dc.l	$C5555542
  	dc.l	$75555524
  	dc.l	$75555554
  	dc.l	$75555552
  	dc.l	$55555555
  	dc.l	$44444444	; Tile #388
  	dc.l	$44444444
  	dc.l	$54444444
  	dc.l	$55544444
  	dc.l	$25552444
  	dc.l	$44555544
  	dc.l	$44455524
  	dc.l	$44442554
  	dc.l	$44444444	; Tile #389
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #390
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$444677BB	; Tile #391
  	dc.l	$44446667
  	dc.l	$44444666
  	dc.l	$44444666
  	dc.l	$44444466
  	dc.l	$44444446
  	dc.l	$44444446
  	dc.l	$4444444C
  	dc.l	$77BBBBBB	; Tile #392
  	dc.l	$B767BB77
  	dc.l	$66766777
  	dc.l	$66666677
  	dc.l	$66666677
  	dc.l	$66777777
  	dc.l	$77777777
  	dc.l	$BBBB7777
  	dc.l	$BBBBBBBB	; Tile #393
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777766
  	dc.l	$77766666
  	dc.l	$777C5555
  	dc.l	$77BC5555
  	dc.l	$77BC5555
  	dc.l	$BBB767E5	; Tile #394
  	dc.l	$7776666B
  	dc.l	$77766666
  	dc.l	$66666666
  	dc.l	$6667B666
  	dc.l	$55555566
  	dc.l	$55555559
  	dc.l	$55555555
  	dc.l	$EBE55555	; Tile #395
  	dc.l	$BE555555
  	dc.l	$66955555
  	dc.l	$66665555
  	dc.l	$66669555
  	dc.l	$66669555
  	dc.l	$66695555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #396
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #397
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #398
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #399
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #400
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #401
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #402
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #403
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #404
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #405
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #406
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #407
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #408
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #409
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555516	; Tile #410
  	dc.l	$55555566
  	dc.l	$55555966
  	dc.l	$55555662
  	dc.l	$55559665
  	dc.l	$55556665
  	dc.l	$5552667C
  	dc.l	$55596677
  	dc.l	$65522996	; Tile #411
  	dc.l	$95129999
  	dc.l	$51229999
  	dc.l	$51299999
  	dc.l	$51299999
  	dc.l	$11299999
  	dc.l	$12299999
  	dc.l	$52299999
  	dc.l	$77777777	; Tile #412
  	dc.l	$67777777
  	dc.l	$96777777
  	dc.l	$99667777
  	dc.l	$99366777
  	dc.l	$99336667
  	dc.l	$99934666
  	dc.l	$99934466
  	dc.l	$77777777	; Tile #413
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777765
  	dc.l	$77777755
  	dc.l	$67777752
  	dc.l	$66777559
  	dc.l	$77768A55	; Tile #414
  	dc.l	$77755199
  	dc.l	$65519993
  	dc.l	$55999946
  	dc.l	$59999445
  	dc.l	$99999955
  	dc.l	$99999555
  	dc.l	$99992559
  	dc.l	$51298255	; Tile #415
  	dc.l	$93695555
  	dc.l	$66551111
  	dc.l	$95522222
  	dc.l	$51922222
  	dc.l	$19999999
  	dc.l	$99999999
  	dc.l	$99999999
  	dc.l	$55555555	; Tile #416
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$22555555
  	dc.l	$22299992
  	dc.l	$99993444
  	dc.l	$99466666
  	dc.l	$66666666
  	dc.l	$54444455	; Tile #417
  	dc.l	$54444444
  	dc.l	$55444444
  	dc.l	$55544444
  	dc.l	$55554444
  	dc.l	$92552444
  	dc.l	$44955444
  	dc.l	$66455534
  	dc.l	$44444444	; Tile #418
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #419
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$4444449B	; Tile #420
  	dc.l	$444448BB
  	dc.l	$44444CBB
  	dc.l	$4444CBBB
  	dc.l	$4449BBBB
  	dc.l	$448BBBBB
  	dc.l	$44BBBBBB
  	dc.l	$4CBBBBBB
  	dc.l	$BBBBBB77	; Tile #421
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBB77B
  	dc.l	$BBB7777B
  	dc.l	$B77777BC
  	dc.l	$BBBC5555	; Tile #422
  	dc.l	$BBB55555
  	dc.l	$BBB55555
  	dc.l	$BBE55555
  	dc.l	$BB555555
  	dc.l	$B5555555
  	dc.l	$C5555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #423
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #424
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #425
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #426
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #427
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #428
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #429
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #430
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #431
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #432
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #433
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #434
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #435
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #436
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #437
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #438
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55566777	; Tile #439
  	dc.l	$55966777
  	dc.l	$55967777
  	dc.l	$55667777
  	dc.l	$55667777
  	dc.l	$51677777
  	dc.l	$59677777
  	dc.l	$55677777
  	dc.l	$81299999	; Tile #440
  	dc.l	$7C199999
  	dc.l	$77C59999
  	dc.l	$77785999
  	dc.l	$77777C99
  	dc.l	$77777699
  	dc.l	$77777767
  	dc.l	$77777777
  	dc.l	$99934446	; Tile #441
  	dc.l	$99944446
  	dc.l	$99344666
  	dc.l	$93446666
  	dc.l	$93466666
  	dc.l	$94466666
  	dc.l	$94666666
  	dc.l	$76666666
  	dc.l	$66677519	; Tile #442
  	dc.l	$66667519
  	dc.l	$66666559
  	dc.l	$66666159
  	dc.l	$66666655
  	dc.l	$66666695
  	dc.l	$66666955
  	dc.l	$66695555
  	dc.l	$99995559	; Tile #443
  	dc.l	$99955599
  	dc.l	$99955599
  	dc.l	$99555299
  	dc.l	$99555999
  	dc.l	$29555999
  	dc.l	$52555999
  	dc.l	$55555999
  	dc.l	$99999946	; Tile #444
  	dc.l	$99993666
  	dc.l	$99994666
  	dc.l	$99396666
  	dc.l	$99396666
  	dc.l	$99346666
  	dc.l	$93996666
  	dc.l	$34996666
  	dc.l	$66666666	; Tile #445
  	dc.l	$64666666
  	dc.l	$64466666
  	dc.l	$64446666
  	dc.l	$64444666
  	dc.l	$64444466
  	dc.l	$64444446
  	dc.l	$64444444
  	dc.l	$66695554	; Tile #446
  	dc.l	$66695552
  	dc.l	$66695553
  	dc.l	$66655554
  	dc.l	$66955554
  	dc.l	$66555553
  	dc.l	$49555551
  	dc.l	$25555552
  	dc.l	$44444444	; Tile #447
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444466
  	dc.l	$44444666
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #448
  	dc.l	$44444447
  	dc.l	$4444446B
  	dc.l	$446666B7
  	dc.l	$66666777
  	dc.l	$66666667
  	dc.l	$66666779
  	dc.l	$46444455
  	dc.l	$9BBBBBB7	; Tile #449
  	dc.l	$BBBBB777
  	dc.l	$BB777777
  	dc.l	$77777777
  	dc.l	$77777B79
  	dc.l	$77BB9C55
  	dc.l	$E5555555
  	dc.l	$55555555
  	dc.l	$77777BC5	; Tile #450
  	dc.l	$77777C55
  	dc.l	$77B75555
  	dc.l	$B7E55555
  	dc.l	$E5555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #451
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #452
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #453
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #454
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #455
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #456
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #457
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #458
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #459
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #460
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #461
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #462
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #463
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #464
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #465
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #466
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #467
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55677777	; Tile #468
  	dc.l	$55977777
  	dc.l	$555C7777
  	dc.l	$55555777
  	dc.l	$55555577
  	dc.l	$5555555C
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$77777766	; Tile #469
  	dc.l	$77777776
  	dc.l	$77777666
  	dc.l	$77777666
  	dc.l	$77776666
  	dc.l	$77766755
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$66666666	; Tile #470
  	dc.l	$66666675
  	dc.l	$66667555
  	dc.l	$66955555
  	dc.l	$95555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$95555555	; Tile #471
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555993	; Tile #472
  	dc.l	$55555194
  	dc.l	$55555593
  	dc.l	$55555559
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$44998666	; Tile #473
  	dc.l	$46899666
  	dc.l	$66699966
  	dc.l	$66699996
  	dc.l	$99664995
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$64444444	; Tile #474
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$94444444
  	dc.l	$55444444
  	dc.l	$55514444
  	dc.l	$55555544
  	dc.l	$45555344	; Tile #475
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444	; Tile #476
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44452444
  	dc.l	$45555444
  	dc.l	$44442555	; Tile #477
  	dc.l	$44445555
  	dc.l	$44444555
  	dc.l	$44444255
  	dc.l	$44444415
  	dc.l	$44444445
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$55555555	; Tile #478
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$45555555
  	dc.l	$55555555	; Tile #479
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #480
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #481
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #482
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #483
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #484
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #485
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #486
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #487
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #488
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #489
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #490
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #491
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #492
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #493
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #494
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #495
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #496
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #497
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #498
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #499
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #500
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #501
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #502
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #503
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$52222225	; Tile #504
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555544	; Tile #505
  	dc.l	$55555524
  	dc.l	$55555552
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$44444444	; Tile #506
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$54444444
  	dc.l	$52444444
  	dc.l	$55444444
  	dc.l	$55544444
  	dc.l	$42555555	; Tile #507
  	dc.l	$44555555
  	dc.l	$44455555
  	dc.l	$44445555
  	dc.l	$44444555
  	dc.l	$44444555
  	dc.l	$44444455
  	dc.l	$44444445
  	dc.l	$55555555	; Tile #508
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #509
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #510
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #511
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #512
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #513
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #514
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #515
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #516
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #517
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #518
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #519
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #520
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #521
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #522
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #523
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #524
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #525
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #526
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #527
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #528
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #529
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #530
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #531
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #532
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #533
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #534
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55524444	; Tile #535
  	dc.l	$55554444
  	dc.l	$55555444
  	dc.l	$55555444
  	dc.l	$55555544
  	dc.l	$55555524
  	dc.l	$55555554
  	dc.l	$55555555
  	dc.l	$44444442	; Tile #536
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$55555555	; Tile #537
  	dc.l	$55555555
  	dc.l	$45555555
  	dc.l	$44555555
  	dc.l	$44255555
  	dc.l	$44455555
  	dc.l	$44445555
  	dc.l	$44444555
  	dc.l	$55555555	; Tile #538
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #539
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #540
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #541
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #542
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #543
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #544
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #545
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #546
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #547
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #548
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #549
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #550
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #551
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #552
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #553
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #554
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #556
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #557
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #558
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #559
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #560
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #561
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #562
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #563
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #564
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$24444444	; Tile #565
  	dc.l	$54444444
  	dc.l	$55444444
  	dc.l	$55244444
  	dc.l	$55544444
  	dc.l	$55554444
  	dc.l	$55554444
  	dc.l	$55555444
  	dc.l	$44444155	; Tile #566
  	dc.l	$44444455
  	dc.l	$44444445
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$55555555	; Tile #567
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$25555555
  	dc.l	$45555555
  	dc.l	$44555555
  	dc.l	$44455555
  	dc.l	$55555555	; Tile #568
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #569
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #570
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #571
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555557
  	dc.l	$55555C77
  	dc.l	$55555555	; Tile #572
  	dc.l	$555555C7
  	dc.l	$55557777
  	dc.l	$55C77777
  	dc.l	$57777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$5C7777C5	; Tile #573
  	dc.l	$77777777
  	dc.l	$7777777C
  	dc.l	$77777791
  	dc.l	$77777995
  	dc.l	$77777955
  	dc.l	$77779255
  	dc.l	$77779155
  	dc.l	$55555555	; Tile #574
  	dc.l	$C5555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #575
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #576
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #577
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #578
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #579
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #580
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #581
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #582
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #583
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #584
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #585
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #586
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #587
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #588
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #589
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #590
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #591
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #592
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #593
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555144	; Tile #594
  	dc.l	$55555534
  	dc.l	$55555554
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$44444444	; Tile #595
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$44444444
  	dc.l	$34444425
  	dc.l	$54441555
  	dc.l	$55255555
  	dc.l	$55555555
  	dc.l	$44425555	; Tile #596
  	dc.l	$44445555
  	dc.l	$44455555
  	dc.l	$15555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #597
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55529999
  	dc.l	$59966695
  	dc.l	$96669555
  	dc.l	$55555555	; Tile #598
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$95555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #599
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$5555555C
  	dc.l	$55555C77
  	dc.l	$555C7777
  	dc.l	$55777777
  	dc.l	$57777777
  	dc.l	$5555C777	; Tile #600
  	dc.l	$55577777
  	dc.l	$5C777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777	; Tile #601
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$777B2155	; Tile #602
  	dc.l	$77799955
  	dc.l	$77799955
  	dc.l	$77993555
  	dc.l	$77933555
  	dc.l	$77939555
  	dc.l	$77935555
  	dc.l	$73995559
  	dc.l	$55555555	; Tile #603
  	dc.l	$5555F555
  	dc.l	$5555E555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55E99555
  	dc.l	$59955555
  	dc.l	$95555555
  	dc.l	$55555555	; Tile #604
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #605
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #606
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #607
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #608
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #609
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #610
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #611
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #612
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #613
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #614
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #615
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #616
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #617
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #618
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #619
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #620
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #621
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #622
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #623
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #624
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555559
  	dc.l	$55555999
  	dc.l	$55559999
  	dc.l	$55999995
  	dc.l	$55555594	; Tile #625
  	dc.l	$55559966
  	dc.l	$55996669
  	dc.l	$99966255
  	dc.l	$99995555
  	dc.l	$99555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$66955555	; Tile #626
  	dc.l	$69555555
  	dc.l	$55555599
  	dc.l	$55559395
  	dc.l	$55596955
  	dc.l	$55969555
  	dc.l	$59695555
  	dc.l	$96655555
  	dc.l	$55555555	; Tile #627
  	dc.l	$99555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$57777777	; Tile #628
  	dc.l	$A7777CC7
  	dc.l	$C7777C77
  	dc.l	$C7777777
  	dc.l	$C7777777
  	dc.l	$57777777
  	dc.l	$57777777
  	dc.l	$5C777777
  	dc.l	$77777777	; Tile #629
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777	; Tile #630
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777779
  	dc.l	$77777773
  	dc.l	$73995599	; Tile #631
  	dc.l	$73959D95
  	dc.l	$79959F55
  	dc.l	$3995F559
  	dc.l	$39995596
  	dc.l	$9929F695
  	dc.l	$29996955
  	dc.l	$19969555
  	dc.l	$5555E555	; Tile #632
  	dc.l	$55999555
  	dc.l	$99995555
  	dc.l	$69555555
  	dc.l	$95555555
  	dc.l	$555F5555
  	dc.l	$5E995555
  	dc.l	$969F5555
  	dc.l	$55555555	; Tile #633
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #634
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #635
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #636
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #637
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #638
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #639
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #640
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #641
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #642
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #643
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #644
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #645
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #646
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #647
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #648
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #649
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #650
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #651
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #652
  	dc.l	$55555555
  	dc.l	$55555552
  	dc.l	$55555522
  	dc.l	$55555559
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$52999955	; Tile #653
  	dc.l	$29999555
  	dc.l	$99995555
  	dc.l	$99955555
  	dc.l	$99955555
  	dc.l	$29255555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555559	; Tile #654
  	dc.l	$55555596
  	dc.l	$55555966
  	dc.l	$55559666
  	dc.l	$555A7667
  	dc.l	$55596677
  	dc.l	$55966777
  	dc.l	$59667777
  	dc.l	$66A55555	; Tile #655
  	dc.l	$66555555
  	dc.l	$67555555
  	dc.l	$77555555
  	dc.l	$77555555
  	dc.l	$77555555
  	dc.l	$77C55555
  	dc.l	$77755555
  	dc.l	$55555555	; Tile #656
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$5555555E
  	dc.l	$555555EE
  	dc.l	$5555EEEE
  	dc.l	$555EEEEE
  	dc.l	$55EEEEEB
  	dc.l	$55777777	; Tile #657
  	dc.l	$5EEB7777
  	dc.l	$EEEB7777
  	dc.l	$EEEBB777
  	dc.l	$EEEEBB77
  	dc.l	$EEEEBB77
  	dc.l	$EBEEEBB7
  	dc.l	$BBEEEEBB
  	dc.l	$77777777	; Tile #658
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777779	; Tile #659
  	dc.l	$77777795
  	dc.l	$77777795
  	dc.l	$77777959
  	dc.l	$77779156
  	dc.l	$77779596
  	dc.l	$77795566
  	dc.l	$77995966
  	dc.l	$19995596	; Tile #660
  	dc.l	$99995B69
  	dc.l	$36996995
  	dc.l	$69969E96
  	dc.l	$66699695
  	dc.l	$66996999
  	dc.l	$696999D5
  	dc.l	$66996955
  	dc.l	$99555555	; Tile #661
  	dc.l	$5E955555
  	dc.l	$B9555555
  	dc.l	$95555555
  	dc.l	$95555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #662
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #663
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #664
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #665
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #666
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #667
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #668
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #669
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #670
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #671
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #672
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #673
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #674
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #675
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #676
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #677
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #678
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #679
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #680
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #681
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #682
  	dc.l	$555555C9
  	dc.l	$55555996
  	dc.l	$55559966
  	dc.l	$55559667
  	dc.l	$55555777
  	dc.l	$55555777
  	dc.l	$55555777
  	dc.l	$96677777	; Tile #683
  	dc.l	$66777777
  	dc.l	$67777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77755555	; Tile #684
  	dc.l	$777C5555
  	dc.l	$7777555B
  	dc.l	$77775EBB
  	dc.l	$77777BBB
  	dc.l	$7777BBBB
  	dc.l	$777BBBBB
  	dc.l	$7777BBBB
  	dc.l	$5EEEEEBB	; Tile #685
  	dc.l	$BEEEEBBB
  	dc.l	$BBEEBBBB
  	dc.l	$BBBBBBB6
  	dc.l	$BBBBBB69
  	dc.l	$BBBBB699
  	dc.l	$BBBB6999
  	dc.l	$EEE99999
  	dc.l	$BBBEEEBB	; Tile #686
  	dc.l	$BBBEEEEB
  	dc.l	$67BBEEEB
  	dc.l	$99BBBEEE
  	dc.l	$999BBBEB
  	dc.l	$999BBBBB
  	dc.l	$999BBBBB
  	dc.l	$99EBBBBB
  	dc.l	$77777777	; Tile #687
  	dc.l	$B7777777
  	dc.l	$B7777777
  	dc.l	$BB777779
  	dc.l	$BB777779
  	dc.l	$BBB77795
  	dc.l	$BBB76915
  	dc.l	$BBB69952
  	dc.l	$77955666	; Tile #688
  	dc.l	$79556666
  	dc.l	$9F596666
  	dc.l	$95566666
  	dc.l	$55666666
  	dc.l	$54666666
  	dc.l	$96666635
  	dc.l	$66666955
  	dc.l	$636D9555	; Tile #689
  	dc.l	$66969555
  	dc.l	$66695555
  	dc.l	$66555555
  	dc.l	$65555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #690
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #691
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #692
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #693
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #694
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #695
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #696
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #697
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #698
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #699
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #700
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #701
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #702
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #703
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #704
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #705
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #706
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #707
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #708
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #709
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #710
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555C77	; Tile #711
  	dc.l	$55555C77
  	dc.l	$55555577
  	dc.l	$55555577
  	dc.l	$55555577
  	dc.l	$555555C7
  	dc.l	$55555557
  	dc.l	$55555557
  	dc.l	$77777777	; Tile #712
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$7777BBBB	; Tile #713
  	dc.l	$77777BBB
  	dc.l	$77777BBB
  	dc.l	$777777BB
  	dc.l	$777777BB
  	dc.l	$7777777B
  	dc.l	$7777777B
  	dc.l	$77777777
  	dc.l	$EEEE9999	; Tile #714
  	dc.l	$BEEE9929
  	dc.l	$BEEEE99B
  	dc.l	$BBEEEBBB
  	dc.l	$BBEEEBBB
  	dc.l	$BBBEEBBB
  	dc.l	$BBBEEBBB
  	dc.l	$BBBBBBBB
  	dc.l	$9BBBBBBB	; Tile #715
  	dc.l	$BBBBBBBB
  	dc.l	$BBBBBBB9
  	dc.l	$BBBBBB96
  	dc.l	$BBBBB966
  	dc.l	$BBBB9669
  	dc.l	$BB996699
  	dc.l	$B9B66999
  	dc.l	$BBBB9996	; Tile #716
  	dc.l	$BB699966
  	dc.l	$B6699666
  	dc.l	$66996666
  	dc.l	$69966669
  	dc.l	$99666655
  	dc.l	$96666555
  	dc.l	$66695555
  	dc.l	$66669555	; Tile #717
  	dc.l	$66655555
  	dc.l	$66555555
  	dc.l	$95555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #718
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #719
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #720
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #721
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #722
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #723
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #724
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #725
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #726
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #727
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #728
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #729
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #730
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #731
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #732
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #733
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #734
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #735
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #736
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #737
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #738
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #739
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555557	; Tile #740
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$77777777	; Tile #741
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$57777777
  	dc.l	$57777777
  	dc.l	$5C777777
  	dc.l	$55777777
  	dc.l	$77777777	; Tile #742
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$77777777
  	dc.l	$7777776D
  	dc.l	$BBBBBBBB	; Tile #743
  	dc.l	$7BBBBBB9
  	dc.l	$77BBBB96
  	dc.l	$77BBBB66
  	dc.l	$776BB669
  	dc.l	$77999999
  	dc.l	$79999919
  	dc.l	$99999F96
  	dc.l	$9B669996	; Tile #744
  	dc.l	$66699966
  	dc.l	$63993669
  	dc.l	$99966655
  	dc.l	$99664555
  	dc.l	$96695555
  	dc.l	$66555555
  	dc.l	$95555555
  	dc.l	$66955555	; Tile #745
  	dc.l	$65555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #746
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #747
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #748
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #749
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #750
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #751
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #752
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #753
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #754
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #755
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #756
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #757
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #758
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #759
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #760
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #761
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #762
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #763
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #764
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #765
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #766
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #767
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #768
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555512
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #769
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$52222222
  	dc.l	$22222299
  	dc.l	$11222229
  	dc.l	$55512222
  	dc.l	$55555555
  	dc.l	$55C77777	; Tile #770
  	dc.l	$55577777
  	dc.l	$55296776
  	dc.l	$99997766
  	dc.l	$99999663
  	dc.l	$99999666
  	dc.l	$22999966
  	dc.l	$55122294
  	dc.l	$77776693	; Tile #771
  	dc.l	$77669939
  	dc.l	$66993399
  	dc.l	$99999999
  	dc.l	$99999999
  	dc.l	$69999996
  	dc.l	$66993639
  	dc.l	$66699999
  	dc.l	$99999661	; Tile #772
  	dc.l	$99996455
  	dc.l	$99969225
  	dc.l	$93699999
  	dc.l	$44999999
  	dc.l	$99999999
  	dc.l	$99999999
  	dc.l	$99999999
  	dc.l	$55555555	; Tile #773
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$99225555
  	dc.l	$99999925
  	dc.l	$99999999
  	dc.l	$99999999
  	dc.l	$99999999
  	dc.l	$55555555	; Tile #774
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$22555555
  	dc.l	$99225555
  	dc.l	$99992555
  	dc.l	$55555555	; Tile #775
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #776
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #777
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #778
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #779
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #780
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #781
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #782
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55555555	; Tile #783
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #784
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #785
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #786
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #787
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #788
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #789
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #790
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #791
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #792
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #793
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #794
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #795
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #796
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #797
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #798
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555512	; Tile #799
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$22299999	; Tile #800
  	dc.l	$55522229
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$99999999	; Tile #801
  	dc.l	$99999999
  	dc.l	$22299999
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$99999999	; Tile #802
  	dc.l	$99999999
  	dc.l	$99999992
  	dc.l	$52222555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$99922255	; Tile #803
  	dc.l	$92221555
  	dc.l	$22555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #804
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #805
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #806
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #807
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #808
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #809
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555	; Tile #810
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55555555
  	dc.l	$55000000	; Tile #811
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000
  	dc.l	$55000000

__end:
