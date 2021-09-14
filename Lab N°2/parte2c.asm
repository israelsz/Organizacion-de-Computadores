.data
	imprimirTexto: .asciiz "El resultado de la división es: "
	imprimirComa: .asciiz ","
	imprimirMenos: .asciiz "-"
	imprimirCasoCero: .asciiz "No es posible dividir por cero !"
	
	# Definicion de los operandos
	primerOperando: .word 1
	segundoOperando: .word 100  # OPERACION: primerOperando / segundoOperando
.text
main:
	lw $a1, primerOperando #Se carga el primer operando
	lw $a2, segundoOperando #Se carga el segundo operando
	
	#Se verifica caso base de division por cero
	jal divisionCero
	
	#En caso de haber un operando negativo, este se convertira a positivo
	jal convertirPrimerOperando
	jal convertirSegundoOperando
	
	jal dividir #Se efectua la división
	
	#Se imprime por pantalla el texto previo a imprimir el resultado de la división
	la $a0, imprimirTexto
	li $v0, 4
	syscall
	
	#En caso de que algun operando haya sido negativo, se verificara si es necesario convertir a negativo el resultado
	jal verificarConversionResultadoNegativo
	
	#Se imprime el primer numero
	# se usa el codigo 1 en la llamada de sistema para imprimir numeros enteros por pantalla
	move $a0, $s0
	li $v0, 1
	syscall
	
	#Se imprime por pantalla la coma
	la $a0, imprimirComa
	li $v0, 4
	syscall
	
	#Se imprime el primer decimal
	move $a0, $s1
	li $v0, 1
	syscall
	
	#Se imprime el segundo decimal
	move $a0, $s2
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
	
dividir:
	add $t2, $t2, $zero #Se fija el contador en 0
	
	# Se respalda el valor del registro $ra para poder volver a donde se llamó a "dividir"
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	jal divisionEntera #Se efectua la division de la parte entera
	
	move $s0, $t2 #Se mueve el resultado de $t2 a $s0
	# A continuacion se calculan los decimales
	jal calcularDecimales
	
	# Se restablece el valor del registro $ra para volver a main
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
	
	jr $ra #Se vuelve al main
	
divisionEntera:
	# Condición de termino si primerTermino <= 0
	blt $a1, $a2, salirDivisionEntera
	# En caso que continue el ciclo:
	sub $a1, $a1, $a2 #Se efectua primerOperando = primerOperando - segundoOperando
	addi $t2, $t2, 1 #Se suma uno al contador, contiene el resultado de la division entera
	
	j divisionEntera #Se vuelve a ejecutar el ciclo
	
	
salirDivisionEntera:
	jr $ra

calcularDecimales:
	beqz $a1, salirCalculoDecimal #Si el resto es cero, no hay decimales por lo que se escapa del ciclo
	
	#Ya que hay resto, el resto se multiplicara por 10 el resto
	move $t5, $a1 #Se mueve el resto a $t5
	li $t6, 10 #Se fija el segundo operando de la multiplicacion como 10
	
	# Se respalda el valor del registro $ra para poder volver a donde se llamó a "calcularDecimales"
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	li $t4, 0
	li $t7, 0
	
	jal multiplicar #Se efectua la multiplicacion
	
	move $a1, $v1 #Se mueve a $a1 el valor de la multiplicacion que se encuentra en $v1
	li $t2, 0
	
	jal divisionEntera #Se efectua la division entre el resto*10 y el dividendo
	
	# Se restablece el valor del registro $ra
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
	
	move $s1, $t2 #Se mueve el valor del primer decimal a $s1
	# se verifica si aun queda resto
	beqz $a1, salirCalculoDecimal #Si el resto es cero, no hay decimales por lo que se escapa del ciclo
	
	#En caso de que no se haya escapado del ciclo, se calculara el segundo decimal:
	
	#Ya que hay resto, el resto se multiplicara por 10 el resto
	move $t5, $a1 #Se mueve el resto a $t5
	li $t6, 10 #Se fija el segundo operando de la multiplicacion como 10
	
	# Se respalda el valor del registro $ra para poder volver a donde se llamó a "calcularDecimales"
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	li $t4, 0
	li $t7, 0
	
	jal multiplicar #Se efectua la multiplicacion
	
	move $a1, $v1 #Se mueve a $a1 el valor de la multiplicacion que se encuentra en $v1
	li $t2, 0
	
	jal divisionEntera #Se efectua la division entre el resto*10 y el dividendo
	
	# Se restablece el valor del registro $ra
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
	
	move $s2, $t2 #Se mueve el valor del segundo decimal a $s2
	
	jr $ra #Se escapa del ciclo
salirCalculoDecimal:
	jr $ra #Se regresa al proceso de division
									
multiplicar:
	#Se verifica condicion de termino: si $t0 es igual al segundo operando se procede a escribir el resultado
	beq $t7, $t6, escribirResultado
	
	#En caso que aun se este multiplicando
	add $t4, $t4, $t5 # Se acumula la suma del primer operando en el registro $t4
	addi $t7, $t7, 1 #Se suma uno al valor actual de $t7, el que es usado como contador
	j multiplicar #Se vuelve al ciclo
	
escribirResultado:
	#Se traspasa el valor de $t4 a $v1
	add $v1, $t4, $zero
	#Se regresa al proceso principal
	jr $ra

verificarConversionResultadoNegativo:
	# si $s7 es igual a 1, significa que solo uno de los operando es negativos, entonces se debe convertir el resultado de la multiplicacion
	beq $s7, 1, convertirResultadoANegativo
	#En caso que no sea 1 se regresa al main
	jr $ra
	
convertirResultadoANegativo:
	# Como no es posible convertir el cero en negativo, entonces en vez de convertir el primer operando a negativo, solo se imprimira un negativo por pantalla
	#Se imprime por pantalla el simbolo menos
	la $a0, imprimirMenos
	li $v0, 4
	syscall
	#Se vuelve al proceso principal
	jr $ra

divisionCero:
	#Se verifica si el segundo operando es cero
	beqz $a2, terminoDivisionCero
	#En caso que no sea cero se vuelve al main
	jr $ra

terminoDivisionCero:
	# Se imprime por pantalla que no es posible dividir por cero
	la $a0, imprimirCasoCero
	li $v0, 4 #El codigo 4 permite mostrar texto por consola
	syscall
	#Se termina la ejecucion del programa
	li $v0, 10 #El codigo 10 termina la ejecución del programa
	syscall
