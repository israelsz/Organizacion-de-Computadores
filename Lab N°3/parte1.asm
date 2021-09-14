.data
	pedirOperando: .asciiz "Por favor ingrese el entero positivo a evaluar: "
	imprimirCasoCero: .asciiz "No es posible dividir por cero !"
	imprimirCoseno: .asciiz "\n El coseno del numero ingresado es: "
	imprimirSenoHip: .asciiz "\n El seno hiperbolico del numero ingresado es: "
	imprimirLn: .asciiz "\n El Logaritmo natural del numero ingresado es:  "
	errorLn: .asciiz "\n EL logaritmo natural de cero no se encuentra definido ! "
	
	positivo1: .float 1.0
	positivo0.1: .float 0.1
	positivo0.01: .float 0.01
	cero: .float 0.0
	menos1: .float -1.0
	menos0.1: .float -0.1
	menos0.01: .float -0.01
	
.text
main:
	# Se imprime el texto para pedir el numero entero el cual sera evaluado
	la $a0, pedirOperando
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
	
	# Para leer un entero se usa el codigo 5 en la llamada de sistema
	li $v0, 5
	syscall
	# El numero queda en $v0, se guarda en $t7
	add $t7, $v0, $zero
	
	#Se calculara su Coseno de orden 7
	jal calcularCoseno
	
	#Escribir coseno
	
	la $a0, imprimirCoseno
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
	
	li $v0, 2 #Codigo 2 printea floats del registro f12
	mov.s $f12, $f5 #Se carga el numero a printear en f12
	syscall
	
	#Se calculara su Seno Hiperbolico
	jal calcularSenoHip
	
	#Escribir Seno Hip
	
	la $a0, imprimirSenoHip
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
	
	li $v0, 2 #Codigo 2 printea floats del registro f12
	mov.s $f12, $f5 #Se carga el numero a printear en f12
	syscall
	
	#Se calculara su Logaritmo natural ln(1-x)
	jal calcularLn
	
	#Escribir Ln
	
	la $a0, imprimirLn
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
	
	li $v0, 2 #Codigo 2 printea floats del registro f12
	mov.s $f12, $f5 #Se carga el numero a printear en f12
	syscall
	
	# Se termina la ejecución del programa
	li $v0, 10
	syscall

calcularLn: #Se calcula el valor de Ln(1-x)
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t1, 1 #Contador
	l.s $f5, cero #Acumulador
	l.s $f3, cero #Acumulador
	#Se verifica el caso cero
	beqz $t7, LnCasoCero
	#Se verifica en caso que sea el caso 1 del logaritmo ln(1)
	beq $t7, 1, LnCasoUno
	#En caso que no sea 1, se le resta uno debido a que la serie corresponde a ln(1+x)
	subi $t7, $t7, 1
	j loopCalcularLn

LnCasoCero:
	la $a0, errorLn
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
		
	# Se termina la ejecución del programa
	li $v0, 10
	syscall

LnCasoUno:
	#Se carga el valor de cero en f5
	l.s $f5, cero #Acumulador
	jr $ra #Se vuelve al proceso principal

