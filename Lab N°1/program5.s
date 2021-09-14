.data
arr: .word 10 12 15 2 9 7 4
end:
.text

la $s0, arr # esta instrucción pone la dirección base de arr en $s0
la $s1, end #Esta instruccion pone la direccion de la base end en $s1
subu $s1, $s1, $s0 #Se resta la direccion de $s1 con $s0 dando como resultado la direccion de memoria que corresponde usar luego de las usadas por el arreglo (+0, +4, +8, +c, etc)
srl $s1, $s1, 2 # ahora $s1 = num elementos en arreglo. ¿Cómo?
#Como $s1 ahora contiene "La posicion" que corresponde usar ahora en la dirección de memoria, basta dividir ese numero por 4 para conseguir la cantidad total de direcciones
#de memoria usadas por el arreglo.

add $t0, $t0, 0 # Se usa $t0 para la variable evensum
add $t1, $t1, 0 #Se usara $t1 como i = 0

for: 
	bgt $t1, $s1, salida #Se verifica si i < arrlen
	lw $t2, 0($s0) #Se carga el valor de la posicion del arreglo al registro t2. arr[i]
	and $t3, $t2, 1 #Se efectua la operacion AND entre arr[i] y 1. Se almacena su resultado en $t3
	beq $t3, 0, suma # Se verifica. if (arr[i] & 0) == 0
	add $t1, $t1, 1 # i = i + 1
	addiu $s0, $s0, 4 #Se avanza una posicion en el arreglo
	j for
suma:
	add $t0, $t0, $t2 #evensum += arr[i]
	add $t1, $t1, 1 # i = i + 1
	addiu $s0, $s0, 4 #Se avanza una posicion en el arreglo
	j for

salida:

#Nota: El programa suma todos los numeros pares presentes dentro del arreglo.

#los resultados de evensum se encuentran en el registro $t0 en formato hexadecimal.