.data
	welcomeMessage: .asciiz "Simple calculator\n"
	giveNumber: .asciiz "\nGive a number\n"
	chooseOperation: .asciiz "\nPress 1 to add both numbers\nPress 2 to substract both numbers\nPress 3 to multiply both numbers\nPress 4 to divide both numbers\nPress 5 to calculate the reciprocal\nPress 6 to calculate the absolute value\nPress 7 to calculate exponentation\nPress 8 to calculate factorial\n"
	resultMessage: .asciiz "\nResult\n"
	askForOptionAfterOperation: .asciiz "\n\nPress 1 to add to the buffer\nPress 2 to substract from the buffer\nPress 3 to reset the buffer\nPress 4 to read the buffer\nPress 5 if you want to continue performing operations using the previously calculated result\n"
	improperSign: .asciiz "Improper sign. The program will stop execution\n"
	exitMessage: .asciiz "Stopping the calculator"
	oneFloat: .float 1
	zeroFloat: .float 0
	
# Note - real numbers everywhere!!!
.text
main:
	# Simple description of what every variable does
	# Note $f0 will keep the float number read
	# Note2 $f12 will be used to print the result
	l.s $f1, zeroFloat # The first number
	l.s $f2, zeroFloat # The second number
	l.s $f3, zeroFloat # The result
	l.s $f4, zeroFloat # The buffer
	li $t0, 0 # Choice
	li $t1, 0 # Integer value used when we need to convert float to int
	li $t2, 0 # Filler integer holding the value of factorial

	li $v0, 4	# Code for printing strings
	la $a0, welcomeMessage		# Printing welcomeMessage
	syscall
	
	li $v0, 4
	la $a0, giveNumber	# Print string asking for a number
	syscall
	li $v0, 6	# Read first float from the user
	syscall
	mov.s $f1, $f0	# Move the first float we got into the proper register
	j ChooseOperation
	
AssignTheFirstRegisterTheResult:
	mov.s $f1, $f3	# Move the result into the 

ChooseOperation:	
	li $v0, 4
	la $a0, chooseOperation		# Print string asking for an operation
	syscall
	li $v0, 5	# Read choice made by user
	syscall
	move $t0, $v0	# Move the operation we got into the proper register
	
	# Methods that don't need the second number
	beq $t0 5, Reciprocal
	beq $t0 6, AbsoluteValue
	beq $t0 8, FactiorialBeginning
	
	li $v0, 4
	la $a0, giveNumber		
	syscall
	li $v0, 6	# Read second float from the user
	syscall
	mov.s $f2, $f0	# Move the second float we got into the proper register
	
	# Here implement the way to move into methods that use both numbers
	beq $t0, 1, Addition	
	beq $t0, 2, Substraction
	beq $t0, 3, Multiplication
	beq $t0, 4, Division
	beq $t0, 7, ExponentationBeginning
	j ErrorMessage
	
# Few notes - we use single precision and floats to perform operations on real numbers
Addition:
	add.s $f3, $f1, $f2	# Adding the numbers
	j EndOfOperation		# Jumping to the proper place
	
Substraction:
	sub.s $f3, $f1, $f2
	j EndOfOperation
	
Multiplication:
	mul.s $f3, $f1, $f2
	j EndOfOperation
	
Division:
	div.s $f3, $f1, $f2
	j EndOfOperation
	
Reciprocal:
	l.s $f3, oneFloat
	div.s $f3, $f3, $f1
	j EndOfOperation

AbsoluteValue:
	abs.s $f3, $f1
	j EndOfOperation
	
ExponentationBeginning:
	l.s $f3, oneFloat	# To perform exponentation properly we need to set $f3 to 1
	cvt.w.s  $f2, $f2	# If $f2 = 5.5 than after it $f2 = 5
	mfc1 $t1, $f2		# Convert float to int
	beqz  $t1, EndOfOperation
	bgt $t1, 0, ExponentationLoop
	abs $t1, $t1
	div.s $f1, $f3, $f1
	
ExponentationLoop:
	mul.s $f3, $f3, $f1
	subi $t1, $t1, 1
	beqz $t1, EndOfOperation	
	j ExponentationLoop
	
FactiorialBeginning:
	cvt.w.s  $f1, $f1	# If $f1 = 5.5 than after it $f1 = 5
	mfc1 $t1, $f1		# Convert float to int
	li $t2, 1		# In $t2 we will keep the value of the result

FactorialLoop:
	mul $t2 $t2, $t1
	subi $t1, $t1, 1
	mtc1 $t2, $f3		# Move the current result of the operation to $f3
	cvt.s.w $f3, $f3	# Convert to float
	beqz $t1, EndOfOperation
	j FactorialLoop

ErrorMessage:
	li $v0, 4
	la $a0, improperSign		# Printing the error message
	syscall
	li $v0, 10	# Stop the execution of the programme
	syscall
	
AddToBuffer:
	add.s $f4, $f4, $f3
	j EndOfOperation
	
SubstractFromBuffer:
	sub.s $f4, $f4, $f3
	j EndOfOperation
	
ResetBuffer:
	l.s $f4 zeroFloat
	j EndOfOperation
	
ReadBuffer:
	mov.s $f3, $f4
	j EndOfOperation
	
EndOfOperation:
	li $v0, 4
	la $a0, resultMessage		# Printing the result message
	syscall
	li $v0, 2
	mov.s $f12, $f3		# Print the result (float)
	syscall
	
	li $v0, 4
	la $a0, askForOptionAfterOperation
	syscall
	li $v0, 5
	syscall
	move $t0, $v0
	beq $t0, 1, AddToBuffer
	beq $t0, 2, SubstractFromBuffer
	beq $t0, 3, ResetBuffer
	beq $t0, 4, ReadBuffer
	beq $t0, 5, AssignTheFirstRegisterTheResult
	
	li $v0, 4
	la $a0, exitMessage		# Printing the exit message
	syscall
	li $v0, 10	# Stop the execution of the programme
	syscall
	

