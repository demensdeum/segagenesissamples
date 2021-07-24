DATA_RomHeader:
 00 ff 2b 52 00 00 02 00 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 92 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 00 00 49 90 53 45 47 41 20 4d 45 47 41 20 44 52 49 56 45 20 28 43 29 20 20 20 20 20 20 20 20 20 2e 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 2d 20 20 00 00 4a 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 00 00 00 00 00 07 ff ff 00 ff 00 00 00 ff ff ff 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 55 45 20 20 20 20 20 20 20 20 20 20 20 20 20 20

SUBROUTINE_InitializeTMSS:
  MOVE.B A1,D0; get hardware version into D0 registry
  ANDI.B 0x0F,D0; mask last 4 bits in D0 (see only 4 last bits)
  BEQ.B SUBROUTINE_Entry; if D0 == 0 then jump to SUBROUTINE_Loop, because there is no security lock.
  MOVE.L "SEGA",A1; fill security lock with long word "SEGA" (ASCII - 0x53 0x45 0x47 0x41) into A1 address registry

DATA_TestTile:
 0F 0F 01 15 03 56 01 39 00 31 00 33 07 85 05 CD 0A 9D 0E EE 01 54 04 EE 09 8A 07 43 0F 95 07 9A

SUBROUTINE_Entry:
SUBROUTINE_LoadPalette:
  MOVE.L 0xC0000003,0xC0000004

SUBROUTINE_LoadPaletteLoop:
  NOP; TODO

SUBROUTINE_LoadPalletes:
  NOP; TODO
