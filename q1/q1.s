.global make_node
.global insert
.global get
.global getAtMost
.section .text

make_node:
    addi sp, sp, -16 # store the return address and the node value, as they will be replaced by malloc func
    sw a0, 0(sp) # node value in first argument
    sd ra, 8(sp) # return address of the current function

    li a0, 24 # giving the size argument to the malloc as the first argument
    call malloc

    # get back the elements we pushed into the stack
    lw t0, 0(sp) 
    ld ra, 8(sp) 
    addi sp, sp, 16
    
    # now a0 has the return value -> the pointer to the memory location. 
        # Now at 0 offset from a0, store the integer and , 8 offset store the next pointer (for now it is NULL (x0))

    sw t0 , 0(a0)
    sd x0 , 8(a0)
    sd x0 , 16(a0)

    # the pointer to the memory location is already stored in the a0 register. So it will be returned as required .
    ret


insert:

    # insert accepts two arguments. root and the value to be inserted
        # store ra in stack
        # since we use the saved registers , we need to push them into the stack as we need to guarantee the s registers are not affected

    addi sp, sp, -32
    sd ra, 0(sp)
    sd s0, 8(sp)
    sd s1, 16(sp)
    sd s2, 24(sp)


    mv s0, a0  # storing the root pointer into the s0
    mv s1, a1  # storing the value into the s1
    mv s2, s0  # storing the root so that orginal root wont be affected

    beq s2, x0, return_new_node

    insert_loop: 

        # get the value of the root and check it with the current value

        lw t0, 0(s2)
        blt s1, t0, insert_left
        bgt s1, t0, insert_right
        beq s1, t0, return_the_root

    insert_left:

        # get the value of the left child of the current root

        ld t1, 8(s2)
        
        bne t1, x0, loop_again 

        mv a0, s1 
        call make_node

        sd a0, 8(s2)

        j return_the_root 

    insert_right:

        # get the value of the right child of the current root

        ld t1, 16(s2)
        
        bne t1, x0, loop_again 

        mv a0, s1 
        call make_node

        sd a0, 16(s2)

        j return_the_root 


    loop_again:

        # make the child to be the new root
        mv s2, t1 
        j insert_loop

    return_new_node:

        mv a0, s1 
        call make_node
        mv s0, a0 # just to ensure , return the root when called works properly
        # the execution flow reaches return_the_root 

    return_the_root:

        mv a0, s0  # returning the root as per the given function description
        ld ra, 0(sp)
        ld s0, 8(sp)
        ld s1, 16(sp)
        ld s2, 24(sp)
        addi sp, sp, 32
        ret

get:

    # i feel that the registers are not affected. So i am not pushing them into stack.
    # here i will modify the argument  register itself as that makes it simple

    find_loop: 

        # if the root is NULL return NULL
        beq a0, x0, return_the_root_2
        
        # get the value of the root and check it with the current value
        lw t0, 0(a0)
        blt a1, t0, find_left
        bgt a1, t0, find_right
        beq a1, t0, return_the_root_2

    find_left:
        
        ld  a0, 8(a0)
        j find_loop

    find_right:
        
        ld a0, 16(a0)
        j find_loop

    return_the_root_2:
        ret

getAtMost:

    mv t2, x0 # initialising the possible answer variable
    mv t3, x0 # using t3 as flag for detecting update

    find_loop_2: 

        # if the root is NULL , check if the flag has changed
        beq a0, x0, return_the_node

        # get the value of the root and check it with the current value
        lw t0, 0(a0)
        blt a1, t0, find_left_2
        bgt a1, t0, find_right_2
        
        addi t3, t3, 1 # setting flag to be 1
        mv t2, t0
        j return_the_node

    find_left_2:
        
        ld  a0, 8(a0)
        j find_loop_2

    find_right_2:
        
        mv t2, t0
        addi t3, t3, 1 # setting flag to be 1
        ld a0, 16(a0)
        j find_loop_2

    return_the_node:
        
        beq x0, t3, return_neg_1
        mv a0, t2
        ret
    
    return_neg_1:

        li a0, -1
        ret
