


.global handle_type_4
handle_type_4:
# we must check the column of person to count how many people he owes to
	la a0, temp_tokens # the only name in this task
    jal ra, is_name_registered
    # a0 is the index of name

    la t1, table
    li t3, 0 # counter

    la t4, num_people
    lw t5, 0(t4)
    li t4, 0 # index counter, to check reaching to num_people

    slli t6, a0, 2 # mul by 4 bytes
    add t1, t1, t6

    mv t6, a0 
    # t6 is the index of name
people_loop:
    beq t5, t4, end_people
    lw t2, 0(t1)
    beqz t2, next_person

    addi sp, sp, -16
    sw t1, 0(sp)
    sw t3, 4(sp)
    sw t4, 8(sp)
    sw t5, 12(sp)
    # a0 is not the index(=()
    mv a0, t6
    mv a1, t4
    mv a2, t2
    jal ra, debt_value 
    # a0 is debt value
    lw t1, 0(sp)
    lw t3, 4(sp)
    lw t4, 8(sp)
    lw t5, 12(sp)
    addi sp, sp, 16
    
    ble a0, zero, next_person # not debtor
    addi t3, t3, 1
next_person:
    addi t1, t1, 400
    addi t4, t4, 1
    j people_loop
end_people:
    mv a0, t3
    li a7, 1 # print integer
    ecall

    la a0, new_line
    li a7, 4 # print string
    ecall

    j exit_handlers

