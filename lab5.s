jal main
#                         CS 240, Lab #5
#
#      IMPORTANT NOTES:
#
#      Write your assembly code only in the marked blocks.
#
#      DO NOT change anything outside the marked blocks.
#
#      Remember to fill in your name, Red ID in the designated fields.
#
#
#      
###############################################################
#                           Data Section
.data
student_name: .asciiz "Dean Kajosevic"
student_id: .asciiz "130790098"

identity_m: .word 1, 0, 0, 0, 1, 0
scale_m:    .word 2, 0, 0, 0, 1, 0
rotation_m: .word 0, 1, 0, 1, 0, 0
shear_m:    .word 1, 1, 0, 0, 1, 0

input_1: .byte 100, 60, 81, 2
input_2: .byte 10, 20, 30, 110, 127, 130, 210, 220, 230
input_3: .byte 0, 10, 20, 30, 40, 110, 128, 130, 140, 210, 220, 230, 240, 250, 255, 55
output_1: .space 4
output_2: .space 9
output_3: .space 16
input_4: .byte 1, 2, 3, 4, 5,1, 2, 3, 4, 5,1, 2, 3, 4, 5,1, 2, 3, 4, 5,1, 2, 3, 4, 5
input_5: .byte 210, 220, 230,10, 20, 30, 110, 127, 130, 55 , 140, 210, 220, 230, 240, 2, 3, 4, 5,10
input_6: .byte 10, 20, 30, 40, 110, 128, 130, 140, 210, 220, 230, 240, 250, 255, 55, 230, 240, 250, 255, 55,230, 240, 250, 255, 55
output_4: .space 25
output_5: .space 25
output_6: .space 25

# Part 1 tests data
# thresh value = 128
test_11_expected_output: .byte 0, 0, 0, 0
test_12_expected_output: .byte 0, 0, 0, 0, 0, 255, 255, 255, 255
test_13_expected_output: .byte 0, 0, 0, 0, 0, 0, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0

# Part 2 tests data
# identity and rotation on input 2
test_221_expected_output: .byte 10, 20, 30, 110, 127, 130, 210, 220, 230
test_222_expected_output: .byte 10, 110, 210, 20, 127, 220, 30, 130, 230
# identity, scale, rotation, and shear on input 3
test_231_expected_output: .byte 0, 10, 20, 30, 40, 110, 128, 130, 140, 210, 220, 230, 240, 250, 255, 55
test_232_expected_output: .byte 0, 20, 0, 0, 40, 128, 0, 0, 140, 220, 0, 0, 240, 255, 0, 0
test_233_expected_output: .byte 0, 40, 140, 240, 10, 110, 210, 250, 20, 128, 220, 255, 30, 130, 230, 55
test_234_expected_output: .byte 0, 10, 20, 30, 110, 128, 130, 0, 220, 230, 0, 0, 55, 0, 0, 0

# Part 3 tests data 
test_31_expected_output: .byte 4 3 1 5 2 4 3 1 5 2 4 3 1 5 2 4 3 1 5 2 4 3 1 5 2 
test_32_expected_output: .byte 10 230 210 20 220 130 127 30 55 110 230 220 140 240 210 5 4 2 10 3 40 30 10 110 20
test_33_expected_output: .byte 40 30 10 110 20 210 140 128 220 130 255 250 230 55 240 255 250 230 55 240 255 250 230 55 240

# Messages
new_line: .asciiz "\n"
space: .asciiz " "
i_str: .asciiz  "Program input:   " 
po_str: .asciiz "Program output:  " 
eo_str: .asciiz "Expected output: " 
t1_str: .asciiz "Testing part 1: \n" 
t2_str_0: .asciiz "Testing part 2 (identity): \n" 
t2_str_1: .asciiz "Testing part 2 (scale): \n" 
t2_str_2: .asciiz "Testing part 2 (rotation): \n" 
t2_str_3: .asciiz "Testing part 2 (shear): \n" 
t3_str: .asciiz "Testing part 3 (Cryptography): \n" 

