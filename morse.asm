.text


main:	



# STUDENTS MAY MODIFY CODE BELOW
# vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv

	## Test code that calls procedure for part A
	# jal save_our_souls

	## morse_flash test for part B
	# addi $a0, $zero, 0x42   # dot dot dash dot
	# jal morse_flash
	
	## morse_flash test for part B
	# addi $a0, $zero, 0x37   # dash dash dash
	# jal morse_flash
		
	## morse_flash test for part B
	# addi $a0, $zero, 0x32  	# dot dash dot
	# jal morse_flash
			
	## morse_flash test for part B
	# addi $a0, $zero, 0x11   # dash
	# jal morse_flash	
	
	# flash_message test for part C
	# la $a0, test_buffer
	# jal flash_message
	
	# letter_to_code test for part D
	# the letter 'P' is properly encoded as 0x46.
	# addi $a0, $zero, 'P'
	# jal letter_to_code
	
	# letter_to_code test for part D
	# the letter 'A' is properly encoded as 0x21
	# addi $a0, $zero, 'A'
	# jal letter_to_code
	
	# letter_to_code test for part D
	# the space' is properly encoded as 0xff
	# addi $a0, $zero, ' '
	# jal letter_to_code
	
	# encode_message test for part E
	# The outcome of the procedure is here
	# immediately used by flash_message
	la $a0, message10
	la $a1, buffer01
	jal encode_message
	la $a0, buffer01
	jal flash_message
	
	
	# Proper exit from the program.
	addi $v0, $zero, 10
	syscall

	
	
###########
# PROCEDURE
save_our_souls:

	addi $sp, $sp, -24
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_long
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	jal delay_long
	jal seven_segment_on
	jal delay_short
	jal seven_segment_off
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	addi $sp, $sp, 24
	
	jr $31
	


morse_helper:

	beq $a1, $zero, morse_flash_over	#if the byte is zero, we stop flashing the message
						
	addi $a1, $a1, -1			#subtract one from a1 which is the counter of how many flashes there are left
	and $t4, $t3, $a2			#put together the counter, and the 
	sll $a2, $a2, 1
	beq $t4, $zero, dot
	beq $zero, $zero, dash
	
	jr $ra
	
dot:

	jal seven_segment_on		#turn all segments on
	jal delay_short			#short delay for dot
	jal seven_segment_off		#turn segments off
	jal delay_long			#long delay until next morse
	beq $zero, $zero, morse_helper	#return to morse_helper
	
dash: 
	jal seven_segment_on		#turn all segments on
	jal delay_long			#long delay for dash
	jal seven_segment_off		#turn segments off
	jal delay_long			#long delay until next morse
	beq $zero, $zero, morse_helper	#return to morse_helper
	
space:
	jal seven_segment_off		#turn all segments off
	jal delay_long			#long delay
	jal delay_long			#long delay
	jal delay_long			#long delay
	jr $s1
	
# PROCEDURE
morse_flash:
	beq $a0, 0xffffffff, space	#just a precaution, should never happen
	beq $a0, 0xff, space		#if the read character is a space, go to space
	addi $t5, $zero, 0xf		#t5 holds a temporary mask to find the right four bits of morse code
	addi $t6, $zero, 0xf0		#t6 holds a temporary mask to find the left four bits of morse code
	and $a1, $t6, $a0		#contains left four bits corresponding to length
	and $a2, $t5, $a0		#containts right four bits corresponding to dots or dashes
	beq $a1, $zero, morse_flash_over#if character is zero, then we have reached the end
	srl $a1, $a1, 4			#shift the left four bits to the right by 4 so they become a number to act as a counter
	add $s1, $zero, $ra		#rather than stack, we can just store the return address in #s1
	addi $a1, $a1, -1		#subtract one from counter to shift the mask t3 so that we don't start reading from right most bit
	addi $t3, $zero, 1		#make a mask with 1 and least significant bit
	sllv $t3, $t3, $a1		#shift this by counter - 1 to get to start of dots and dashes
	addi $a1, $a1, 1		#add back the 1 to the counter
	jal morse_helper
	
	
	
	jr $s1

morse_flash_over:
	jal delay_long			#after each letter, there will be a delay plus add this delay to distinguish between letters
	jr $s1


