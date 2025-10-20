.section .data
instr: .space 64 # to store instructions

table: .space 40000 # 100 * 100 people * 4 bytes (integer)

names: .space 1200 

net_worth: .space 400 

num_people: .word 0

temp_tokens: .space 32 # for extracted strings from instr

new_line: .asciz "\n"


.section .text
.global _start
_start:
	li sp, 0xbb10
	# read input
	li a7, 5
	ecall
	mv s3, a0

get_instr:
	# s3 caontains q, must not be changed
	beqz s3, done_instr
	
	### -- read instruction -- ###
	# zero out instr
	la a0, instr
	li a1, 64
	jal ra, make_zero

	# read
	la a0, instr
	li a1, 64
	li a7, 8 # sysall=8 : read string
	ecall

	
	### -- tokenize and determine instruction type -- ###
	# zero out temp_tokens
	la a0, temp_tokens
	li a1, 32
	jal ra, make_zero

	la t1, temp_tokens
	sw zero, 0(t1)
	la t1, instr 
	mv a0, t1
	jal ra, tokenize_input
	la t1, instr
	lb t2, 0(t1) # first char of instruction(1, 2, 3, 4, 5, 6)
	
	li t3, '1'
	beq t2, t3, handle_type_1
	li t3, '2'
	beq t2, t3, handle_type_2
	li t3, '3'
	beq t2, t3, handle_type_3
	li t3, '4'
	beq t2, t3, handle_type_4
	li t3, '5'
	beq t2, t3, handle_type_5
	li t3, '6'
	beq t2, t3, handle_type_6
	
exit_handlers:
	### -- decrement s3 -- ###
	addi s3, s3, -1
	j get_instr
	
	
done_instr:
	li a7, 10 # syscall 10: exit
    ecall

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



handle_type_2:
    la t1, net_worth
    li t2, 0
    li t0, -1
    li t4, 0

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



handle_type_3:
    la t1, net_worth
    li t2, 0
    li t0, -1
    li t4, 0

loop_through_net_worth1:
    lw t3, num_people
    beq t3, t4, end_loop1 # end of net_worth array

    lw t3, 0(t1)
    bge t3, t2, mid_continue1 # if t3 => t2 then mid_continue1
    addi t2, t3, 0 
    mv  t0, t4 # save index in t0
    addi t4, t4, 1
    addi t1, t1, 4
    j loop_through_net_worth1


mid_continue1: 
    beq t2, zero, continue11
	bne t2, t3, continue11
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
continue11:
    addi t4, t4, 1
    addi t1, t1, 4
    j loop_through_net_worth1

end_loop1:
    li t1, -1
    beq t0, t1, no_worthy_person1

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


no_worthy_person1:
    mv a0, t0 # t0=-1
    li a7, 1 # print integer
    ecall
    la a0, new_line
    li a7, 4 # print string
    ecall

	j exit_handlers



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




handle_type_6:
	la a0, temp_tokens  # a0 is pointer
    jal ra, is_name_registered
    mv s1, a0 # index of person 1

    la t1, temp_tokens
	addi a0, t1, 8  # a0 is pointer
    jal ra, is_name_registered
    mv s2, a0 # index of person 2

    # asked value is how much s1 must pay to s2:
    # [s2, s1] - [s1, s2]
    # so find [s2, s1] then call debt_value procedure for result

    la t1, table
    li t2, 100
    mul t3, t2, s2
    add t3, t3, s1
    slli t3, t3, 2
    add t4, t3, t1 # t4 is now address of [s2, s1]

    lw t1, 0(t4)
    mv a0, s1
    mv a1, s2
    mv a2, t1
    jal ra, debt_value

    li t2, 100
    div t1, a0, t2
    rem t3, a0, t2
    li t2, 46 # ascii code of '.'

    # example: 456.03, saved as 46503 (int)
    mv a0, t1 # t1 = 45603/100 = 456
    li a7, 1 # print integer
    ecall
    mv a0, t2 # t2 = '.'
    li a7, 11 # print string
    ecall

    # t3 = 46503 % 100 = 3 so putput is : 456.3 (NO) 
    # print a zero before 3 (or any number less than 10)
    li t2, 10
    blt t3, t2, print_zero
continue2:
    mv a0, t3 # t3 = 46503 % 100 = 3 
    li a7, 1 # print integer
    ecall
    la a0, new_line
    li a7, 4 # print string
    ecall
## should go to main here and not continue to print_zero!!
    j exit_handlers

print_zero:
    li a0, 48 # ascii code for '0'
    li a7, 11 # print char
    ecall
    j continue2


