.macro read_int(%x)
	li a7, 5
	ecall
	mv %x, a0
.end_macro

.macro print_int(%x)
	li a7, 1
	mv a0, %x
	ecall
.end_macro

   .macro print_char(%x)
   li a7, 11
   li a0, %x
   ecall
   .end_macro

   .macro newline
   print_char('\n')
   .end_macro
   
 .eqv BASE 0x10040000
 .eqv WHITE 0xFFFFFFFF
 .eqv BLACK 0x00000000
 .eqv BLUE 0x0000ff
 .eqv RED 0xff0000
 .eqv GREEN 0x008000
 .eqv LIGHT_GREEN 0x7fff00
 
 
 .eqv PIXELS 16384
 .eqv LINESIZE 64
 .eqv VERICALSIZE 64
 .eqv DIAGSIZE 256
 .eqv LEFTSHIFT 8
 .eqv HIGHLIGHT_SIZE 19
 
 
# positions
.eqv CROSS_1 512
.eqv CROSS_2 604
.eqv CROSS_3 696
.eqv CROSS_4 6400
.eqv CROSS_5 6492
.eqv CROSS_6 6584
.eqv CROSS_7 12288
.eqv CROSS_8 12380
.eqv CROSS_9  12472
.eqv CROSS_SIZE 14
 
 
 .eqv CIRCLE_1 2340
 .eqv CIRCLE_2 2432
 .eqv CIRCLE_3 2524
 .eqv CIRCLE_4 8228
 .eqv CIRCLE_5 8320
 .eqv CIRCLE_6 8412
 .eqv CIRCLE_7 14116
 .eqv CIRCLE_8 14208
 .eqv CIRCLE_9 14300
 .eqv CIRCLE_RAD 6
 
 .macro swap %x, %y
   xor %x, %x, %y
   xor %y, %x, %y
   xor %x, %x, %y
   .end_macro
   
   .macro inverse %x
   not %x, %x
   addi %x, %x, 1
   .end_macro
 
 .macro SAVE_S_REGISTERS
 addi sp, sp, -48
sw s0, 0(sp)
 sw s1, 4(sp)
  sw s2, 8(sp)
   sw s3, 12(sp)
    sw s4, 16(sp)
     sw s5, 20(sp)
      sw s6, 24(sp)
       sw s7, 28(sp)
	sw s8, 32(sp)
	sw s9, 36(sp)
	sw s10, 40(sp)
	sw s11, 44(sp)
.end_macro

.macro LOAD_S_REGISTERS
lw s0, 0(sp)
 lw s1, 4(sp)
  lw s2, 8(sp)
   lw s3, 12(sp)
    lw s4, 16(sp)
     lw s5, 20(sp)
      lw s6, 24(sp)
       lw s7, 28(sp)
	lw s8, 32(sp)
	lw s9, 36(sp)
	lw s10, 40(sp)
	lw s11, 44(sp)
 	addi sp, sp, 48
 .end_macro
 
 .data 
 array:
 	.space 36
 
 crosses_pos:
 .word 512, 604, 696, 6400,6492,6584,12288,12380,12472
 
 circles_pos:
 .word 2340, 2432, 2524,8228, 8320, 8412, 14116,14208, 14300
 
 highlight_pos:
 .word 4352, 4444, 4536,10496,10588,10680, 15872,15964,16056

  global_cnt:
 .word 0
 
 flag_is_finished:
 .word 0
 
   .text
 

 
main:
 


.eqv IN_CTRL  0xffff0000
.eqv IN       0xffff0004
.eqv OUT_CTRL 0xffff0008
  


jal, ra, white_screen
li a0, 5120
jal, ra, print_horizontal_line
li a0, 11264
jal, ra, print_horizontal_line

li a0, 76
jal, ra, print_vertical_line

li a0, 168
jal, ra, print_vertical_line
# start pos
  li a0, 4
  li a1, LIGHT_GREEN
  jal, ra, highlighter
  
  li a0, 4
  mv s5, a0
  li s4, 9

  li   s0, IN_CTRL
  li   s1, IN
  li   s2, OUT_CTRL

poll_in:




mv a0, s5
  lw   t0, 0(s0)
  beqz t0, poll_in
  lw   t0, 0(s1)
  