line: .asciiz "__________________________________________________\n" 

# Files
fin: .asciiz "lenna.pgm"
fout_thresh: .asciiz "lenna_thresh.pgm"
fout_rotate: .asciiz "lenna_rotation.pgm"
fout_shear: .asciiz "lenna_shear.pgm"
fout_scale: .asciiz "lenna_scale.pgm"

fin2: .asciiz "textfile.pgm"
fout_crypt: .asciiz "text_crypt.pgm"

# Input/output buffers
.align 2
in_buffer: .space 400000
in_buffer_end:
.align 2
out_buffer: .space 400000
out_buffer_end:

###############################################################
#                           Text Section
.text
# Utility function to print byte arrays
#a0: array
#a1: length
print_array:
li $t1, 0
move $t2, $a0
print:
lb $a0, ($t2)
andi $a0, $a0, 0xff
li $v0, 1   
syscall
li $v0, 4
la $a0, space
syscall
addi $t2, $t2, 1
addi $t1, $t1, 1
blt $t1, $a1, print
jr $ra
########################################################################################
#a0 = input array
#a1 = output array
#a2 = matrix
#s3 = input dim
#s4 = test str
#s5 = expected array
# Test transform function
########################################################################################
test_p2:
# save ra
addi $sp, $sp, -4
sw $ra, 0($sp)

addi $sp, $sp, -4
sw $a0, 0($sp)
addi $sp, $sp, -4
sw $a1, 0($sp)
addi $sp, $sp, -4
sw $a2, 0($sp)
addi $sp, $sp, -4
sw $a3, 0($sp)
addi $sp, $sp, -4
sw $s4, 0($sp)
addi $sp, $sp, -4
sw $s5, 0($sp)


#a0: input buffer address
#a1: output buffer address
#a2: transform matrix address
#a3: image dimension  (Image will be square sized, i.e. total size = a3*a3)
jal transform 

lw $s5, 0($sp)    
addi $sp, $sp, 4
lw $s4, 0($sp)
addi $sp, $sp, 4
lw $s3, 0($sp)
addi $sp, $sp, 4
lw $s2, 0($sp)
addi $sp, $sp, 4
lw $s1, 0($sp)
addi $sp, $sp, 4
lw $s0, 0($sp)
addi $sp, $sp, 4

# s5: exp arraay
# s4: input string
# s3: input dimenstion
# s2: matrix
# s1: user out
# s0: inputd

mul $s3, $s3, $s3

move $a0, $s4
syscall
la $a0, i_str
syscall
move $a0, $s0
move $a1, $s3
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
move $a0, $s1
move $a1, $s3
jal print_array
li $v0, 4
la $a0, new_line
syscall
la $a0, eo_str
syscall
move $a0, $s5
move $a1, $s3
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

# restore ra
lw $ra, 0($sp)
addi $sp, $sp, 4

jr $ra
###############################################################
###############################################################
#                       PART 1 (Image Thresholding)
#a0: input buffer address
#a1: output buffer address
#a2: image dimension (Image will be square sized, i.e., number of pixels = a2*a2)
#a3: threshold value 
###############################################################
.globl threshold
threshold:
############################## Part 1: your code begins here ###
mul $t9, $a2, $a2 #t9 has every pixel of the image
loop1:
lbu $t0, 0($a0) #load color value
bge $t0, $a3, isGreaterEqual #if color value is greater than threshhold, branch
li $t0, 0 
sb $t0, 0($a1) #else, set output bit to 0
j endLoop1
isGreaterEqual:
li $t0, 255
sb $t0, 0($a1) #if statement was taken, so set ouput value to 255

