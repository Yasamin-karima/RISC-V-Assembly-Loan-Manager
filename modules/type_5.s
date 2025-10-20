


.global handle_type_5

handle_type_5:
# we must check the row of person to count The number of people who owe them money
	la a0, temp_tokens # the only name in this task
    jal ra, is_name_registered
    # a0 is the index of name

    la t1, table
    li t3, 0 # counter

    la t4, num_people
    lw t5, 0(t4)
    li t4, 0 # index counter, to check reaching to num_people

    li t2, 400
    mul t6, t2, a0
    add t1, t1, t6

    mv t6, a0
people_loop1:
    beq t5, t4, end_people1
    lw t2, 0(t1)
    beqz t2, next_person1

    addi sp, sp, -16
    sw t1, 0(sp)
    sw t3, 4(sp)
    sw t4, 8(sp)
    sw t5, 12(sp)
    
    #we have [a0, a1] must find [a1, a0]
    mv a1, t6
    mv a0, t4
    mv a2, t2
    jal ra, debt_value 
    # a0 is debt value
    lw t1, 0(sp)
    lw t3, 4(sp)
    lw t4, 8(sp)
    lw t5, 12(sp)
    addi sp, sp, 16
    
    ble a0, zero, next_person1 # not creditor
    addi t3, t3, 1
next_person1:
    addi t1, t1, 4
    addi t4, t4, 1
    j people_loop1
end_people1:
    mv a0, t3
    li a7, 1 # print integer
    ecall

    la a0, new_line
    li a7, 4 # print string
    ecall
    
    j exit_handlers



