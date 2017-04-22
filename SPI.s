.ifndef SPI
    SPI:
    .data
    counter: .word 0
    joystick: .space 5
    y_data: .word 0
    x_data: .word 0
    .text
    .include "SENDTOUART2.s"
    # SPI2CON
    # SPI2CON2
    # SPI2STAT
    # SPI2BUF
    # SPI2BRG
    # 1)For slave select is disabled SPI2CON<28> = 0
    # 2)Generate a frame sync pulse on every data character SPI2CON<26:24?> = 00
    # 3)Master clock select use the baud rate generator SPI2CON<23> = 0 
    # 4)Set the baud rate generator to 1MHz 
    # 5)Enhanced Buffer mode is disabled SPI2CON<17> = 0
    # 6)Enable SPI peripheral SPI2CON<15> = 1
    # 7)Continue Operation in Idle mode SPI2CON<13> = 0
    # 8)The SOD is controlled by the peripheral SPI2CON<12> = 0
    # 9)Operation Mode 0, 8-bit SPI2CON<11:10> = 0, AUDEN = 0
    # 10)Input data sampled at the middle of data output time SPI2CON<9> = 0
    # 11)Slave select enabled, pin controlled by port function, SPI2CON<7> = 0
    # 12)Enabled master mode, SPI2CON<5> = 1
    # 13)The SDI is controlled by the peripheral SPI2CON<4> = 0
    # 14) Date from read data is not signed, SPI2CON2<15> = 0
  
    .ent setup_SPI
	setup_SPI:
	DI
	
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	# Set the clock as output
	LI $t0, 1 << 6
	SW $t0, TRISGCLR
	
	# Set SDI as input
	LI $t0, 1 << 7
	SW $t0, TRISGSET
	
	# Set SDO as output
	LI $t0, 1 << 8
	SW $t0, TRISGCLR
	
	# Set slave select line as output
	LI $t0, 1 << 9
	SW $t0, TRISGCLR
	
	LI $t0, 1 << 9
	SW $t0, LATGSET
	
	SW $zero, SPI2CON
	
	# Disable SPI peripheral 
	LI $t0, 1 << 15
	SW $t0, SPI2CONCLR
	
	SW $zero, SPI2BUF
	
	# Set the PIC32 as master mode
	# SPI2CON<5> = 1
	LI $t0, 1 << 5
	SW $t0, SPI2CONSET
	
	# Test 
	LI $t0, 1 << 6
	SW $t0, SPI2CONCLR
	
	LI $t0, 1 << 8
	SW $t0, SPI2CONSET
	
	# Set the baud rate generator to 1MHz 
	# Load 19 into baud rate register to get 1Mhz at a 40Mhz PBCLK
	LI $t0, 19
	SW $t0, SPI2BRG
	
	# Enable SPI peripheral
	LI $t0, 1 << 15
	SW $t0, SPI2CONSET
	
	EI
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end setup_SPI
    
    .ent send_spi
	send_spi:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LI $t0, 1 << 9 # Drive the slave select to low
	SW $t0, LATGCLR
	
	LI $s0, 1 << 15
	SW $s0, T1CONSET
	
	LI $s0, 1
	
	# Loop will continue until interrupt sets the $s0 = 0
	# 30 us 
	SW $zero, TMR1
	loop_slave_low:
	BEQZ $s0, startsend_spi
	NOP
	J loop_slave_low
	LI $s0, 1 << 15 # Turn on timer1
	SW $s0, T1CONCLR
	
	startsend_spi:
	LI $t1, 0x00
	SB $t1, SPI2BUF # Store to buffer
	
	waittosend_spi:
