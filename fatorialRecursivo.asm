	.data
promptMessage:	.asciiz "Enter a number to find its factorial: "
resultMessage:	.asciiz "\nThe factorial of the numer is "
theNumber:	.word 0
theAnswer:	.word 0
	
	.text
	.globl main
main:	li $v0, 4			# Printa a mensagem de comeco.
	la $a0, promptMessage
	syscall
	
	li $v0, 5			# Aquisita um valor do usuario.
	syscall
	
	sw $v0, theNumber		# Coloca o valor aquisitado em theNumber. 
	
	lw $a0, theNumber		#  Carrega o valor em $a0.
	jal findFactorial		#  Vai para a funcao de calculo de fatorial.
	sw $v0, theAnswer 		#  Guarda o resultado em theAnswer.
	
	li $v0, 4			#  Imprimi a frase de resultado.
	la $a0, resultMessage
	syscall

	li $v0, 1			#  Imprimi o resultado.
	lw $a0, theAnswer
	syscall
	
	li $v0, 10			#  Sai do programa.
	syscall

#-------------------------------------------------------------------------------------#
	.globl findFactorial
findFactorial:
	subu $sp, $sp, 8
	sw $ra, ($sp)
	sw $s0, 4($sp)
	
	#Base
	li $v0, 1
	beqz $a0, factorialDone
	
	#(Number - 1)
	move $s0, $a0
	sub $a0, $a0, 1
	jal findFactorial
	
	# Magia
	mul $v0, $s0, $v0
	
	factorialDone:
		lw $ra, ($sp)
		lw $s0, 4($sp)
		addu $sp, $sp, 8
		jr $ra 