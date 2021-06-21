.data
	askForEquation: .asciiz "Write an equation (remember about spaces and if you used the previous number)\n"
	currentEquation: .asciiz "Current equation (without the previous number): "
	postfixEquation: .asciiz "Postfix notation: "
	errorMessage: .asciiz "Error in notation\n"
	resultMessage: .asciiz "\nResult\n"
	askForOptionAfterOperation: .asciiz "\n\nPress 1 to add to the buffer\nPress 2 to substract from the buffer\nPress 3 to reset the buffer\nPress 4 to read the buffer\nPress 5 to continue operations (without using factorial, reciprocal or absolute value)\nPress 6 to continue operations (if you want to use factorial, reciprocal or absolute value)\nBe aware that when you continue operations only the whole positive part of the number will be kept\n"
	exitMessage: .asciiz "Stopping the calculator"
	infix: .space 256
	postfix: .space 256	# Postfix notation (reverse Polish notation)
	operator: .space 256	# Preserve all operators here (like +, - etc.)
	zeroFloat: .float 0
	oneFloat: .float 1
	converter: .word 1
	wordToConvert: .word 1
	stack: .float
	
.text
start:
	li $v0 4
	la $a0 askForEquation
	syscall

	li $v0 8
	la $a0 infix	# Our infix buffer
	la $a1 256
	syscall
	
	li $v0 4
	la $a0 currentEquation
	syscall
	
	li $v0 4
	la $a0 infix
	syscall
	
	la $t1, infix
	addi $t1, $t1, -1	# Set it to -1 so we don't skip the first input
	la $t2, postfix
	la $t3, operator
	li $t5, -1		# Postfix top offset
	li $t6, -1		# Operator top offset
	# $t8 is for keeping the proper index
	# $t9 is for temporary use
	li $s1, 0	# Current input status (important to keep track of errors in notation)
	# 0 - no input, 1 - digit, 2 - operator, 3 - open bracket, 4 - close bracket
	# $s2 is for keeping the current infix input
	# $s3 is for keeping the current number
	# $f1, $f2 - numbers, $f3 - score, $f4 - buffer
	# Save the number from the previous output
	beq $t0, 5, saveNumber
	# Save the number but the first operation is factorial, absolute value, reciprocal
	li $s2 1
	
scanInfix:
	addi $t1, $t1, 1
	lb $s2, ($t1)	# Load current infix input
	beq $s2, ' ', scanInfix		# Ignore spaces
	beq $s2, '\n' EndOfOperation	# End of equation
	# Operations in order of precedence
	beq $s2, '+', plusMinusOperator
	beq $s2, '-', plusMinusOperator
	beq $s2, '*', multiplyDivideOperator
	beq $s2, '/', multiplyDivideOperator
	beq $s2, 'f', factorialOperator		# Factorial operator - in this case we will print f before the number we want to calculate the factorial of
	beq $s2, '^', exponentationOperator
	beq $s2, 'a', absoluteReciprocalOperator		# Calculate absolute value
	beq $s2, 'r', absoluteReciprocalOperator	# Calculate reciprocal
	beq $s2, '(', openBracket
	beq $s2, ')', closeBracket
	# Digits
	beq $s2, '0', startReadNumber	# Use ASCII to read numbers
	beq $s2, '1', startReadNumber
	beq $s2, '2', startReadNumber
	beq $s2, '3', startReadNumber
	beq $s2, '4', startReadNumber
	beq $s2, '5', startReadNumber
	beq $s2, '6', startReadNumber
	beq $s2, '7', startReadNumber
	beq $s2, '8', startReadNumber
	beq $s2, '9', startReadNumber
	
wrongInput:
	li $v0, 4
	la $a0, errorMessage
	syscall
	li $v0 10
	syscall
		
startReadNumber:
	beq $s1, 1, wrongInput
	beq $s1, 4, wrongInput
	subi $s2, $s2, 48	# Convert from ASCII to integer
	move $s3, $s2
	li $s4, 1	# We will divide by 1 if it's an integer
	
