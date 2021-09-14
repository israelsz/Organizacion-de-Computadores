# El siguiente programa guarda 5 números en memoria y actualiza sus valores con el cuadrado del número correspondiente
.data
	numeros: .word 1 2 3 4 5
	cantidad: .word 5

.text
	main:
		# Se carga la dirección base del arreglo
		la $s0, numeros 
		# Se carga la cantidad de elementos del arreglo
		lw $s1, cantidad
	
		# Se deja en cero el contador $t1
		add $t1, $zero, $zero
	
		# Se salta la sub rutina que realiza el loop de la operación
		jal loop
	
		# Se termina la ejecución del programa
		li $v0, 10
		syscall
	
	# Sub rutina que realiza la operación
	loop:
		# Condición de salida, si el contador $t1 es igual a la cantidad de números en el arreglo, sale del loop
		beq $t1, $s1, exitLoop
		# Se carga el número correspondiente
		lw $t2, 0($s0)
		
		# Se respalda el valor del registro $ra para poder volver a donde se llamó a "loop"
		addi $sp, $sp, -4  # Se da espacio en el stack
		sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
		
		# Se asignan los valores de los argumentos de la sub rutina "potencia"
		add $a1, $zero, $t2 # Base = número correspondiente del arreglo cargado en la línea 26
		addi $a2, $zero, 2  # Exponente = 2
		
		# Se salta a la sub rutina "potencia"
		jal potencia
		
		# Se restablece el valor del registro $ra
		lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
		addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
		
		# Se guarda en memoria el nuevo valor, el cuadrado del número incialmente almacenado
		sw $v1, 0($s0)
		
		# Se pasa a la siguiente posición del arreglo
		addi $s0, $s0, 4
		# Se incrementa en 1 el contador
		addi $t1, $t1, 1
		
		# Se salta nuevamente a "loop"
		j loop
	
	# Para volver a donde se llamó a la sub rutina "loop" inicialmente (en la línea 15)
	exitLoop:
		jr $ra

	#-------------------------------------  POTENCIA  ----------------------------------------------
	#Se crea una sub rutina para el calculo de la potencia para base y exponente enteros
	#la base debe estar en $a1 y el exponente en $a2
	potencia: 
		#Se respaldan los valores de los registros que seran utilizados
		addi $sp, $sp, -8
		sw $s0, 0($sp)
		sw $t1, 4($sp)
		
		#El acumulador es $s0, se inicializa en uno
		addi $s0, $zero, 1
		add $t1, $zero, $zero  # $t1 sera el contador, se inicializa en 0
		
		#Se respalda $ra
		addi $sp, $sp, -4
		sw $ra, 0($sp)
		
		jal loopPotencia
		
		lw $ra, 0($sp)
		addi $sp, $sp, 4
		
		#Se deja el resulado en $v1
		move $v1, $s0
		
		#Se restauran los valores de los registros que fueron utilizados
		lw $s0, 0($sp)
		lw $t1, 4($sp)
		addi $sp, $sp, 8
		
		jr $ra
		
		
	loopPotencia: 
		
		beq $t1, $a2, exitLoopPotencia
		mul $s0, $s0, $a1
		addi $t1, $t1, 1
		j loopPotencia
		
	exitLoopPotencia:
		jr $ra