flash_message_helper:
	lb $t8, 0($s3)				#load the first byte of data into t8
	addi $s3, $s3, 1			#move the address s3 to reference the next piece of data
	add $a0, $zero, $t8			#add into a0, (the input argument of morse_flash) the character
	beq $a0, $zero, flash_message_over	#if a0 is zero, then we finish flashing the message
	jal morse_flash				#else, flash the morse code
	add $t8, $zero, $zero			#clear the temporary register with the morse code
	beq $zero, $zero, flash_message_helper	#repeat flash_message_helper
	
	
	
	
###########
# PROCEDURE
flash_message:
	add $s3, $zero, $a0			#load the address given in a0 into s3 as a0 will be overwritten
	add $s2, $zero, $ra			#add the return address into s2
	beq $zero, $zero, flash_message_helper	#go to flash_message_helper now that things are set up
	
	jr $s2

flash_message_over:
	jr $s2
	
	
letter_to_code_helper:
	
	addi $s5, $s5, 8			#add 8 to the address stored in s5 to go to next character
	lb $t7, 0($s5)				#add what is at s5's location to t7
	beq $t7, $a0, letter_to_code_equal	#if what is in t7 is the same as a0 go to letter_to_code_equal
	beq $zero, $zero letter_to_code_helper	#otherwise, repeat this letter_to_code_helper procedure
	

###########
# PROCEDURE
letter_to_code:
	la $s5, codes				#load the address of letter codes into s5
	addi $s5, $s5, -8			#subtract 8 from the address so that we can add 8 each time we enter "letter_to_code_helper"
	add $t9, $zero, $ra			#add the return address into t9
	addi $v0, $zero, 0			#clear v0
	addi $s4, $zero, 0			#clear s4
	beq $a0, ' ', letter_to_code_space	#if character is a space, go to letter_to_code_space
	beq $zero, $zero, letter_to_code_helper	#go to letter_to_code_helper
	
	

	jr $t9	
letter_to_code_equal:				#if character is equal to a character in "codes"
	addi $s5, $s5, 1			#add 1 to the address to get the first dot, dash, or 0
	lb $s6, 0($s5)				#load the first symbol into s6
	beq $zero, $s6, letter_to_code_over	#if the symbol is zero, go to letter_to_code_over
	add $t1, $zero, '.'			#add the value of '.' into register t1
	add $t2, $zero, '-'			#add the value of '-' into register t2
	beq $s6, $t1, letter_to_code_dot	#if the value matches '.', go to letter_to_code_dot
	beq $s6, $t2, letter_to_code_dash	#if the value matches '-', go to letter_to_code_dash
	
	beq $zero, $zero, letter_to_code_equal 	#go back to letter_to_code_equal to code next symbol

letter_to_code_dot:
	sll $s4, $s4, 1				#shift bits in s4 left by one to place latest value in least significant position
	addi $s4, $s4, 0			#add a zero on left most bit to represent a dot
	addi $v0, $v0, 16			#add 16 to v0, as this is essentially a "1" in the left-most four bits in a byte
	beq $zero, $zero, letter_to_code_equal	#go back to letter_to_code_equal
	
letter_to_code_dash:
	sll $s4, $s4, 1				#shift left s4 by 1 to allow space for new right-most-bit
	addi $s4, $s4, 1			#add one to right-most-bit to represent a dash 
	addi $v0, $v0, 16			#add 16 to v0, or essentiall 1 to the left-most four bits
	beq $zero, $zero, letter_to_code_equal	#go back to letter_to_code_equal
	
letter_to_code_space:
	addi $v0, $zero, 0xff			#set v0 to 0xff if space
	add $a3, $zero, $v0			#copy what is in v0 to a3
	jr $t9
	
letter_to_code_over:
	or $v0, $v0, $s4			#or v0, and s4 to get 8 bits where left four are length, right four are dash or dot
	add $a3, $zero, $v0			#add v0 into a3 for safety
	jr $t9


encode_message_helper:
	lb $t0, 0($t3)					#load the first character into t0
	addi $t3, $t3, 1				#add one to the address to look at next character in following iteration
	beq $t0, $zero, encode_message_over		#if zero, we have reached the end of message, go to over
	add $a0, $zero, $t0				#add into a0, the character. a0 is the input register for letter_to_code
	jal letter_to_code				#call letter_to_code
	sb $a3, 0($a1)					#store what is returned from letter_to_code into buffer
	addi $a1, $a1, 1				#add 1 to address of buffer for next character
	beq $zero, $zero, encode_message_helper		#go to encode_message_helper again for next character
	jr $ra
	
	
