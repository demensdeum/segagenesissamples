  include "romHeader.asm"
  include "vdpRegisters.asm"
  include "colors.asm"
  include "sprite.asm"

vdp_vram_write_command = $40000000

vdp_control_port     = $C00004
vdp_data_port        = $C00000

joypad_one_control_port = $A10009
joypad_one_data_port = $A10003

vsync_flag = $00FF00000

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
  move.l  d0,vdp_control_port ; Asking to VDP access CRAM at byte 0 (bits from sega manual) ; #$C07f0000 last color index 127
  move.w  (a0)+,d1;
  move.w  d1,(vdp_data_port);
  add.l #$20000,d0 ; increment address
  dbra d7,VDPCRAMFillLoopStep

ClearVRAM:
  move.l #$40000000,vdp_control_port; write to VRAM command
  move.w #16384,d0 ; counter
ClearVRAMLoop:
  move.l #$00000000,vdp_data_port;
  dbra d0,ClearVRAMLoop

SpriteVRAM:
  lea Sprite,a0
  move.l #$40200000,vdp_control_port; write to VRAM command
  move.w #128,d0 ; (16*8 rows of sprite) counter
SpriteVRAMLoop:
  move.l (a0)+,vdp_data_port;
  dbra d0,SpriteVRAMLoop

skeletonXpos = $FF0000
skeletonYpos = $FF0002
frameCounter = $FF0004
skeletonHorizontalFlip = $FF0006

  move.w #$0100,skeletonXpos
  move.w #$0100,skeletonYpos
  move.w #$0001,skeletonHorizontalFlip

FillSpriteTable:
  move.l #$70000003,vdp_control_port
  move.w skeletonYpos,vdp_data_port
  move.w #$0F00,vdp_data_port
  move.w skeletonHorizontalFlip,vdp_data_port
  move.w skeletonXpos,vdp_data_port

StartWaitFrame:
  move.w #512,frameCounter
WaitFrame:
  move.w frameCounter,d0
  sub.w #1,d0
  move.w d0,frameCounter
  dbra d0,WaitFrame

GameLoop:
  jsr ReadJoypad
  jsr HandleJoypad
  jmp GameLoop

ReadJoypad:
  move.b #$40,joypad_one_control_port; C/B/Dpad
  nop ; bus sync
  nop ; bus sync
  move.b joypad_one_data_port,d2
  rts

HandleJoypad:
  cmp #$FFFFFF7B,d2; handle left
  beq MoveLeft
  cmp #$FFFFFF77,d2; handle right
  beq MoveRight
  cmp #$FFFFFF7E,d2; handle up
  beq MoveUp
  cmp #$FFFFFF7D,d2; handle down
  beq MoveDown
  rts

MoveUp:
  move.w skeletonYpos,d0
  sub.w #1,d0
  move.w d0,skeletonYpos
  jmp FillSpriteTable

MoveDown:
  move.w skeletonYpos,d0
  add.w #1,d0
  move.w d0,skeletonYpos
  jmp FillSpriteTable

MoveLeft:
  move.w skeletonXpos,d0
  sub.w #1,d0
  move.w d0,skeletonXpos
  move.w #$0801,skeletonHorizontalFlip
  jmp FillSpriteTable

MoveRight:
  move.w skeletonXpos,d0
  add.w #1,d0
  move.w d0,skeletonXpos
  move.w #$0001,skeletonHorizontalFlip
  jmp FillSpriteTable

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
