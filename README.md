# Computer-from-Sketch

Este é um projeto acadêmico de um processador simples de 8 bits, desenvolvido "do zero" em VHDL. O objetivo é simular os componentes fundamentais de um computador, implementando o ciclo completo de busca, decodificação e execução de instruções.

O processador é capaz de ler um "programa" em binário (um arquivo `.txt`), gerado por um assembler customizado, e executá-lo em simulação.

## Arquitetura

A arquitetura é baseada em uma Máquina de Estados Finitos (FSM) que orquestra os diferentes componentes. Os principais módulos VHDL são:

* **`controlDecoderEntity.vhd`**: Esta é a Unidade de Controle principal (CPU). Ela contém:
    * A **Máquina de Estados Finitos (FSM)** que gerencia o ciclo de instrução (busca, decodificação, execução).
    * Um **Program Counter (PC)** interno que aponta para a próxima instrução.
    * Um pequeno **Banco de Registradores** local para armazenar dados.
    * Uma **Memória de Instruções (ROM)** interna, que é inicializada no começo da simulação lendo o arquivo `sim/instructions.txt`.

* **`ulaEntity.vhd`**: A Unidade Lógica e Aritmética (ULA). É responsável por realizar as operações matemáticas (como SOMA, SUB) e lógicas (como AND, OR, NOT).

* **`processor_tb.vhd`**: O testbench principal, usado para simular o processador. Ele fornece o `clock` e o `reset`, e o processador executa o programa da ROM autonomamente.

## Assembler (Compilador)

Para facilitar a programação do processador, o projeto inclui um assembler customizado. Este programa (ex: `compiler.c`) converte uma linguagem de montagem (Assembly) legível por humanos em código de máquina binário que o processador entende.

### Fluxo de Programação

O fluxo de trabalho para criar e rodar um novo programa é:

1.  Escrever as instruções em Assembly em um arquivo (ex: `programa.asm`).
2.  Usar o assembler para converter o arquivo `.asm` no binário `instructions.txt`.
3.  Rodar a simulação do VHDL, que irá carregar o `instructions.txt` recém-gerado.

**Exemplo de Fluxo:**
```sh
