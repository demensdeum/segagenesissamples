  include "romHeader.asm"
  include "vdpRegisters.asm"
  include "colors.asm"
  include "tiles.asm"

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

VDPCRAMFill:
    move.l #$C0000000,d0
    move.l  d0,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  #$0000,d1; Black color
    move.w  d1,(vdp_data_port);

VDPCRAMFillLoop:
    lea Colors,a0
    move.l #15,d7
VDPCRAMFillLoopStep:
    add.l #131072,d0 ; increment address
    move.l  d0,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
    move.w  (a0)+,d1;
    move.w  d1,(vdp_data_port);
    dbra d7,VDPCRAMFillLoopStep

ClearVRAM:
  move.l #$40000000,vdp_control_port; write to VRAM command
  move.w #16384,d0 ; counter
ClearVRAMLoop:
  move.l #$00000000,vdp_data_port;
  dbra d0,ClearVRAMLoop

TilesVRAM:
  lea Tiles,a0
  move.l #$40200000,vdp_control_port; write to VRAM command
  move.w #6488,d0 ; counter
TilesVRAMLoop:
  move.l (a0)+,vdp_data_port;
  dbra d0,TilesVRAMLoop

FillBackground:
  move.w #0,d0     ; column index
  move.w #1,d1     ; tile index
  move.l #$40000003,(vdp_control_port) ; initial drawing location
  move.l #2500,d7     ; how many tiles to draw (700 total)

imageWidth = 28
screenWidth = 64

FillBackgroundStep:
  cmp.w	#imageWidth,d0
	ble.w	FillBackgroundStepFill

FillBackgroundStep2:
  cmp.w	#imageWidth,d0
  bgt.w	FillBackgroundStepSkip

FillBackgroundStep3:
  add #1,d0
  cmp.w	#screenWidth,d0
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

__end:
