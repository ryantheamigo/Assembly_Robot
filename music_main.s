.global main 
    
.data
notes:                   # Memory position in notes array
No:	.word	0	 # 0
C4:     .word   2386     # 4
C4S:    .word   2256     # 8
D4:     .word   2126     # 12
D4S:    .word   2010     # 16
E4:     .word   1894     # 20
F4:     .word   1790     # 24
F4S:    .word   1690     # 28
G4:     .word   1594     # 32
G4S:    .word   1506     # 36
A4:     .word   1419     # 40
A4S:    .word   1342     # 44
B4:     .word   1266     # 48
# octave
C5:     .word   1195     # 52
C5S:    .word   1127     # 56
D5:     .word   1064     # 60
D5S:    .word   1004     # 64
E5:     .word   948      # 68
F5:     .word   895      # 72
F5S:    .word   845      # 76
G5:     .word   798      # 80
G5S:    .word   753      # 84
A5:     .word   710      # 88
A5S:    .word   670      # 92
B5:     .word   633      # 96
# octave
C6:     .word   597      # 100
C6S:    .word   564      # 104
D6:     .word   532      # 108
D6S:    .word   502      # 112
E6:     .word   474      # 116
F6:     .word   447      # 120
F6S:    .word   422      # 124
G6:     .word   398      # 128
G6S:    .word   376      # 132
A6:     .word   355      # 136
A6S:    .word   335      # 140
B6:     .word   316      # 144

    
timer3_flag: .word 0
							                  # riff
# song_freqs: .byte 28, 0, 28, 0, 56, 0, 28, 0, 60, 0, 28, 0, 56, 0, 48, 0, 28, 0, 48, 0, 40, 0, 36, 0, 40, 0, 48, 0, 36, 0, 28, 0, 20, 0
  song_freqs: .byte 20, 0, 20, 0, 20, 0, 4, 0, 32, 0, 20, 0, 4, 0, 32, 0, 20, 0    
    
song_times: .byte 20, 2, 20, 2, 20, 2, 10, 1, 10, 1, 24, 2, 10, 1, 10, 1, 24, 2 

    
.text

.ent main
main:
    di
    # setup pin directions
    jal setup_pins
    # setups initial amp signals
    jal init_amp2
    # setups timer 3 for 1 ms
    # and timer 2 for OC1 base
    jal setup_timers
    # setup output compare 1 for timer 2 base
    jal setup_output_compare1
    
    ei
    
    # top of the song
    begin_song:
	la $s0, song_freqs # load first note
	la $s1, song_times # load first note duration
	la $s3, notes          # load table of notes
	li $s2, 0              # count to know when we have hit the end of our song

	loop:
        # Get the first note location in the note table
        lb $t7, 0($s0)
        add $t7, $t7, $s3

        # Get the actual note (PR value) from the note table
        lw $a0, 0($t7)

        # Get the note duration in 100ms
        lb $a1, 0($s1)

        # Play the note
        jal play_note

        # Wait for 100ms
        li $a0, 1
        jal delay

        # Increment all of our addresses to point to next note
        addi $s0, $s0, 1
        addi $s1, $s1, 1

        # Increment note counter
        addi $s2, $s2, 1

        # Set the amount of notes in the second arguement
        beq $s2, 26, begin_song

        # Play the next note
        j loop
   
.end main
    
# a0 = note to play
# a1 = note duration
.ent play_note
play_note:
    # push to stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # Set the period of our note
    sw $a0, PR2
    # Set the duty cycle of our note to 50%
    srl $a0, $a0, 1
    sw $a0, OC1RS

    # Wait for the note duration in 100ms increments
    move $a0, $a1
    jal delay

    # pop off stack
    lw $ra, 0 ($sp)
    addi $sp, $sp, 4

    jr $ra
.end play_note
    
# counts for a certain number of ms
# a0 = number of ms to loop
.ent delay
delay:
    
    # input number of ms to count
    move $t0, $a0
    
    # reset timer values
    sw $zero, TMR2
    sw $zero, TMR3
    
    li $t1, 1 << 12
    sw $t1, IEC0SET
    
    wait_100ms:
	lw $t1, timer3_flag # waits for 100ms timer 
	beqz $t1, wait_100ms
	
	# subtracts from number of loops
	addi $t0, $t0, -1
	
	# resets flag for next loop
	sw $zero, timer3_flag
	
	# if more ms, restart loop
	bgtz $t0, wait_100ms
    
    # disable timer 3 interrupt
    li $t0, 1 << 12
    sw $t0, IEC0CLR
    jr $ra
    
.end delay

# setup timer 2 as output compare base /64
# setup timer 3 as a 100ms timer
.ent setup_timers
setup_timers:
    
    # disables and resets timers 2 & 3 
    sw $zero, T2CON
    sw $zero, T3CON
    
    # enables timer 2
    # sets timer 2 prescale /64
    li $t0, 0x8060
    sw $t0, T2CON
    
    # enables timer 3
    # sets timer 3 prescale /256
    li $t0, 0x8060
    sw $t0, T3CON
    
    # clears PR2, initial note freq = 0
    sw $zero, PR2
    
    # 100 ms 
    li $t0, 15625
    sw $t0, PR3
    
    # sets priority of timer 3 to 4
    li $t0, 4 << 2
    sw $t0, IPC3
    
    # enable timer 3 interrupt
    lw $t0, IEC0
    ori $t0, $t0, 1 << 12
    sw $t0, IEC0
    
    # setup multi-vector mode
    li $t0, 1 << 12
    sw $t0, INTCONSET
    
    jr $ra
.end setup_timers
    
# OC1 generates the PWM signals to make the notes
.ent setup_output_compare1
setup_output_compare1:
    
    # clear OC1CON and set intital freq = 0
    sw $zero, OC1CON
    sw $zero, OC1R
    sw $zero, OC1RS
    
    li $t0, 6	# sets to PWM mode
    ori $t0, $t0, 1 << 15   # enables OC1
    sw $t0, OC1CONSET
    
    # timer 2 is base by default
    
    jr $ra
.end setup_output_compare1
    
# place timer3_ISR in vector table
.section .vector_12, code
j timer3_ISR
    
.text

# timer 3 interrupt handler
.ent timer3_ISR
timer3_ISR:
    di
    # push to stack
    addi $sp, $sp, -4
    sw $t0, 0($sp)
    
    # clear timer 3 interrupt flag
    li $t0, 1 << 12
    sw $t0, IFS0CLR
    
    # set timer3_flag 
    li $t0, 1
    sw $t0, timer3_flag
    
    # pop off stack
    lw $t0, 0($sp)
    addi $sp, $sp, 4
    
    ei
    eret
.end timer3_ISR
    
.ent init_amp2
init_amp2:
    # Drive the initial amplifier signals
    # PORTD<8> = high for active state
    # PORTE<8> = high for 6 dB
    li $t0, 1 << 8
    sw $t0, LATDSET
    sw $t0, LATESET
    
    # PORTD<0> = clear analog out
    li $t0, 1
    sw $t0, LATDCLR
   
    jr $ra
.end init_amp2
    
.ent setup_pins
setup_pins:
    
    # setup PMW as out
    li $t0, 1
    sw $t0, TRISDCLR
    
    # setup gain and shutdown as output
    li $t0, 1 << 8
    sw $t0, TRISDCLR
    sw $t0, TRISECLR
    
    jr $ra
.end setup_pins
    
    
    
 