###########
# PROCEDURE
encode_message:
	add $s0, $zero, $ra				#store return address in s0
	add $t3, $zero, $a0 				#add a0 into t3, this is the address of the message
	beq $zero, $zero, encode_message_helper		#go to encode_message_helper
	
encode_message_over:			
	sb $t0, 0($a1)					#store the final 0x00 into a1 to terminate the message
	jr $s0
	

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# STUDENTS MAY MODIFY CODE ABOVE

#############################################
# DO NOT MODIFY ANY OF THE CODE / LINES BELOW

###########
# PROCEDURE
seven_segment_on:
	la $t1, 0xffff0010     # location of bits for right digit
	addi $t2, $zero, 0xff  # All bits in byte are set, turning on all segments
	sb $t2, 0($t1)         # "Make it so!"
	jr $31


###########
# PROCEDURE
seven_segment_off:
	la $t1, 0xffff0010	# location of bits for right digit
	sb $zero, 0($t1)	# All bits in byte are unset, turning off all segments
	jr $31			# "Make it so!"
	

###########
# PROCEDURE
delay_long:
	add $sp, $sp, -4	# Reserve 
	sw $a0, 0($sp)
	addi $a0, $zero, 600
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31

	
###########
# PROCEDURE			
delay_short:
	add $sp, $sp, -4
	sw $a0, 0($sp)
	addi $a0, $zero, 200
	addi $v0, $zero, 32
	syscall
	lw $a0, 0($sp)
	add $sp, $sp, 4
	jr $31




#############
# DATA MEMORY
.data
codes:
	.byte 'A', '.', '-', 0, 0, 0, 0, 0
	.byte 'B', '-', '.', '.', '.', 0, 0, 0
	.byte 'C', '-', '.', '-', '.', 0, 0, 0
	.byte 'D', '-', '.', '.', 0, 0, 0, 0
	.byte 'E', '.', 0, 0, 0, 0, 0, 0
	.byte 'F', '.', '.', '-', '.', 0, 0, 0
	.byte 'G', '-', '-', '.', 0, 0, 0, 0
	.byte 'H', '.', '.', '.', '.', 0, 0, 0
	.byte 'I', '.', '.', 0, 0, 0, 0, 0
	.byte 'J', '.', '-', '-', '-', 0, 0, 0
	.byte 'K', '-', '.', '-', 0, 0, 0, 0
	.byte 'L', '.', '-', '.', '.', 0, 0, 0
	.byte 'M', '-', '-', 0, 0, 0, 0, 0
	.byte 'N', '-', '.', 0, 0, 0, 0, 0
	.byte 'O', '-', '-', '-', 0, 0, 0, 0
	.byte 'P', '.', '-', '-', '.', 0, 0, 0
	.byte 'Q', '-', '-', '.', '-', 0, 0, 0
	.byte 'R', '.', '-', '.', 0, 0, 0, 0
	.byte 'S', '.', '.', '.', 0, 0, 0, 0
	.byte 'T', '-', 0, 0, 0, 0, 0, 0
	.byte 'U', '.', '.', '-', 0, 0, 0, 0
	.byte 'V', '.', '.', '.', '-', 0, 0, 0
	.byte 'W', '.', '-', '-', 0, 0, 0, 0
	.byte 'X', '-', '.', '.', '-', 0, 0, 0
	.byte 'Y', '-', '.', '-', '-', 0, 0, 0
	.byte 'Z', '-', '-', '.', '.', 0, 0, 0
	
message01:	.asciiz "AAA"
message02:	.asciiz "AAAA"
message03:	.asciiz "AAAAA"
message04:	.asciiz "AAAAAA"
message05:	.asciiz "AAAAAAA"
message06:	.asciiz "AAAAAAAA"
message07:	.asciiz "AAAAAAAAA"
message08:	.asciiz "AAAAAAAAAA"
message09:	.asciiz "KNOWING ME KNOWING YOU"
message10:	.asciiz "FERNANDO"

buffer01:	.space 128
buffer02:	.space 128
test_buffer:	.byte 0x30 0x37 0x30 0x21 0x21 0x21 0x21 0x21 0x21 0x00    # This is SOS