loopCalcularLn: #Resultado en f5
	beq $t1, 52, salirloopCalcularLn #Calculara desde 1 hasta 7
	
	# Se respalda el valor de $t1, ya que es usado en la otra función
	addi $sp, $sp, -8  # Se da espacio en el stack
	sw $t1, 0($sp)  # Se guarda el valor de $t1 en el stack
	sw $ra, 4($sp) #Se guarda tambien el valor de ra en el stack
	
	#Se calcula la parte de arriba de la division
	li $a1, -1
	addi $a3, $t1, 1 #n+1

	jal calcularElevado #Se calcula -1 elevado a n+1
	move $s0, $v1 #Se mueve el resultado a $s0 (parte de arriba de la division)
	
	lw $t1, 0($sp) #Se restaura el valor de t1 desde el stack
	
	#Ahora se calcula x elevado a n
	move $a1, $t7
	move $a3, $t1
	
	jal calcularElevado
	
	move $a2, $v1 #Se mueve el resultado a a2
	move $a1, $s0 #Se mueve el resultado de -1 elevado a n+1 a a1
	#t3 = a1 * a2
	jal multiplicar
	move $s0, $t3 #Resultado de la parte de arriba de la multiplicacion
	
	lw $t1, 0($sp) #Se restaura el valor de t1 desde el stack
	
	#La parte de abajo de la división es solamente n, disponible en el registro $t1
	
	#Se procede a dividir:
	move $a1, $s0 #Se mueve la parte de arriba de la division a a1
	move $a2, $t1 #Se mueve la parte de abajo de la division a a2
	
	jal dividir #Se efectua la division
	
	#Se traspasan los valores de la division a $t3, $t4 y $t5
	move $t3, $s4 #Parte entera
	move $t4, $s5 #Primer decimal
	move $t5, $s6 #Segundo decimal

	#Se transformaran los resultados a float
	jal convertirDivisionFloat
	
	#Se junta el numero solo en un registro
	add.s $f3, $f0, $f1
	add.s $f3, $f3, $f2
	
	#Se acumula en $f5 el resultado de todas los resultados
	add.s $f5, $f5, $f3 #Acumulador de resultados
	
	# Se restablece el valor del registro $t1
	lw $t1, 0($sp)    # Se carga el valor del registro $t1 anteriormente almacenado
	lw $ra, 4($sp)	  # Se carga el valor de $ra, almacenado
	addi $sp, $sp, 8  # Se restablece el valor de $sp (puntero)
	
	#Se aumenta en 1 el contador
	addi $t1, $t1, 1
	
	j loopCalcularLn
	
salirloopCalcularLn:
	jr $ra #Se vuelve a la rutina principal
	
calcularSenoHip:
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t1, 0 #Contador
	l.s $f5, cero #Acumulador
	l.s $f3, cero #Acumulador
	j loopCalcularSenoHip

loopCalcularSenoHip: #Resultado en f5
	beq $t1, 6, salirLoopCalcularSenoHip #Calculara desde 0 hasta 6
	
	# Se respalda el valor de $t1, ya que es usado en la otra función
	addi $sp, $sp, -8  # Se da espacio en el stack
	sw $t1, 0($sp)  # Se guarda el valor de $t1 en el stack
	sw $ra, 4($sp) #Se guarda tambien el valor de ra en el stack
	
	#Se calcula la parte de arriba de la division
	
	li $a1, 2
	move $a2, $t1
	#t3 = a1 * a2
	jal multiplicar #da el valor de 2*n
	
	addi $t3, $t3, 1 #Da el valor de 2n+1
	
	move $a3, $t3 #Se mueve el resultado de 2n+1 al registro $a3
	move $t6, $t3 #Tambien se mueve el resultado de 2n+1 a $t6
	
	move $a1, $t7 #Se carga el numero x al cual se quiere calcular su valor
	
	#Se calcula x elevado a 2n+1
	jal calcularElevado
	#Se mueve el resultado a $s0 (parte de arriba de la division)
	move $s0, $v1
	
	#Ahora se calculara la parte de abajo de la division
	move $a3, $t6 #Se mueve 2n+1 a $a3
	
	# v1 = !a3
	jal calcularFactorial
	move $s1, $v1 #Se mueve este resultado a $s1
	
	#Finalmente se divide
	move $a1, $s0
	move $a2, $s1
	
	jal dividir
	
	#Se traspasan los valores de la division a $t3, $t4 y $t5
	move $t3, $s4 #Parte entera
	move $t4, $s5 #Primer decimal
	move $t5, $s6 #Segundo decimal

	#Se transformaran los resultados a float
	jal convertirDivisionFloat
	
	#Se junta el numero solo en un registro
	add.s $f3, $f0, $f1
	add.s $f3, $f3, $f2
	
	#Se acumula en $f5 el resultado de todas los resultados
	add.s $f5, $f5, $f3 #Acumulador de resultados
	
	# Se restablece el valor del registro $t1
	lw $t1, 0($sp)    # Se carga el valor del registro $t1 anteriormente almacenado
	lw $ra, 4($sp)	  # Se carga el valor de $ra, almacenado
	addi $sp, $sp, 8  # Se restablece el valor de $sp (puntero)
	
	#Se aumenta en 1 el contador
	addi $t1, $t1, 1
	
	j loopCalcularSenoHip

salirLoopCalcularSenoHip:
	jr $ra


calcularCoseno:
	li $s4, 0
	li $s5, 0
	li $s6, 0
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t1, 0 #Contador
	l.s $f5, cero #Acumulador
	l.s $f3, cero #Acumulador
	j loopCalcularCoseno

