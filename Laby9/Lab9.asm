.data
	welcomeMessage: .asciiz "Simple calculator\n"
	giveNumber: .asciiz "\nGive a number\n"
	chooseOperation1: .asciiz "\nPress 1 to add both numbers\nPress 2 to substract both numbers\nPress 3 to multiply both numbers\n"
	chooseOperation2: .asciiz "Press 4 to divide both numbers\nPress 5 to calculate exponentation\n"
	chooseOperation3: .asciiz "Press the following keys to perform integer operations!\n"
	chooseOperation4: .asciiz "Press 6 to calculate factorial\nPress 7 to add both numbers\nPress 8 to substract both numbers\nPress 9 to multiply both numbers\n"
	chooseOperation5: .asciiz "Press 10 to divide both numbers\nPress 11 to calculate exponentation\n"
	readInput: .asciiz "Press 12 to load the input from the array\n"
	saveOutput: .asciiz "\nPress 1 if you want to store the output (error here)\n"
	resultMessage: .asciiz "\nResult\n"
	exitMessage: .asciiz "\nStopping the calculator"
	oneFloat: .float 1
	
# Note - real numbers everywhere!!!
.text
main:
	li $v0, 4
	la $a0, welcomeMessage
	syscall
	la $a0, chooseOperation1
	syscall
	la $a0, chooseOperation2
	syscall
	la $a0, chooseOperation3
	syscall
	la $a0, chooseOperation4
	syscall
	la $a0, chooseOperation5
	syscall
	la $a0, readInput
	syscall
	li $v0, 5
	syscall
	move $t9, $v0
	beq $t9, 1, FloatOperations
	beq $t9, 2, FloatOperations
	beq $t9, 3, FloatOperations
	beq $t9, 4, FloatOperations
	beq $t9, 5, ExponentationOperationFloat
	beq $t9, 6, FactorialOperation
	beq $t9, 7, IntegerOperations
	beq $t9, 8, IntegerOperations
	beq $t9, 9, IntegerOperations
	beq $t9, 10, IntegerOperations
	beq $t9, 11, IntegerOperations
	beq $t9, 12, LoadDataError
	
FloatOperations:
	li $v0, 4
	la $a0, giveNumber
	syscall
	li $v0, 6
	syscall
	mov.s $f1, $f0
	li $v0, 4
	la $a0, giveNumber
	syscall
	li $v0, 6
	syscall
	mov.s $f2, $f0
	beq $t9, 1, AdditionFloat
	beq $t9, 2, SubstractionFloat
	beq $t9, 3, MultiplicationFloat
	beq $t9, 4, DivisionFloat

ExponentationOperationFloat:
	li $v0, 4
	la $a0, giveNumber
	syscall
	li $v0, 6
	syscall
	mov.s $f1, $f0
	li $v0, 4
	la $a0, giveNumber
	syscall
	li $v0, 5
	syscall
	move $t1, $v0
	j CheckingIfCanCalculateExponentationFloat

FactorialOperation:
	li $v0, 4
	la $a0, giveNumber
	syscall
	li $v0, 5
	syscall
	move $t1, $v0
	j FactiorialBeginning

IntegerOperations:
	li $v0, 4
	la $a0, giveNumber
	syscall
	li $v0, 5
	syscall
	move $t1, $v0
	li $v0, 4
	la $a0, giveNumber
	syscall
	li $v0, 5
	syscall
	move $t2, $v0
	beq $t9, 7, AdditionInteger
	beq $t9, 8, SubstractionInteger
	beq $t9, 9, MultiplicationInteger
	beq $t9, 10, DivisionInteger
	beq $t9, 11, CheckingIfCanCalculateExponentationInteger
	
LoadDataError:
	lw $t1, ($zero)
	
AdditionFloat:
	add.s $f3, $f1, $f2	
	j ResultFloat		
	
SubstractionFloat:
	sub.s $f3, $f1, $f2
	j ResultFloat
	
MultiplicationFloat:
	mul.s $f3, $f1, $f2
	j ResultFloat
	
DivisionFloat:
	div.s $f3, $f1, $f2
	j ResultFloat

CheckingIfCanCalculateExponentationFloat:	# Trap if we calculate 0^0
	cvt.w.s  $f30, $f1	# If $f1 = 5.5 than after it $f1 = 5
	mfc1 $t2, $f30		# Convert float to int
	bnez $t2, ExponentationBeginningFloat
	teq $t1, $zero	# Trap because we have 0^0s
			
ExponentationBeginningFloat:
	l.s $f3, oneFloat
	beqz $t1, ResultFloat
	bgt $t1, 0, ExponentationLoopFloat
	abs $t1, $t1
	div.s $f1, $f3, $f1
	
