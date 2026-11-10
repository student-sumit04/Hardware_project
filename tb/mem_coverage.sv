package mem_coverage_pkg;

    import mem_transaction_pkg::*;
    import uvm_pkg::*;
    
    `include "uvm_macros.svh"


    class mem_coverage extends uvm_component;

        uvm_analysis_export   #(mem_transaction) mem_analysis_export;
        uvm_tlm_analysis_fifo #(mem_transaction) mem_fifo;    
        `uvm_component_utils(mem_coverage)

        mem_transaction mem_tr;
        covergroup mem_cg ;
            option.per_instance = 1; 
            addr_cp: coverpoint mem_tr.mem_addr {
                bins first     = {0};
                bins low       = {[1:255]};
                bins mid_low   = {[256:511]};
                bins mid_high  = {[512:767]};
                bins high      = {[768:1023]};
            }
            we_cp: coverpoint mem_tr.mem_we {
                bins write = {1};
                bins read  = {0};
            }
        endgroup

        function new (string name = "mem_coverage" ,  uvm_component parent);
            super.new(name, parent);
            mem_cg = new();
            mem_analysis_export = new("mem_analysis_export",this);
            mem_fifo = new("mem_fifo",this);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            `uvm_info(get_type_name(),"MEM COVERAGE BUILD PHASE",UVM_MEDIUM)
        endfunction

        function void connect_phase(uvm_phase phase);
            mem_analysis_export.connect(mem_fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
        
            forever begin
                mem_fifo.get(mem_tr);
                `uvm_info(get_type_name(), "MEM Coverage sampled transaction!", UVM_LOW)
                mem_cg.sample();
            end
        endtask

    endclass
endpackage