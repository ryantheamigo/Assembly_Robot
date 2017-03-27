    # **************************************************************************
    # Author: Ryan Epperson
    # 
    # Program: Lab 6 - ROBO driver "figure skating"
    # 
    # Description: 
    # **************************************************************************
    
    # s0 - accumulator
    # s1 - program counter
    # s2 - opcode
    # s3 - operation
    # s4 - operand
    # s5 - upper accumulator
    
    .global main
    
    .include "led_lib.s"
    .include "timer_and_interrupt_lib.s"
    .include "motor_lib.s"
    
    # data section
    .data
	program_counter:    .word 0
	# instructions in hex for program to run
    # *************************************************************
    # instructions contain six digit hex opcode (0xFFFFFF)
    # most significant 2 are the operation, rest are operand
    # *************************************************************
	
	# Square
	instructions:	    .word 0x420000, 0x425050, 0x440FA0, 0x455050, 0x4406A4, 0x425050, 0x440FA0, 0x455050, 0x4406A4, 0x425050, 0x440FA0, 0x455050, 0x4406A4, 0x425050, 0x440FA0
	
	# Circle
		    	    .word 0x420000, 0x410100, 0x42505A, 0x444268
	
	# Triangle		  reset	    direction forward	brake	  rotate    brake     repeat
			    .word 0x420000, 0x410100, 0x425050, 0x440FA0, 0x420050, 0x440FA0, 0x425050, 0x440FA0, 0x420050, 0x440FA0, 0x425050, 0x440FA0
    
	# Figure 8		  reset	    direction b-right	brake	  direction b-left    brake	b-right	  brake	    halt    
			    .word 0x420000, 0x410100, 0x424B5F, 0x441770, 0x410100, 0x425F4B, 0x442328, 0x424B5F, 0x441770, 0x340000
	
	families:	    .word robo_data, robo_math, robo_branch, robo_control, robo_led
	
	data_ops:	    .word robo_read, robo_write, robo_load, robo_store, robo_loadi
	math_ops:	    .word robo_add, robo_sub, robo_mult
	branch_ops:	    .word robo_b, robo_beqz, robo_bnez, robo_halt
	control_ops:	    .word robo_direction, robo_forward, robo_backward, robo_brake, robo_rotate_right, robo_rotate_left
	led_ops:	    .word robo_output, robo_clear, robo_delay
	storage:	    .space 80
	timer_counter:	    .word 0
    
    .text
   
    # embedded loop
    .ent main
    main:
	DI
	jal setup_multi_vector_mode
	jal setup_leds
	jal setup_output_compare2
	jal setup_output_compare3
	jal setup_timer2_16bit
 	jal setup_timer3_16bit
	jal enable_timer3
	jal setup_motor_pins
	
	nop
	
	EI
	
	LI $t0, 11 << 7
	SW $t0, LATDCLR
	
	main_loop:
	    jal fetch
	    nop
	    
	    jal decode
	    nop
	    move $a0, $v0
	
	    jal execute
	    nop
	
	    j main_loop
	
	halt_end:
	    nop
	j halt_end
    .end main
    
    # family fetch (void)
    .ent fetch
    fetch:
	lw $s1, program_counter
	la $t1, instructions
	sll $t0, $s1, 2			# multiplies PC by 2 for address offset
	add $t0, $t0, $t1		# add base to offset   
	# t0 is now current address
	
	lw $s2, 0($t0)			# loads into instruction reg
	li $t0, 0xFF0000
	and $s3, $s2, $t0		# opcode reg
	sra $s3, $s3, 16
	andi $s4, $s2, 0xFFFF		# operand reg
	
	addiu $s1, $s1, 1		# increments pc
	sw $s1, program_counter		# stores new pc value
	
	jr $ra				# return to caller
    
    .end fetch
    
    # instruction decode (family)
    .ent decode
    decode:
	# loads family address
	la $t1, families
	andi $t0, $s3, 0xF0
	sra $t0, $t0, 4
	addi $t0, $t0, -1		# hex address in table starts at zero, but 
	sll $t0, $t0, 2			#   the user input will be 1
	add $t0, $t0, $t1		# offsets family base by $t0
	lw $t1, 0($t0)			# loads family type (x_ops)
	
	# loads instruction w/in family
	andi $t2, $s3, 0xF
	addi $t2, $t2, -1		# zero indexes
	sll $t2, $t2, 2			# mult by 2 for addressing
	
	jr $t1				# jumps to family type
	
	robo_data:
	    la $t0, data_ops		# loads op table
	    add $t2, $t2, $t0		# adds instruction to base address
	    lw $v0, 0($t2)		# loads instruction
	    j return
	    
	robo_math:
	    la $t0, math_ops		# loads op table
	    add $t2, $t2, $t0		# adds instruction to base address
	    lw $v0, 0($t2)		# loads instruction
	    j return
    
	robo_branch:
	    la $t0, branch_ops		# loads op table
	    add $t2, $t2, $t0		# adds instruciton to base address
	    lw $v0, 0($t2)		# loads instruction
	    j return
	    
	robo_control:
	    la $t0, control_ops		# loads op table
	    add $t2, $t2, $t0		# adds instruciton to base address
	    lw $v0, 0($t2)		# loads instruction
	    j return
	    
	robo_led:
	    la $t0, led_ops		# loads op table
	    add $t2, $t2, $t0		# adds instruciton to base address
	    lw $v0, 0($t2)		# loads instruction
	    j return
	    
	return:
	    jr $ra
   
    .end decode
    
    # void execute (instruction)
    .ent execute
    execute:
	# la $a1, instructions		# prepares the instruction input for 
	# andi $a1, $a1, 0xFF		#   passing into function
	
	jr $a0				# jumps to subr
    .end execute
    
    # **********************
    # robo_data instructions
    # **********************
    .ent robo_read
    robo_read:
	lw $t1, PORTE			# reads from PORTE 7:0
	andi $t1, 0xFF			
	
	la $t2, storage			# loads instruction address
	sll $t0, $s4, 2		
	add $t0, $t0, $t2
	
	li $t0, 0xFF			# sets PORTE 7:0 as input
	sw $t0, TRISESET
	sw $t1, 0($t0)			# stores to data slot
	
	jr $ra
    .end robo_read
    
    .ent robo_write
    robo_write:
	la $t2, storage			# loads instruction address
	sll $t0, $s4, 2			
	add $t0, $t0, $t2
	
	lw $t1, 0($t0)			# retrieves data from memory
	andi $t1, $t1, 0xFF
	
	li $t0, 0xFF			# sets PORT 7:0 as output
	sw $t0, TRISECLR
	sw $t1, LATESET
	
	jr $ra
    .end robo_write
    
    .ent robo_load
    robo_load:
	la $t2, storage			# loads instruction address 
	sll $t0, $s4, 2			
	add $t0, $t0, $t2		# adds input offset
	
	lw $s0, 0($t0)			# loads from memory into s0

	jr $ra
    .end robo_load
    
    .ent robo_store
    robo_store:
	la $t2, storage			# loads instruction address 
	sll $t0, $s4, 2			
	add $t0, $t0, $t2		# adds input offset
	
	sw $s0, 0($t0)
	
	jr $ra
    .end robo_store
    
    .ent robo_loadi
    robo_loadi:
	move $s0, $s4
	jr $ra
    .end robo_loadi
    
    # **********************
    # robo_math instructions
    # **********************
    .ent robo_add
    robo_add:
	la $t0, storage		# loads operand from storage
	sll $t1, $s4, 2
	add $t0, $t0, $t1
	sw $t1, 0($t0)
	
	add $s0, $s0, $t1	# adds operand to accumulator
	
	jr $ra
    .end robo_add
    
    .ent robo_sub
    robo_sub:
	la $t0, storage		# loads operand from storage
	sll $t1, $s4, 2
	add $t0, $t0, $t1
	lw $t1, 0($t0)
	
	sub $s0, $s0, $t1	# subtracts operand from accumulator
	
	jr $ra
    .end robo_sub
    
    .ent robo_mult
    robo_mult:
	la $t0, storage			# calculates data address
	sll $t1, $s4, 2
	add $t0, $t0, $t1
	
	lw $t1, 0($t0)			# loads from storage
	mult $t1, $s0			# multiplies to accumulator
	
	mfhi $s5			# grabs from accumulator
	mflo $s0
	
	jr $ra
    .end robo_mult
    
    # ************************
    # robo_branch instructions
    # ************************
    .ent robo_b
    robo_b:
	sw $s4, program_counter	    # set program counter
	jr $ra
    .end robo_b
    
    .ent robo_beqz
    robo_beqz:
	bnez $s0, end_beqz	    # skips jump if s0 != 0
	sw $s4, program_counter	    # set program counter
	
	end_beqz:
	    jr $ra
    .end robo_beqz
    
    .ent robo_bnez
     robo_bnez:
	beqz $s0, end_bnez	    # skips jump if s0 == 0
	sw $s4, program_counter	    # set program counter
	
	end_bnez:
	    jr $ra
    .end robo_bnez
    
    .ent robo_halt
    robo_halt:
	j halt_end
    .end robo_halt
    
    # *************************
    # robo_control instructions
    # *************************
    
    .ent robo_direction
    robo_direction:
	# turns off enable pin
	sw $zero, OC2RS
	sw $zero, OC2RS
	
	# masks value from operand
	andi $t0, $s4, 0xF
	andi $t1, $s4, 0xF00
	
	# jumps to set_high if t0 == 1
	li $t2, 0b1000000
	bgtz $t0, set_high1
	
	# clears direction pin
	sw $t2, LATDCLR
	j set2
	
	# sets direction pin high
	set_high1:
	sw $t2, LATDSET
	
	# runs again for second motor
	set2:
	li $t2, 0b10000000
	bgtz $t1, set_high2
	sw $t2, LATDCLR
	j end_direction
	
	set_high2:
	sw $t2, LATDSET
	
	end_direction:
	jr $ra
	
    .end robo_direction
    
    # drives both wheels forward at independent input speeds
    .ent robo_forward
    robo_forward:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# writes zero to EN before changing DIR
	move $a0, $zero
	move $a1, $zero
	jal write_to_motors
	
	li $t0, 0b10000000
	sw $t0, LATDSET
	li $t0, 0b1000000
	sw $t0, LATDCLR
    
	andi $a0, $s4, 0xFF
	andi $a1, $s4, 0xFF00
	sra $a1, $a1, 8
	
	jal write_to_motors
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra			    # return to caller
    .end robo_forward
    
    .ent robo_backward
    robo_backward:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# writes zero to EN before changing DIR
	move $a0, $zero
	move $a1, $zero
	jal write_to_motors
	
	li $t0, 0b1000000
	sw $t0, LATDSET
	li $t0, 0b10000000
	sw $t0, LATDCLR
    
	andi $a0, $s4, 0xFF
	andi $a1, $s4, 0xFF00
	sra $a1, $a1, 8
	
	jal write_to_motors
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra			    # return to caller
    .end robo_backward
    
    # implements a timer delay and stops the motors after
    # a count is fufilled
    .ent robo_brake
    robo_brake:
	addi $sp, $sp, -4
	sw $ra, 0($s0)
	
    	lw $t0, timer_counter
	
	brake_loop:
	lw $t1, timer_counter
	sub $t1, $t1, $t0
	beq $t1, $s4, end_brake 
	j brake_loop
	
	end_brake:
	move $a0, $zero
	move $a1, $zero
	jal write_to_motors
	
	lw $ra, 0($s0)
	addi $sp, $sp, -4
	
	jr $ra
    .end robo_brake
    
    # rotates the robot left on a dime
    .ent robo_rotate_left
    robo_rotate_left:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# writes zero to EN before changing DIR
	move $a0, $zero
	move $a1, $zero
	jal write_to_motors
	
	li $t0, 0b11000000
	sw $t0, LATDCLR
    
	andi $a0, $s4, 0xFF
	andi $a1, $s4, 0xFF00
	sra $a1, $a1, 8
	
	jal write_to_motors
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra			    # return to caller
    
    .end robo_rotate_left
    
    # rotates the robot right on a dime
    .ent robo_rotate_right
    robo_rotate_right:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	# writes zero to EN before changing DIR
	move $a0, $zero
	move $a1, $zero
	jal write_to_motors
	
	li $t0, 0b11000000
	sw $t0, LATDSET
    
	andi $a0, $s4, 0xFF
	andi $a1, $s4, 0xFF00
	sra $a1, $a1, 8
	
	jal write_to_motors
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	jr $ra			    # return to caller
    
    .end robo_rotate_right
    
    # *********************
    # robo_led instructions
    # *********************
    
    .ent robo_output
    robo_output:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $a0, $s0		# inputs s0 to leds
	beqz $s4, led_display
	
	la $t0, storage		# gets value from storage to display
	sll $t1, $s4, 2
	add $t0, $t0, $t1
	lw $a0, 0($t0)
	
	led_display:		# outputs to leds
	jal output_to_leds
	
	lw $ra, 0($sp)		# pops off stack and returns to caller
	addiu $sp, $sp, 4
	jr $ra
    .end robo_output
    
    .ent robo_clear
    robo_clear:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	move $a0, $zero
	jal output_to_leds
	
	lw $ra, 0($sp)		# pops off stack and returns to caller
	addiu $sp, $sp, 4
	jr $ra
    .end robo_clear
    
    .ent robo_delay
    robo_delay:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	
	li $a0, 25000
	jal delay
	
	lw $ra, 0($sp)		# pops off stack and returns to caller
	addiu $sp, $sp, 4
	jr $ra
    .end robo_delay
    
    
    # *****************
    # Setup motor subr
    # *****************
    
    .ent setup_motor_pins
    setup_motor_pins:
	li $t0, 0b11000110
	sw $t0, TRISDCLR
	sw $zero, LATD
	
	jr $ra
    .end setup_motor_pins
    
    # ********
    # Handlers
    # ********
    
    # handler for timer
    .section .vector_12, code
    j timer3Handler
    
    .text
    .ent timer3Handler
    timer3Handler:
	di
	
	# pushes to stack
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	
	lw $t0, timer_counter		# increments counter
	addi $t0, $t0, 1
	sw $t0, timer_counter	
	
	li $t0, 1 << 12		# clears flag
	sw $t0, IFS0CLR
	
	# pops off stack
	lw $t0, 0($sp)	
	lw $t1, 4($sp)
	addi $sp, $sp, 8
	
	ei
	eret
    
    .end timer3Handler
 

    
 