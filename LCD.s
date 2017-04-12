.ifndef LCD
    LCD:
    .include "ASCIINUMBERCON.s"
    .include "SENDTOUART2.s"
    .Data
    # ******************************************
    # LCD Data
    disp_left: .asciiz "Left Motor:"
    disp_right: .asciiz "Right Motor:"
    disp_motors_off: .asciiz "Motors off"
    clear_disp2: .byte 0x1B, '[', 'j', 0x00
    set_disp: .byte 0x1B, '[', '0', 'h', 0x00
    set_curs: .byte 0x1B, '[', '2', 'c', 0x00
    set_to_second_set: .byte 0x1B, '[', '1', ';', '0', 'H', 0x00
    # ****************************************** 
    .Text
    .ent display_left_Motor_DC
	display_left_Motor_DC:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LA $a0, clear_disp2
	JAL send
	LA $a0, disp_left
	JAL send
	LB $s0, OC2RS
	LI $s1, 10
	DIV $s0, $s1
	MFLO $a0
	JAL assign_ascii
	MOVE $a0, $v0
	JAL send_byte

	LB $s0, OC2RS
	LI $s1, 10
	DIV $s0, $s1
	MFHI $a0
	JAL assign_ascii
	MOVE $a0, $v0
	JAL send_byte
   
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end display_left_Motor_DC
    
    .ent display_right_Motor_DC
	display_right_Motor_DC:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LA $a0, disp_right
	JAL send
	LB $s0, OC3RS
	LI $s1, 10
	DIV $s0, $s1
	MFLO $a0
	JAL assign_ascii
	MOVE $a0, $v0
	JAL send_byte

	LB $s0, OC3RS
	LI $s1, 10
	DIV $s0, $s1
	MFHI $a0
	JAL assign_ascii
	MOVE $a0, $v0
	JAL send_byte
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end display_right_Motor_DC
    
    .ent display_motors
	display_motors:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	JAL display_left_Motor_DC
	LA $a0, set_to_second_set
	JAL send
	JAL display_right_Motor_DC
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end display_motors
    
    .ent clear_LCD
	clear_LCD:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LA $a0, clear_disp2
	JAL send 
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end clear_LCD
.endif


