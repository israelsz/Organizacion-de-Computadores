.data
	base: .word 2
	exponente: .word 5
.text
	
	lw $a1, base
	lw $a2, exponente
	
	main:
	
		jal potencia
		
		#Para terminar la ejecucion
		li $v0, 10
		syscall
	
	#-------------------------------------  POTENCIA  ----------------------------------------------
	#Se crea una sub rutina para el calculo de la potencia para base y exponente enteros
	#la base debe estar en $f4 y el exponente en $a2
	potencia: 
		#Se respaldan los valores de los registros que seran utilizados
		addi $sp, $sp, -4
		sw $s0, 0($sp)
		
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
		addi $sp, $sp, 4
		
		jr $ra
		
		
		
	loopPotencia: 
		
		beq $t1, $a2, exitLoopPotencia
		mul $s0, $s0, $a1
		addi $t1, $t1, 1
		j loopPotencia
		
	exitLoopPotencia:
		jr $ra
		
