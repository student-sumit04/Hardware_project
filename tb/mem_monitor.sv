package mem_monitor_pkg;

    import uvm_pkg::*;
    import common_cfg_pkg::*;
    import mem_transaction_pkg::*;
    `include "uvm_macros.svh"

    class mem_monitor extends uvm_monitor;

        uvm_analysis_port #(mem_transaction) mem_ap;
        virtual mem_if mem_vif;
        common_cfg m_cfg;
        `uvm_component_utils(mem_monitor)

        function new (string name = "mem_monitor" ,  uvm_component parent);
            super.new(name, parent);
            mem_ap = new("mem_ap",this);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            if(!(uvm_config_db #(virtual mem_if)::get(this,"","mem_vif",mem_vif)))
                `uvm_fatal(get_type_name(),"FAILED TO GET MEM INTERFERACE")

            `uvm_info(get_type_name(),"MEM MONITOR BUILD PHASE",UVM_LOW)
        endfunction

       
        task run_phase(uvm_phase phase);
            int i = 0;
            `uvm_info(get_type_name(),"Entered Run phase in MEM monitor",UVM_LOW)
            forever 
            begin
                
                mem_transaction mem_tr = mem_transaction::type_id::create("mem_tr");
                mem_tr.mem_en    = mem_vif.mem_en;    
                mem_tr.mem_we    = mem_vif.mem_we;    
                mem_tr.mem_addr  = mem_vif.mem_addr;    
                mem_tr.mem_wdata = mem_vif.mem_wdata;
                mem_tr.rst_n     = mem_vif.rst_n;
                @(posedge mem_vif.clk);
                #10ps;
                mem_tr.mem_rdata = mem_vif.mem_rdata;
                `uvm_info("MEM_MON", "About to send MEM transaction", UVM_LOW)
                    mem_ap.write(mem_tr);
                `uvm_info("MEM_MON", "About to send MEM transaction ", UVM_LOW)
            end
        endtask



    endclass
endpackage