readNumber:
	addi $t1, $t1, 1
	lb $s2, ($t1)
	beq $s2, '0', readInteger
	beq $s2, '1', readInteger
	beq $s2, '2', readInteger
	beq $s2, '3', readInteger
	beq $s2, '4', readInteger
	beq $s2, '5', readInteger
	beq $s2, '6', readInteger
	beq $s2, '7', readInteger
	beq $s2, '8', readInteger
	beq $s2, '9', readInteger
	beq $s2, ' ' saveNumber
	beq $s2, '\n' saveNumber
	j wrongInput
	
# Multiply by 10 and add the remaining number
readInteger:
	subi $s2, $s2, 48	# Convert from ASCII to integer
	mul $s3, $s3, 10
	add $s3, $s3, $s2
	j readNumber
	
saveNumber:
	addi $t5, $t5, 1
	add $t8, $t5, $t2
	sb $s3, ($t8)	# Store the number 
	li $s1, 1
	beq $s2, '\n' EndOfOperation	# It's the last number
	li $t0, 0	# For safety reasons
	j scanInfix

# We detected plus or minus operator
plusMinusOperator:
	beq $s1, 2, wrongInput
	beq $s1, 3, wrongInput
	beq $s1, 0, wrongInput
	li $s1, 2

continuePlusMinusOperator:
	beq $t6, -1, inputToOp
	add $t8, $t6, $t3	# Assing $t8 the value from $t3 at index $t6
	lb $t9, ($t8)
	beq $t9,'(', inputToOp	
	beq $t9,'+', equalPrecedence	
	beq $t9,'-', equalPrecedence
	beq $t9,'*', lowerPrecedencePlusMinus	
	beq $t9,'/', lowerPrecedencePlusMinus
	beq $t9, 'f', lowerPrecedencePlusMinus
	beq $t9, '^', lowerPrecedencePlusMinus
	beq $t9, 'a', lowerPrecedencePlusMinus
	beq $t9, 'r' lowerPrecedencePlusMinus
	
multiplyDivideOperator:
	beq $s1, 2, wrongInput
	beq $s1, 3, wrongInput
	beq $s1, 0, wrongInput
	li $s1, 2
	
continueMultiplyDivideOperator:
	beq $t6, -1, inputToOp
	add $t8, $t6, $t3	# Assing $t8 the value from $t3 at index $t6
	lb $t9, ($t8)
	beq $t9,'(', inputToOp	
	beq $t9,'+', inputToOp	
	beq $t9,'-', inputToOp
	beq $t9,'*', equalPrecedence	
	beq $t9,'/', equalPrecedence
	beq $t9, 'f', lowerPrecedenceMultiplyDivide
	beq $t9, '^', lowerPrecedenceMultiplyDivide
	beq $t9, 'a', lowerPrecedenceMultiplyDivide
	beq $t9, 'r' lowerPrecedenceMultiplyDivide
	
factorialOperator:
	beq $s1, 1, wrongInput
	beq $s1, 4, wrongInput
	li $s1 2
	j continueExponentationFactorialOperator
	
exponentationOperator:
	beq $s1, 2, wrongInput
	beq $s1, 3, wrongInput
	beq $s1, 0, wrongInput
	li $s1, 2
	
continueExponentationFactorialOperator:
	beq $t6, -1, inputToOp
	add $t8, $t6, $t3	# Assing $t8 the value from $t3 at index $t6
	lb $t9, ($t8)
	beq $t9,'(', inputToOp	
	beq $t9,'+', inputToOp	
	beq $t9,'-', inputToOp
	beq $t9,'*', inputToOp	
	beq $t9,'/', inputToOp
	beq $t9, 'f', equalPrecedence
	beq $t9, '^', equalPrecedence
	beq $t9, 'a', lowerPrecedenceExponentation
	beq $t9, 'r' lowerPrecedenceExponentation
	
# Special type of operators
# They should appear before the number (so they should appear after an operator or '(' )
absoluteReciprocalOperator:
	beq $s1, 1, wrongInput
	beq $s1, 4, wrongInput
	li $s1 2
	
