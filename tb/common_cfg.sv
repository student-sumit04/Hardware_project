package common_cfg_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"


    class common_cfg extends uvm_object ;

        
        `uvm_object_utils (common_cfg) 
        event stimulus_sent_e;

        function new (string name = "common_cfg");
            super.new(name);
            `uvm_info(get_type_name(),"INSIDE NEW Common CLASS" ,UVM_MEDIUM)
        endfunction

        
    
endclass


endpackage