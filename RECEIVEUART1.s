.ifndef RECEIVEUART1
    RECEIVEUART1:
    .ent receive_byte
	receive_byte:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)

	waittoreceive:
	LW $t2, U1STA
	ANDI $t2, $t2, 1
	BEQZ $t2, waittoreceive
	J endreceive
	
	endreceive:
	LB $v0, U1RXREG
	LI $t0, 32
	BEQ $v0, $t0, waittoreceive # Ignore character 
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end receive_byte
.endif


