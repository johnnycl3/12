##########################################################################
# Created by:  Chen, Johnny
#              jchen290
#              13 November 2020
#
# Assignment:  Lab 3: ASCII-risks (Asterisks)
#              CSE 012, Computer Systems and Assembly Language
#              UC Santa Cruz, Fall 2020
# 
# Description: This program prints a specific pattern, triangle, using 
# 	       numbers and stars with a tab between each of them. 
#
# Notes:       This program is intended to be run from the MARS IDE.
##########################################################################

# REGISTER USAGE
# $t0: height of pattern (user input)
# $t1: current height
# $t2: number of outside tabs 
# $t3: number of inside tabs 
# $t4: current number
# $t5: number from $t4 is set into it to determine if it is even or odd

# PSEUDOCODE
# Ask user for height
# build pattern
# 	print outside tabs
# 		number of outside tabs to print is equal to (current height - 1)
# 	rint number
# 		if "current number is even"
#			print newline
# 		if "current number is equal to height"
#			end program
# 	print inside tabs
#		number of inside tabs to print is equal to the current number
# 		print stars inbetween tabs
# end program

.data 
	prompt:		.asciiz "Enter the height of the pattern (must be greater than 0):\t"
	invalid:	.asciiz "Invalid Entry!\n"
	tab:		.asciiz "\t"
	newline:	.asciiz "\n"
	
.text
height:
	# Prompt for height of pattern
	li $v0 4
	la $a0, prompt
	syscall
	
	# Get the number of patterns
	li $v0, 5
	syscall
	
	blez $v0, error		# If user input is < 0, error prompt
	
	move $t0, $v0		# Height of pattern, moved from $v0
	
	li $t1, 1 		# Current height
	li $t4, 1		# Current number
	
build:
	bgt $t1, $t0, quit	# If current height > height, quit
	
	sub $t2, $t0, $t1	# Number of outside tabs (height - current height)
	add $t3, $t4, 0		# Number of inside tabs
	
	# Print outside tabs
	j outside_tabs
	
# Print the outside tabs (the ones to the left of the leftmost numbers)
outside_tabs:
	blez $t2, print_number	# If number of outside tabs <= 0, branch to print_number
	li $v0, 4		# Print tab
	la $a0, tab
	syscall
	sub $t2, $t2, 1		# Subtract 1 from number of outside tabs (t2)
	j outside_tabs		# Jump back to outside_tabs
	
# Print number 
print_number:
	li $v0, 1		# Print number
	la $a0, ($t4)
	syscall
	add $t4, $t4, 1		# Add 1 to current number (t4)
	
	andi $t5, $t4, 0x0001	# Check if number is even or odd
	beqz $t5, next_line	# If number is even, branch to nextline
	beq $t5, $t0, quit	# If current height == height, branch to quit
	j inside_tabs		# Else, jump to inside_tabs
	
# Print a new line
next_line:
	li $v0, 4
	la $a0, newline
	syscall
	sub $t2, $t2, 1		# Subtracts 1 from outside tabs
	add $t1, $t1, 1		# Adds 1 to current height (t1)
	j build
	
# Print the inside tabs and stars
inside_tabs:
	li $v0, 4		# Print tab
	la $a0, tab
	syscall
	sub $t3, $t3, 1		# Subtract 1 from inside tabs (t3)
	
	blez $t3, print_number
	
	li $v0, 11		# Print a star
	la $a0, '*'
	syscall
	j inside_tabs		# jump back to inside tabs
	
	
# Prints invalid prompt
error:
	li $v0, 4
	la $a0, invalid
	syscall
	j height

# Quits the program
quit:
	li $v0, 10
	syscall
