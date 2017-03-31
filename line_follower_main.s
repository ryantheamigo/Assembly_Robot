.global main
    
.include "motor_lib.s"
.include "timer_and_interrupt_lib.s"
    
.data
    drive_case:	.word default, right, default, left, default, slant_right
		.word default, default, rotate_left, default, slant_left
		.word slant_left, rotate_Right, slant_right, default, default
    
.text
    
    
.ent main
main:
    jal setup_sensor
    
    while:
    jal read_sensor
    move $a0, $v0
    jal movement
   
    j while
    
.end main
    
.ent movement
movement:
    move $t0, $a0
    
    # stops motor movement in case direction change
    move $a0, $zero
    move $a1, $zero
    jal write_to_motors
    
    # loads drive_case address
    la $t1, drive_case
    sll $t0, $t0, 2	# multiplies index by 4
    add $t1, $t0, $t1	# offsets index
    lw $t0, $t1		# loads jump value
    jr $t1
    
    # goes forward as a default
    default:
    # sets wheels to forward
    li $t0, 0b10000000
    sw $t0, LATDSET
    li $t0, 0b1000000
    sw $t0, LATDCLR

    # sets to 80% duty cycle
    lw $a0, 80
    lw $a1, 80
    jal write_to_motors
    
    j endMovement
    
    slant_right:
    # sets wheels to forward
    li $t0, 0b10000000
    sw $t0, LATDSET
    li $t0, 0b1000000
    sw $t0, LATDCLR

    # sets to left wheel to slower duty cycle
    lw $a0, 90
    lw $a1, 70
    jal write_to_motors
    j end_movement
    
    rotate_right:
    # sets left wheel to forward and right to back
    li $t0, 0b11000000
    sw $t0, LATDSET

    # sets to 80% duty cycle
    lw $a0, 80
    lw $a1, 80
    jal write_to_motors
    j end_movement
    
    slant_left:
    # sets wheels to forward
    li $t0, 0b10000000
    sw $t0, LATDSET
    li $t0, 0b1000000
    sw $t0, LATDCLR

    # sets left wheel to slower duty cycle
    lw $a0, 70
    lw $a1, 90
    jal write_to_motors
    j end_movement
    
    rotate_left:
    # sets right motor to forward and left to back
    li $t0, 0b11000000
    sw $t0, LATDCLR
     
    # sets to 80% duty cycle
    lw $a0, 80
    lw $a1, 80
    jal write_to_motors
    j end_movement
    
    end_movement:
    jr $ra
.end movement


