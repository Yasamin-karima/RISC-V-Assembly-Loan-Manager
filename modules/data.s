.section .data
instr: .space 64 # to store instructions

table: .space 40000 # 100 * 100 people * 4 bytes (integer)

names: .space 1200 # 1

net_worth: .space 400 

num_people: .word 0

temp_tokens: .space 32 # for extracted strings from instr

new_line: .asciz "\n"
