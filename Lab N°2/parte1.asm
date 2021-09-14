.data
	pedirPrimerEntero: .asciiz "Por favor ingrese el primer entero: "
	pedirSegundoEntero: .asciiz "Por favor ingrese el segundo entero: "
	
	imprimirMaximo: .asciiz "El maximo es: "	
.text
main:
	# Se imprime el texto para pedir el primer numero entero, se carga el string al registro $a0
	la $a0, pedirPrimerEntero
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
	
	# Para leer un entero se usa el codigo 5 en la llamada de sistema
	li $v0, 5
	syscall
	# El numero queda en $v0, se guarda en $a1
	add $a1, $v0, $zero
	
	
	# Se imprime el texto para pedir el segundo numero entero, se carga el string al registro $a0
	la $a0, pedirSegundoEntero
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
	
	# Para leer un entero se usa el codigo 5 en la llamada de sistema
	li $v0, 5
	syscall
	# El numero queda en $v0, se guarda en $a2
	add $a2, $v0, $zero
	
	#Se determina el maximo
	jal determinarMaximo
	
	#Se imprime por pantalla el texto previo a imprimir el numero maximo
	la $a0, imprimirMaximo
	li $v0, 4
	syscall
	
	# A continuacion se copia al registro $a0 el numero maximo que se encuentra en $v1 ya que el numero a imprimir debe estar en el registro $a0
	# se usa el codigo 1 en la llamada de sistema para imprimir numeros enteros por pantalla
	add $a0, $v1, $zero
	li $v0, 1
	syscall
	
	#El programa ya cumplio su funcion, entonces a continuación se termina la ejecución del programa
	li $v0, 10 #El codigo 10 termina la ejecución del programa
	syscall
	
determinarMaximo:
	bgt $a1, $a2, primerNumeroMaximo #¿Es a1 mayor a a2?
	#Si no se efectuo el salto, entonces $a2 es mayor o igual a $a0
	#Se traspasa el valor de $a2 al registro de resultados $v1
	add $v1, $a2, $zero
	#Se regresa al proceso principal
	jr $ra

primerNumeroMaximo:
	#Se traspasa el valor de $a1 al registro de resultados $v1
	add $v1, $a1, $zero
	#Se regresa al proceso principal
	jr $ra
