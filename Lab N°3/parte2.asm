.data
	pedirOperando: .asciiz "Por favor ingrese el termino de fibonnaci que desea encontrar: "
	stringRespuesta: .asciiz "\n El resultado es: "
	
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
	# El numero queda en $v0, se guarda en $a1
	move $a1, $v0

	#Se calcula el termino de fibonacci
	jal fibonacci #Resultado se encuentra en v1
	
	#Se escribe el resultado
	
	la $a0, stringRespuesta
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
	
	# A continuacion se copia al registro $a0 el resultado de fibonacci del registro $v1 ya que el numero a imprimir debe estar en el registro $a0
	# se usa el codigo 1 en la llamada de sistema para imprimir numeros enteros por pantalla
	add $a0, $v1, $zero
	li $v0, 1
	syscall
	
	#Se termina la ejecución del programa
	li $v0, 10 #El codigo 10 termina la ejecución del programa
	syscall

fibonacci:
	#Caso base n == 0
	beqz $a1, casoCero
	#Caso base n == 1
	beq $a1, 1, casoUno
	
	#Se calcula fibonnaci(n-1)
	
	# Se respalda el valor del registro $ra para poder volver a este punto
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	subi $a1, $a1, 1 #n-1
	jal fibonacci #fibonacci(n-1)
	addi $a1, $a1, 1 #vuelve a ser n
	
	# Se restablece el valor del registro $ra
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp
	
	#Se almacena el valor conseguido de fibonnaci (n-1) en el stack
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $v1, 0($sp)  # Se guarda el valor de $v1 en el stack
	
	
	#Se calcula fibonacci (n-2)
	
	# Se respalda el valor del registro $ra para poder volver a este punto
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	subi $a1, $a1, 2 #n-2
	jal fibonacci #fibonacci(n-2)
	addi $a1, $a1, 2 #vuelve a ser n
	
	# Se restablece el valor del registro $ra
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp
	
	#Se calcula fibonnaci(n-1) + fibonacci(n-2)
	lw $t0, 0($sp) #Se carga el valor de n-1 almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp, para luego poder cargar otro resultado almacenado
	
	#En v1 se encuentra el resultado de fibonacci(n-2)
	add $v1, $v1, $t0 #Se realiza la suma de fibbonaci(n-2) + fibonnaci(n-1)
	#Finalmente se avanza al siguiente valor de n o se sale de la sub rutina
	jr $ra 
	
casoCero:
	li $v1, 0 #Se carga el resultado como 0
	jr $ra
	
casoUno:
	li $v1, 1 #Se carga el resultado como 1
	jr $ra