.ifndef SENSORS
    SENSORS:
    .ent setup_sensor
	setup_sensor:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LI $t0, 15 << 12 # Set pins RG12, RG13, RG14, RG15 as input
	SW $t0, TRISGCLR
	SW $t0, TRISGSET
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end setup_sensor
    
    .ent READ_SENSOR
	READ_SENSOR:
	ADDI $sp, $sp, -4
	SW $ra, 0($sp)
	
	LW $t0, PORTG # Read PORTE
	LI $t1, 15 << 12 # Load and value
	AND $t0, $t0, $t1 # Mask of the bits 12,13,14,15
	SRL $t0, $t0, 12 # Shift to first four bits
	MOVE $s0, $t0 # Move to $v0
	
	LW $ra, 0($sp)
	ADDI $sp, $sp, 4
	JR $ra
    .end READ_SENSOR	
 .endif 


