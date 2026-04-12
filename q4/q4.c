#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <dlfcn.h>

int main() {
    char op[256];
    int num1, num2;

    while (scanf("%255s %d %d", op, &num1, &num2) == 3) {
        // Build the library name dynamically
        char lib_name[262] = "lib";   
        strcat(lib_name, op);         
        strcat(lib_name, ".so");      
        
        // 1. Load the library into the Memory Mapping Segment
        void *handle = dlopen(lib_name, RTLD_LAZY);
        
        // 2. Locate the specific operation in the Symbol Table
        void *raw_address = dlsym(handle, op);

        // 3. Cast the raw address to your specific function pointer signature
        int (*func_name)(int, int) = (int (*)(int, int)) raw_address;
        
        // Execute the function
        int result = func_name(num1, num2);
        printf("%d\n", result);

        // 4. Unmap the library to free the 1.5GB and stay under the 2GB cap
        dlclose(handle);
        
        // 5. Best practice: prevent the dangling pointer from being reused
        func_name = NULL; 
    }

    return 0;
}