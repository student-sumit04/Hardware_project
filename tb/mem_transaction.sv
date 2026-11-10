package mem_transaction_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    parameter MEM_ADDR_WIDTH = 10;
    parameter MEM_DATA_WIDTH = 32;

    class mem_transaction extends uvm_sequence_item;

        logic                       rst_n;
        logic                       mem_en;
        logic                       mem_we;
        logic [MEM_ADDR_WIDTH-1:0]  mem_addr;
        logic [MEM_DATA_WIDTH-1:0]  mem_wdata;
        logic [MEM_DATA_WIDTH-1:0]  mem_rdata;
        `uvm_object_utils_begin(mem_transaction)
            `uvm_field_int(mem_en,UVM_DEFAULT)
            `uvm_field_int(mem_we,UVM_DEFAULT)
            `uvm_field_int(mem_addr,UVM_DEFAULT)
            `uvm_field_int(mem_wdata, UVM_DEFAULT)
            `uvm_field_int(mem_rdata, UVM_DEFAULT)
        `uvm_object_utils_end

        function new(string name = "mem_transaction");
            super.new(name);
        endfunction

    endclass

endpackage