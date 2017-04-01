.global main
    
.include "MOTORS.s"
.include "SENSORS.s"
.include "BUTTON.s"
.data
   # drive_case: .word default, rotate_left, default, slant_left, default, slant_right, default, rotate_left, rotate_right, default, slant_left, default, slant_right, slant_right, rotate_right, default
   # drive_case: .word default, rotate_left, default, rotate_left, default, rotate_right, default, rotate_left, rotate_right, default, rotate_left, default, rotate_right, rotate_right, rotate_right, default
   drive_case: .word forward, forward, forward, forward, forward, forward, forward, pivot_right, forward, forward, forward, pivot_right, forward, pivot_left, pivot_left, forward
.text
    
    
.ent main
main:
    jal setup_sensor
    jal left_motor
    jal right_motor
    jal motor_timer
    jal setup_button
    while:
    JAL get_button
    LI $t0, 1
    BEQ $t0, $v1, TURNON
    J while
    
    TURNON:
    jal read_sensor
    move $a0, $v0
    jal movement
    j TURNON
.end main
    
# .ent movement
# movement:
#     ADDI $sp, $sp, -4
#     SW $ra, 0($sp)
#     
#     move $t0, $a0
#     # stops motor movement in case direction change
#     move $a0, $zero
#     move $a1, $zero
#     jal write_to_motors
#     
#     # loads drive_case address
#     la $t1, drive_case
#     sll $t0, $t0, 2	# multiplies index by 4
#     add $t1, $t0, $t1	# offsets index
#     lw $t0, 0($t1)		# loads jump value
#     jr $t0
#     
#     # goes forward as a default
#     default:
#     # sets wheels to forward
#     li $t0, 0b10000000
#     sw $t0, LATDSET
#     li $t0, 0b1000000
#     sw $t0, LATDCLR
# 
#     # sets to 80% duty cycle
#     li $a0, 25
#     li $a1, 25
#     jal write_to_motors
#     j end_movement
#     
#     slant_right:
#     # sets wheels to forward
#     li $t0, 0b10000000
#     sw $t0, LATDSET
#     li $t0, 0b1000000
#     sw $t0, LATDCLR
# 
#     # sets to left wheel to slower duty cycle
#     li $a0, 30 # left
#     li $a1, 25 # right
#     jal write_to_motors
#     j end_movement
#     
#     rotate_right:
#     # sets left wheel to forward and right to back
#     li $t0, 0b10000000
#     sw $t0, LATDSET
#     li $t0, 0b1000000
#     sw $t0, LATDCLR
# 
#     # sets to 80% duty cycle
#     li $a0, 35 # left
#     li $a1, 20 # right
#     jal write_to_motors
#     j end_movement
#     
#     slant_left:
#     # sets wheels to forward
#     li $t0, 0b10000000
#     sw $t0, LATDSET
#     li $t0, 0b1000000
#     sw $t0, LATDCLR
# 
#     # sets left wheel to slower duty cycle
#     li $a0, 25 # left
#     li $a1, 30 # right
#     jal write_to_motors
#     j end_movement
#     
#     rotate_left:
#     # sets wheels to forward
#     li $t0, 0b10000000
#     sw $t0, LATDSET
#     li $t0, 0b1000000
#     sw $t0, LATDCLR
# 
#     # sets left wheel to slower duty cycle
#     li $a0, 20 # left
#     li $a1, 35 # right
#     jal write_to_motors
#     j end_movement
#     
#     end_movement:
#     
#     LW $ra, 0($sp)
#     ADDI $sp, $sp, 4
#     jr $ra
# .end movement

.ent movement
movement:
    ADDI $sp, $sp, -4
    SW $ra, 0($sp)
    
    move $t0, $a0
    
    move $a0, $zero
    move $a1, $zero
    jal write_to_motors
    
    # loads drive_case address
    la $t1, drive_case
    sll $t0, $t0, 2	# multiplies index by 4
    add $t1, $t0, $t1	# offsets index
    lw $t0, 0($t1)		# loads jump value
    jr $t0
    
    forward:
    # sets wheels to forward
    li $t0, 0b10000000
    sw $t0, LATDSET
    li $t0, 0b1000000
    sw $t0, LATDCLR

    # sets to 80% duty cycle
    li $a0, 25
    li $a1, 25
    jal write_to_motors
    j end_movement
    
    pivot_left:
    li $t0, 0b10000000
    sw $t0, LATDCLR
    li $t0, 0b1000000
    sw $t0, LATDCLR
    
    li $a0, 25 # left
    li $a1, 25 # right
    jal write_to_motors
    j end_movement
    
    pivot_right:
    li $t0, 0b10000000
    sw $t0, LATDSET
    li $t0, 0b1000000
    sw $t0, LATDSET
    
    li $a0, 25 # left
    li $a1, 25 # right
    jal write_to_motors
    j end_movement
    
    end_movement:
    
    LW $ra, 0($sp)
    ADDI $sp, $sp, 4
    jr $ra
.end movement
    
    
