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
