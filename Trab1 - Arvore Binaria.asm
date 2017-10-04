##################### Trabalho 1 de Organizacao de Computadores ##########################
#	Trabalho desenvolvido pelos alunos: Hiago De Franco Moreira (9771289), Leonardo  #
# Sensiate (9771571), Mateus Castilho Leite (9771550) e Vincius Nakasone Dilda (9771612).#
#	O Trabalho compreende implementar em Assembly MIPS um algoritmo que permita a    #
#insercao e posteriormente os percorrimentos pre-ordem, em-ordem e pos-ordem em uma      #
#arvore binaria.								 	 #
##########################################################################################

############################################## DATA ######################################
		.data
		.align 2
pilha_rec:	.space 100					
					#  Aqui aloco um vetor para ser utilizado nas
					#recursoes dos algoritmos. 100 eh um valor arbitrario
					#grande o suficiente para que construir uma arvore 
					#degenerada de tamanho 100.
str_menu:	.asciiz "\nMenu:\n1. Insercao.\n2. Percorrimento pre-ordem.\n3. Percorrimento em-ordem.\n4. Percorrimento pos-ordem.\n5. Sair.\n"
str_escolhaMenu:.asciiz "Escolha uma opcao: "
str_digite:	.asciiz "Digite um valor para ser inserido: "
str_pre:	.asciiz "Pre-ordem: "
str_pos:	.asciiz "Pos-ordem: "
str_em:		.asciiz "Em-ordem: "
str_pontoVir:	.asciiz ","
str_pontoFin:	.asciiz "."
str_vazio:	.asciiz "Arvore Vazia!\n"
str_invalido:	.asciiz "Valor invalido! (Nao posso inserir 0 na arvore.)\n"
########################################### END DATA #######################################
		
############################################ TEXT ##########################################

############################################################################################
#  Registradores utilizados:					   #
#  $s0 = guarda o valor do comeco da pilha $sp.						   #
#  $t0 = usado em diversas partes do codigo para guardar os valores da pilha para comparacao.
#  $t1 =  usado para guardar o valor de 2*i+1 ou 2*i+2 multiplicado por -4.		   #
#  $s1 = usado para guardar a posicao atual no vetor (2*i+1 e 2*i+2).			   #
#  $s2 = usado para guardar o endereco de comeco da pilha_rec	   			   #
#  $s3 = usado como flag para decidir se printa a virgula ou nao.			   #
###########################################################################################					
		.text
		move $s0, $sp		#  Incializa $s0 com o valor de $sp, para voltarmos
					#no vetor quando precisarmos.
		la $s2, pilha_rec	#  Recebe o endereco do vetor pilha_rec, onde serao
					#armazenados os valores de retorno da recursao.
###### Inicio Main ######			
main:		move $s3, $zero		#  Flag para printar a virgula inicializada em 0, 
					#se ela for igual 1 em print_valor ela ira printar
					#a virgula.
		la $a0, str_menu	#  Impresssao do menu.
		li $v0, 4
		syscall
		la $a0, str_escolhaMenu #  Impressao da string de escolha.
		li $v0, 4
		syscall				
		li $v0, 5		#  Aquisita uma valor para o switch do menu.
		syscall
		beq $v0, 1, insercao	#  Aqui ocorre um switch, dependendo da opcao digitada
		beq $v0, 2, pre_ordem	#ocorre um branch diferente (Assumindo que nao sera
		beq $v0, 3, em_ordem	#digitado um valor diferente destes).
		beq $v0, 4, pos_ordem
		beq $v0, 5, sair
###### Fim da main ######

###### Funcao de insercao ######
insercao:	la $a0, str_digite	#  Impressao da string para aquisitar um valor.
		li $v0, 4		
		syscall
		li $v0, 5		#  Aquisita o valor a ser inserido.
		syscall
		beqz $v0, ERRO_INVALIDO	#  Valor invalido: 0. Volto para o menu.
		move $s1, $zero		#  Aqui irei guardar o valor da minha posicao
					#atual no vetor, considerando que ele comeca na posicao
					#0. Desta forma, posteriormente poderei multiplicar
					#este valor por -4 para andar no vetor.
	loop_filhos:
		lw $t0, 0($sp)		#  Carrego o valor inicial do vetor em $t0 para
					#compara-lo com o valor obtido.
		move $sp, $s0
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
			j loop_filhos	# Volto no loop.		
		direita:
			mul $s1, $s1, 2 #  Ja para a direita, vamos para a pos 2*i+2.
			addi $s1, $s1, 2
			mul $t1, $s1, -4
			add $sp, $sp, $t1
			j loop_filhos
	entra_vetor:
		mul $t1, $s1, -4	#  Multiplico a posicao atual por -4 para inserir
					#no vetor.
		add $sp, $sp, $t1	#  Pego o valor de $t1 e ando este valor no vetor.	
		sw $v0, 0($sp)  	#  Coloco o valor no vetor.
		move $sp, $s0		#  Retorno $sp para o inicio do vetor.
		move $s1, $zero		#  Volto o valor da posicao para 0.
		j main			#  Volto para o menu.
