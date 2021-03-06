#.section .text
#.global	calc_expr
.text
.global main
main:
	# rdi stores the address in memory to string_convert (will be saved in r14)
	# rsi stores the address in memory to result_as_string (will be saved in r15)
	movq %rdi, %r14
	movq %rsi, %r15
	# STEPS:
	# take string as input from STDIN and use the number of characters taken as input, to figure out length (func)
	# call split on the input string, using the provided len, and specifying start as 0 (func)
	# extra functions:
	# convert_leaf - will receive start, end and expr, will create a new char array and send it to string_convert func, and eventually return the numeric result
	# convert_no_para - will recieve i, start and expr, will create a new char array and send it to string_convert func, and eventually return the numeric result
	# determine_operator - will receive an ASCII character as input and will return an int to determine which operator to use (func)
	# is_arithmetic_operator - will receive an ASCII character as input and will return 1 if it is, and 0 otherwise (func)

	# implementation order:
    # 1. determine_operator (V)
    # 2. convert_leaf (V?)
    # 3. convert_non_para (V?)
    # 4. read_from_input (V)
    # 5. split (and PRAY)

read_from_input:
    # right now rsp points to the last saved value onto the stack, we will begin saving new values below, so we decrement r12
    # r12 will store the base address where the input string is stored
    movq %rsp, %r12
    sub $8, %r12
    # counter for string length
    xor %r13, %r13
read_another_char:
    movq $0, %rax
    movq $0, %rdi
    movq $CHAR_FROM_INPUT, %rsi
    movq $1, %rdx
    syscall

    movb (NULL_TERM), %al
    movb (CHAR_FROM_INPUT), %bl
    cmp %rax, %rbx
    ### if these are equal, that means we finished taking the string as input, need to add to the stack, but not increment counter
    je finish_string_input
    # pushing the character we recieved as input onto the stack
    push %rbx
    # manual stack writing
    # sub $8, %rsp
    # movq %rbx, (%rsp)
    # retrieve value (don't want to do this here)
    # pop %r10
    inc %r13
    jmp read_another_char

finish_string_input:
    # push $CHAR_FROM_INPUT
    # prepare for split
    # push $0
    # get the current value from the stack example:
    # movq (%r12), %r10
    movq %r12, %rdi # saving the address of char * expr in rdi
    movq $0, %rsi # saving start in rsi
    #movq $1, %rsi
    movq %r13, %rdx # saving the length of the string in rdx
    #movq $2, %rdx
#    call split
    call convert_leaf
#    ret
  movq $60, %rax
  movq $0, %rdi
  syscall

# long long split(char *expr, int start, int end);


# long long convert_leaf(char* expr, int start, int end)
convert_leaf:
    # rdi stores the address of the string
    # rsi stores the start index
    # rdx stores the end index
    # prologue
    pushq %rbp
    movq %rsp, %rbp
    # r11 stores the current index in the temporary char array
    movq %rsi, %r11
    # rbx stores int end
    movq %rdx, %rbx
    sub %rsi, %rbx # should do rbx - rsi and save in rbx
    add $2, %rbx # rbx should now store len = end - start + 2
    movq %rbx, %r9
    dec %r9 # r9 stores len - 1
    # r10 saves the number of characters pushed onto the stack
    xor %r10, %r10
    xor %r8, %r8
    imul $-1, %rsi
load_expr_loop:
    # now r8 stores the value from (rdi+rsi*1) == expr[j]
    movq (%rdi, %rsi, 8), %r8
    push %r8
    inc %r10
    dec %rsi
    inc %r11
    cmp %r11, %r9
    jne load_expr_loop
    movq $0, %r8
    push %r8 # pushes null terminator to the end of the stack
    inc %r10
    movq %rbp, %rdi
    # rdi now points to the adress on the stack, where the char* expr starts --> (%rdi) == expr[0]
    sub $8, %rdi

    call *%r14
    # now rax stores return value, which should be a long long number we wanted to convert from string
    # increasing stack size to delete old values pushed to the stack
    leaq (%rsp, %r10, 8), %rsp
    leave
    ret
    # need to push onto the stack the number we want to convert and (probably) pass a register storing the address to the conversion function
    # need to push null terminator to the end of the stack so that the function can stop converting

# int determine_operator(char op);
determine_operator:
    # rdi stores the character to check
    # prologue
    pushq %rbp
    movq %rsp, %rbp
    cmp $PLUS, %rdi
    jne check_minus
    movq $0, %rax
    jmp det_op_end
check_minus:
    cmp $MINUS, %rdi
    jne check_multi
    movq $1, %rax
    jmp det_op_end
check_multi:
    cmp $MULTI, %rdi
    jne check_divide
    movq $2, %rax
    jmp det_op_end
check_divide:
    cmp $DIVIDE, %rdi
    jne not_operator
    movq $3, %rax
    jmp det_op_end
not_operator:
    movq $4, %rax
det_op_end:
    # epilogue
    leave
    ret


.section .data
#PLUS: .ascii "+"
#MINUS: .ascii "-"
#MULTI: .ascii "*"
#DIVIDE: .ascii "/"
#OPEN_PAR: .ascii "("
#CLOSE_PAR: .ascii ")"
#NULL_TERM: .ascii "\0"
PLUS: .byte 43
MINUS: .byte 45
MULTI: .byte 42
DIVIDE: .byte 47
OPEN_PAR: .byte 40
CLOSE_PAR: .byte 41
# todo: change this to actual null terminator
NULL_TERM: .byte 10
CHAR_FROM_INPUT: .byte 0
