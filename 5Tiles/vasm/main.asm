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
    move.w  #$00E,d0; Red color
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
  move.w #7,d0 ; counter
CharactersVRAMLoop:
  move.l (a0)+,vdp_data_port;
  dbra d0,CharactersVRAMLoop

FillBackground:
  move.w #1,d0     ; tile index 1
  move.l #$40000003,(vdp_control_port) ; initial drawing location
  move.l #$6FF,d3     ; how many tiles to draw (1792 total)
FillBackgroundLoop:
  move.w  d0,(vdp_data_port)    ; copy the pattern to VPD
  dbra    d3,FillBackgroundLoop    ; loop to next tile

Stuck:
    nop
    jmp Stuck

Characters:
  dc.l $00000000
  dc.l $01111100
  dc.l $01000100
  dc.l $01000100
  dc.l $01000100
  dc.l $01000100
  dc.l $01111100
  dc.l $00000000


; EXCEPTION AND INTERRUPT HANDLERS
; ----------------------------------------------------------------------------
    align 2 ; word-align code

ignore_handler
    rte ; return from exception (seems to restore PC)

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

__end:
