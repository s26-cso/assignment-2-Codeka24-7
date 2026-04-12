
.section .rodata
oformat: .string "%d "
newline: .string "\n"
last_element: .string "%d"
.section .text
.globl main

main:
    mv s0, a0 # Save argc (number of strings + 1)
    mv s1, a1 # Save argv pointer
    
    # initialising the values
    addi s2, s0, -1 # s2 = n (number of IQs)
    li s3, 0 # Index i = 0

using_malloc:
    
    slli a0, s2, 2 # for integer  malloc_argument = sizeof(int)
    call malloc
    mv s7, a0 # storing the base address of this dynamic array into -> s7 -> storing the iqs

    slli a0, s2, 2 # for integer  malloc_argument = sizeof(int)
    call malloc
    mv s8, a0 # storing the base address of this dynamic array into -> s8 -> storing the result

    setup_stack:
        slli a0, s2, 2 # for integer  malloc_argument = sizeof(int)
        call malloc
        mv s4, a0 # storing the base address of this dynamic array into -> s8 -> The stack
        
        li s5, 0 # s5 is the "stack top" (number of elements in stack)

parse_args:
    beq s3, s2, end_parse # If i == n, exit loop ~ (s3==n)
    
    # Get address of argv[i+1] (exclude the name of the file. So start at index 1)
    addi t0, s3, 1 # t0 = i + 1
    slli t0, t0, 3 # t0 = (i + 1) * 8 (for 64-bit pointers)
    add t1, s1, t0 # t1 = &argv[i+1]
    ld a0, 0(t1) # a0 = argv[i+1] (the string)
    
    # Call atoi to convert string to int
    jal ra, atoi                
    
    # Store result in iqs[i]
    mv t2, s7
    slli t3, s3, 2 # t3 = i * 4
    add t2, t2, t3 # t2 = &iqs[i]
    sw a0, 0(t2) # Store the integer
    
    addi s3, s3, 1 # i++
    j parse_args


end_parse:

    addi s6, x0, -1 # storing the value -1 in s6

    mv t0, s3

    loop_iqs:

        beq t0, x0, end_loop
        
        addi t0, t0, -1
        mv t1, t0
        slli t1, t1, 2
        add t2, t1, s7 # storing the index of the iqs array
        add t3, t1, s8 # storing the index of the result array

        lw t5, 0(t2) # storing the value of the current value in the iqs array -> arr[i]

        # for now the next greatest element is undefined. so i am storing the answer value as -1
        sw s6, 0(t3)

        pop_stack:
            beq s5, x0, result_time # if the stack is empty then exit
            
            # get the stack's top 
            slli t4, s5, 2
            add t4, s4, t4
            lw t4, -4(t4) 

            # compare the top of stack with arr[i]
            slli t6, t4, 2
            add t6, t6, s7
            lw t6, 0(t6)
            bgt t6, t5, result_time

            addi s5, s5, -1 # pop the top
            j pop_stack
            
        result_time:
            
            # push the arr[i] into top of stack
            slli t4, s5, 2
            add t4, s4, t4
            
            sw t0, 0(t4) # pushed the arr[i] into stack
            # since we added an element into the stack, increment the top of the stack
            addi s5, s5, 1

            addi t6, s5, -1
            ble t6, x0, loop_iqs # if stack was empty then go to next iteration

            slli t6, s5, 2
            add t6, t6, s4
            lw t6, -8(t6)
            sw t6, 0(t3) # result time for the current element 

            j loop_iqs
            
atoi:
    li a1, 0 # result = 0
    li a2, 10 # used for the logic : 42 = 4*(a2) + 2; 429 = 42*(a2) + 9

atoi_loop:
    lb a3, 0(a0) # load the character
    beqz a3, atoi_done # If null terminator, we're done

    addi a3, a3, -48 # convert ASCII to int
    mul a1, a1, a2
    add a1, a1, a3

    addi a0, a0, 1 # next char
    j atoi_loop

atoi_done:
    mv a0, a1
    ret

end_loop:

    # using saved registers because i am calling the printf func. else i wud have to use stack pointer
    mv s3, x0 # index value in the result array
    addi s9, s2, -1 # to check the last element print

    print_loop:

        # get the ith value in the result array
        # beq s3, s2, end_print

        mv s0, s3
        slli s0, s0, 2
        add s0, s8, s0
        lw s0, 0(s0)

        beq s3, s9, end_print

        la a0, oformat # needs a pointer to the string. here the pointer to the string is the oformat
        mv a1, s0

        call printf

        addi s3, s3, 1

        j print_loop

    end_print:

        la a0, last_element # needs a pointer to the string. here the pointer to the string is the last_element
        mv a1, s0
        call printf

        la a0, newline
        call printf
        
        li a0, 0        # Exit status 0
        # Call C stdlib exit
        call exit
