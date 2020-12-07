	.file	"ass1b_18cs30006.c"
	.text
	.section	.rodata
	.align 8
.LC0:
	.string	"\nGCD of %d, %d, %d and %d is: %d"		# storing string in data
	.text
	.globl	main
	.type	main, @function	    # main function
main:
	endbr64
	pushq	%rbp				# save rbp in stack
	movq	%rsp, %rbp			# rbp=rsp
	subq	$32, %rsp           # stack memory allocation for variable declarations
	movl	$45, -20(%rbp)      # assign a as 45
	movl	$99, -16(%rbp)      # assing b as 99
	movl	$18, -12(%rbp)		# assign c as 18
	movl	$180, -8(%rbp)		# assign d as 180
	movl	-8(%rbp), %ecx      # d as 4th argument (ecx)
	movl	-12(%rbp), %edx		# c as 3rd argument (edx)
	movl	-16(%rbp), %esi		# b as 2nd argument (esi)
	movl	-20(%rbp), %eax		# eax = a
	movl	%eax, %edi			# a as 1st argument (edi)
	call	GCD4				# call gcd4 with 4 arg.
	movl	%eax, -4(%rbp)      # result = eax
	movl	-4(%rbp), %edi		# for print: result as 1st arg.
	movl	-8(%rbp), %esi		# d as 2nd arg.
	movl	-12(%rbp), %ecx		# c as 4th arg.
	movl	-16(%rbp), %edx		# b as 3rd arg.
	movl	-20(%rbp), %eax		# assing eax as a
	movl	%edi, %r9d			# 6th arg. -> result
	movl	%esi, %r8d			# 5th arg. -> d
	movl	%eax, %esi			# 2nd arg. -> a
	leaq	.LC0(%rip), %rdi
	movl	$0, %eax
	call	printf@PLT			# calling print()
	movl	$10, %edi			# edi as "\n" (10 ascii value)
	call	putchar@PLT       	# calling print("\n")
	movl	$0, %eax			# assign eax as 0 to return 0
	leave
	ret        					# return from function main
	.size	main, .-main
	.globl	GCD4
	.type	GCD4, @function
GCD4:
	endbr64
	pushq	%rbp				# save rbp in stack
	movq	%rsp, %rbp			# rbp=rsp
	subq	$32, %rsp			# stack memory assign for variables
	movl	%edi, -20(%rbp)		# assign n1 as a 1st arg.
	movl	%esi, -24(%rbp)		# assign n2 as b 2nd arg.
	movl	%edx, -28(%rbp)		# assign n3 as c 3rd arg.
	movl	%ecx, -32(%rbp)		# assign n4 as d 4th arg.
	movl	-24(%rbp), %edx		# assign edx as n2
	movl	-20(%rbp), %eax		# assign eax as n1
	movl	%edx, %esi			# assign esi (2nd arg.) as edx (n2)
	movl	%eax, %edi			# assign edi (1st arg.) as eax (n1)
	call	GCD 				# call GCD func with 2 arg. (n1 & n2)
	movl	%eax, -12(%rbp)		# assign t1 as return value func. GCD(n1,n2)
	movl	-32(%rbp), %edx		# assign edx as n4
	movl	-28(%rbp), %eax		# assign eax as n3
	movl	%edx, %esi			# assign esi (2nd arg.) as n4
	movl	%eax, %edi			# assign edi (1st arg.) as n3
	call	GCD 				# call GCD func with 2 arg.(n3 & n4)
	movl	%eax, -8(%rbp)		# assign t2 as return value func. GCD(n3,n4)
	movl	-8(%rbp), %edx		# assign edx as t2
	movl	-12(%rbp), %eax		# assign eax as t1
	movl	%edx, %esi			# assign esi (2nd arg.) as t2
	movl	%eax, %edi			# assign edi (1st arg.) as t1
	call	GCD 				# call GCD func with 2 arg. (t1 & t2)
	movl	%eax, -4(%rbp)		# assign t3 as return value func. GCD(t1,t2)
	movl	-4(%rbp), %eax		# assign eax as t3 to return t3
	leave
	ret 
	.size	GCD4, .-GCD4
	.globl	GCD
	.type	GCD, @function
GCD:
	endbr64
	pushq	%rbp 				# save rbp in stack
	movq	%rsp, %rbp			# assign rbp as rsp
	movl	%edi, -20(%rbp)		# assign num1 as 1st arg. recieved
	movl	%esi, -24(%rbp)		# assign num2 as 2nd arg. recieved
	jmp	.L6
.L7:
	movl	-20(%rbp), %eax		# assign eax as num1
	cltd						# conversion to 64bit
	idivl	-24(%rbp)			# divide num1 by num2 (eax-> quotient, edx-> remainder)
	movl	%edx, -4(%rbp)		# assign temp as num1%num2
	movl	-24(%rbp), %eax		# assign eax as num2
	movl	%eax, -20(%rbp)		# assign num1 as num2(eax)
	movl	-4(%rbp), %eax		# assign eax as temp
	movl	%eax, -24(%rbp)		# assign num2 as temp(eax)
.L6:
	movl	-20(%rbp), %eax		# assign eax as num1
	cltd						# conversion to 64bit
	idivl	-24(%rbp)			# dividing num1 by num2 (eax-> quotient, edx-> remainder)
	movl	%edx, %eax			# edx -> num1%num2		
	testl	%eax, %eax			# compare num1%num2 and 0
	jne	.L7						# if num1%num2!=0 condition is true
	movl	-24(%rbp), %eax		# assign eax as num2 to return
	popq	%rbp				# pop base pointer
	ret 						# return 
	.size	GCD, .-GCD
	.ident	"GCC: (Ubuntu 9.3.0-10ubuntu2) 9.3.0"
	.section	.note.GNU-stack,"",@progbits
	.section	.note.gnu.property,"a"
	.align 8
	.long	 1f - 0f
	.long	 4f - 1f
	.long	 5
0:
	.string	 "GNU"
1:
	.align 8
	.long	 0xc0000002
	.long	 3f - 2f
2:
	.long	 0x3
3:
	.align 8
4:
