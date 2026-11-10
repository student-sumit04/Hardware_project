package axi_coverage_pkg;

    import axi_transaction_pkg::*;
    import uvm_pkg::*;
    
    `include "uvm_macros.svh"


    class axi_coverage extends uvm_component;

        uvm_analysis_export   #(axi_transaction) analysis_export;
        uvm_tlm_analysis_fifo #(axi_transaction) fifo;    
        `uvm_component_utils(axi_coverage)

        axi_transaction tr;
        covergroup cg ;
        //option.per_instance = 1; 
        cp_awaddr: coverpoint tr.AWADDR {
            bins low_addr  = {[0 : 1023]};
            bins mid_addr  = {[1024 : 3071]};
            bins high_addr = {[3072 : 4095]};
        }

        cp_awlen: coverpoint tr.AWLEN {
            bins len_single = {0};                 // Single beat
            bins len_short  = {[1 : 15]};          // Short burst
            bins len_med    = {[16 : 127]};        // Medium burst
            bins len_max    = {[128 : 255]};       // Long burst
        }

        cp_araddr: coverpoint tr.ARADDR {
            bins low_addr  = {[0 : 1023]};
            bins mid_addr  = {[1024 : 3071]};
            bins high_addr = {[3072 : 4095]};
        }

        cp_arlen: coverpoint tr.ARLEN {
            bins len_single = {0};
            bins len_short  = {[1 : 15]};
            bins len_med    = {[16 : 127]};
            bins len_max    = {[128 : 255]};
        }

        cp_awvalid: coverpoint tr.AWVALID;
        cp_arvalid: coverpoint tr.ARVALID;
        cp_op: coverpoint tr.op;
        cp_address_mode: coverpoint tr.addr_mode {
            bins mode_0 = {0};
            bins mode_1 = {1};
            bins mode_2 = {2};
        }
        cp_op_mode: cross cp_op, cp_address_mode;
        cp_wadd_len: cross cp_awaddr, cp_awlen {
            bins low_singlelen = binsof(cp_awaddr.low_addr) && binsof(cp_awlen.len_single);
        }
        cp_radd_len: cross cp_araddr, cp_arlen {
            bins low_singlelen = binsof(cp_araddr.low_addr) && binsof(cp_arlen.len_single);
        }
        
        endgroup

        function new (string name = "axi_coverage" ,  uvm_component parent);
            super.new(name, parent);
            cg = new();
            analysis_export = new("analysis_export",this);
            fifo = new("fifo",this);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            `uvm_info(get_type_name(),"AXI COVERAGE BUILD PHASE",UVM_MEDIUM)
        endfunction

        function void connect_phase(uvm_phase phase);
            analysis_export.connect(fifo.analysis_export);
        endfunction

        task run_phase(uvm_phase phase);
        
            forever begin
                fifo.get(tr);
                `uvm_info(get_type_name(), "Coverage sampled transaction!", UVM_LOW)
                cg.sample();
            end
        endtask

    endclass
endpackage