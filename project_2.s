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

    la   $a0, substring
    jal  get_substring_value   # result in $v0

    li   $s7, 0x7FFFFFF       # flag value for invalid substring
    beq  $v0, $s7, print_null
    move $a0, $v0
    li   $v0, 1              # syscall: print integer
    syscall
    j    semicolon_check
print_null:
    la   $a0, null_str
    li   $v0, 4              # syscall: print string
    syscall

semicolon_check:
    addi $s5, $t8, 1         # $s5 = current substring counter + 1 (using $s5)
    blt  $s5, $t6, print_sc  # if not last substring, jump to print semicolon
    j    incr_loop
print_sc:
    la   $a0, semicolon_str
    li   $v0, 4
    syscall
incr_loop:
    addi $t8, $t8, 1         # increment substring counter
    j    main_loop

main_done:
    li   $v0, 10
    syscall

# Subroutine entry: save callee-saved registers.
get_substring_value:
    addi $sp, $sp, -12
    sw   $s0, 0($sp)
    sw   $s1, 4($sp)
    sw   $s2, 8($sp)

    li   $s0, 0       # count of valid characters
    li   $s1, 0       # sum for first half
    li   $s2, 0       # sum for second half
    li   $t0, 0       # index = 0
first_half_loop:
    li   $t1, 5
    bge  $t0, $t1, sh_start
    add  $t2, $a0, $t0
    lb   $t3, 0($t2)

    li   $t4, 48      # check digit range: '0'
    li   $t5, 57      # '9'
    blt  $t3, $t4, fh_lower
    bgt  $t3, $t5, fh_lower
    subu $t6, $t3, $t4
    add  $s1, $s1, $t6
    addi $s0, $s0, 1
    j    fh_next
fh_lower:
    li   $t4, 97      # check lowercase range: 'a'
    li   $t5, 119     # 'w'
    blt  $t3, $t4, fh_upper
    bgt  $t3, $t5, fh_upper
    subu $t6, $t3, $t4
    addi $t6, $t6, 10
    add  $s1, $s1, $t6
    addi $s0, $s0, 1
    j    fh_next
fh_upper:
    li   $t4, 65      # check uppercase range: 'A'
    li   $t5, 87      # 'W'
    blt  $t3, $t4, fh_next
    bgt  $t3, $t5, fh_next
    subu $t6, $t3, $t4
    addi $t6, $t6, 10
    add  $s1, $s1, $t6
    addi $s0, $s0, 1
fh_next:
    addi $t0, $t0, 1
    j    first_half_loop

sh_start:
    li   $t0, 5       # start index for second half
sh_loop:
    li   $t1, 10
    bge  $t0, $t1, calc_done
    add  $t2, $a0, $t0
    lb   $t3, 0($t2)

    li   $t4, 48
    li   $t5, 57
    blt  $t3, $t4, sh_lower
    bgt  $t3, $t5, sh_lower
    subu $t6, $t3, $t4
    add  $s2, $s2, $t6
    addi $s0, $s0, 1
    j    sh_next
sh_lower:
    li   $t4, 97
    li   $t5, 119
    blt  $t3, $t4, sh_upper
    bgt  $t3, $t5, sh_upper
    subu $t6, $t3, $t4
    addi $t6, $t6, 10
    add  $s2, $s2, $t6
    addi $s0, $s0, 1
    j    sh_next
sh_upper:
    li   $t4, 65
    li   $t5, 87
    blt  $t3, $t4, sh_next
    bgt  $t3, $t5, sh_next
    subu $t6, $t3, $t4
    addi $t6, $t6, 10
    add  $s2, $s2, $t6
    addi $s0, $s0, 1
sh_next:
    addi $t0, $t0, 1
    j    sh_loop

calc_done:
    beq  $s0, $zero, no_valid
    subu $v0, $s1, $s2
    j    restore_sub
no_valid:
    li   $v0, 0x7FFFFFF
restore_sub:
    lw   $s0, 0($sp)
    lw   $s1, 4($sp)
    lw   $s2, 8($sp)
    addi $sp, $sp, 12
    jr   $ra
