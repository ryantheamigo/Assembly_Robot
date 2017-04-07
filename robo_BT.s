
   
# places instructions in corresponing spot in array
.ent place_instructions
place_instructions:
    # pushes to stack
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    la $s0, instructions    # loads instruction address
    li $s1, counter # begins counter
    
    place_in_array:
	jal get_instructions	# gets hex instruction
	move $t0, $v0
	beq $t0, 0x204000, end_place	# if halt, end
	
	sll $t1, $s1, 2	# shifts for placing in array
	addi $t1, $s0, $t1  # adds offset
	sw $t0, 0($t1) # place in instruction array
	addi $s0, $s0, 1
	
    end_place:
    # pops off stack
    lw $ra, 0($sp)
    lw $s0, 4($sp)
    lw $s1, 8($sp)
    addi $sp, $sp, 12
    jr $ra
    
.end place_instructions
    
# loads 6-digit hex value from BT
.ent get_instruction
get_instruction:
    # pushes to stack
    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $ra, 12($sp)
    
    # load counter
    li $s0, 6
    read_from_BT:
	# reads byte from BT
	jal receive_byte
	move $a0, $v0	# moves output from recieve_byte to ascii_to_hex input
	jal ascii_to_hex

	# moves BT output to temp reg
	move $t0, $v0
	
	# places digits in their place in the opcode
	mul $t1, $s0, 4	# multiplies counter by 4
	sllv $s1, $t0, $t1  # shifts by counter x 4
	
	add $s0, $s0, -1    # decrement counter
	bnez $s0, read_from_BT 
    
    # move to output
    move $v0, $s0
    
    # pops off stack
    lw $s0, 0($sp)
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    
    jr $ra
.end get_instruction
    
# converts ascii input (a0) to hex output (v0)
.ent ascii_to_hex
ascii_to_hex:
    move $t0, $a0	# moves input to temp reg
    addi $t0, $t0, -30 # moves ascii 0-9 to hex 0-9
    
    sltiu $t1, $t0, 0xA	# if less than A, return to caller
    bgtz $t1, return	# skips if 0-9
    
    addi $t0, $t0, -7	# if greater than A, subtract 7 more
    
    return:
    # moves to output
    move $v0, $t1
    jr $ra
    
.end ascii_to_hex