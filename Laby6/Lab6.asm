.data
	welcomeMessage: .asciiz "Simple calculator\n"
	giveNumber: .asciiz "Give a number\n"
	chooseOperation: .asciiz "Press 1 to add both numbers\nPress 2 to substract both numbers\nPress 3 to multiply both numbers\nPress 4 to divide both numbers\n"
	resultMessage: .asciiz "Result\n"
	askIfRepeat: .asciiz "\nPress 1 if you want to continue performing operations using the previously calculated result\n"
	improperSign: .asciiz "Improper sign. The program will stop execution\n"
	exitMessage: .asciiz "Stopping the calculator"
	newline: . "\n"
.text
main:
	li $v0, 4	# Code for printing strings
	la $a0, welcomeMessage		# Printing welcomeMessage
	syscall
	li $v0, 4
	la $a0, newline		# Printing the empty line
	syscall 
	
	li $v0, 4
	la $a0, giveNumber		# Print string asking for a number
	syscall
	li $v0 5	# Read integer from the user
	syscall
	move $t0, $v0	# Move the first integer we got into the proper register
	j TakeSecondNumberAndPerformComputation
	
AssignTheFirstRegisterTheResult:
	li $v0, 4
	la $a0, newline		# Printing the empty line
	syscall 
	move $t0, $t3
	j TakeSecondNumberAndPerformComputation
	
TakeSecondNumberAndPerformComputation:
	li $v0, 4
	la $a0, giveNumber		
	syscall
	li $v0 5	# Read integer from the user
	syscall
	move $t1, $v0	# Move the second integer we got into the proper register
	
	li $v0, 4
	la $a0, chooseOperation		# Print string asking for a sign
	syscall
	li $v0 5	# Read choice made by user
	syscall
	move $t2, $v0	# Move the operation we got into the proper register
	
	beq $t2, 1, Addition	# Checking if the sign is +. If it is jump to Addition
	beq $t2, 2, Substraction
	beq $t2 3, Multiplication
	beq $t2 4, Division
	li $v0, 4
	la $a0, improperSign		# Printing the error message
	syscall
	li $v0 10	# Stop the execution of the programme
	syscall
	
Addition:
	add $t3, $t0, $t1	# Adding the numbers
	j	EndOfOperation		# Jumping to the proper place
	
Substraction:
	sub $t3, $t0, $t1
	j	EndOfOperation
	
Multiplication:
	mult $t0, $t1	# Lower 32 bits are stored in lo
	mflo $t3
	j 	EndOfOperation
	
Division:
	div $t0, $t1	# Quotient is stored in lo
	mflo $t3
	j 	EndOfOperation
	
EndOfOperation:
	li $v0, 4
	la $a0, resultMessage		# Printing the result message
	syscall
	li $v0 1
	move $a0 $t3	# Print the result
	syscall
	
	li $v0 4
	la $a0 askIfRepeat
	syscall
	li $v0 5
	syscall
	move $t4, $v0
	beq $t4, 1, AssignTheFirstRegisterTheResult
	
	li $v0, 4
	la $a0, exitMessage		# Printing the exit message
	syscall
	li $v0 10	# Stop the execution of the programme
	syscall
	
		
			
	
	
	
