	.file	"ass1a_18cs30006.c"
	.text
	.section	.rodata
.LC0:
	.string	"\nThe greater number is: %d"
	.text
	.globl	main
	.type	main, @function	  
main:
	endbr64
	pushq	%rbp              # save rbp in stack
	movq	%rsp, %rbp        # rbp = rsp 
	subq	$16, %rsp         # stack memory declare
	movl	$45, -8(%rbp)     # mem[ebp-8])=45  (num1)
	movl	$68, -4(%rbp)     # mem[ebp-4]=68	(num2)
	movl	-8(%rbp), %eax    # eax=num1
	cmpl	-4(%rbp), %eax    # comparing num2 and num1
	jle	.L2                   # else part num1<=num2
	# if num1>num2
	movl	-8(%rbp), %eax    # eax= num1 
	movl	%eax, -12(%rbp)   # assigning greater as num1
	jmp	.L3
# else part
.L2:
	movl	-4(%rbp), %eax     # assigning eax as num2
	movl	%eax, -12(%rbp)    # assigning greater as num2
.L3:
	movl	-12(%rbp), %eax    # assigning eax as greater  
	movl	%eax, %esi         # assigning esi as greater for printing
	leaq	.LC0(%rip), %rdi
	movl	$0, %eax			# assign eax as 0 to return 0
	call	printf@PLT			# calling print fuction	
	movl	$0, %eax
	leave
	ret                         # return from main function
	.size	main, .-main
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
