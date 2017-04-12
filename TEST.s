.Global main

.data
num: .word 10

.text
.ent main
    main:
    LA $a0, num
    JAL read
    NOP
.end main

.ent read
    read:
    LW $t0, PORTE
    ANDI $t0, $t0, 0xFF
    SW $t0, 0($a0)
    JR $ra
.end read

.ent write
    write:
    LW $t0, 0($a0)
    ANDI $t0, $t0, 0xFF
    SW $t0, LATESET
    JR $ra
.end write
 
.ent load
    load: 
    LW $s0, 0($a0)
    JR $ra
.end load

.ent store
    store:
    SW $s0, 0($a0)
    JR $ra
.end store

.ent ADD_
    ADD_:
    LW $t0, 0($a0)
    ADD $s0, $s0, $t0
    JR $ra
.end ADD_

.ent SUB_
    SUB_:
    LW $t0, 0($a0)
    SUB $s0, $s0, $t0
    JR $ra
.end SUB_

# .ent MUL_
#     MUL_:
#     LW $t0, 0($a0)
#     MUL 
# .end MUL_
