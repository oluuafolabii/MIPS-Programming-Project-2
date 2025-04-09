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

    la   $t0, input_buffer     
    addi $t0, $t0, 1000        
    sb   $zero, 0($t0)         # enforce null terminator at end

    la   $t0, input_buffer
strip_loop:
    lb   $t2, 0($t0)
    beq  $t2, $zero, strip_done
    li   $t3, 10             # LF
    beq  $t2, $t3, kill_char
    li   $t3, 13             # CR
    beq  $t2, $t3, kill_char
    addi $t0, $t0, 1
    j    strip_loop
kill_char:
    sb   $zero, 0($t0)       # replace with null
    j    strip_done
strip_done:

    la   $t0, input_buffer
    li   $t1, 0              # counter = 0
len_loop:
    lb   $t2, 0($t0)
    beq  $t2, $zero, len_done
    addi $t1, $t1, 1
    addi $t0, $t0, 1
    j    len_loop
len_done:
    move $t3, $t1            # $t3 now holds the input length

    la   $t0, input_buffer
    add  $t0, $t0, $t3       # point to just after the last valid character
    sb   $zero, 0($t0)       # force null terminator there

    addi $t4, $t3, 9         # length + 9
    li   $t5, 10
    div  $t4, $t5
    mflo $t6                 # $t6 = number of substrings

    la   $s6, input_buffer   # base address of input
    li   $t7, 0              # overall input index
    li   $t8, 0              # substring counter (0-indexed)
    li   $s4, 10             # constant 10

main_loop:
    bge  $t8, $t6, main_done  # if substring counter >= num_substrings, exit loop

    la   $t9, substring      # pointer to substring buffer
    li   $s3, 0              # inner loop counter for 10 chars
copy_loop:
    bge  $s3, $s4, copy_done  # if 10 characters copied, exit loop
    blt  $t7, $t3, copy_valid # if there is still input, copy character
    li   $t1, 32             # pad with space if no input remains
    j    copy_store
copy_valid:
    add  $t2, $s6, $t7       # compute address: base + input index
    lb   $t1, 0($t2)         # load character
copy_store:
    sb   $t1, 0($t9)         # store into substring buffer
    addi $t9, $t9, 1
    addi $s3, $s3, 1         # increment inner loop counter
    addi $t7, $t7, 1         # increment overall input index
    j    copy_loop
copy_done:
    la   $t9, substring
    sb   $zero, 10($t9)      # null-terminate the substring

