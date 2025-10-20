
##@@##
# copy_name(a0: ptr_name to copy, a1: place to copy name) -> nothing
## copies name in a0 to the place shown by a1 char by char
copy_name:
	mv t1, a0
	mv t2, a1
    li t3, 8 # copy 8 chars
copy_loop:
    beqz t3, done_copy
    lb t4, 0(t1)
    sb t4, 0(t2)
    addi t1, t1, 1
    addi t2, t2, 1
    addi t3, t3, -1
    j copy_loop
done_copy:
	sw zero, 0(t2)
    jr ra

##@@##
# add_name(a0: ptr_to_name) -> a0 = index
## stores new name in names and table(?: no, because table doesn't need indexing, it has indices!!)
add_name:
	# mv t1, a0
	la t2, names
	# index 
	la t3, num_people
	lw t0, 0(t3)
	li t4, 12
	mul t5, t0, t4
	add t6, t5, t2 # t6 = num_people * 12 + ptr(names) = free index for next name

	# save t3 and t0 on stack for later use:
	addi sp, sp, -20
	sw t3, 0(sp)
	sw t0, 8(sp)
	sw ra, 16(sp)

	mv a1, t6
	# a0 is still ptr to new name
	jal ra, copy_name

	# restore from stack
	lw ra, 16(sp)
	lw t3, 0(sp)
	lw t0, 8(sp)
	addi sp, sp, 20
	# t3 is num_people, the index of new name in names array
	mv a0, t0
	addi t0, t0, 1
	sw t0, 0(t3)

	jr ra


.global handle_type_1
handle_type_1:
	la t1, temp_tokens
	mv a0, t1 # a0 is pointer

	addi sp, sp, -4
	sw t1, 0(sp)
	jal ra, is_name_registered
	lw t1, 0(sp)
	addi sp, sp, 4

    li t2, -1
    bne a0, t2, next1
	mv a0, t1 # a0 is pointer
	jal ra, add_name
next1:
	mv s1, a0 # index of name 1
	
	la t1, temp_tokens
	addi a0, t1, 8  # a0 is pointer

	addi sp, sp, -4
	sw t1, 0(sp)
	jal ra, is_name_registered
	lw t1, 0(sp)
	addi sp, sp, 4

    li t2, -1
    bne a0, t2, next2
	addi a0, t1, 8  # a0 is pointer
	jal ra, add_name
next2:
	mv s2, a0 # index of name 2

# changes in table
	jal ra, extract_money
	la t1, table

	# index [s1, s2] = (s1 * 100 + s2) * 4 bytes
	li t2, 100
	mul t3, t2, s1
	add t3, t3, s2
	slli t3, t3, 2 # mul by 4
	add t3, t3, t1
	# t3 is the address where i should add that money value! (finally =))
	lw t4, 0(t3)
	add t5, a0, t4
	sw t5, 0(t3)
# changes in net_worth
	la t1, net_worth
	slli s1, s1, 2
	add t2, t1, s1
	lw t3, 0(t2)
	sub t3, t3, a0 # his/her net_worth - lost money
	sw t3, 0(t2)

	slli s2, s2, 2
	add t2, t1, s2
	lw t3, 0(t2)
	add t3, t3, a0 # his/her net_worth + given money
	sw t3, 0(t2)

	j exit_handlers