poll_out:
la t5, flag_is_finished
lw t5, 0(t5)
bnez t5, restart

  lw   t1, 0(s2)
  li t2 , 'w'
  
  bne t0, t2, a
  addi a0, a0, -3
  bgez a0, done
  addi a0, a0, 3
    j poll_in
  a:
  li t2, 'a'
  bne t0, t2, s
  addi a0, a0, -1
  bgez a0, done
  addi a0, a0, 1
  j poll_in
  s:
  li t2, 's'
  bne t0, t2, d
  addi a0, a0, 3
  blt a0, s4, done
  addi a0, a0, -3
  j poll_in
  d:
  li t2, 'd'
  bne t0, t2, restart
  addi a0, a0, 1
    blt a0, s4, done
   addi a0, a0, -1
    j poll_in
    
    
restart:
li t2, 'r'

bne t0, t2, enter

terminated_restart:
la t4, array
sw zero 0(t4)
sw zero 4(t4)
sw zero 8(t4)
sw zero 12(t4)
sw zero 16(t4)
sw zero 20(t4)
sw zero 24(t4)
sw zero 28(t4)
sw zero 32(t4)

la t4, global_cnt
sw zero, 0(t4)

la t4, flag_is_finished
sw zero, 0(t4)
j main


enter:
li t2, '\n'
bne t0, t2, exit
la t4, global_cnt
lw t4, 0(t4)
li t5, 2
rem t5, t4, t5
bnez t5, circle

jal, ra, go_cross

this_check:


jal, ra, check_winner
la t1, global_cnt
lw t1, 0(t1)
addi t1, t1, -9
or t1, t1, a0
beqz t1, terminated_restart

beqz a0, poll_in
SAVE_S_REGISTERS

li s1, 1
sw t1, flag_is_finished, t1
jal, ra, white_screen

bne a0, s1, finish_circle
li a0, 6492
li a1, CROSS_SIZE
LOAD_S_REGISTERS
jal, ra, print_cross
j poll_in


finish_circle:
li a0, CIRCLE_RAD
li a1, 8320
LOAD_S_REGISTERS
jal, ra, print_circle



j poll_in
circle:

jal, ra, go_circle
    j this_check
  bnez t1, poll_out

  j poll_in
  
   done:
   swap(s5, a0)
   li a1, WHITE
   jal, ra, highlighter
   swap(s5, a0)
   mv s5, a0
   li a1, LIGHT_GREEN
   jal, ra, highlighter
   
  j poll_in
  
  
  exit:
	li t2, 'Q'
	bne t0, t2, poll_in
	li a7, 10
	ecall
 
print_cross:
	SAVE_S_REGISTERS
	addi sp, sp, -4
	sw ra, 0(sp)
	jal, ra, print_right_diag
	addi a0, a0, 64
	jal, ra, print_left_diag
	
	lw, ra, 0(sp)
	addi sp, sp, 4
	LOAD_S_REGISTERS
	jalr, x0, 0(ra)
  

print_vertical_line:
	SAVE_S_REGISTERS
	mv s1, a0
	li s0, BASE
	add s1, s0, s1
	li t0, VERICALSIZE
	mv t1, zero
	li t2, BLACK
	while_ver_line:
		beq t0, t1, end_ver_line
		sw t2, 0(s1)
		sw t2, 4(s1)
		sw t2, 8(s1)
		sw t2, 12(s1)
		addi s1, s1, 256
		addi t1, t1, 1
		j while_ver_line
	end_ver_line:
	LOAD_S_REGISTERS
	jalr x0, 0(ra)
 
   
  # 1024 - base + 256 * line  
print_horizontal_line: 
SAVE_S_REGISTERS 
  mv s1, a0
  li s0, BASE
 add s1, s0, s1
 li t0, LINESIZE
 mv t1, zero
 li t2, BLACK
 while_line:
	 beq t0, t1, end_line
	 sw t2, 0(s1)
	 sw t2, 256(s1)
	 sw t2, -256(s1)
	 sw t2, 512(s1)
	 	 
	 addi s1, s1, 4 
	 
	addi t1, t1, 1
	j while_line
		 
end_line:
LOAD_S_REGISTERS
jalr x0, 0(ra)

