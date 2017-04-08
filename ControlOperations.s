.ifndef ControlOperations
    ControlOperations: 
       .include "MOTORS.s"
	.ent ROBO_LEFT
	    ROBO_LEFT:
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

	    jr $ra
	.end ROBO_LEFT

	.ent ROBO_RIGHT
	    ROBO_RIGHT:
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

	    jr $ra	
	.end ROBO_RIGHT

	.ent ROBO_FORWARD
	    ROBO_FORWARD:
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

	    jr $ra	
	.end ROBO_FORWARD

	.ent ROBO_BACKWARD 
	    ROBO_BACKWARD:	
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

	    jr $ra		
	.end ROBO_BACKWARD

	.ent ROBO_BRAKE
	    ROBO_BRAKE:
	    ADD $sp, $sp, -4 # Adds space on the stack
	    SW  $ra, 0($sp) # Save the current return address in the stack

	    # Base time is 1 tenth of a second
	    LI $t1, 62500
	    MOVE $t0, $s4 # Load the operand which is the multipler
	    MUL $t0, $t0, $t1 # Mutiplies the base 

	    # Set how long 
	    SW $t0, PR4

	    # Turn on timer 4
	    LI $t0, 1 << 15
	    SW $t0, T4CONSET

	    LI $t1, 1
	    # Loop will continue until interrupr sets the $t1 = 0
	    while_c:
	    BEQZ $t1, end_delay_c
	    NOP
	    J while_c

	    end_delay_c:

	    # Turn off timer 4
	    LI $t0, 1 << 15
	    SW $t0, T4CONCLR

	    LW  $ra, 0($sp)
	    ADD $sp, $sp, 4
	    JR $ra
	.end ROBO_BRAKE
.endif
    
    