loopCalcularCoseno: #Resultado en f5
	beq $t1, 7, salirLoopCalcularCoseno #Calculara desde 0 hasta 7
			
	# Se respalda el valor de $t1, ya que es usado en la otra función
	addi $sp, $sp, -8  # Se da espacio en el stack
	sw $t1, 0($sp)  # Se guarda el valor de $t1 en el stack
	sw $ra, 4($sp) #Se guarda tambien el valor de ra en el stack
	
	#Se calcula la parte de arriba de la division
	li $a1, -1
	move $a3, $t1
	
	jal calcularElevado #Calcula -1 elevado a n
	move $s0, $v1 #Se mueve este resultado a $s0
	
	
	
	lw $t1, 0($sp)    # Se carga el valor del registro $t1 anteriormente almacenado
	
	li $a1, 2
	move $a2, $t1
	#t3 = a1 * a2
	jal multiplicar #da el valor de 2*n
		
	move $a1, $t7 #Se carga el numero x al cual se quiere calcular su valor de coseno
	move $a3, $t3 #Se mueve el resultado de la multiplicacion al registro $a3
	move $t6, $t3 #Tambien se mueve el resultado de la multiplicacion a $t6
	
	jal calcularElevado #Calcula el valor de x elevado a 2n
	move $s1, $v1 #Se mueve este resultado a $s1
	
	#A continuación se multiplicaran los dos resultados conseguidos de la parte de arriba
	move $a1, $s0
	move $a2, $s1
	jal multiplicar
	move $s0, $t3 #Se almacena el resultado de toda la parte de arriba de la division en el registro $s0
		
	
	#Ahora se debe calcular la parte de abajo de la division, para ello
	move $a3, $t6 #Se mueve 2n a $a3
	# v1 = !a3
	jal calcularFactorial
	move $s1, $v1 #Se mueve este resultado a s1
	
	#Ahora resta dividir
	#Se cargan los operandos
	move $a1, $s0
	move $a2, $s1
	
	jal dividir
	
	#Se traspasan los valores de la division a $t3, $t4 y $t5
	move $t3, $s4 #Parte entera
	move $t4, $s5 #Primer decimal
	move $t5, $s6 #Segundo decimal

	#Se transformaran los resultados a float
	jal convertirDivisionFloat
	
	#Se junta el numero solo en un registro
	add.s $f3, $f0, $f1
	add.s $f3, $f3, $f2

	
	#Se acumula en $f5 el resultado de todas los resultados
	add.s $f5, $f5, $f3 #Acumulador de resultados
	
	# Se restablece el valor del registro $t1
	lw $t1, 0($sp)    # Se carga el valor del registro $t1 anteriormente almacenado
	lw $ra, 4($sp)	  # Se carga el valor de $ra, almacenado
	addi $sp, $sp, 8  # Se restablece el valor de $sp (puntero)
	
	#Se aumenta en 1 el contador
	addi $t1, $t1, 1
	
	j loopCalcularCoseno
	
salirLoopCalcularCoseno:
	jr $ra #Se escapa
	
convertirDivisionFloat:
	# Se respalda el valor del registro $ra para poder volver al proceso
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack

	#Se verifica si el numero es negativo o positivo
	#Si es negativo
	beq $s7, 1, convertirDecimalNegativo
	
	#Si no entro en la condición anterior, significa que es positivo
	j convertirDecimalPositivo
	

convertirDecimalPositivo:
	#En primer lugar se convertira la parte entera
	l.s $f12, positivo1
	l.s $f0, cero
	
	jal convertirParteEnteraPositivo
	
	#Luego se convierte el primer decimal
	l.s $f12, positivo0.1
	l.s $f1, cero
	
	jal convertirPrimerDecimalPositivo
	
	#Luego se convierte el segundo decimal
	l.s $f12, positivo0.01
	l.s $f2, cero
	
	jal convertirSegundoDecimalPositivo
	
	#Se restauran el valor de ra del stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#Se regresa al proceso
	jr $ra	

convertirParteEnteraPositivo:
	beq $t3, 0, salirParteEnteraPositivo
	
	sub $t3, $t3, 1
	add.s $f0, $f0, $f12
	
	j convertirParteEnteraPositivo

salirParteEnteraPositivo:
	jr $ra