# 	LW $t2, SPI2STAT # Check if module is busy
# 	ANDI $t2, $t2, 1 << 11
# 	SRL $t2, $t2, 11
# 	BEQ $t2, 1, waittosend_spi
	
	LB $t1, SPI2BUF  # Load the first byte of the returned data
	
	LW $t0, counter  # Load the value of the joy stick 
	LA $t2, joystick
	ADD $t0, $t2, $t0 # Add the offset to the base address
	SB $t1, 0($t0) # Store the recevied byte into joystick
	
	LW $t0, counter  # Load the value of the joy stic
	ADDI $t0, $t0, 1
	SW $t0, counter
	BEQ $t0, 5, endsend_spi # If counter equals five jump to end 
	
	LI $s0, 1 << 15 # Turn on timer1
	SW $s0, T1CONSET
	
	LI $s0, 1
	
	# Loop will continue until interrupt sets the $s0 = 0
	# 30 us 
	SW $zero, TMR1
	loop_next_byte:
	BEQZ $s0, startsend_spi
	NOP
	J loop_next_byte
	
	endsend_spi:
	LI $t0, 1 << 9 # Drive the slave select to low
	SW $t0, LATGSET

	# Store number Y
	LA $t1, joystick
	ADDI $t0, $t1, 1 # Get the second byte
	LB $s0, 0($t0)
	
	
	ADDI $t0, $t1, 2
	LB $s1, 0($t0) # Load the third byte
	
	ANDI $s1, $s1, 0x3
	SLL $s1, $s1, 8
	
	ADD $s2, $s1, $s0
	SW $s2, y_data
	
	# Store number X
	ADDI $t0, $t1, 3 # Get the fourth byte
	LB $s0, 0($t0)
	ANDI $s0, $s0, 0xFF
	
	ADDI $t0, $t1, 4
	LB $s1, 0($t0) # Load the fifth byte
	

	ANDI $s1, $s1, 0x3
	SLL $s1, $s1, 8
	
	ADD $s2, $s1, $s0
	SW $s2, x_data
	
	LW $v0, y_data
	LW $v1, x_data
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end send_spi
    
    .ent setup_timer_1
	setup_timer_1:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	DI
	LI $t0, 1 << 12
	SW $t0, INTCONSET
	
	# Turn off timer 1
	# TICON<15> = 0
	LI $t0, 1 << 15
	SW $t0, T1CONCLR

	# Select parent clock
	# T1CON<1> = 0, internal peripheral clock
	LI $t0, 1 << 1
	SW $t0, T1CONCLR

	# Set prescalar value 
	# T1CON<5:4> = 0b01 1:8
	LI $t0, 3 << 4
	SW $t0, T1CONCLR

	LI $t0, 1 << 4
	SW $t0, T1CONSET

	# Set the TMR1 to zero
	SW $zero, TMR1

	# Set the period register 
	# Peripheral Clock is running at 40MHz, Prescalar 8, Timer Running at 5000000
	LI $t0, 150 # Gives 30 us
	SW $t0, PR1

	# Setup Timer 1 interrupt
	# Disable timer 1 interrupt
	# IEC0<4> = 0
	LI $t0, 1 << 4
	SW $t0, IEC0CLR

	# Set interrupt priority
	# IPC1<4:2> = 0b110
	LI $t0, 7 << 2
	SW $t0, IPC1CLR

	LI $t0, 6 << 2
	SW $t0, IPC1SET

	# Enable timer 1 interrupt
	# IEC0<4> = 0
	LI $t0, 1 << 4
	SW $t0, IEC0SET

	EI
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end setup_timer_1

    .section .vector_4, code
    J timer_1_handler 

    .Text
     .ent timer_1_handler 
 	timer_1_handler:
 	DI
 
 	ADDI $sp, $sp, -12
 	SW $ra, 0($sp)
 	SW $t0, 4($sp)
 	SW $t1, 8($sp)
 
 	# Clear interrupt flag
 	# IFS0<4> = 0, Cleared interrupt flag
 	LI $t0, 1 << 4
 	SW $t0, IFS0CLR
	
	# Flag to exit loop
	LI $s0, 0

 	LW $ra, 0($sp)
 	LW $t0, 4($sp)
 	LW $t1, 8($sp)
	ADDI $sp, $sp, 12
 	EI
 	ERET
     .end timer_1_handler 
    
.endif 