ExponentationLoopFloat:
	mul.s $f3, $f3, $f1
	subi $t1, $t1, 1
	beqz $t1, ResultFloat	
	j ExponentationLoopFloat
	
FactiorialBeginning:
	tlt $t1, $zero	# Trap if factorial smaller than 0
	li $t3, 1		# In $t3 we will keep the value of the result

FactorialLoop:
	beqz $t1, ResultInteger
	mul $t3 $t3, $t1
	subi $t1, $t1, 1
	j FactorialLoop
	
AdditionInteger:
	add $t3, $t1, $t2
	j ResultInteger	
	
SubstractionInteger:
	sub $t3, $t1, $t2
	j ResultInteger
	
MultiplicationInteger:
	mulo $t3, $t1, $t2
	j ResultInteger
	
DivisionInteger:
	div $t3, $t1, $t2
	j ResultInteger
	
CheckingIfCanCalculateExponentationInteger:
	bnez $t2, ExponentationBeginningInteger
	teq $t1, $zero	# Trap because we have 0^0s
	
ExponentationBeginningInteger:
	li $t3, 1
	beqz $t1, ResultInteger
	bgt $t1, 0, ExponentationLoopFloat
	abs $t1, $t1
	div $t1, $t3, $t1
	
ExponentationLoopInteger:
	mulo $t3, $t3, $t1
	subi $t1, $t1, 1
	beqz $t1, ResultInteger	
	j ExponentationLoopInteger
	
ResultFloat:
	li $v0, 4
	la $a0, resultMessage		
	syscall
	li $v0, 2
	mov.s $f12, $f3		
	syscall
	j End
	
ResultInteger:
	li $v0, 4
	la $a0, resultMessage		
	syscall
	li $v0, 1
	move $a0, $t3		
	syscall
	li $v0, 4
	la $a0, saveOutput
	syscall
	li $v0, 5
	syscall
	beq $v0, 1 ErrorStoring
	j End
	
ErrorStoring:
	sw $t3, ($zero)
	
End:
	li $v0, 4
	la $a0, exitMessage		
	syscall
	li $v0, 10	
	syscall	
	
.kdata	
	address_exception_load: .asciiz "ADDRESS_EXCEPTION_LOAD"
	address_exception_store: .asciiz "ADDRESS_EXCEPTION_STORE"
	syscall_exception: .asciiz "SYSCALL_EXCEPTION" 
	breakpoint_exception: .asciiz "BREAKPOINT_EXCEPTION"
	overflow_exception: .asciiz "ARITHMETIC_OVERFLOW_EXCEPTION" 
	divide_by_zero_exception: .asciiz "DIVIDE_BY_ZERO_EXCEPTION"
	negative_factorial: .asciiz "NEGATIVE FACTORIAL"
	zero_to_power_zero: .asciiz "0^0 ERROR"
	test: .asciiz "Unknown error (below is the value of k1)\n"

.ktext 0x80000180  
__kernel_entry_point:
	mfc0 $k0, $13   
	andi $k1, $k0, 0x00007c  
	srl  $k1, $k1, 2
	
__exception:
	beq $k1, 4, __address_exception_load
	beq $k1, 5, __address_exception_store
	beq $k1, 8, __syscall_exception
	beq $k1, 9, __breakpoint_exception
	beq $k1, 12, __overflow_exception
	beq $k1, 13, __trap_exception
	li $v0, 4
	la $a0, test
	syscall
	li $v0, 1
	move $a0, $k1
	syscall
	li $v0 10
	syscall
	
__address_exception_load:
	li $v0 4
	la $a0, address_exception_load
	syscall
	j __end_exception
	
__address_exception_store:
	li $v0 4
	la $a0, address_exception_store
	syscall
	j __end_exception
	
__syscall_exception:
	li $v0 4
	la $a0, syscall_exception
	syscall
	j __end_exception
	
__breakpoint_exception:
	li $v0 4
	la $a0, breakpoint_exception
	syscall
	j __end_exception
	
__overflow_exception:
	li $v0 4
	la $a0, overflow_exception
	syscall
	j __end_exception
	
__trap_exception:
	beq $t9, 5, __zero_to_power_zero
	beq $t9, 6, __negative_factorial
	
__negative_factorial:
	li $v0, 4
	la $a0, negative_factorial
	syscall
	j __end_exception
	
__zero_to_power_zero:
	li $v0, 4
	la $a0, zero_to_power_zero
	syscall
	j __end_exception
	
__end_exception:
	li $v0, 10
	syscall