convertirPrimerDecimalPositivo:
	beq $t4, 0, salirConvertirPrimerDecimalPositivo
	
	sub $t4, $t4, 1
	add.s $f1, $f1, $f12
	
	j convertirPrimerDecimalPositivo

salirConvertirPrimerDecimalPositivo:
	jr $ra

convertirSegundoDecimalPositivo:
	beq $t5, 0, salirConvertirSegundoDecimalPositivo
	
	sub $t5, $t5, 1
	add.s $f2, $f2, $f12
	
	j convertirSegundoDecimalPositivo
	
salirConvertirSegundoDecimalPositivo:
	jr $ra

convertirDecimalNegativo:
	#En primer lugar se convertira la parte entera
	l.s $f12, menos1
	l.s $f0, cero
	
	jal convertirParteEnteraNegativa
	
	#Luego se convierte el primer decimal
	l.s $f12, menos0.1
	l.s $f1, cero
	
	jal convertirPrimerDecimalNegativo
	
	#Luego se convierte el segundo decimal
	l.s $f12, menos0.01
	l.s $f2, cero
	
	jal convertirSegundoDecimalNegativo
	
	#Se restauran el valor de ra del stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#Se regresa al proceso
	jr $ra

convertirParteEnteraNegativa:
	beq $t3, 0, salirParteEnteraNegativa
	
	add $t3, $t3, 1
	add.s $f0, $f0, $f12
	
	j convertirParteEnteraNegativa
	
salirParteEnteraNegativa:
	jr $ra

convertirPrimerDecimalNegativo:
	beq $t4, 0, salirConvertirPrimerDecimalNegativo
	
	sub $t4, $t4, 1
	add.s $f1, $f1, $f12
	
	j convertirPrimerDecimalNegativo

salirConvertirPrimerDecimalNegativo:
	jr $ra

convertirSegundoDecimalNegativo:
	beq $t5, 0, salirConvertirSegundoDecimalNegativo
	
	sub $t5, $t5, 1
	add.s $f2, $f2, $f12
	
	j convertirSegundoDecimalNegativo
	
salirConvertirSegundoDecimalNegativo:
	jr $ra
	
dividir: # a1 /a2 | entero en $s4, decimal 1 en $s5, decimal 2 en $s6
	
	# Se respalda el valor del registro $ra para poder volver a donde se llamó a "dividir"
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	#Se reinician contadores, los mismos ocupados para multiplicar
	jal reiniciarContadoresMultiplicacion
	li $t9, 0 #Ademas se reinicia t9 manualmente
	#Se verifica caso base de division por cero
	jal divisionCero
	
	#En caso de haber un operando negativo, este se convertira a positivo
	jal convertirPrimerOperando
	jal convertirSegundoOperando
	
	# Guarda s7
	addi $sp, $sp, -4  
	sw $s7, 0($sp)  
	
	jal calcularDivision #Se efectua la división
	
	#Restaura s7
	lw $s7, 0($sp)  
	addi $sp, $sp, 4  
	
	#En caso de que algun operando haya sido negativo, se verificara si es necesario convertir a negativo el resultado
	jal verificarConversionResultadoNegativoDivision
	
	# Se restablece el valor del registro $ra para volver a main
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
	
	#Se regresa al proceso principal
	jr $ra