endLoop1:
addi $a0, $a0, 1 #increment selected pixel from input image
addi $a1, $a1, 1 #increment selected pixel from output image
addi $t9, $t9, -1 #decrement the amount of pixels left to iterate through
bnez $t9, loop1 # branch if every pixel was not modified 

		
############################### Part 1: your code ends here ###
jr $ra
###############################################################
###############################################################
#                           PART 2 (Matrix Transform)
#a0: input buffer address
#a1: output buffer address
#a2: transform matrix address
#a3: image dimension  (Image will be square sized, i.e., number of pixels = a3*a3)
###############################################################
.globl transform
transform:
############################### Part 2: your code begins here ##
li $t8, 0 #load number of colomns count
li $t9, 0 #load number of rows count

loopCol: #for loop for columns
loopRow: #nested for loop for rows
lw $t0, 0($a2) #load M00
lw $t1, 4($a2) #load M01
lw $t2, 8($a2) #load M02

mul $t3, $t0, $t8 #M00 * x
mul $t4, $t1, $t9 #M01 * y
add $t5, $t3, $t4 #x0 = M00 * x + M01 * y
add $t5, $t5, $t2 #x0 += M02

lw $t0, 12($a2) #load M10
lw $t1, 16($a2) #load M11
lw $t2, 20($a2) #load M12

mul $t3, $t0, $t8 #M10 * x
mul $t4, $t1, $t9 #M11 * y
add $t6, $t3, $t4 #y0 = M10 * x + M11 * y
add $t6, $t6, $t2 #y0 += M12

#checking to see if the coordinates lay within the picture
blt $t5, $a3, check1
j invalid
check1:
bge $t5, $zero, check2
j invalid
check2:
blt $t6, $a3, check3
j invalid
check3:
bge $t6, $zero, valid

invalid: 
li $t4, 0
sb $t4, 0($a1) #store byte with 0 if invalid pixel
j finishRow

valid:
mul $t7, $t6, $a3 # offset = y0 * a3
add $t7, $t7, $t5 # offset += x0
add $t7, $t7, $a0 # addr = offset + a0
lbu $t4, 0($t7) 
sb $t4, 0($a1)


finishRow:
addi $a1, $a1, 1 #increment input pixel
addi $t8, $t8, 1 #increment number of rows left
blt $t8, $a3, loopRow #loop row until every row is checked


li $t8, 0 #reset row counter after entire row is checked, for next column
addi $t9, $t9, 1 #increment column
blt $t9, $a3, loopCol #loops to new column if all columns have not been checked
############################### Part 2: your code ends here  ##
jr $ra
###############################################################
###############################################################
#                       PART 3 (Image Cryptography)
#a0: input buffer address
#a1: output buffer address
#a2: image dimension (Image will be square sized, i.e., number of pixels = a2*a2)
###############################################################
.globl cryptography
cryptography:
############################## Part 3: your code begins here ###
li $t8, 0 #col count
li $t9, 0 #row count

loopCol2:
loopRow2:
lbu $t0, 3($a0) #load 4th pixel
lbu $t1, 2($a0) #load 3rd pixel
lbu $t2, 0($a0) #load 1st pixel
lbu $t3, 4($a0) #load 5th pixel
lbu $t4, 1($a0) #load 2nd pixel

#storing the pixels in order to output
sb $t0, 0($a1)
sb $t1, 1($a1)
sb $t2, 2($a1)
sb $t3, 3($a1)
sb $t4, 4($a1)

addi $t9, $t9, 5 #increment x value
addi $a0, $a0, 5 #increment input by 5 because we use offset of up to 5
addi $a1, $a1, 5 #increment output by 5 because we use offset of up to 5
blt $t9, $a2 loopRow2

li $t9, 0 #reset x value
addi $t8, $t8, 1 #increment y value
blt $t8, $a2, loopCol2

		
############################### Part 3: your code ends here ###
jr $ra
###############################################################
###############################################################
###############################################################
#                          Main Function
main:

.text

li $v0, 4
la $a0, student_name
syscall
la $a0, new_line
syscall  
la $a0, student_id
syscall 
la $a0, new_line
syscall


# Test threshold function
li $v0, 4
la $a0, t1_str
syscall

