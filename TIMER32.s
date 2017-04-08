.ifndef TIMERS2
    TIMER32:
	.ent timer_setup
	timer_setup:
	DI # Turning off all external interrupts 

	# Setup multi vector mode (enabling interrupt vector table)
	# INTCON<12> = 1 for multi vector mode
	LI $t0, 1 << 12
	SW $t0, INTCONSET

	# Turn off timer 4 and 5
	LI $t0, 1 << 15
	SW $t0, T4CONCLR
	SW $t0, T5CONCLR

	# Setting timer as a 32bit timer with timer 3
	# T4CON<3> = 1, 32-bit Timer Mode Select Bit
	LI $t0, 1 << 3
	SW $t0, T4CONSET

	# **************************************************************
	# Timer 2 configuration registers will be used to configure the timer
	# **************************************************************
	# Selecting the parent clock for the timer 
	# T4CON<1> = 0, Internal peripheral clock
	LI $t0, 1 << 1
	SW $t0, T4CONCLR

	# Setting the prescalar value for the peripheral clock
	# T4CON<6:4> = 0b110, 64 prescalar value
	LI $t0, 7 << 4
	SW $t0, T4CONCLR
	LI $t0, 6 << 4
	SW $t0, T4CONSET

	# Setting the counter timer count register to 0
	SW $zero, TMR4


	# ***********************************************************************
	# Timer 5 interrupt control registers will be used to configure the timer 
	# ***********************************************************************
	# Turn off timer 5 interrupt while setup configuration
	# IEC0<20> = 0, turn off 
	LI $t0, 1 << 20
	SW $t0, IEC0CLR 

	# Set interrupt priority to 6
	# IPC5<4:2> = 0b110
	LI $t0, 7 << 2
	SW $t0, IPC5CLR
	LI $t0, 6 << 2
	SW $t0, IPC5SET

	# Turn on the timer interrupt
	# IEC0<20> = 1, turn on
	LI $t0, 1 << 20
	SW $t0, IEC0SET

	EI
	JR $ra
     .end timer_setup

    .section .vector_20, code
    J timer_4_5_handler    

    .Text
    .ent timer_4_5_handler
	timer_4_5_handler:
	DI # Turn off all interrupts

	ADDI $sp, $sp, -100
	SW $v0, 0($sp)
	SW $v1, 4($sp)
	SW $a0, 8($sp)
	SW $a1, 12($sp)
	SW $a2, 16($sp)
	SW $a3, 20($sp)
	SW $t0, 24($sp)
	# SW $t1, 28($sp)
	SW $t2, 32($sp)
	SW $t3, 36($sp)
	SW $t4, 40($sp)
	SW $t5, 44($sp)
	SW $t6, 48($sp)
	SW $t7, 52($sp)
	SW $s0, 56($sp)
	SW $s1, 60($sp)
	SW $s2, 64($sp)
	SW $s3, 68($sp)
	SW $s4, 72($sp)
	SW $s5, 76($sp)
	SW $s6, 80($sp)
	SW $s7, 84($sp)
	SW $t8, 88($sp)
	SW $t9, 92($sp)
	SW $ra, 96($sp)

	# Clear interrupt flag
	# IFS0<20> = 0, Cleared interrupt flag
	LI $t0, 1 << 20
	SW $t0, IFS0CLR

	# Set duty cycle to zero 
	LI $t0, 0
	SW $t0, OC2RS
	SW $t0, OC3RS
	
	LI $t1, 0
	
	LW $v0, 0($sp)
	LW $v1, 4($sp)
	LW $a0, 8($sp)
	LW $a1, 12($sp)
	LW $a2, 16($sp)
	LW $a3, 20($sp)
	LW $t0, 24($sp)
	# LW $t1, 28($sp)
	LW $t2, 32($sp)
	LW $t3, 36($sp)
	LW $t4, 40($sp)
	LW $t5, 44($sp)
	LW $t6, 48($sp)
	LW $t7, 52($sp)
	LW $s0, 56($sp)
	LW $s1, 60($sp)
	LW $s2, 64($sp)
	LW $s3, 68($sp)
	LW $s4, 72($sp)
	LW $s5, 76($sp)
	LW $s6, 80($sp)
	LW $s7, 84($sp)
	LW $t8, 88($sp)
	LW $t9, 92($sp)
	LW $ra, 96($sp)
	ADDI $sp, $sp, 100

	EI
	ERET  
    .end timer_4_5_handler
.endif 
