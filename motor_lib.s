.ifndef motor_lib
    motor_lib:
    
    # sets up output compare two for use with exsisting motor setup
    .ent setup_output_compare2
    setup_output_compare2:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	# turns off OC2 and clears all control reg
	move $t0, $zero
	sw $t0, OC2CON
	sw $t0, OC2R
	sw $t0, OC2RS
	
	# sets OC2 behavior
	la $s0, OC2CON
	li $t0, 6
	ori $t0, $t0, 1 << 15
	sw $t0, 0($s0)
	
	# Set priority of compare match interrupt IPC2<20:18>
	la $s0, IPC2SET
	li $t0, 6 # priority 6
	sll $t0, $t0, 18
	sw $t0, ($s0)

	# Pop registers
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra
    
    .end setup_output_compare2
    
    # sets up output compare three for use with exsisting motor setup
    .ent setup_output_compare3
    setup_output_compare3:
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	# turns off OC2 and clears all control reg
	move $t0, $zero
	sw $t0, OC3CON
	sw $t0, OC3R
	sw $t0, OC3RS
	
	# sets OC2 behavior
	la $s0, OC3CON
	li $t0, 6
	ori $t0, $t0, 1 << 15
	sw $t0, 0($s0)
	
	# Set priority of compare match interrupt IPC2<20:18>
	la $s0, IPC2SET
	li $t0, 6 # priority 6
	sll $t0, $t0, 18
	sw $t0, ($s0)

	# Pop registers
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra
    
    .end setup_output_compare3
    
    # writes to motors individually
    # a0 - duty cylce of right motor
    # a1 - duty cycle of left motor
    .ent write_to_motors
    write_to_motors:
	# pops on stack
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	
	# takes duty cycle as input for each motor
	move $s0, $a0	# left duty cycle
	move $s1, $a1	# right duty cycle
	
	# writes to motors
	sw $s0, OC2RS
	sw $s1, OC3RS
	
	# pops off stack
	lw $ra, 8($sp)
        lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 12
	
	jr $ra
    .end write_to_motors
    
.endif



