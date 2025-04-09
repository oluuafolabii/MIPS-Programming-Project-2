.data
prompt:         .asciiz "Enter input: "
newline:        .asciiz "\n"
debugLen:       .asciiz "Input length: "      # optional debug
debugSubs:      .asciiz "Num substrings: "    # optional debug
input_buffer:   .space 1001   # up to 1000 chars + null
substring:      .space 11     # 10 chars + null
semicolon_str:  .asciiz ";"
null_str:       .asciiz "NULL"

