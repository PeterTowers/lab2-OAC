.data
a: .word 9, 8, 7, 6, 5

.text
addi $t1, $zero, 0x10010000
lw $t1, 0($t1)
xor $t1, $zero, $t1
salta: add $t1, $t1, $t2
slt $t3, $t1, $t1
li $t2, 0x99999999
beq $t1, $t1, salta
addi $t1, $zero, 0x10010000
lw $t1, 3($t1)
srl $t1,$t1,31
li $t1, -1000
subu $t1, $zero, $t1
addi $t1, $zero, 0x10010000
lw $t1, 8($t1)
sll $t1, $t1, 10
mult $t1, $t1
mflo $t1
