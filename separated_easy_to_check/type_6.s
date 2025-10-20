

.global handle_type_6
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
