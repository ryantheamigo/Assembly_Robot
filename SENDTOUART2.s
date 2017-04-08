.ifndef SENDTOUART2
    SENDTOUART2:
    .ent send
	send:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	MOVE $t0, $a0
	
	startsend:
	LB $t1, 0($t0)
	ADDI $t0, $t0, 1
	BEQZ $t1, endsend
	
	waittosend:
	LW $t2, U2STA
	ANDI $t2, $t2, 1 << 9
	SRL $t2, $t2, 9
	BEQZ $t2, endwaittosend
	J waittosend
	
	endwaittosend:
	SB $t1, U2TXREG
	J startsend
	
	endsend:
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end send
    
    .ent send_byte
	send_byte:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	MOVE $t0, $a0
	
	waittosendbyte:
	LW $t2, U2STA
	ANDI $t2, $t2, 1 << 9
	SRL $t2, $t2, 9
	BEQZ $t2, endwaittosendbyte
	J waittosendbyte
	
	endwaittosendbyte:
	SB $t0, U2TXREG
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end send_byte
.endif


