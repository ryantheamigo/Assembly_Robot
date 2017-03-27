.ifndef timer_and_interrupt_lib
    timer_and_interrupt_lib:    

    .ent setup_multi_vector_mode
    setup_multi_vector_mode:
    addi $sp, $sp, -4
    sw $s0, 0($sp)
    
     # setup multi vector mode (enable interrupt table)
    la $s0, INTCON # Register necessary for setting multi-vectored mode
    lw $t0, ($s0)
    ori $t0, $t0, 1 << 12 # Set for mutli-vectored mode
    sw $t0, INTCON
    
    lw $s0, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
    .end setup_multi_vector_mode
    
    # enables timer 2
    .ent enable_timer2
    enable_timer2:
    # Preserve registers - push to stack
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	# Reenables timer
	li $t3, 1 << 15
	lw $t4, T2CON
	or $t3, $t3, $t4
	sw $t3, T2CON

	la $s0, IEC0 # Interrupt enable control register - our mask register
	lw $t0, 0($s0)
	ori $t0, $t0, 0b1 << 8 # Set corresponding mask bit to 1 to enable, 12 is T3IE (Timer 3 Interrupt Enable) position
	sw $t0, 0($s0)

	# Pop registers
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8

	jr $ra
    
    .end enable_timer2
    
    # disables timer 2
    .ent disable_timer2
    disable_timer2:
    # Preserve registers - push to stack
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	# Disables timer
	li $t3, 0x7FFF
	lw $t4, T2CON
	and $t3, $t3, $t4
	sw $t3, T2CON

	la $s0, IEC0CLR # Interrupt enable control register - our mask register
	li $t1, 1
	sll $t1, $t1, 12
	sw $t1, ($s0)

	# Pop registers
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8

	jr $ra
    
    .end disable_timer2
    
    # sets up timer 2 as a 16 bit timer with a 256 PBCLK divison
    .ent setup_timer2_16bit
    setup_timer2_16bit:
	addi $sp, $sp, -8	# preserve to stack
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	# disables timer 2 and sets all options to zero
	la $s0, T2CON
	move $t0, $zero
	lw $t0, 0($s0)
	
	# claers timer 2 value
	la $s0, TMR2
	move $zero, $t0
	lw $t0, 0($s0)
	
	# sets period register - determines how often the PWM is reset
	la $s0, PR2
	li $t0, 99
	sw $t0, 0($s0)
	
	# <15> enables T2CON
	# <6:4> sets prescaler to /64
	# <3> sets to 16 bit timer
	la $s0, T2CON
	li $t0, 0x8040
	sw $t0, 0($s0)
	
	# Pop registers
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8

	jr $ra

    .end setup_timer2_16bit
    
    # enables timer 2
    .ent enable_timer3
    enable_timer3:
    # Preserve registers - push to stack
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	# Reenables timer
	li $t3, 1 << 15
	lw $t4, T3CON
	or $t3, $t3, $t4
	sw $t3, T3CON

	la $s0, IEC0 # Interrupt enable control register - our mask register
	lw $t0, 0($s0)
	ori $t0, $t0, 0b1 << 12 # Set corresponding mask bit to 1 to enable, 12 is T3IE (Timer 3 Interrupt Enable) position
	sw $t0, 0($s0)

	# Pop registers
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8

	jr $ra
    
    .end enable_timer3
    
    # disables timer 3
    .ent disable_timer3
    disable_timer3:
    # Preserve registers - push to stack
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	# Disables timer
	li $t3, 0x7FFF
	lw $t4, T3CON
	and $t3, $t3, $t4
	sw $t3, T3CON

	la $s0, IEC0CLR # Interrupt enable control register - our mask register
	li $t1, 1
	sll $t1, $t1, 12
	sw $t1, ($s0)

	# Pop registers
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8

	jr $ra
    
    .end disable_timer3
    
    # sets up timer 3 as a 16 bit timer with a 256 PBCLK divison
    .ent setup_timer3_16bit
    setup_timer3_16bit:
	addi $sp, $sp, -8	# preserve to stack
	sw $ra, 4($sp)
	sw $s0, 0($sp)
	
	# disables timer 2 and sets all options to zero
	la $s0, T3CON
	move $t0, $zero
	lw $t0, 0($s0)
	
	# clears timer 2 value
	la $s0, TMR3
	move $zero, $t0
	lw $t0, 0($s0)
	
	# sets period register - determines how often the PWM is reset
	la $s0, PR3
	li $t0, 156	# counts milliseconds
	sw $t0, 0($s0)
	
	# <15> enables T3CON
	# <6:4> sets prescaler to /256
	# <3> sets to 16 bit timer
	la $s0, T3CON
	li $t0, 0x8060
	sw $t0, 0($s0)
	
	# Set priority IPC2<4:2> to six 
	# la $s0, IPC2
	la $s0, IPC3
	lw $t0, 0($s0)
	ori $t0, $t0, 6 << 2
	sw $t0, 0($s0)
	
	# Set priority IPC3<4:2> to six 
# 	la $s0, IPC3
# 	lw $t0, 0($s0)
# 	li $t1, 0xFFFFFFE3
# 	and $t0, $t0, $t1
# 	ori $t0, $t0, 0b10000
# 	sw $t0, 0($s0)
	
	# Pop registers
	lw $s0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8

	jr $ra
    .end setup_timer3_16bit
    
#    # Sets up timer 2 & 3 as a 32-bit timer with a 256 PBCLK division
#     .ent setup_timer2_32bit
#     setup_timer2_32bit:
#  
# 	addi $sp, $sp, -8	# preserve to stack
# 	sw $ra, 4($sp)
# 	sw $s0, 0($sp)
# 
# 	# Halts and clears timer 2 functions
# 	la $s0, T2CON
# 	li $t0, 0x0	   
# 	sw $t0, 0($s0)
# 	
# 	# T2CON <15> - enable timer
# 	# T2CON <7> - enable gate accumulation
# 	# T2CON <6:4> - PBCLK / 256
# 	# T2CON <3> - enable 32-bit clock
# 	la $s0, T2CON
# 	li $t0, 0x8078  
# 	sw $t0, 0($s0)
# 	
# 	# TMR2 contains current value of timer 2
# 	la $s0, TMR2
# 	move $t0, $zero
# 	sw $t0, 0($s0)
# 	
# 	# Sets the period match value to 1 sec
# 	la $s0, PR2
# 	li $t0, 156250
# 	sw $t0, 0($s0)
# 	
# 	# Set priority IPC2<4:2> to six 
# 	# la $s0, IPC2
# 	la $s0, IPC3
# 	lw $t0, 0($s0)
# 	ori $t0, $t0, 6 << 2
# 	sw $t0, 0($s0)
# 	
# 	# Pop registers
# 	lw $s0, 0($sp)
# 	lw $ra, 4($sp)
# 	addi $sp, $sp, 8
# 	
# 	jr $ra
#     
#     .end setup_timer2_32bit
    
.endif

