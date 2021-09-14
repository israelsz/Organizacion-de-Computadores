.data
	imprimirTexto: .asciiz "El resultado del factorial es: "
	
	# Definicion del numero cuyo factorial sera calculado
	factorialDe: .word 0
	
.text
main:
	lw $a3, factorialDe #Se carga el numero al cual se calculara su factorial
	add $t2, $zero, $zero #Se fija el registro $t2 al valor cero
	addi $t3, $zero, 1 #Se fija el registro $t3 al valor uno
	jal calcularFactorial
	
	
	#Se imprime por pantalla el texto previo a imprimir el resultado del factorial
	la $a0, imprimirTexto
	li $v0, 4
	syscall
	
	# A continuacion se copia al registro $a0 el resultado del factorial del registro $v1 ya que el numero a imprimir debe estar en el registro $a0
	# se usa el codigo 1 en la llamada de sistema para imprimir numeros enteros por pantalla
	add $a0, $v1, $zero
	li $v0, 1
	syscall
	
	#Se termina la ejecución del programa
	li $v0, 10 #El codigo 10 termina la ejecución del programa
	syscall

calcularFactorial:
	#Se verifica la condicion de termino: si $t2 es igual al numero cuyo factorial esta siendo calculado se procede a escribir el resultado
	beq $t2, $a3, escribirResultadoFactorial
	
	#Si aun no acaba el ciclo, se calcula la multiplicacion del valor actual de $t2 con la acumulacion
	add $a1, $t3, $zero #Se traspasa el valor acumulado en $t3 al registro $a1 ahora es el primer operando de la multiplicacion
	add $a2, $t2, $zero #Se traspasa el valor actual de $t2 a $a2, sera el segundo operando de la multiplicacion
	add $t0, $zero, $zero #Se fija el registro $t0 al valor cero
	add $t1, $zero ,$zero #Se fija el registro $t1 al valor cero
	
	# Se respalda el valor del registro $ra para poder volver a donde se llamó a "calcularFactorial"
	addi $sp, $sp, -4  # Se da espacio en el stack
	sw $ra, 0($sp)  # Se guarda el valor de $ra en el stack
	
	jal multiplicar #Se efectua la multiplicacion en una subrutina
	
	# Se restablece el valor del registro $ra
	lw $ra, 0($sp)    # Se carga el valor del registro $ra anteriormente almacenado
	addi $sp, $sp, 4  # Se restablece el valor de $sp (puntero)
	
	#Luego de efectuar la multiplicacion se actualizan los acumuladores
	add $t3, $t3, $v1 # $t3 contiene la suma de las multiplicaciones
	addi $t2, $t2, 1
	j calcularFactorial
	
multiplicar:
	#Se verifica condicion de termino: si $t0 es igual al segundo operando se procede a escribir el resultado
	beq $t0, $a2, escribirResultadoMultiplicacion
	
	#En caso que aun se este multiplicando
	add $t1, $t1, $a1 # Se acumula la suma del primer operando en el registro $t1
	addi $t0, $t0, 1 #Se suma uno al valor actual de $t0, el que es usado como contador
	j multiplicar #Se vuelve al ciclo
	
escribirResultadoMultiplicacion:
	#Se traspasa el valor de $t1 a $v1
	move $v1, $t1
	#Se regresa al proceso de calculo de factorial
	jr $ra

escribirResultadoFactorial:
	#El resultado del factorial se encuentra en $t3
	move $v1, $t3 #Se mueve el resultado del factorial al registro $v1
	jr $ra