###### Fim funcao de insercao ######

###### Funcao de Pre_ordem ######
pre_ordem:	lw $t0, 0($sp)		#  Carrego o primeiro valor em $t0 e verifico se
		beqz $t0, ERRO_VAZIO	#ele eh zero. Se for, temos uma arvore vazia = ERRO.
		
		la $a0, str_pre		#  Printa a string: "Pre-ordem: "
		li $v0, 4
		syscall
		
		jal pre_ordem_rec	#  Inicia a recursao.
		
		la $a0, str_pontoFin	#  Printa "." .
		li $v0, 4
		syscall
		
		move $sp, $s0
		j main			#  Volta para o menu.
		
	pre_ordem_rec:
		sw $ra, 0($s2)		#  Armazena o endereco de retorno em pilha_rec.
		addi $s2, $s2, 4	#  Proxima posicao de pilha_rec.
		
		# BASE: Verifica se o valor atual do no eh zero. Se for, chegamos em um no
		#folha e por isso devemos voltar para o no pai.
		lw $t0, 0($sp)
		beqz $t0, pre_ordem_done
		
		#  Aqui, se ele nao for zero, entao mostra o valor.
		jal print_valor
	
		#  Vou para o filho da esquerda.
		move $sp, $s0
		mul $s1, $s1, 2 	#  Para acessar o filho da esquerda, vamos para a
					#posicao 2*i + 1.
		addi $s1, $s1, 1
		mul $t1, $s1, -4	#  Multiplico a posicao atual por -4 para inserir
					#no vetor.
		add $sp, $sp, $t1	#  Pego o valor de $t1 e ando este valor no vetor.
		#  #
		
		jal pre_ordem_rec
		
		#  Voltei da recursao, vou para a direita (2*i + 2).
		move $sp, $s0
		mul $s1, $s1, 2
		addi $s1, $s1, 2
		mul $t1, $s1, -4
		add $sp, $sp, $t1
		#  #
		
		jal pre_ordem_rec
		
	pre_ordem_done:
		#  Volto para o pai. Calculo: (i-1)/2
		move $sp, $s0
		addi $s1, $s1, -1
		div $s1, $s1, 2
		mul $t1, $s1, -4	# Aqui o valor eh multiplicado por -4 e somado
		add $sp, $sp, $t1	# em $sp para podermos andar o numero de casas
					# referente ao valor guardado em $s1.
		addi $s2, $s2, -4
		lw $ra, 0($s2)		#  Desempilha o valor de retorno da recusao.
		jr $ra			#  Volto para a recursao.
				
###### Fim da funcao de Pre_ordem ######
	
###### Funcao de Em_ordem ######
em_ordem:	lw $t0, 0($sp)		#  Carrego o primeiro valor em $t0 e verifico se
		beqz $t0, ERRO_VAZIO	#ele eh zero. Se for, temos uma arvore vazia = ERRO.
		
		la $a0, str_em		#  Printa a string: "Em-ordem: "
		li $v0, 4
		syscall
		
		jal em_rec		#  Inicia a recursao.
		
		la $a0, str_pontoFin	#  Printa "." .
		li $v0, 4
		syscall
		
		move $sp, $s0		#  
		j main			#  Volta para o menu.
	
	em_rec:
		sw $ra, 0($s2)		#  Armazena o endereco de retorno em pilha_rec.
		addi $s2, $s2, 4	#  Proxima posicao de pilha_rec.
		
		# BASE: Verifica se o valor atual do no eh zero.
		lw $t0, 0($sp)
		beqz $t0, em_done
		
		#  Vou para o filho da esquerda.
		move $sp, $s0
		mul $s1, $s1, 2 	#  Para acessar o filho da esquerda, vamos para a
					#posicao 2*i + 1.
		addi $s1, $s1, 1
		mul $t1, $s1, -4	#  Multiplico a posicao atual por -4 para inserir
					#no vetor.
		add $sp, $sp, $t1	#  Pego o valor de $t1 e ando este valor no vetor.
		#  #
		
		jal em_rec
		
		#  Aqui, se ele nao for zero, entao mostra o valor.
		lw $t0, 0($sp)
		jal print_valor
		
		#  Voltei da recursao, vou para a direita (2*i + 2).
		move $sp, $s0
		mul $s1, $s1, 2
		addi $s1, $s1, 2
		mul $t1, $s1, -4
		add $sp, $sp, $t1
		#  #
		
		jal em_rec
		
	em_done:
		#  Volto para o pai. Calculo: (i-1)/2
		move $sp, $s0
		addi $s1, $s1, -1
		div $s1, $s1, 2
		mul $t1, $s1, -4
		add $sp, $sp, $t1
		
		addi $s2, $s2, -4
		lw $ra, 0($s2)
		jr $ra
		