la $a0, input_1
la $a1, output_1
li $a2, 2
li $a3, 128
jal threshold

la $a0, i_str
syscall
la $a0, input_1
li $a1, 4
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_1
li $a1, 4
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_11_expected_output
li $a1, 4
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

la $a0, input_2
la $a1, output_2
li $a2, 3
li $a3, 128
jal threshold

la $a0, i_str
syscall
la $a0, input_2
li $a1, 9
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_2
li $a1, 9
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_12_expected_output
li $a1, 9
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

la $a0, input_3
la $a1, output_3
li $a2, 4
li $a3, 128
jal threshold

la $a0, i_str
syscall
la $a0, input_3
li $a1, 16
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_3
li $a1, 16
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_13_expected_output
li $a1, 16
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

# Part 2 testing
#a0 = input array
#a1 = output array
#a2 = matrix
#s3 = input dim
#s4 = test str
#s5 = expected array

la $a0, input_2
la $a1, output_2
la $a2, identity_m
li $a3, 3 # dim
la $s4, t2_str_0
la $s5, test_221_expected_output
jal test_p2

la $a0, input_2
la $a1, output_2
la $a2, rotation_m
li $a3, 3 # dim
la $s4, t2_str_2
la $s5, test_222_expected_output
jal test_p2

########
la $a0, input_3
la $a1, output_3
la $a2, identity_m
li $a3, 4 # dim
la $s4, t2_str_0
la $s5, test_231_expected_output
jal test_p2

la $a0, input_3
la $a1, output_3
la $a2, scale_m
li $a3, 4 # dim
la $s4, t2_str_1
la $s5, test_232_expected_output
jal test_p2

la $a0, input_3
la $a1, output_3
la $a2, rotation_m
li $a3, 4 # dim
la $s4, t2_str_2
la $s5, test_233_expected_output
jal test_p2

la $a0, input_3
la $a1, output_3
la $a2, shear_m
li $a3, 4 # dim
la $s4, t2_str_3
la $s5, test_234_expected_output
jal test_p2


#Test Part 3
li $v0, 4
la $a0, t3_str
syscall

la $a0, input_4
la $a1, output_4
li $a2, 5
li $a3, 128
jal cryptography

la $a0, i_str
syscall
la $a0, input_4
li $a1, 25
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_4
li $a1, 25
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_31_expected_output
li $a1, 25
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

la $a0, input_5
la $a1, output_5
li $a2, 5
li $a3, 128
jal cryptography

la $a0, i_str
syscall
la $a0, input_5
li $a1, 25
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_5
li $a1, 25
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_32_expected_output
li $a1, 25
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall

la $a0, input_6
la $a1, output_6
li $a2, 5
li $a3, 128
jal cryptography

la $a0, i_str
syscall
la $a0, input_6
li $a1, 25
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, po_str
syscall
la $a0, output_6
li $a1, 25
jal print_array
li $v0, 4
la $a0, new_line
syscall

la $a0, eo_str
syscall
la $a0, test_33_expected_output
li $a1, 25
jal print_array
li $v0, 4
la $a0, new_line
syscall
syscall


#### Test on images
#open the file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, in_buffer   # address of buffer to which to read
la   $a2, in_buffer_end     # hardcoded buffer length
sub $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall

## Copy the header
la $t0, in_buffer
la $t1, out_buffer
lw $t2, ($t0)
sw $t2, ($t1)
lw $t2, 4($t0)
sw $t2, 4($t1)
lw $t2, 8($t0)
sw $t2, 8($t1)
lw $t2, 12($t0)
sw $t2, 12($t1)

# Threshold
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
li $a2, 512
li $a3, 80
jal threshold 


#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fout_thresh      # board file name
li   $a1, 1        # Open for writing
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor
# write back
li   $v0, 15       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, out_buffer   # address of buffer to which to read
la   $a2, out_buffer_end     # hardcoded buffer length
subu $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall    