calcularDivision:
	add $t2, $t2, $zero #Se fija el contador en 0
	
	# Se respalda el valor del registro $ra para poder volver a donde se llamó a "dividir"
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	
	jal divisionEntera #Se efectua la division de la parte entera
	
	move $s4, $t2 #Se mueve el resultado de $t2 a $s4
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
	beqz $a1, salirCalculoDecimalNoDecimales #Si el resto es cero, no hay decimales por lo que se escapa del ciclo
	
	#Se almacena el valor del dividendo en el stack
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	
	#Ya que hay resto, el resto se multiplicara por 10 el resto
	li $a2, 10 #Se fija el segundo operando de la multiplicacion como 10
	
	# Se respalda el valor del registro $ra para poder volver a donde se llamó a "calcularDecimales"
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	
	jal multiplicar #Se efectua la multiplicacion
	
	move $a1, $t3 #Se mueve a $a1 el valor de la multiplicacion que se encuentra en $t3
	li $t2, 0 #Reinicio de contador
	
	#Se restaura el valor del dividendo
	lw $a2, 0($sp)
	addi $sp, $sp, 4
	
	jal divisionEntera #Se efectua la division entre el resto*10 y el dividendo de a2
	
	move $s5, $t2 #Se mueve el valor del primer decimal a $s5
	
	# Se restablece el valor del registro $ra
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
	
	
	# se verifica si aun queda resto
	beqz $a1, salirCalculoDecimal #Si el resto es cero, no hay decimales por lo que se escapa del ciclo
	
	#En caso de que no se haya escapado del ciclo, se calculara el segundo decimal:
	
	#Se almacena el valor del dividendo en el stack
	addi $sp, $sp, -4
	sw $a2, 0($sp)
	
	#Ya que hay resto, el resto se multiplicara por 10 el resto
	li $a2, 10 #Se fija el segundo operando de la multiplicacion como 10
	
	# Se respalda el valor del registro $ra para poder volver a donde se llamó a "calcularDecimales"
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	jal multiplicar #Se efectua la multiplicacion
	
	move $a1, $t3 #Se mueve a $a1 el valor de la multiplicacion que se encuentra en $t3
	li $t2, 0 #Reinicio de contador
	
	#Se restaura el valor del dividendo
	lw $a2, 0($sp)
	addi $sp, $sp, 4
	
	jal divisionEntera #Se efectua la division entre el resto*10 y el dividendo
	
	# Se restablece el valor del registro $ra
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
	
	move $s6, $t2 #Se mueve el valor del segundo decimal a $s6
	
	jr $ra #Se escapa del ciclo
	
salirCalculoDecimalNoDecimales:
	li $s5, 0
	li $s6, 0
	jr $ra #Se regresa al proceso de division

salirCalculoDecimal:
	li $s6, 0
	jr $ra #Se regresa al proceso de division

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
	
calcularFactorial: # v1 = a3!
	li $t2, 0 #Reinicio de contador
	li $t4, 1 #Reinicio de acumulador
	j loopCalcularFactorial
	
loopCalcularFactorial:
	#Se verifica la condicion de termino: si $t2 es igual al numero cuyo factorial esta siendo calculado se procede a escribir el resultado
	beq $t2, $a3, escribirResultadoFactorial
	
	
	#Si aun no acaba el ciclo, se calcula la multiplicacion del valor actual de $t2 con la acumulacion
	add $a1, $t4, $zero #Se traspasa el valor acumulado en $t4 al registro $a1 ahora es el primer operando de la multiplicacion
	add $a2, $t2, $zero #Se traspasa el valor actual de $t2 a $a2, sera el segundo operando de la multiplicacion

	# Se respalda el valor de registros
	addi $sp, $sp, -8  # Se da espacio en el stack
	sw $t2, 0($sp)  # Se guarda el valor de $t2 en el stack
	sw $ra, 4($sp)  #Se guarda el valor de $ra en el stack
	
	#t3 = a1*a2
	jal multiplicar #Se efectua la multiplicacion en una subrutina
	
	# Se restablece el valor de los registros
	lw $t2, 0($sp) # Se restaura el valor de $t2
	lw $ra, 4($sp) # Se restaura el valor de $ra
	addi $sp, $sp, 8 #Se restaura el espacio en el stack
			
	#Luego de efectuar la multiplicacion se actualizan los acumuladores
	add $t4, $t4, $t3 # $t4 contiene la suma de las multiplicaciones
	addi $t2, $t2, 1
	j loopCalcularFactorial

escribirResultadoFactorial:
	#El resultado del factorial se encuentra en $t4
	move $v1, $t4 #Se mueve el resultado del factorial al registro $v1
	jr $ra


calcularElevado: #v1 = a1**a3 | a1 = a2
	# Caso borde, si esta elevado a 0
	beq $a3, 0, calcularElevadoCero
	
	#Segundo caso borde si a3 = 1
	beq $a3, 1, calcularElevadoUno
	# Se respalda el valor del registro $ra para poder volver a donde se llamó a calcularElevado
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	#Se guarda el valor de a2 = a1 y se respalda en a0
	add $a2, $a1, $zero
	add $a0, $a1, $zero
	
	#En primer lugar se reinicia el contador
	jal reiniciarContador
	
	#Se resta 1 a a3
	subi $a3, $a3, 1
	
	#Se elevara a1 a a3
	jal loopCalcularElevado
	
	#El resultado se encuentra en v1
	
	#Se regresa a donde se llamo la función para calcular el elevado
	# Se restablece el valor del registro $ra
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
	
	jr $ra