continueAbsoluteReciprocalOperator:
	beq $t6, -1, inputToOp
	add $t8, $t6, $t3	# Assing $t8 the value from $t3 at index $t6
	lb $t9, ($t8)
	beq $t9,'(', inputToOp	
	beq $t9,'+', inputToOp	
	beq $t9,'-', inputToOp
	beq $t9,'*', inputToOp	
	beq $t9,'/', inputToOp
	beq $t9, 'f', inputToOp
	beq $t9, '^', inputToOp
	beq $t9, 'a', equalPrecedence
	beq $t9, 'r' equalPrecedence
	
equalPrecedence:
	jal opToPostFix
	j inputToOp
	
lowerPrecedencePlusMinus:
	jal opToPostFix
	j continuePlusMinusOperator
	
lowerPrecedenceMultiplyDivide:
	jal opToPostFix
	j continueMultiplyDivideOperator
	
lowerPrecedenceExponentation:
	jal opToPostFix
	j continueExponentationFactorialOperator
	
openBracket:
	beq $s1, 1, wrongInput		
	beq $s1, 4, wrongInput
	li $s1, 3
	j inputToOp
	
closeBracket:
	beq $s1, 2, wrongInput
	beq $s1, 3, wrongInput
	li $s1, 4
	add $t8, $t6, $t3
	lb $t9 ($t8)
	beq $t9, '(', wrongInput # () is an error

continueCloseBracket:
	beq $t6, -1, wrongInput # there is not an open bracket
	add $t8, $t6, $t3
	lb $t9, ($t8)
	beq $t9, '(', matchBracket	# We found the matching bracket
	jal opToPostFix
	j continueCloseBracket
	
matchBracket:
	addi $t6, $t6, -1	# Decrement top of the operator offset
	j scanInfix

inputToOp:	# Push input to operator
	add $t6, $t6, 1
	add $t8, $t6, $t3
	sb $s2, ($t8)
	beq $t0, 6, saveNumber
	j scanInfix
	
opToPostFix:
	addi $t5, $t5, 1
	add $t8, $t5, $t2
	addi $t9, $t9, 100	# We add this so that later we could easily differentiate between operators and numbers
	sb $t9, ($t8)
	addi $t6, $t6,-1	
	jr $ra
	
EndOfOperation:
	beq $s1, 2, wrongInput
	beq $s1, 3, wrongInput
	beq $t5, -1, wrongInput
	j popAll

# Pop all operators to Postfix
popAll:
	beq $t6, -1, finishScan
	add $t8, $t6, $t3
	lb $t9, ($t8)
	beq $t9, '(', wrongInput
	beq $t9, ')', wrongInput
	jal opToPostFix
	j popAll

# We will print our postfix notation
finishScan:
	li $v0, 4
	la $a0, postfixEquation
	syscall
	li $t6, -1	# Used for keeping track of the postfix offset
	li $t7, -1	# Used for keeping the number of tens in the output
	
printPostfix:
	addi $t6, $t6, 1
	add $t8, $t2, $t6
	lbu $t7, ($t8)
	bgt $t6, $t5, finishPrint
	bgt $t7, 99, printOp	
	li $v0, 1
	add $a0, $t7, $zero
	syscall
	li $v0 11
	li $a0, ' '
	syscall
	j printPostfix
	
printOp:
	li $v0, 11
	addi $t7, $t7, -100
	add $a0, $t7, $zero
	syscall
	li $v0 11
	li $a0, ' '
	syscall
	j printPostfix
	
finishPrint:
	li $v0, 11
	li $a0, '\n'
	syscall
	
startCalculation:
	li $t9, -4
	la $t3, stack
	li $t6 -1
	l.s $f0, converter

