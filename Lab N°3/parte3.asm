.data
	pedirOperando: .asciiz "Por favor ingrese el termino de fibonnaci hasta cual desea encontrar: "
	stringRespuesta: .asciiz "\n El arreglo es: "
	guion: .asciiz " - "
	
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
	
	#Se inicializa un arreglo en $t5:
	addiu $t5, $zero, 0x10010100 #Se fija la direccion de memoria
	#Se grabaran los casos base directamente en el arreglo:
	addiu $t1, $t5, 4
	li $t2, 1
	sw $t2, 0($t1)
	
	#Se calcula el termino de fibonacci
	jal fibonacci #Resultado se encuentra en v1
	
	#Se escribe el resultado
	
	la $a0, stringRespuesta
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
	
	#A continuacion se escribe el arreglo
	li $t7, 0
	jal escribirArreglo
	
	#Se termina la ejecución del programa
	li $v0, 10 #El codigo 10 termina la ejecución del programa
	syscall

fibonacci:
	#Caso base n == 0
	beqz $a1, casoCero
	
	#Caso base n == 1
	beq $a1, 1, casoUno
	
	#Se verifica si esta el valor de fibonnaci n en el arreglo
	sll $t1, $a1, 2 #Se multiplica n por 4 para conseguir la posicion en el arreglo
	add $t1, $t1, $t5 #Se añade a la direccion de memoria base del arreglo para conseguir la dirección exacta a revisar
	lw $v1, 0($t1) #Se carga el numero almacenado en el arreglo
	bne $v1, 0, recuperarValorArreglo #Si es distinto a cero significa que el valor si se encuentra dentro del arreglo
	
	#En caso de no estar dentro del arreglo se debera calcular:
	
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
	
	#Se guarda el valor calculado en el arreglo:
	sll $t1, $a1, 2 #Se multiplica por 4 para conseguir la posicion en el arreglo
	add $t1, $t1, $t5 #Se añade a la direccion de memoria base del arreglo para conseguir la dirección exacta a escribir
	sw $v1, 0($t1)
	
	#Finalmente se avanza al siguiente valor de n o se sale de la sub rutina
	jr $ra 

recuperarValorArreglo:
	#El valor ya se encuentra en v1
	jr $ra
	
casoCero:
	li $v1, 0 #Se carga el resultado como 0
	jr $ra
	
casoUno:
	li $v1, 1 #Se carga el resultado como 1
	jr $ra

escribirArreglo:
	blt $a1, $t7, salirEscribirArreglo
	#Se calcula la dirección
	sll $t1, $t7, 2 #Se multiplica por 4
	add $t1, $t1, $t5 #Se consigue la dirección exacta que se leera

	#Se imprime el guion
	la $a0, guion
	#Se usa el codigo 4 en la llamada de sistema para imprimir el string por pantalla
	li $v0, 4
	syscall
	#Se imprime el numero
	lw $a0, 0($t1) #Se carga el valor del arreglo en t0
	li $v0, 1
	syscall
	#se añade uno al contador
	addi $t7, $t7, 1
	j escribirArreglo
	
salirEscribirArreglo:
	jr $ra #Se vuelve a la rutina
	
	