###### Fim Funcao de Em_ordem ######

###### Funcao de Pos_ordem ######
pos_ordem:	lw $t0, 0($sp)		#  Carrego o primeiro valor em $t0 e verifico se
		beqz $t0, ERRO_VAZIO	#ele eh zero. Se for, temos uma arvore vazia = ERRO.
		
		la $a0, str_pos		#  Printa a string: "Pos-ordem: "
		li $v0, 4
		syscall
		
		jal pos_rec		#  Inicia a recursao.
		
		la $a0, str_pontoFin	#  Printa "." .
		li $v0, 4
		syscall
		
		move $sp, $s0
		j main			#  Volta para o menu.
		
	pos_rec:
		sw $ra, 0($s2)		#  Armazena o endereco de retorno em pilha_rec.
		addi $s2, $s2, 4	#  Proxima posicao de pilha_rec.
		
		# BASE: Verifica se o valor atual do no eh zero.
		lw $t0, 0($sp)
		beqz $t0, pos_done
		
		#  Vou para o filho da esquerda.
		move $sp, $s0
		mul $s1, $s1, 2 	#  Para acessar o filho da esquerda, vamos para a
					#posicao 2*i + 1.
		addi $s1, $s1, 1
		mul $t1, $s1, -4	#  Multiplico a posicao atual por -4 para inserir
					#no vetor.
		add $sp, $sp, $t1	#  Pego o valor de $t1 e ando este valor no vetor.
		#  #
		
		jal pos_rec
		
		#  Voltei da recursao, vou para a direita (2*i + 2).
		move $sp, $s0
		mul $s1, $s1, 2
		addi $s1, $s1, 2
		mul $t1, $s1, -4
		add $sp, $sp, $t1
		#  #
		
		jal pos_rec
		
		#  Aqui, se ele nao for zero, entao mostra o valor.
		lw $t0, 0($sp)
		jal print_valor
		
	pos_done:
		#  Volto para o pai. Calculo: (i-1)/2
		move $sp, $s0
		addi $s1, $s1, -1
		div $s1, $s1, 2
		mul $t1, $s1, -4
		add $sp, $sp, $t1
		
		addi $s2, $s2, -4
		lw $ra, 0($s2)
		jr $ra
		
###### Fim Funcao de Pos_ordem ######

###### Funcao para printar os valores ######
print_valor:	beq $s3, 1, print_virgula
print_valorVir:	move $a0, $t0
		li $v0, 1		#  Impressao do valor da arvore.
		syscall
		li $s3, 1
		jr $ra			#  Volto para a funcao em que estava.
###### Fim da funcao para printar os valores ######

###### Funcao para printar valor sem virgula ######
print_virgula:	li $v0, 4
		la $a0, str_pontoVir
		syscall
		j print_valorVir
###### Fim da Funcao para printar valor sem virgula ######

###### Mensagem de ERRO ######
ERRO_VAZIO:	la $a0, str_vazio	# Impressao do erro se a arvore estiver vazia.
		li $v0, 4
		syscall
		j main			#  Volto para o menu
###### Fim mensagem de ERRO ######

####### Mensagem de Valor invalido #######
ERRO_INVALIDO:	la $a0, str_invalido	#  Erro: Tentou inserir o numero 0 na arvore.
		li $v0, 4		#  Printa a mensagem de erro e volta para o menu.
		syscall
		j main	
###### Fim Mensagem de Valor invalido ######

##### Termina o Programa #######
sair:		li $v0, 10		#  Encerra o programa.
		syscall
#### Fim Do Termina o Programa #####

###############################  END TEXT  ####################
