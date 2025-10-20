
.global handle_type_2
handle_type_2:
    la t1, net_worth
    li t2, 0 # base to compare with
    li t0, -1 # result index
    li t4, 0 # index counter

loop_through_net_worth:
    lw t3, num_people
    beq t3, t4, end_loop # end of net_worth array

    lw t3, 0(t1)
    ble t3, t2, mid_continue # if t3 <= t2 then mid_continue
    addi t2, t3, 0 
    mv  t0, t4 # save index in t0
    addi t4, t4, 1
    addi t1, t1, 4
    j loop_through_net_worth


mid_continue: 
    beq t2, zero, continue1
	bne t2, t3, continue1
    addi sp, sp, -12
    sw t1, 0(sp)
    sw t2, 4(sp)
    sw t4, 8(sp)
	mv a0, t4
    mv a1, t0
    jal ra, compare_Lexicographically
    mv t0, a0 # index of Lexicographically smaller name
    lw t1, 0(sp)
    lw t2, 4(sp)
    lw t4, 8(sp)
    addi sp, sp, 12
continue1:
    addi t4, t4, 1
    addi t1, t1, 4
    j loop_through_net_worth

end_loop:
    li t1, -1
    beq t0, t1, no_worthy_person

    la t1, names
    # find name for that index
	li t5, 12
    mul t2, t0, t5 # multiply by 12 bytes
    add t0, t2, t1

    mv a0, t0
	li a7, 4 # print string
    ecall

    la a0, new_line
    li a7, 4 # print string
    ecall
## should not continue to no_wrthy_person!!
    j exit_handlers


no_worthy_person:
    mv a0, t0 # t4=-1
    li a7, 1 # print integer
    ecall

    la a0, new_line
    li a7, 4 # print string
    ecall

	j exit_handlers

