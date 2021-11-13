.data 0x10000000 ##!
  display: 	.space 65536
  		.align 2
  redPrompt:	.asciiz "Enter a RED color value for the background (integer in range 0-255):\n"
  greenPrompt:	.asciiz "Enter a GREEN color value for the background (integer in range 0-255):\n"
  bluePrompt:	.asciiz "Enter a BLUE color value for the background (integer in range 0-255):\n"
  redSquarePrompt:	.asciiz "Enter a RED color value for the squares (integer in range 0-255):\n"
  greenSquarePrompt:	.asciiz "Enter a GREEN color value for the squares (integer in range 0-255):\n"
  blueSquarePrompt:	.asciiz "Enter a BLUE color value for the squares (integer in range 0-255):\n"
  upLeftXPrompt:	.asciiz "Enter the x value of the upper left corner (integer in the range 0-127):\n"
  upLeftYPrompt:	.asciiz "Enter the y value of the upper left corner (integer in the range 0-127):\n"
  sizePrompt:	.asciiz "Enter the width in pixels of the square (integer in the range 0-128):\n"
  
  


.text 0x00400000 ##!
main:

	addi	$v0, $0, 4  			# system call 4 is for printing a string
	la 	$a0, redPrompt 		# address of columnPrompt is in $a0
	syscall           			# print the string
	# read in the R value
	addi	$v0, $0, 5			# system call 5 is for reading an integer
	syscall 				# integer value read is in $v0
 	add	$s0, $0, $v0			# copy N into $s0
 	
 	
 	
 	addi	$v0, $0, 4  			# system call 4 is for printing a string
	la 	$a0, greenPrompt 		# address of columnPrompt is in $a0
	syscall           			# print the string
	# read in the G value
	addi	$v0, $0, 5			# system call 5 is for reading an integer
	syscall 				# integer value read is in $v0
 	add	$s1, $0, $v0			# copy N into $s1
 	
 	
 	
 	addi	$v0, $0, 4  			# system call 4 is for printing a string
	la 	$a0, bluePrompt 		# address of columnPrompt is in $a0
	syscall           			# print the string
	# read in the B value
	addi	$v0, $0, 5			# system call 5 is for reading an integer
	syscall 				# integer value read is in $v0
 	add	$s2, $0, $v0			# copy N into $s2
 	
 	
	#############################################
	## Calculate background color and put in   ##
	## appropriate register                    ##
	#############################################
	j drawDisplay
	
# Exit from the program
exit:
  ori $v0, $0, 10       		# system call code 10 for exit
  syscall               		# exit the program
	
drawDisplay:
	mul $t3, $t0, 4
	sw $t1, display($t3)
	addi $t0, $t0, 1
	bne $t0, $s3, drawDisplay
	
	
readSquareColors:
	addi	$v0, $0, 4  	
	la 	$a0, redSquarePrompt 
	syscall           	
	# read in the R value
	addi	$v0, $0, 5	
	syscall 		
 	add	$s0, $0, $v0	
 	
 	
 	
 	addi	$v0, $0, 4  			
	la 	$a0, greenSquarePrompt 		
	syscall           			
	# read in the G value
	addi	$v0, $0, 5			
	syscall 				
 	add	$s1, $0, $v0			
 	
 	
 	
 	addi	$v0, $0, 4  		
	la 	$a0, blueSquarePrompt 	
	syscall           		
	# read in the B value
	addi	$v0, $0, 5		
	syscall 			
 	add	$s2, $0, $v0	
 	
 	#############################################
	## Calculate square color and put in       ##
	## appropriate register  ($a3)             ##
	#############################################

readPosition:
	addi	$v0, $0, 4  	
	la 	$a0, upLeftXPrompt
	syscall           	
	addi	$v0, $0, 5	
	syscall 		
 	add	$t0, $0, $v0
 	
 	addi	$v0, $0, 4  	
	la 	$a0, upLeftYPrompt
	syscall           	
	addi	$v0, $0, 5	
	syscall 		
 	add	$a1, $0, $v0
	
readSize:
	addi	$v0, $0, 4  	
	la 	$a0, sizePrompt 
	syscall           	
	addi	$v0, $0, 5	
	syscall 		
 	add	$a2, $0, $v0	
 	
 	add $a0, $t0, $0  	# $a0 is used for the syscalls, so we set it after getting all of the other values
 	
 	jal drawSquare # Do not change this line
 	j exit # Do not change this line
 	
 drawSquare:	# Do not change this label
 	# $a0 - upper left x
 	# $a1 - upper left y
 	# $a2 - width
 	# $a3 - color 
 	
 	# $a0 is xmin (i.e., left edge; must be within the display)
	# $a1 is width (must be nonnegative and within the display)
	# $a2 is ymin  (i.e., top edge, increasing down; must be within the display)
	# $a3 is height (must be nonnegative and within the display)

	beq $a1,$0,rectangleReturn # zero width: draw nothing
	beq $a3,$zero,rectangleReturn # zero height: draw nothing

	li $t0,-1 # color: white
	la $t1,display
	add $a2,$a2,$a0 # simplify loop tests by switching to first too-far value
	add $a3,$a3,$a1
	sll $a0,$a0,2 # scale x values to bytes (4 bytes per pixel)
	sll $a2,$a2,2
	sll $a1,$a1,11 # scale y values to bytes (512*4 bytes per display row)
	sll $a3,$a3,11
	addu $t2,$a1,$t1 # translate y values to display row starting addresses
	addu $a3,$a3,$t1
	addu $a1,$t2,$a0 # translate y values to rectangle row starting addresses
	addu $a3,$a3,$a0
	addu $t2,$t2,$a2 # and compute the ending address for first rectangle row
	li $t4,0x800 # bytes per display row

rectangleYloop:
	move $t3,$a1 # pointer to current pixel for X loop; start at left edge

rectangleXloop:
	sw $t0,($t3)
	addiu $t3,$t3,4
	bne $t3,$t2,rectangleXloop # keep going if not past the right edge of the rectangle

	addu $a1,$a1,$t4 # advace one row worth for the left edge
	addu $t2,$t2,$t4 # and right edge pointers
	bne $a1,$a3,rectangleYloop # keep going if not off the bottom of the rectangle

rectangleReturn:
	jr $ra
 	
 	
 	
