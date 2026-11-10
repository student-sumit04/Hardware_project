package axi_para_pkg;
    parameter DATA_WIDTH   = 32;
    parameter ADDR_WIDTH   = 16;
    parameter MEMORY_DEPTH = 1024;

    typedef enum 
        {
            WRITE,
            READ,
            IDLE
        } op_t;
endpackage