.ifndef RECIEVEUART1
    RECIEVEUART1:
    .ent recieve_byte
	recieve_byte:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)

	waittorecieve:
	LW $t2, U1STA
	ANDI $t2, $t2, 1
	BEQZ $t2, waittorecieve
	J endrecieve
	
	endrecieve:
	LB $v0, U1RXREG
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end recieve_byte
.endif