white_screen:
	SAVE_S_REGISTERS
	 li s0, BASE
	 li t0, PIXELS
	 li t2, WHITE
	 mv s1, s0
	 mv t1, zero
	 while:
		 beq t1, t0, end_while
		 sw t2, 0(s1)
		 addi s1, s1, 4
		 addi t1, t1, 1
		 j while
	 end_while:
	 LOAD_S_REGISTERS
	 jalr x0, 0(ra)
	 
print_right_diag:
	SAVE_S_REGISTERS
	li s0, BASE
	mv t0, a1
	mv t1, zero
	li t2, BLUE
	add s1, s0, a0
	while_right_diag:
		beq t1, t0,end_right_diag
		sw t2, 0(s1)
		sw t2, 4(s1)
	 	sw t2, 8(s1)
		addi s1, s1,DIAGSIZE
		addi s1, s1, 4
		addi t1, t1, 1
		j while_right_diag
	end_right_diag:
	LOAD_S_REGISTERS
	jalr x0, 0(ra)
	
print_left_diag:
	SAVE_S_REGISTERS
	li s0, BASE
	mv t0, a1
	mv t1, zero
	li t2, BLUE
	add s1, a0, s0
	while_left_diag:
		beq t1, t0, end_left_diag
		sw t2, 0(s1)
		sw t2, -4(s1)
		sw t2, -8(s1)
		addi s1, s1, DIAGSIZE
		addi s1, s1, -4
		addi t1, t1, 1
		j while_left_diag
	end_left_diag:
	LOAD_S_REGISTERS
	jalr x0, 0(ra)
	
print_circle:
	SAVE_S_REGISTERS
	# в a0 - радиус
	# в a1 - start(x)

	
	 # s2 start + r
	 # t0, t1 = staert - r
	 
	li s0, BASE
	mv t2, a0
	#slli t2, t2, 2
	sub t0, a1, t2
	add s2, a1, t2
	
	li t5, RED
	#add s1, a0, s0
	mv t1, t0
	#s3 = r^2
	mul s3, t2, t2
	next_t0:
		bgt t0, s2, end_for_t0
	next_t1:
		bgt t1, s2, end_for_t1
		# t3 = ( i -start) (x)
		# t4 = (j - start)(y)
		sub t3, t0, a1
		sub t4, t1, a1
		
		mul t3, t3, t3
		mul t4, t4, t4
		add t3,t3, t4
		
		bgt t3, s3, else
		# delta = (t0 - start) + (t1 - start) * size
		# pos = start - delta
		sub t3, t0, a1
		sub t4, t1, a1
		
		slli t3, t3, 2
		slli t4,t4 LEFTSHIFT
		add t3, t3, t4
		add s1, a1, s0
		add s1, s1, t3
		
		sw t5, 0(s1)
		else:
		addi t1, t1, 1
		j next_t1
		end_for_t1:
		addi t0, t0, 1
		sub t1, a1, t2
		
		j next_t0
	end_for_t0:
	LOAD_S_REGISTERS
	jalr x0, 0(ra)
# a0 - индекс
go_cross:
	SAVE_S_REGISTERS
	mv t0, a0
	la t1, array
	#li t2, 9
	#bltz t0, go_cross
	#bgt t0, t2, go_cross
	slli t0, t0, 2
	add t1, t1, t0
	lw t3, 0(t1)
	beqz t3, ok_cross
	j poll_in
	
	ok_cross:
	li t2, 1
	sw t2, 0(t1)
	
	la t4, global_cnt
	lw  t5, 0(t4)
	addi t5, t5, 1
	sw t5, 0(t4)
	
	la t3, crosses_pos
	add t3, t3, t0
	lw t1, 0(t3)
	
	mv a0, t1
	li a1, CROSS_SIZE
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal, ra, print_cross
	lw, ra, 0(sp)
	addi sp, sp, 4
	LOAD_S_REGISTERS
	jalr, x0, 0(ra)
	
