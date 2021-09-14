.data
	arr: .word 10 22 15 40
	end:

.text
	la $s0, arr  # $s0 posee la direccion base de arr  # esta instrucción pone la dirección base de arr en $s0			
	la $s1, end  # se carga la direccion siguiente al ultimo elemento de arr 
	subu $s1, $s1, $s0 # se hace la diferencia entre la direccion base y la direccion siguiente al ultimo elemento de arr
				# para obtener la cantidad de bytes entre ellas y poder sacar la cantidad de elementos en arr
			# ahora $s1 = num elementos en arreglo. ¿Cómo?  Porque srl da el desplazamiento logico
			# srl hace un desplazamiento de 2 bits hacia la derecha (se eliminan los ultimos dos bits)
			# esto es lo mismo que dividir por 4
			# por lo tanto, se divide la diferencia de bytes entre las direcciones por 4 porque cada palabra posee 4 bytes
			# asi se obtiene la cantidad de elementos de arr
	srl $s1, $s1, 2 # $s1 posee la cantidad de elementos de arr = arrlen
	
	add $s2, $zero, $zero  # $s2 es evensum
	add $t1, $zero, $zero  # $t1 = i
	
	for: 	
		# si arrlen es igual o menor a i, se sale del for
		beq $s1, $t1, exit
		slt $t2, $s1, $t1
		beq $t2, 1, exit
		j if
		
	if:
		mul $t6, $t1, 4
		add $t3, $s0, $t6
		lw $t4, 0($t3)  # se carga a[i] en $t4
		and $t5, $t4, 1	# La condicion determina si un numero es par (verdadero si es par)
		
		# se incrementa i en uno
		addi $t1, $t1, 1
		
		beq $t5, $zero, sum
		j for
	
	sum: 
		add $s2, $s2, $t4
		j for
		
	exit:
		li $v0, 10
		syscall