calcularElevadoUno:
	add $v1, $zero, $a1
	jr $ra
calcularElevadoCero:
	addi $v1, $zero, 1
	jr $ra
	
loopCalcularElevado:
	#Para cuando $t1 = $a3
	beq $t1, $a3, salirLoopCalcularElevado
	
	# Se respalda el valor de $t1, ya que es usado en la otra función
	addi $sp, $sp, -8  # Se da espacio en el stack
	sw $t1, 0($sp)  # Se guarda el valor de $t1 en el stack
	sw $ra, 4($sp) #Se guarda tambien el valor de ra en el stack
	
	#Se restaura el valor de a2, en caso que haya sido convertido a positivo
	add $a2, $a0, $zero
	
	# t3 = t3 * a1
	jal multiplicar
	
	#Se mueve el resultado de la multiplicacion en $a1, para poder acumular el resultado
	move $a1, $t3
	
	# Se restablece el valor del registro $t1
	lw $t1, 0($sp)    # Se carga el valor del registro $t1 anteriormente almacenado
	lw $ra, 4($sp)	  # Se carga el valor de $ra, almacenado
	addi $sp, $sp, 8  # Se restablece el valor de $sp (puntero)
	
	# t1 = t1 + 1
	addi $t1, $t1, 1
	
	j loopCalcularElevado

salirLoopCalcularElevado:
	move $v1, $a1 #Se mueve el resultado de la operacion a $v1
	jr $ra #Se vuelve donde se llamo al loop
		
reiniciarContador:
	#el registro $t0 sera usado de contador
	li $t0, 0
	li $t1, 0
	jr $ra

multiplicar: #t3 = a1*a2
	# Se respalda el valor del registro $ra para poder volver a donde se llamó al subproceso
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	#En primer lugar se reinician los contadores
	jal reiniciarContadoresMultiplicacion
	
	#En caso de haber un operando negativo, este se convertira a positivo
	jal convertirPrimerOperando
	jal convertirSegundoOperando
	
	#Se multiplica a1*a2, resultado disponible en t3
	jal loopMultiplicar
	
	#En caso de que algun operando haya sido negativo, se verificara si es necesario convertir a negativo el resultado
	jal verificarConversionResultadoNegativo
	
	# Se restablece el valor del registro $ra
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
	
	jr $ra #Se regresa a donde se llamo la subrutina
	
loopMultiplicar:
	#Se verifica condicion de termino: si $t1 es igual a2 segundo operando se procede a escribir el resultado
	beq $t1, $a2, escribirResultado
	
	#En caso que aun se este multiplicando
	add $t2, $t2, $a1 # Se acumula la suma del primer operando en el registro $t2
	addi $t1, $t1, 1 #Se suma uno al valor actual de $t1, el que es usado como contador
	j loopMultiplicar #Se vuelve al ciclo
	
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
	add $t0, $t3, $zero #Se traspasa el valor de $t3 al registo $t0
	# A continuacion se resta dos veces $t0 a $t3, para que pase a su forma negativa
	sub $t3, $t3, $t0
	sub $t3, $t3, $t0
	#Se regresa al main
	jr $ra

verificarConversionResultadoNegativoDivision:
	# si $s7 es igual a 1, significa que solo uno de los operando es negativos, entonces se debe convertir el resultado de la multiplicacion
	beq $s7, 1, convertirResultadoANegativoDivision
	#En caso que no sea 1 se regresa al main
	jr $ra

convertirResultadoANegativoDivision:
	add $t0, $s4, $zero #Se traspasa el valor de $s4 al registo $t0
	# A continuacion se resta dos veces $t0 a $t3, para que pase a su forma negativa
	sub $s4, $s4, $t0
	sub $s4, $s4, $t0
	#Se regresa al proceso
	jr $ra

escribirResultado:
	#Se traspasa el valor de $t2 a $t3
	add $t3, $t2, $zero
	#Se regresa al proceso principal
	jr $ra

reiniciarContadoresMultiplicacion:
	#el registro $t1 sera usado de contador, $t2 y $t3 acumuladores y $s7 como verificador de negativos
	li $t0, 0
	li $t1, 0
	li $t2, 0
	li $t3, 0
	li $s7, 0
	jr $ra
