############ Trabalho 1 de Organizacoa de Computadores ################################
#	Trabalho desenvolvido pelos alunos: Hiago De Franco Moreira (9771289), Leonardo
# Sensiate (9771571), Mateus Castilho Leite (9771550) e Vincius Nakasone Dilda (9771612).
#	O Trabalho compreende implementar em Assembly MIPS um algoritmo que permita a 
#insercao e posteriormente os percorrimentos pre-ordem, em-ordem e pos-ordem em uma 
#arvore binaria ordenada.

########################## DATA ##############################
		.data
		.align 2
vet_rec:	.space 400		#  Aqui eu aloco um vetor para ser utilizado nas
					#recursoes 
str_menu:	.asciiz "Menu:\n1. Insercao.\n2. Percorrimento pre-ordem.\n3. Percorrimento em-ordem.\n4. Percorrimento pos-ordem.\n5. Sair.\n"
str_escolhaMenu:.asciiz "Escolha uma opcao: "
str_digite:	.asciiz "Digite um valor para ser inserido: "
str_pre:	.asciiz "Pre-ordem:\n"
str_pos:	.asciiz "Pos-ordem:\n"
str_em:		.asciiz "Em-ordem:\n"
str_newline:	.asciiz "\n"
str_pontoVir:	.asciiz ";"
str_pontoFin:	.asciiz "."
str_vazio:	.asciiz "Arvore Vazia!\n"
####################### END DATA ############################
		
###################### TEXT #################################		
		.text
		move $s0, $sp		#  Incializa $s0 com o valor de $sp, para voltarmos
					#no vetor se precisarmos.
###### Inicio Main ######		
main:		la $a0, str_menu	#  Impresssao do menu.
		li $v0, 4
		syscall
		la $a0, str_escolhaMenu #  Impressao da string de escolha.
		li $v0, 4
		syscall				
		li $v0, 5		#  Aquisita uma valor para o switch do menu.
		syscall
		beq $v0, 1, insercao	#  Aqui ocorre um switch, dependendo da opcao digitada
		beq $v0, 2, pre_ordem	#ocorre um branch diferente.
		beq $v0, 3, em_ordem
		beq $v0, 4, pos_ordem
		beq $v0, 5, sair
###### Fim da main ######

###### Funcao de insercao ######
insercao:	la $a0, str_digite	#  Impressao da string para aquisitar um valor.
		li $v0, 4		
		syscall
		li $v0, 5		#  Aquisita o valor a ser inserido.
		syscall
		beqz $v0, main		#  Valor invalido: 0. Volto para o menu.
		move $s1, $zero		#  Aqui irei guardar o valor da minha posicao
					#atual no vetor, considerando que ele comeca na posicao
					#0. Desta forma, posteriormente poderei multiplicar
					#este valor por -4 para andar no vetor.
	recursao_filhos:
		lw $t0, 0($sp)		#  Carrego o valor inicial do vetor em $t0 para
					#compara-lo com o valor obtido.
		beqz $t0, entra_vetor	#  Se o valor que esta no vetor for 0, o valor aquisitado
					#entrara no vetor.
		ble $v0, $t0, esquerda  #  Se o valor aquisitado for menor ou igual que o valor
					#sendo comparado na arvore, ele entrara na esquerda.
		bgt $v0, $t0, direita	#  Caso contrario, vou para a direita da arvore.	 
		esquerda:
			mul $s1, $s1, 2 #  Para acessar o filho da esquerda, vamos para a
					#posicao 2*i + 1.
			addi $s1, $s1, 1
			mul $t1, $s1, -4#  Multiplico a posicao atual por -4 para inserir
					#no vetor.
			add $sp, $sp, $t1#  Pego o valor de $t1 e ando este valor no vetor.  
			j recursao_filhos			
		direita:
			mul $s1, $s1, 2 #  Ja para a direita, vamos para a pos 2*i+2.
			addi $s1, $s1, 2
			mul $t1, $s1, -4
			add $sp, $sp, $t1
			j recursao_filhos
	entra_vetor:	
		sw $v0, 0($sp)  	#  Coloco o valor no vetor.
		move $sp, $s0		#  Retorno $sp para o inicio do vetor.
		move $s1, $zero		#  Volto o valor da posicao para 0.
		j main			#  Volto para o menu.
###### Fim funcao de insercao ######

###### Funcao de Pre_ordem ######
pre_ordem:	lw $t0, 0($sp)		#  Carrego a raiz da arvore em $t0.
		beqz $t0, ERRO		#  Se for zero, arvore vazia (ERRO).
	recursao_impressao:
		lw $t0, 0($sp)
		move $a0, $t0		#  Passo o valor para $a0 para poder printar.
		jal print_valor		#  Pula para a funcao para printar o no.
	pre_esquerda:			#  Codigo para ir para o filho da esquerda em 
					#pre-ordem.
		#move $t1, $sp		#  Guardo a posicao atual de $sp em $t1 para poder voltar
					#depois.
		mul $s1, $s1, 2		#  Aqui preciso ir para a esquerda, logo $s1 = 2*i+1.
		addi $s1, $s1, 1
		mul $t2, $s1, -4	#  Multiplico pro -4 e guardo em $t2 para andar no
					#vetor.
		add $sp, $sp, $t2	#  Ando para o filho da esquerda.
		lw $t3, 0($sp)		#  Carrego o valor do no filho da esq em $t3.
		beqz $t3, pre_direita	#  Se o valor for 0, vou para a direita.
		j recursao_impressao	#  Se nao, volto para printar de novo.
	pre_direita:
		
	
		

###### Fim da funcao de Pre_ordem ######

em_ordem:
pos_ordem:

###### Funcao para printar os valores ######
print_valor:	li $v0, 1		#  Impressao do valor da arvore.
		syscall
		li $v0, 4		#  Impressao do ponto e virgula
		la $a0, str_pontoVir
		syscall
		jr $ra			#  Volto para a funcao em que estava.
###### Fim da funcao para printar os valores ######

###### Mensagem de ERRO ######
ERRO:		la $a0, str_vazio	# Impressao do erro se a arvore estiver vazia.
		li $v0, 4
		syscall
		j main			#  Volto para o menu
###### Fim mensagem de ERRO ######

##### Termina o Programa #######
sair:		li $v0, 10		#  Encerra o programa.
		syscall
#### Fim Do Termina o Programa #####
###############################  END TEXT  ####################
