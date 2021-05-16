# Laboratório 02 - Organização e Arquitetura de Computadores

## Abstract
This is an assignment for Universidade de Brasília's (University of Brasilia) course "Organização e Arquitetura de Computadores" (Computer Organization and Architecture). As such, most of its documentation is in Portuguese. The code available here is meant to simulate a 32-bit MIPS processor using the software Quartus II version 13.0.1 SP1 Web Edition and Verilog language. For more information, please ask one of the collaborators.

---
## Introdução
Este trabalho foi desenvolvido para a disciplina de Organização e Arquitetura de Computadores, durante o 2º semestre de 2020, da Universidade de Brasília. Seu objetivo é simular o funcionamento de um processador MIPS de 32 bits com as seguintes instruções:

* `lw \$t0, OFFSET(\$s3)`
* `add/sub/and/or/nor/xor \$t0, \$s2, \$t0`
* `sw \$t0, OFFSET(\$s3)`
* `j LABEL`
* `jr \$t0`
* `jal LABEL`
* `beq/bne \$t1, \$zero, LABEL`
* `slt \$t1, \$t2, \$t3`
* `lui \$t1, 0xXXXX`
* `addu/subu \$t1, \$t2, \$t3`
* `sll/srl \$t2, \$t3, 10`
* `addi/andi/ori/xori \$t2, \$t3, -10`
* `mult \$t1, \$t2`
* `div \$t1, \$t2`
* `li \$t1, XX`
* `mfhi/mflo \$t1`
* `bgez \$t1, LABEL`
* `clo \$t1, \$t2`
* `srav \$t1, \$t2, \$t3`
* `sra \$t2, \$t1, 10`
* `madd \$t1, \$t2`
* `msubu \$t1, \$t2`
* `jalr \$t1`
* `bgezal \$t1, LABEL`
* `addiu \$t1, \$t2, \$t3`
* `lb \$t1, 100(\$t2)`
* `movn \$t1, \$t2, \$t3`
* `mul \$t1, \$t2, \$t5`
* `sb \$t4, 1000(\$t2)`
* `slti/sltu \$t1, \$t2, -100`

O projeto foi desenvolvido utilizando o software Quartus II versão 13.0.1 SP1 Web Edition. Para executar a simulação, o arquivo `mips_uniciclo.v` deve estar definido como entidade *top-level* e o arquivo `mips_uniciclo_tb00.v` como *test bench*. As instruções do *assembly* MIPS devem ser compiladas e copiadas para o arquivo `UnicicloInst.mif`. A parte relativa à memória (`.data` no código *assembly*) deve ser copiada para o arquivo `UnicicloData.mif`. Maiores informações estão disponíveis no arquivo `mips_uniciclo_tb00.v`.

Repositório no GitHub: https://github.com/PeterTowers/lab2-OAC

## Estrutura
Todos os arquivos necessários para a execução do projeto estão no diretório raiz. O diretório `img` contém imagens das simulações exportadas em formato `.png` a partir do software ModelSim. É importante frisar que essas imagens não possuem o conteúdo completo das simulações. O diretório `test` contém códigos em *assembly* MIPS e seus respectivos *bytecodes* montados para permitir a execução de algumas simulações.