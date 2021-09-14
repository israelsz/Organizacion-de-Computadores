add $t3, $zero, 12
add $t4, $zero, 0
beq $t3, 0, A
beq $t3, 1, B
li $t4, 100

A:	add $t4, $t4, 1

B:	add $t4, $t4, -1
