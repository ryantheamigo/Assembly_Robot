.ifndef ASCIINUMBERCON
    ASCIINUMBERCON:
    .Data 
	ASCIITABLE: .word zero, one, two, three, four, five, six, seven, eight, nine
    .Text
    .ent assign_ascii
	assign_ascii:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	MOVE $t0, $a0

	# Find the ascii for the number
	LA $t2, ASCIITABLE
	SLL $t0, $t0, 2
	ADD $t2, $t0, $t2
	LW $t0, 0($t2)
	J $t0
	zero:
	LI $v0, 48
	J end_assign
	one:
	LI $v0, 49
	J end_assign
	two:
	LI $v0, 50
	J end_assign
	three:
	LI $v0, 51
	J end_assign
	four:
	LI $v0, 52
	J end_assign
	five:
	LI $v0, 53
	J end_assign
	six:
	LI $v0, 54
	J end_assign
	seven:
	LI $v0, 55
	J end_assign
	eight:
	LI $v0,56
	J end_assign
	nine:
	LI $v0, 57
	
	end_assign:
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end assign_ascii
.endif


