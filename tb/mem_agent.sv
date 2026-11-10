package mem_agent_pkg;
    import uvm_pkg::*;
    import mem_monitor_pkg::*;
    `include "uvm_macros.svh"

    class mem_agent extends uvm_agent;

        mem_monitor mem_mon;
        `uvm_component_utils(mem_agent)

        function new (string name = "mem_agent" ,  uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            //if(!(uvm_config_db #(uvm_active_passive_enum)::get(this,"","is_active",is_active)))
               // `uvm_fatal(get_type_name(),"FAILED TO GET UVM ACTIVE PASSIVE AGENT")
    
            mem_mon = mem_monitor::type_id::create("mem_mon",this);
            `uvm_info(get_type_name(),"MEM AGENT BUILD PHASE",UVM_MEDIUM)
        endfunction
    endclass
endpackage