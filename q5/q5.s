.section .data
    filename: .asciz "input.txt"
    yes_msg:  .asciz "Yes\n"
    no_msg:   .asciz "No\n"

.section .text
    .global main

main:

    # 1. OPEN THE FILE  

    li a7, 56 # Syscall ID for openat (or use your specific open ID)
    li a0, -100 # AT_FDCWD (Current working directory)
    la a1, filename # arg1: Memory address of the filename
    li a2, 0 # arg2: O_RDONLY flag (0 = read only)
    li a3, 0 # arg3: Mode 
    ecall               
    
    # ecall returns the File Descriptor in a0.
    # Save it to a saved register (like s0) so it isn't overwritten.
    mv s0, a0            

    # 2. FIND FILE LENGTH

    # allocating the space for the two characters in the stack
    addi sp, sp, -16
    li s3, -1 # setting a offset from the end. if \n is present then this offset is -2

    # calling lseek to go to the end of the file
    li a7, 62 # syscall id for lseek
    # a0 already has file descriptor
    li a1, -1 # offset to move
    li a2, 2 # whence = 2 to go to the end
    ecall 

    # this ecall returns the file size. i will store it in s1
    mv s1, a0
    

    check_slash_n:

        # check if the last character is \n
        # ascii for \n is 10
        li t0, 10
        
        li a7, 63 # syscall ID for read
        mv a0, s0 # the file descriptor
        mv a1,sp # address to store the character
        li a2,1 # bytes to read
        ecall 

        lb t1, 0(sp)
        bne t1, t0, check_loop

        # if equal then set the offset to be 1
        addi s1, s1, -1 
        addi s3, s3, -1
        # i also need to store the half the size of the string to check for boundaries...
        srli s4, s1, 1 # s4 stores len(string)/2



    # 3. TWO-POINTER LOOP (Core Logic)

    li s2, 0 # storing the offset from where i need to check the characters at s2 distance from both the ends
    check_loop:
        
    # ------------------ left characcter -------------------------
        li a7, 62 # syscall id for lseek
        mv a0, s0 # file descriptor
        mv a1, s2 # offset to move
        li a2, 0 # whence = 1 to go to the start
        ecall 
            
        li a7, 63 # syscall ID for read
        mv a0, s0 # the file descriptor
        mv a1,sp # address to store the character
        li a2,1 # bytes to read
        ecall

        # store the character into a temporary register
        lb t0, 0(sp)
    # ------------------ right character -------------------------
        
        li a7, 62 # syscall id for lseek
        mv a0, s0 # file descriptor
        sub t2, x0, s2 # doing for getting the negative offset
        add t2, t2, s3 # considering the \n offset
        
        mv a1, t2 # offset to move
        li a2, 2 # whence = 2 to go to the end
        ecall 
            
        li a7, 63 # syscall ID for read
        mv a0, s0 # the file descriptor
        mv a1,sp # address to store the character
        li a2,1 # bytes to read
        ecall

        # store the character into a temporary register
        lb t1, 0(sp)
        
        # comparing the characters
        bne t0,t1, print_no

        addi s2, s2, 1 #increase the offset by 1 
        # check if the offset is greater than the half the size of the string
        bgt s2, s4, print_yes

        j check_loop


        # 4. PRINT RESULTS & 5. EXIT

    print_yes:
        li a7, 64 # syscall id for write
        li a0, 1 # mode is stdin for printing on the screen
        la a1, yes_msg # a1 takes the memory address of the string 
        li a2, 4 # the no of bytes to be printed
        ecall
        j exit_program

    print_no:

        li a7, 64 # syscall id for write
        li a0, 1 # mode is stdin for printing on the screen
        la a1, no_msg # a1 takes the memory address of the string 
        li a2, 3 # the no of bytes to be printed
        ecall

    exit_program:

        li a7, 57
        mv a0, s0
        ecall

        # restore the stack pointer
        addi sp, sp, 16

        li a7, 93 # Syscall ID for 'exit' (93 in RISC-V Linux)
        li a0, 0  # Arg 1: Exit code 0 (means "success")
        ecall # Trigger the kernel to terminate the program
