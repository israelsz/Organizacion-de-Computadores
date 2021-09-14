.data
	imprimirTexto: .asciiz "El resultado de la multiplicación es: "
	
	# Definicion de los operandos
	primerOperando: .word 8
	segundoOperando: .word 5
	
.text
main:
	lw $a1, primerOperando #Se carga el primer operando
	lw $a2, segundoOperando #Se carga el segundo operando
	
	#En caso de haber un operando negativo, este se convertira a positivo
	jal convertirPrimerOperando
	jal convertirSegundoOperando
	
	add $t0, $zero, $zero #Se fija el registro $t0 al valor cero
	add $t1, $zero ,$zero #Se fija el registro $t1 al valor cero
	jal multiplicar #Se efectua la multiplicacion
	
	#En caso de que algun operando haya sido negativo, se verificara si es necesario convertir a negativo el resultado
	jal verificarConversionResultadoNegativo
	
	#Se imprime por pantalla el texto previo a imprimir el resultado de la multiplicacion
	la $a0, imprimirTexto
	li $v0, 4
	syscall
	
	# A continuacion se copia al registro $a0 el resultado de la multiplicacion que se encuentra en $v1 ya que el numero a imprimir debe estar en el registro $a0
	# se usa el codigo 1 en la llamada de sistema para imprimir numeros enteros por pantalla
	add $a0, $v1, $zero
	li $v0, 1
	syscall
	
	#Se termina la ejecución del programa
	li $v0, 10 #El codigo 10 termina la ejecución del programa
	syscall

convertirPrimerOperando:
	#Se verifica si el operando es negativo
	li $t0, 0 #Se fija en cero, se usara como contador
	bltz $a1, convertirPrimerOperandoAPositivo #Si $a1 < 0 se convierte a positivo
	jr $ra #Se regresa al main en caso que sea positivo

convertirPrimerOperandoAPositivo:
	#Se sumara 1 al primer operando hasta que sea cero
	beqz $a1, sumarPrimerOperandoAPositivo
	addi $a1, $a1, 1
	addi $t0, $t0, 1
	j convertirPrimerOperandoAPositivo
	
sumarPrimerOperandoAPositivo:
	#Se sumara la cantidad acumulada en $t0 a $a1, de esta forma quedara positivo
	add $a1, $a1, $t0
	# Se suma 1 al registro s7, para indicar que el operando es negativo
	addi $s7, $s7, 1
	#Se regresa al main
	jr $ra 

convertirSegundoOperando:
	#Se verifica si el operando es negativo
	li $t0, 0 #Se fija en cero, se usara como contador
	bltz $a2, convertirSegundoOperandoAPositivo #Si $a1 < 0 se convierte a positivo
	jr $ra #Se regresa al main en caso que sea positivo

convertirSegundoOperandoAPositivo:
	#Se sumara 1 al segundo operando hasta que sea cero
	beqz $a2, sumarSegundoOperandoAPositivo
	addi $a2, $a2, 1
	addi $t0, $t0, 1
	j convertirSegundoOperandoAPositivo
	
sumarSegundoOperandoAPositivo:
	#Se sumara la cantidad acumulada en $t0 a $a2, de esta forma quedara positivo
	add $a2, $a2, $t0
	# Se suma 1 al registro s7, para indicar que el operando es negativo
	addi $s7, $s7, 1
	#Se regresa al main
	jr $ra 

verificarConversionResultadoNegativo:
	# si $s7 es igual a 1, significa que solo uno de los operando es negativos, entonces se debe convertir el resultado de la multiplicacion
	beq $s7, 1, convertirResultadoANegativo
	#En caso que no sea 1 se regresa al main
	jr $ra
	
convertirResultadoANegativo:
	add $t0, $v1, $zero #Se traspasa el valor de $v1 al registo $t0
	# A continuacion se resta dos veces $t0 a $v1, para que pase a su forma negativa
	sub $v1, $v1, $t0
	sub $v1, $v1, $t0
	#Se regresa al main
	jr $ra
	
multiplicar:
	#Se verifica condicion de termino: si $t0 es igual al segundo operando se procede a escribir el resultado
	beq $t0, $a2, escribirResultado
	
	#En caso que aun se este multiplicando
	add $t1, $t1, $a1 # Se acumula la suma del primer operando en el registro $t1
	addi $t0, $t0, 1 #Se suma uno al valor actual de $t0, el que es usado como contador
	j multiplicar #Se vuelve al ciclo
	
escribirResultado:
	#Se traspasa el valor de $t1 a $v1
	add $v1, $t1, $zero
	#Se regresa al proceso principal
	jr $ra
