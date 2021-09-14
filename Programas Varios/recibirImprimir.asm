.data
	pedirNumeroEntero: .asciiz "Ingrese un numero entero: "
	pedirNumeroDouble: .asciiz "Ingrese un numero decimal: "
	
	imprimirEntero: .asciiz "Su numero entero es: "
	imprimirDecimal: .asciiz "\nSu numero decimal es: "
	
.text
	# Para imprimir texto este debe estar en $a0 y se hace con el codigo 4
	la $a0, pedirNumeroEntero
	li $v0, 4
	syscall
	
	# Para leer un entero se usa el codigo 5
	li $v0, 5
	syscall
	# El numero queda en $v0, se guarda en $s1
	move $s1, $v0
	
	# Para imprimir texto este debe estar en $a0 y se hace con el codigo 4
	la $a0, pedirNumeroDouble
	li $v0, 4
	syscall
	
	# Para leer un numero double se usa el codigo 7
	li $v0, 7
	syscall
	# El numero queda en $f0, se guarda en $f2
	add.d $f2, $f30, $f0
	
	# Para imprimir texto este debe estar en $a0 y se hace con el codigo 4
	li $v0, 4
	la $a0, imprimirEntero
	syscall
	
	# Para imprimir un numero entero este debe estar en el registro $a0 y se usa el codigo 1
	li $v0, 1
	add $a0, $s1, $zero
	syscall
	
	# Para imprimir texto este debe estar en $a0 y se hace con el codigo 4
	li $v0, 4
	la $a0, imprimirDecimal
	syscall
	
	# Para imprimir un numero double este debe estar en el registro $f12 y se usa el codigo 3
	li $v0, 3
	add.d $f12, $f2, $f30
	syscall
	
	# Para terminar la ejecucion del programa se usa el codigo 10
	li $v0, 10
	syscall
	
	# Para hacer efectivas las acciones se debe utilizar la instruccion syscall luego de cargar el codigo en $v0
	# y eventualmente el numero o texto en el registro correspondiente
