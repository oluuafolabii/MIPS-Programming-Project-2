.data
prompt:         .asciiz "Enter input: "
newline:        .asciiz "\n"
debugLen:       .asciiz "Input length: "      # optional debug
debugSubs:      .asciiz "Num substrings: "    # optional debug
input_buffer:   .space 1001   # up to 1000 chars + null
substring:      .space 11     # 10 chars + null
semicolon_str:  .asciiz ";"
null_str:       .asciiz "NULL"

.text
.globl main
main:

    la   $t0, input_buffer      # pointer to input_buffer
    li   $t1, 1001              # number of bytes to clear
zero_loop:
    beq  $t1, $zero, zero_done
    sb   $zero, 0($t0)
    addi $t0, $t0, 1
    addi $t1, $t1, -1
    j    zero_loop
zero_done:

    la   $a0, prompt           # print prompt
    li   $v0, 4
    syscall

    la   $a0, input_buffer
    li   $a1, 1000             # read up to 1000 characters
    li   $v0, 8
    syscall

