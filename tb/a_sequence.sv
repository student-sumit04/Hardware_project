package axi_sequence_pkg;

    import uvm_pkg::*;
    import axi_transaction_pkg::*;
    `include "uvm_macros.svh"

    class axi_sequence extends uvm_sequence #(axi_transaction);
 
        `uvm_object_utils(axi_sequence)

        function new (string name = "axi_sequence");
            super.new(name);
            `uvm_info(get_type_name(),"AXI SEQUENCE INSIDE NEW",UVM_MEDIUM)
        endfunction

        task body();
            axi_transaction req;
                repeat(2000) begin //2000
                    req = axi_transaction::type_id::create("req");
                    start_item(req);
                        assert(req.randomize());
                        `uvm_info(get_type_name(),{"DATA RANDOMIZED:",req.sprint()},UVM_MEDIUM)
                    finish_item(req);
                    
                    
                end
        endtask

    endclass
endpackage