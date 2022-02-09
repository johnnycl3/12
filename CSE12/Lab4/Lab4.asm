##########################################################################
# Created by:  Chen, Johnny
#              jchen290
#              22 November 2020
#
# Assignment:  Lab 4: Searching HEX
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Fall 2020
# 
# Description: This program takes user input through the program 
# 	       arguments, prints them out as decimal numbers, and
#              prints the max value of the bunch.
#
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

# REGISTER USAGE
# $t0: counter for the amount of program arguments entered
# $t1: load value of program argument (probably wrong terminology)
# $t2: a byte of a value from the program argument (also probably wrong terminology)
# $t3: equal to 57 to determine if the character is a letter or number
# $t4: equal to 0 or 1, depending on whether the character is a letter or number
# $t5: starts at 0, but changes when there is a new max value. used to compare
# $t6: stores the new max value
# $s1: stores the nmber of program arguments
# $s2: stores the address where the program arguments are

# PSEUDOCODE
# Read and print out the program arguments
# 	Iterate through the program argument to print each value in it
# Print out the program argument values as decimal numbers
#	skip to the 3rd byte, so we do not have to deal with the starting '0x'
#	determine whether the byte is a letter or number
#		if it is a letter, subtract 55 from the ascii value
#		else, subtract 48 (because it is a number)
#	multiply and add it to get the decimal number
#	print out the decimal number
#	save the decimal value as the new max value
# 		compare with the most recent number with the max value to determine the new max number
# Print out the maximum value
#	print out from the saved decimal value



.data
	arguments:	.asciiz "Program arguments:\n"
	int_values:	.asciiz "\n\nInteger values:\n"
	max_value:	.asciiz "\n\nMaximum value:\n"
	space: 		.asciiz " "
	
.text

main:
	beqz $a0, quit		# quit if there are 0 program arguments
	add $s1, $a0, $0	# Store the number of program arguments
	add $s2, $a1, $0	# Store address of where program arguments are
	add $t0, $0, 0		# Use $t0 as the counter for looping program arguments
	add $t5, $t5, 0		# set $t5 = 0, for max value comparison
	
	li $v0, 4
	la $a0, arguments	# Print the arguments prompt
	syscall
	j print_string
	j quit
	
# prints out the program arguments
print_string:
	# Prints the string in the program argument
	lw $a0, ($a1)		# Prints the first program argument
	syscall
	add $t0, $t0, 1
	add $a1, $a1, 4
	beq $s1, $t0, int	# branch to int if $s1 and $t0 are equal
	li $v0, 4
	la $a0, space		# print a space
	syscall
	
	j print_string


# prints the int_values prompt
int:
	and $t0, $t0, $zero	# and $t0 to make it zero to reuse the program argument counter
	li $v0, 4		# Print integer values prompt
	la $a0, int_values	
	syscall
	j skip_x
	
# start the hex value by skipping '0x'
skip_x:
	and $v0, $v0, 0		# make v0 = 0
	beq $s1, $t0, print_max	# put here just to prevent the last 'space' after the last decimal is printed
	lw $t1, ($s2)		# loads the program argument into $t1
	add $t1, $t1, 2		# make t1 = 2, so we can skip the '0x'

# iterate through the byte 	
iterate_bytes:	
	lb $t2, ($t1)			# loads the first byte into t2
	
	beq $t2, $zero, print_decimal	# branch to quit if the character is equal to 'NULL'
	
 	addi $t3, $zero, 57		# set t3 = 57
 	slt $t4, $t2, $t3		# set t4 = t2 < 57
 	bne $t4, $zero, for_number	# if the character is a number, branch to for_number 
 	j for_letter			# else, branch to for_letter

# print the decimal if it is a number
for_number:
	lb $t2, ($t1)		# subtract 48 from the ascii value because it is a number
	move $a0, $t2		# this will make it the decimal value
	add $a0, $a0, -48
	
	j inc

# print the decimal if it is a letter
for_letter:	
	lb $t2, ($t1)		# subtract 55 from the ascii value because it is a letter
	move $a0, $t2		# this will make it the decimal value 
	add $a0, $a0, -55

	j inc

# for looping through the program arguments 	
increment_prog_args:
	addi $t0, $t0, 1	# adds 1 to the counter of the program arguments
	add $s2, $s2, 4		# adds 4 to get to the next program argument
	beq $s1, $t0, print_max	# branch to int if $s1 and $t0 are equal
	li $v0, 4
	la $a0, space
	syscall
	j skip_x

# does the multiplying my 16 to get the decimal value
inc:
        sll $v0, $v0, 4		# multiply current sum by 16
        addu $v0, $v0, $a0	# add calculated value of character
        addi $t1, $t1, 1	# add 1 to $t1 to get to the next character
        j iterate_bytes		# loop

# prints out the decimal value to the program argument
print_decimal:
	beq $s1, $t0, quit	#  branch to quit if $s1 and $t0 are equal
	move $t2, $v0		# move the value from $v0 to $t2
	li $v0, 1
	move $a0, $t2		# move the value from $t2 to $a0 and print it
	syscall
	bgt $t2, $t5, new_max
	j increment_prog_args	# jump back to increment_prog_args

# set the current value as the max value
new_max:
	move $t6, $t2		# move $t2 into $t6, as the new max value
	move $t5, $t2		# move $t2 into $t5, to set as the old value that we use to compare
	
	j increment_prog_args		# jump back to increment_prog_args

# print the max_value prompt and the max value	
print_max:
	li $v0, 4
	la $a0, max_value	# prints max_value prompt
	syscall
	li $v0, 1
	move $a0, $t6		# prints the max value
	syscall
	j quit
	
# quit program
quit:
	li $v0, 10
	syscall

	