calculatePost:
	addi $t6, $t6, 1
	add $t8, $t2, $t6
	lbu $t7, ($t8)
	bgt $t6, $t5, EndAllCalculation	# No more operations available
	bgt $t7, 99, Calculate	# Check if the current postfix is an operator
	addi $t9, $t9, 4
	add $t4, $t3, $t9
	sw $t7, wordToConvert
	l.s $f10, wordToConvert
	div.s $f10, $f10, $f0
	s.s $f10, ($t4)	# Push number into stack
	sub.s $f10, $f10, $f10
	j calculatePost
	
Calculate:
	# Pop the first number
	add $t4, $t3, $t9
	l.s $f2, ($t4)
	
	subi $t7, $t7, 100	# Change operator to something sensible (check previous alternations)
	beq $t7, 'f', FactiorialBeginning
	beq $t7, 'a', AbsoluteValue
	beq $t7, 'r', Reciprocal
	
	# Pop the second number
	addi $t9, $t9, -4
	add $t4, $t3, $t9
	l.s $f1, ($t4)
	
	beq $t7, '+' , Addition
	beq $t7, '-' , Substraction
	beq $t7, '*' , Multiplication
	beq $t7, '/' , Division
	beq $t7, '^', ExponentationBeginning
	
# Few notes - we use single precision and floats to perform operations on real numbers
Addition:
	add.s $f3, $f1, $f2	# Adding the numbers
	j EndSimpleCalculation		# Jumping to the proper place
	
Substraction:
	sub.s $f3, $f1, $f2
	j EndSimpleCalculation
	
Multiplication:
	mul.s $f3, $f1, $f2
	j EndSimpleCalculation
	
Division:
	div.s $f3, $f1, $f2
	j EndSimpleCalculation
	
Reciprocal:
	l.s $f3, oneFloat
	div.s $f3, $f3, $f2
	j EndSimpleCalculation

AbsoluteValue:
	abs.s $f3, $f2
	j EndSimpleCalculation
	
ExponentationBeginning:
	l.s $f3, oneFloat	# To perform exponentation properly we need to set $f3 to 1
	cvt.w.s  $f2, $f2	# If $f2 = 5.5 than after it $f2 = 5
	mfc1 $s1, $f2		# Convert float to int
	beqz $s1, EndSimpleCalculation
	bgt $s1, 0, ExponentationLoop
	abs $s1, $s1
	div.s $f1, $f3, $f1
	
ExponentationLoop:
	mul.s $f3, $f3, $f1
	subi $s1, $s1, 1
	beqz $s1, EndSimpleCalculation
	j ExponentationLoop
	
FactiorialBeginning:
	cvt.w.s  $f2, $f2	# If $f1 = 5.5 than after it $f1 = 5
	mfc1 $s1, $f2		# Convert float to int
	li $s2, 1		# In $t2 we will keep the value of the result
	bgt $s1, 0, FactorialLoop
	l.s $f3, oneFloat
	beqz $s1, printResult
	j wrongInput

FactorialLoop:
	mul $s2 $s2, $s1
	subi $s1, $s1, 1
	mtc1 $s2, $f3		# Move the current result of the operation to $f3
	cvt.s.w $f3, $f3	# Convert to float
	beqz $s1, EndSimpleCalculation
	j FactorialLoop
	
EndSimpleCalculation:
	s.s $f3, ($t4)
	j calculatePost
	
EndAllCalculation:
	l.s $f3, ($t4)	# Last value in stack
	
printResult:
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
	beq $t0, 5, ContinueOperation
	beq $t0, 6, ContinueOperation
	
	li $v0, 4
	la $a0, exitMessage		# Printing the exit message
	syscall
	li $v0, 10	# Stop the execution of the programme
	syscall
	
AddToBuffer:
	add.s $f4, $f4, $f3
	j printResult
	
SubstractFromBuffer:
	sub.s $f4, $f4, $f3
	j printResult
	
ResetBuffer:
	l.s $f4 zeroFloat
	j printResult
	
ReadBuffer:
	mov.s $f3, $f4
	j printResult
	
ContinueOperation:
	cvt.w.s $f3, $f3
	mfc1 $s3, $f3
	li $s2, 0	# Used so that $s2 would hold the empty value
	j start
	
	