###################################
#### Test on images for cryptography
#open the file for writing
li   $v0, 13       # system call for open file
la   $a0, fin2      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, in_buffer   # address of buffer to which to read
la   $a2, in_buffer_end     # hardcoded buffer length
sub $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall

## Copy the header
la $t0, in_buffer
la $t1, out_buffer
lw $t2, ($t0)
sw $t2, ($t1)
lw $t2, 4($t0)
sw $t2, 4($t1)
lw $t2, 8($t0)
sw $t2, 8($t1)
lw $t2, 12($t0)
sw $t2, 12($t1)

# Threshold
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
li $a2, 500
li $a3, 80
jal cryptography 


#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fout_crypt      # board file name
li   $a1, 1        # Open for writing
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor
# write back
li   $v0, 15       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, out_buffer   # address of buffer to which to read
la   $a2, out_buffer_end     # hardcoded buffer length
subu $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall    

###################################



#open the file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, in_buffer   # address of buffer to which to read
la   $a2, in_buffer_end     # hardcoded buffer length
sub $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall



## Copy the header
la $t0, in_buffer
la $t1, out_buffer
lw $t2, ($t0)
sw $t2, ($t1)
lw $t2, 4($t0)
sw $t2, 4($t1)
lw $t2, 8($t0)
sw $t2, 8($t1)
lw $t2, 12($t0)
sw $t2, 12($t1)

# Rotate
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
la $a2, rotation_m
li $a3, 512
jal transform 


#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fout_rotate      # board file name
li   $a1, 1        # Open for writing
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor
# write back
li   $v0, 15       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, out_buffer   # address of buffer to which to read
la   $a2, out_buffer_end     # hardcoded buffer length
subu $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall



#open the file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, in_buffer   # address of buffer to which to read
la   $a2, in_buffer_end     # hardcoded buffer length
sub $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall



## Copy the header
la $t0, in_buffer
la $t1, out_buffer
lw $t2, ($t0)
sw $t2, ($t1)
lw $t2, 4($t0)
sw $t2, 4($t1)
lw $t2, 8($t0)
sw $t2, 8($t1)
lw $t2, 12($t0)
sw $t2, 12($t1)

# Shear
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
la $a2, shear_m
li $a3, 512
jal transform 


#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fout_shear      # board file name
li   $a1, 1        # Open for writing
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor
# write back
li   $v0, 15       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, out_buffer   # address of buffer to which to read
la   $a2, out_buffer_end     # hardcoded buffer length
subu $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall




#open the file for writing
li   $v0, 13       # system call for open file
la   $a0, fin      # board file name
li   $a1, 0        # Open for reading
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor

#read from file
li   $v0, 14       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, in_buffer   # address of buffer to which to read
la   $a2, in_buffer_end     # hardcoded buffer length
sub $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall



## Copy the header
la $t0, in_buffer
la $t1, out_buffer
lw $t2, ($t0)
sw $t2, ($t1)
lw $t2, 4($t0)
sw $t2, 4($t1)
lw $t2, 8($t0)
sw $t2, 8($t1)
lw $t2, 12($t0)
sw $t2, 12($t1)

# scale
la $a0, in_buffer
addi $a0, $a0, 16
la $a1, out_buffer
addi $a1, $a1, 16
la $a2, scale_m
li $a3, 512
jal transform 


#open a file for writing
li   $v0, 13       # system call for open file
la   $a0, fout_scale      # board file name
li   $a1, 1        # Open for writing
li   $a2, 0
syscall            # open a file (file descriptor returned in $v0)
move $s6, $v0      # save the file descriptor
# write back
li   $v0, 15       # system call for read from file
move $a0, $s6      # file descriptor
la   $a1, out_buffer   # address of buffer to which to read
la   $a2, out_buffer_end     # hardcoded buffer length
subu $a2, $a2, $a1
syscall            # read from file

# Close the file
li   $v0, 16       # system call for close file
move $a0, $s6      # file descriptor to close
syscall


_end_program:
# end program
li $v0, 10
syscall
