# ***************************************************************************************************************************
# * Author: Aron Galvan                                                                                                     
# * Course: EE 234 Microprocessor Systems                                                                                   
# * Project: ROBOMAL                                                                                                        
# * File: ROBOMAL.s                                                                                                                                                                                                                *
# * Description: This program simulates the general three stage process of a microprocessor, fetch, decode, and execute.                                       
# *              The instruction consist of four hex values, where the most signficant hex value is the, family operations  
# *              the instruction belongs to. The second most signficant hex value indicates, what operation to perform      
# *		 within the given family. Finally the last to hex values are resevered for data/operands depending on the   
# *		 operation. Some of the CPU registers are strictly defined to maintain consistency in the program.          
# *		  | Register |    Usage                                                                                     
# *                    $s0      Accumulator                                                                                 
# *                    $s1      Instruction Counter                                                                         
# *                    $s2      Instruction Register                                                                        
# *                    $s3      Operation Code                                                                              
# *                    $s4      Operand                                                                                     
# *                    $s5      Modulus of multiplication                                                                   
# *                    $s6      Address of program_counter                                                                  
# *                    $s7      Address of numbers_data                                                                     
# *                    $a0      Arguments between subroutines                                                               
# *                  $v0-$v1    Returned Parameters		                                                            								  
# *Revision History: 3/2/2017                                                                                               
# ***************************************************************************************************************************
.Global main
    .include "ControlOperations.s"
    .include "DataOperations.s"
    .include "BranchOperations.s"
    .include "MathOperations.s"
    .include "LEDS.s" 
    .include "MOTORS.s"
    .include "TIMER32.s"
    .include "SENSORS.s"
    .include "RECEIVEUART1.s"
    .include "UART1.s"
    .include "UART2.s"
    
.Data
    # ***********************************************************************************************************************************************
    # * Instruction are composed of 4 HEX values, Most significant Hex indicates the which family of operations the instruction is                  
    # * HEX 3, indicates the operation to execute                                                                                                   
    # * HEX 2,1 are reserved for data/operands                                                                                                      
    # * Example: Instruction 0x13AF														    
    # * HEX 1 = 1 >>> binary representation 0001 >>> decimal representation 1, since the decimal value is 1 the operation is a control operation    
    # * HEX 2 = 3 >>> binary representation 0011 >>> decimal representation 3, since the decimal value is 3 the operation is robo forward           
    # * HEX 3 = A >>> binary representation 1010 >>> decimal representation 10, the first operands value                                            
    # * HEX 4 = F >>> binary representation 1111 >>> decimal representation 15, the second operand value                                            
    # *																		    
    # *| HEX-VALUES |   FAMILY    |  OPERATION													    
    # *    110000       control_ops   ROBO_LEFT													    
    # *    102000       control_ops   ROBO_RIGHT													    
    # *    103000       control_ops   ROBO_FORWARD												    
    # *    104000       control_ops   ROBO_BACKWARD												    
    # *    105000       control_ops   ROBO_BRAKE													    
    # *    201000       branch_ops    ROBO_JUMP													    
    # *    202000       branch_ops    ROBO_BEQZ													    
    # *    203000       branch_ops    ROBO_BNEZ													    
    # *    204000       branch_ops    ROBO_HALT													    
    # * etc......																    
    # ***********************************************************************************************************************************************
    program_counter: .word 0
    instructions:.word 0
    
    control_ops: .word ROBO_LEFT, ROBO_RIGHT, ROBO_FORWARD, ROBO_BACKWARD, ROBO_BRAKE, READ_SENSOR
    branch_ops: .word ROBO_JUMP, ROBO_BEQZ, ROBO_BNEZ, ROBO_HALT
    data_ops: .word ROBO_READ, ROBO_WRITE, ROBO_LOAD, ROBO_STORE, ROBO_LOADI
    math_ops: .word ROBO_ADD, ROBO_SUB, ROBO_MUL
    
    numbers_data: .word  
.Text
.ent main
    main:
	SW $zero, LATDSET
	JAL setup_led
	JAL left_motor
	JAL right_motor
	JAL motor_timer
	JAL timer_setup
	JAL setup_sensor
	JAL setup_UART1
	JAL setup_UART2
	
	JAL place_instructions
	
	
	while:
	JAL fetch 

	MOVE $a0, $v0 # Move fetched instruction into $a0 pass to decode
	JAL decode

	MOVE $a0, $v0 # Move the address of the operation into $a0 pass to execute
	MOVE $a1, $v1 # Move the data pass to execute
	JAL execute

	J while
.end main

# ***************************************************************************************************************************
# * Author: Aron Galvan                                                                                                     
# * Course: EE 234 Microprocessor Systems                                                                                   
# * Project: ROBOMAL                                                                                                        
# * File: ROBOMAL.s                                                                                                         
# * Subroutine: fetch                                                                                                       
# * Description: This function fetches the intsruction to be executed in the ROBOMAL program, then increments the program   
# * by one to indictate the instruction was fetched                                                                         
# * Inputs: None                                                                                                            
# * Outputs: $v0 - The ROBOMAL instruction fetched                                                                          
# * Computations: Increments the program counter by 1                                                                       
# *                                                                                                                         
# * Revision History: 3/2/2017                                                                                              
# ***************************************************************************************************************************
.ent fetch
    fetch:
    LW $s1, program_counter # Loads the value of the program counter
    LA $t1, instructions # Loads the address of the instruction
    SLL $t0, $s1, 2 # Multiply the value of the program counter by 4 
    ADD $t0, $t0, $t1 # Adding the multiply value to address of instruction
    LW $v0, 0($t0) # Loads the instruction into $v0
    LW $s2, 0($t0) # Store the instruction into $s2
    ADD $s1, $s1, 1 # Increments the program counter
    SW $s1, program_counter # Store the value of the program counter into $s1
    
    JR $ra
