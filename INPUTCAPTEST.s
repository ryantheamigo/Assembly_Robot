.Global main

.Data
# ****************************************** 
clear_disp2: .byte 0x1B, '[', 'j', 0x00 
disp_motors_off: .asciiz "Motors off"
char_num: .byte 0,0,0,0
x_label: .asciiz "X:"
y_label: .asciiz "Y:"
    
.Text
   .include "BUTTON.s" 
   .include "SPI.s"
   .include "ASCIINUMBERCON.s"
   .include "SENDTOUART2.s"
   .include "UART2.s"
   
.ent main
    main:
    JAL setup_button
    JAL setup_SPI
    JAL setup_timer_1
    JAL setup_UART2
    LA $a0, clear_disp2
    JAL send 
    while:
#     JAL get_button
#     LI $t0, 1
#     BEQ $t0, $v1, TURNON
#     LI $t0, 2
#     BEQ $t0, $v1, TURNOFF
    
    JAL send_spi
    
    MOVE $a1, $v0 # x data
    JAL convert_
    LA $a0, x_label
    JAL send
    LA $a0, char_num
    JAL send
    
    MOVE $a1, $v1 # y data
    JAL convert_
    LA $a0, y_label
    JAL send
    LA $a0, char_num
    JAL send
    J while
    
   TURNON:
#     JAL send_spi
#     MOVE $a1, $v0 # Y data
#     JAL convert_
#     LA $a0, char_num
#     MOVE $s1, $v1 # X data
   J while

   TURNOFF:
   LA $a0, clear_disp2
   JAL send_spi
   J while
    
.end main

.ent convert_
    convert_:
    ADDI $sp, $sp,-4
    SW $ra, 0($sp)
    
    LI $t6, 10
    DIV $a1, $t6
    LA $t0, char_num
    MFHI $t1
    ADDI $t1, $t1, 48
    SB $t1, 3($t0)
    MFLO $a1
    
    DIV $a1, $t6
    LA $t0, char_num
    MFHI $t1
    ADDI $t1, $t1, 48
    SB $t1, 2($t0)
    MFLO $a1
    
    DIV $a1, $t6
    LA $t0, char_num
    MFHI $t1
    ADDI $t1, $t1, 48
    SB $t1, 1($t0)
    MFLO $a1
    
    DIV $a1, $t6
    LA $t0, char_num
    MFHI $t1
    ADDI $t1, $t1, 48
    SB $t1, 0($t0)
    MFLO $a1
    
    LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    JR $ra
  .end convert_