.global make_zero
##@@##
# make_zero(a0: ptr, a1: max bytes)
# to make zero some temp memories
make_zero:
	li t2, 4
	div t1, a1, t2
zero_loop:
    beqz t1, done_zero
    sw zero, 0(a0)        # store zero byte
    addi t1, t1, -1
    addi a0, a0, 4
    j zero_loop
done_zero:
    jr ra


.global tokenize_input
##@@##
# tokenize_input(a0: input line) -> nothing 
## stores tokens in temp_tokens, 
## first name in temp_tokens[0], second name in temp_tokens[8], money value after index 16
tokenize_input:
	la t1, temp_tokens
	addi t5, t1, 8 # address of second name 	
	addi t2, t1, 16 # address of third token(money amount) 	
	addi a0, a0, 1 # skip number at the beginning
	li t0, 0 # numbe of spaces
loop_through_input:
	lb t3, 0(a0)
	beqz t3, done

	li t4, 32 # ascii ' '
	beq t3, t4, next_space

    li t3, 1
	beq t0, t3, store_first
    li t3, 2
	beq t0, t3, store_second
    li t3, 3
	beq t0, t3, store_third
	j done
store_first:
	lb t6, 0(a0)
	sb t6, 0(t1) # store name1 in temp_tokens 
	addi a0, a0, 1 
	addi t1, t1, 1 
	j loop_through_input
store_second: 
	lb t6, 0(a0)
	sb t6, 0(t5)
	addi a0, a0, 1 
	addi t5, t5, 1 
	j loop_through_input
store_third: 
	lb t6, 0(a0)
	sb t6, 0(t2)
	addi a0, a0, 1 
	addi t2, t2, 1 
	j loop_through_input
next_space: 
	addi a0, a0, 1 	
	addi t0, t0, 1 
	j loop_through_input
done:
	jr ra


##@@##
# name_equal(a0: ptr1, a1: ptr2) -> a0 = 1 if equal, else a0 = 0
name_equal:
	li t4, 8 # compare 8 bytes
comp_loop:
	beqz t4, are_equal
	lb t5, 0(a0)
	lb t6, 0(a1)
	li t3, 10 # ascii of \n
	bne t5, t3, and_t6
	li t5, 0
and_t6:
	bne t6, t3, go_ahead
	li t6, 0
go_ahead:
	bne t5, t6, not_equal
	addi a0, a0, 1
	addi a1, a1, 1
	addi t4, t4, -1
	j comp_loop
are_equal:
	li a0, 1
	jr ra
not_equal:
	li a0, 0
	jr ra


.global is_name_registered
##@@## 
# is_name_registered(a0: ptr_to_name) -> a0 = -1 if no, else a0 = index 
is_name_registered:
	la t1, num_people
	lw t2, 0(t1)
	li t1, 0
	mv t3, a0
find_loop:
	beq t1, t2, not_found
	
    # load address of people_names[i]
    li t4, 12
    mul t5, t1, t4 # t5 = index * 12
    la t6, names
    add t0, t6, t5 # t0 = people_names[i]
	
	addi sp, sp, -12
	sw t1, 0(sp)
	sw ra, 4(sp)
	sw t3, 8(sp)

	# compare names
	mv a1, t0 # ptr
	mv a0, t3 # ptr
	jal ra, name_equal

	lw t1, 0(sp)
	lw ra, 4(sp)
	lw t3, 8(sp)
	addi sp, sp, 12

	beqz a0, continue
    mv a0, t1 # return index
    jr ra
continue:
    addi t1, t1, 1
    j find_loop
not_found:
    li a0, -1
    jr ra


.global extract_money
##@@##
# extract_money() -> the value of money in integer
extract_money:
	la t1, temp_tokens
	addi t1, t1, 16
	li t2, 0 # base
# logic: have a base = 0, for current char(digit):
# base = base * 10 + current
# ignore '.', to save value as integer
money_int_part:	
	lb t3, 0(t1)
	li t4, 46 # ascii code of '.'
	beq t3, t4, money_fraction_part

	li t4, 48 # ascii code for '0'
	sub t3, t3, t4 # t3 = current
	li t4, 10
	mul t5, t4, t2 # base * 10
	add t2, t3, t5

	addi t1, t1, 1
	j money_int_part
money_fraction_part:
	addi t1, t1, 1 # skip '.'

# first fraction digit
	lb t3, 0(t1)
	li t4, 48 # ascii code for '0'
	sub t3, t3, t4 # t3 = current
	li t4, 10
	mul t5, t4, t2 # base * 10
	add t2, t3, t5
	addi t1, t1, 1

# second fraction digit
	lb t3, 0(t1)
	li t4, 48 # ascii code for '0'
	sub t3, t3, t4 # t3 = current
	li t4, 10
	mul t5, t4, t2 # base * 10
	add t2, t3, t5

	addi a0, t2, 0
	jr ra


.global compare_Lexicographically
##@@##
# compare_Lexicographically(a0: index of name1, a1: index of name2) 
# returns -> a0: index of Lexicographically smaller name
compare_Lexicographically:
    la t1, names
	li t4, 12
    mul t2, a0, t4 # mul by 12
    add t2, t2, t1 #address of name1
    mul t3, a1, t4
    add t3, t3, t1 #address of name2

compare_loop:
    # stop end of names! no need!
    ## ali - alireza -> ali00000 - alireza0 -> 4th char : '0' and 'r' -> ali is smaller (OK)
    lb t4, 0(t2)
    lb t5, 0(t3)
    beq t4, t5, next_char
    bgt t4, t5, name2_answer # if t4 > t5 then name2_answer
    j name1_answer

next_char:
    addi t2, t2, 1
    addi t3, t3, 1
    j compare_loop

name1_answer:
    # a0 contains indexof name 1
    jr ra

name2_answer:
    mv a0, a1
    jr ra


.global debt_value
##@@##
# debt_value(a0, a1,
#           a2: value of [a1, a0], knew it before(OK) ) 
# returns -> a0 = debt value = [a1, a0] - [a0, a1] 
# In cases, we have [b, a] and we need [a, b] to find [b, a]-[a, b] for our target
# so, need to find [a0, a1]
debt_value:
    la t1, table 
    # a2 is value of [a1, a0]

    # value of [a0, a1]:
        # compute address of [a0, a1]
        li t2, 100
        mul t3, a0, t2
        add t3, t3, a1
        slli t3, t3, 2 # mul by 4 bytes
        add t4, t3, t1
        # t4 is address of [a0, a1]
        lw t2, 0(t4)
    sub t3, a2, t2
    mv a0, t3
    jr ra
    
    