go_circle:
	SAVE_S_REGISTERS
	mv t0, a0
	la t1, array
	#li t2, 9
	#bltz t0, go_circle
	#bgt t0, t2, go_circle
	slli t0, t0, 2
	add t1, t1, t0
	lw t3, 0(t1)
	bnez t3, poll_in
	li t2, -1
	sw t2, 0(t1)
	
	la t4, global_cnt
	lw  t5, 0(t4)
	addi t5, t5, 1
	sw t5, 0(t4)
	
	la t3, circles_pos
	add t3, t3, t0
	lw t1, 0(t3)
	
	mv a1, t1
	li a0, CIRCLE_RAD
	addi sp, sp, -4
	sw ra, 0(sp)
	
	jal, ra, print_circle
	lw, ra, 0(sp)
	addi sp, sp, 4
	LOAD_S_REGISTERS
	jalr, x0, 0(ra)
	
highlighter:
SAVE_S_REGISTERS
# a0 - index
# a1 - color
# a2 - flag

mv a2, zero

li t5, 3
rem t5, a0, t5
addi t5, t5, -2

bnez t5, not_flag
li a2, 1
    
not_flag:
la t4, highlight_pos
slli a0, a0, 2
add t4, t4, a0
lw a0, 0(t4)


mv s1, a0
 li s0, BASE
 add s1, s0, s1
 li t0, HIGHLIGHT_SIZE
 beqz a2, continue
 addi t0, t0, -1
 continue:
 mv t1, zero
 mv t2, a1
 
 while_high:
 beq t0, t1, end_high
  sw t2, 0(s1)
  sw t2, 256(s1)	 	 
  addi s1, s1, 4 	 
  addi t1, t1, 1
  j while_high
 
 
 end_high:
 LOAD_S_REGISTERS
 jalr, x0,0(ra)
# a0 - start pos
# a1 - color

check_winner:
	SAVE_S_REGISTERS
	
	li t4, 3
	la t1, array
	lw t2, 0(t1)
	lw t3, 4(t1)
	add t2, t2, t3
	lw t3, 8(t1)
	add t2, t2, t3
	
	beq t2, t4, return_cross
	inverse t4
	beq t2, t4, return_circle
	inverse t4
	
	lw t2, 12(t1)
	lw t3, 16(t1)
	add t2, t2, t3
	lw t3, 20(t1)
	add t2, t2, t3
	
	beq t2, t4, return_cross
	inverse t4
	beq t2, t4, return_circle
	inverse t4
	
	
	lw t2, 24(t1)
	lw t3, 28(t1)
	add t2, t2, t3
	lw t3, 32(t1)
	add t2, t2, t3
	
	beq t2, t4, return_cross
	inverse t4
	beq t2, t4, return_circle
	inverse t4
	
	lw t2, 0(t1)
	lw t3, 16(t1)
	add t2, t2, t3
	lw t3, 32(t1)
	add t2, t2, t3
	
	beq t2, t4, return_cross
	inverse t4
	beq t2, t4, return_circle
	inverse t4
	
	lw t2, 8(t1)
	lw t3, 16(t1)
	add t2, t2, t3
	lw t3, 24(t1)
	add t2, t2, t3
	
	beq t2, t4, return_cross
	inverse t4
	beq t2, t4, return_circle
	inverse t4
	
	lw t2, 0(t1)
	lw t3, 12(t1)
	add t2, t2, t3
	lw t3, 24(t1)
	add t2, t2, t3
	
	beq t2, t4, return_cross
	inverse t4
	beq t2, t4, return_circle
	inverse t4
	
	
	lw t2, 4(t1)
	lw t3, 16(t1)
	add t2, t2, t3
	lw t3, 28(t1)
	add t2, t2, t3
	
	beq t2, t4, return_cross
	inverse t4
	beq t2, t4, return_circle
	inverse t4
	
	lw t2, 8(t1)
	lw t3, 20(t1)
	add t2, t2, t3
	lw t3, 32(t1)
	add t2, t2, t3
	
	beq t2, t4, return_cross
	inverse t4
	beq t2, t4, return_circle
	inverse t4
	
	
	
	li a0, 0
	LOAD_S_REGISTERS
	jalr, x0, 0(ra)
	
	return_cross:
	li a0, 1
	LOAD_S_REGISTERS
	jalr, x0, 0(ra)
	
	
	return_circle:
	li a0, -1
	LOAD_S_REGISTERS
	jalr, x0, 0(ra)


	
 
 
 
 
