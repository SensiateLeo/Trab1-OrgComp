############ Trabalho 1 de Organizacoa de Computadores ################################
#	Trabalho desenvolvido pelos alunos: Hiago De Franco Moreira (9771289), Leonardo
# Sensiate (9771571), Mateus Castilho Leite (9771550) e Vincius Nakasone Dilda (9771612).
#	O Trabalho compreende implementar em Assembly MIPS um algoritmo que permita a 
#insercao e posteriormente os percorrimentos pre-ordem, em-ordem e pos-ordem em uma 
#arvore binaria ordenada.

########################## DATA ##############################
		.data
		.align 2
#pilha_ESQ:	.space 100		
pilha_rec:	.word 100					
					#  Aqui eu aloco um vetor para ser utilizado nas
					#recursoes dos algoritmos. 400 eh um valor arbitrario
					#grande o suficiente para que construir umas arvore 
					#degenerada de tamanho 400.
					#  Um sera utilizado para a recursao feita para
					#a esquerda e outro para a direita.
					# Codigo em C para visualizacao (exemplo):
					# void emOrdem(struct No *pNo) {
    					# if(pNo != NULL) {
					#      emOrdem(pEsquerda);
    					#      visita(pNo);
   					#      emOrdem(pDireita);
  					#    }
 					# }
str_menu:	.asciiz "\nMenu:\n1. Insercao.\n2. Percorrimento pre-ordem.\n3. Percorrimento em-ordem.\n4. Percorrimento pos-ordem.\n5. Sair.\n"
str_escolhaMenu:.asciiz "Escolha uma opcao: "
str_digite:	.asciiz "Digite um valor para ser inserido: "
str_pre:	.asciiz "Pre-ordem:\n"
str_pos:	.asciiz "Pos-ordem:\n"
str_em:		.asciiz "Em-ordem:\n"
str_newline:	.asciiz "\n"
str_pontoVir:	.asciiz ";"
str_pontoFin:	.asciiz "."
str_vazio:	.asciiz "Arvore Vazia!\n"
str_invalido:	.asciiz "Valor invalido! (Nao posso inserir 0 na arvore.)\n"
####################### END DATA ############################
		
###################### TEXT #################################
#  Registradores convencionados (favor nao trocar!):
#  $s0 = guarda o valor do comeco da pilha $sp.
#  $t0 = usado em diversas partes do codigo para guardar os valores da pilha para comparacao.
#  $t1 =  usado para guardar o valor de 2*i+1 ou 2*i+2 multiplicado por -4.
#  $s1 = usado para guardar a posicao atual no vetor (2*i+1 e 2*i+2).
#  $s2 = usado para guardar o endereco da pilha_rec.					
		.text
		move $s0, $sp		#  Incializa $s0 com o valor de $sp, para voltarmos
					#no vetor se precisarmos.
###### Inicio Main ######		
main:		#jal print_newline
		la $a0, str_menu	#  Impresssao do menu.
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
		beqz $v0, ERRO_INVALIDO	#  Valor invalido: 0. Volto para o menu.
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
pre_ordem:	lw $t0, 0($sp)		#  Carrega o primeiro valor da arvore em $t0 e 
		beqz $t0, ERRO_VAZIO	#verifica se eh uma arvore vazia.
		la $s2, pilha_rec	#  $s2 = endereco do vetor 
		move $t2, $zero		#  Variavel para guardar o tamanho do vetor.	
	recursao_pre_esq:
		lw $t0, 0($sp)		#  Pego o valor do no, dif de zero.
		move $a0, $t0		#  Printa o valor.
		jal print_valor
		##  Armazena o endereco do valor e anda no vetor.
		sw $sp, 0($s2)		#  Armazeno o endereco no vetor para poder saber em
					#qual voltar depois.
		addi $t2, $t2, 1	#  tamanho++
		addi $s2, $s2, 4	#  Vai para a prox posicao do vetor.		
		##  Vou para a esquerda
		mul $s1, $s1, 2		#  2i+1 = vai para a esquerda
		addi $s1, $s1, 1
		mul $t1, $s1, -4
		add $sp, $sp, $t1
		##  ##
		lw $t0, 0($sp)		#  Carrega o valor do vetor para $t0.
		beqz $t0, voltoAnterior	#  Se for zero, preciso voltar na recursao.
		j recursao_pre_esq		#  Se nao for zero, eu continuo com o loop.
	voltoAnterior:
		
	
		
###### Fim da funcao de Pre_ordem ######

###### Funcao de Em_ordem ######
em_ordem:
###### Fim Funcao de Em_ordem ######

###### Funcao de Pos_ordem ######
pos_ordem:
###### Fim Funcao de Pos_ordem ######

###### Funcao para printar os valores ######
print_valor:	li $v0, 1		#  Impressao do valor da arvore.
		syscall
		li $v0, 4		#  Impressao do ponto e virgula
		la $a0, str_pontoVir
		syscall
		jr $ra			#  Volto para a funcao em que estava.
###### Fim da funcao para printar os valores ######

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

###### Printa uma nova linha #######
#print_newline:	la $a0, str_newline	#  Funcao para printar uma linha nova.
#		li $v0, 5		#  Depois volta para quem a chamou.
#		syscall			#  Necessario o uso de jal.
#		jr $ra

##### Termina o Programa #######
sair:		li $v0, 10		#  Encerra o programa.
		syscall
#### Fim Do Termina o Programa #####

###############################  END TEXT  ####################