.end fetch
 
# ***************************************************************************************************************************
# * Author: Aron Galvan                                                                                                     
# * Course: EE 234 Microprocessor Systems                                                                                   
# * Project: ROBOMAL                                                                                                        
# * File: ROBOMAL.s                                                                                                         
# * Subroutine: decode                                                                                                      
# * Description: This function decodes the instruction fected into its consituent parts, family, operation, and operands.   
# * Inputs: $a0 - The ROBOMAL instruction to decode                                                                         
# * Outputs: $v0 - The ROBOMAL operation, the address of the operation                                                      
# *          $v1 - The operands of the ROBOMAL instruction                                                                  
# * Computations: None                                                                                                      
# *                                                                                                                         
# * Revision History: 3/2/2017                                                                                              
# ***************************************************************************************************************************
.ent decode
    decode:
    LI $t0, 0xF00000
    AND $t3, $a0, $t0 # Mask off family
    LI $t0, 0x0F0000
    AND $t4, $a0, $t0 # Mask off the operation 
    LI $t0, 0x00FFFF
    AND $t5, $a0, $t0 # Mask of the last 16 bits 
    
    
    ADD $s3, $t3, $t4 # Stores the opcode 
    MOVE $v1, $t5 # Stores the data section of the command
    MOVE $s4, $t5 # Store Data/Operand section of the instruction into $s4
    
    SRL $t1, $t3, 20 # Shift the four bits values to the first four bits, used to check the family
    MOVE $t2, $t1 
 
    BEQ $t2, 0x1, Control # Jumps to control which will decode which control operation to perform
    BEQ $t2, 0x2, Branch # Jumps to Branch which will decode which branch operation to perform
    BEQ $t2, 0x3, Data # Jumps to Data which will decode which Data operation to perform
    BEQ $t2, 0x4, Math # Jumps to Math which will decode which Math operation to perform
    
    Control:
    LA $t0, control_ops # Loads the address of the control_ops array 
    J op
    Branch:
    LA $t0, branch_ops # Loads the address of the branch_ops array 
    J op
    Data:
    LA $t0, data_ops # Loads the address of the data_ops array 
    J op
    Math:
    LA $t0, math_ops # Loads the address of the math_ops array 
    J op 
    
    op:
    SRL $t1, $t4, 16 # Shifts the second hex value over to the far right aligned with bits 0 - 3
    SUB $t1, $t1, 1
    SLL $t1, $t1, 2 # Mutiples the value to get the offset of the address
    ADD $t0, $t0, $t1 # Adds the offset to the ops array address
    MOVE $v0, $t0 # Stores the new address to $v0
    
    JR $ra 
.end decode

# ***************************************************************************************************************************
# * Author: Aron Galvan                                                                                                     
# * Course: EE 234 Microprocessor Systems                                                                                   
# * Project: ROBOMAL                                                                                                        
# * File: ROBOMAL.s                                                                                                         
# * Subroutine: execute                                                                                                     
# * Description: This function executes the instruction operation, by jumping to the correct operation address, which was   
# *              decode previsouly, the function also sets $s6 to the base address the program_counter, and $s7 to the base 
# *              of numbers_data                                                                                            
# * Inputs: $a0 - The ROBOMAL operation address                                                                             
# * Outputs: None                                                                                                           
# * Computations: None                                                                                                      
# *                                                                                                                         
# * Revision History: 3/2/2017                                                                                              
# *************************************************************************************************************************** 
 .ent execute
    execute:
    ADD $sp, $sp, -4 # Adds space on the stack
    SW  $ra, 0($sp) # Save the current return address in the stack
    
    LA $s6, program_counter  # Loads the address of program counter
    LA $s7, numbers_data # Loads the base address of numbers_data
    LW $t0, 0($a0) # Get the value stored in a0
    JAL $t0 # Jump to the operation 
    
    LW  $ra, 0($sp)
    ADD $sp, $sp, 4

    JR $ra
 .end execute
 
 # ************************************************************************************************88
 # Functions Used to get Bluetooth instructions
 # places instructions in corresponing spot in array
.ent place_instructions
place_instructions:
    # pushes to stack
    addi $sp, $sp, -12
    sw $ra, 0($sp)
    sw $s0, 4($sp)
    sw $s1, 8($sp)
    
    la $s0, instructions    # loads instruction address
    move $s1, $zero # begins counter
    
    place_in_array:
	jal get_instruction	# gets hex instruction
	move $t0, $v0
	
	sll $t1, $s1, 2	# shifts for placing in array
	add $t1, $s0, $t1  # adds offset
	sw $t0, 0($t1) # place in instruction array
	addi $s0, $s0, 1
	
	beq $t0, 0x240000, end_place	# if halt, end
	j place_in_array
	
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
	# jal ascii_to_hex

	# moves BT output to temp reg
	move $t0, $v0
	
	# places digits in their place in the opcode
	mul $t1, $s0, 4	# multiplies counter by 4
	sllv $s1, $t0, $t1  # shifts by counter x 4
	
	addi $s0, $s0, -1    # decrement counter
	bnez $s0, read_from_BT 
    
    # move to output
    move $v0, $s1
    
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
 