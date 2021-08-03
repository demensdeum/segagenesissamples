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
 
