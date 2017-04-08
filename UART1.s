.ifndef UART1
    UART1:
    .ent setup_UART1
	setup_UART1:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	# UART 1 on PORT JE, RD14, RF8, RF2, RD15, Top
	# Setting the buad rate generator to 9600 baud
	# U1BRG = 259
	LI $t0, 259
	SW $t0, U1BRG
	
	# Setting up the UART frame
	# Frame 8 data bits, 1 stop bit, no parity bit
	
	# Disable URAT1 while configuring
	# U1MODE<15> = 0
	LI $t0, 1 << 15
	SW $t0, U1MODECLR
	
	# Parity and Data Seelection, 8 bits no parity
	# U1MODE<2:1> = 00
	LI $t0, 3 << 1
	SW $t0, U1MODECLR

	# Select number of stop bits, 1 stop bit
	# U1MODE<0> = 0
	LI $t0, 1
	SW $t0, U1MODECLR
	
	# Enable UART Transmission
	LI $t0, 1 << 10
	SW $t0, U1STASET
	
	# Enable UART Recieve
	LI $t0, 1 << 12
	SW $t0, U1STASET
	
 	# Enable URAT1 while configuring
	# U1MODE<15> = 1
	LI $t0, 1 << 15
	SW $t0, U1MODESET
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end setup_UART1
.endif


