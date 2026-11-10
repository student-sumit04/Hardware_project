package axi_env_pkg;

   
    import uvm_pkg::*;
    import axi_agent_pkg::*;
    import mem_agent_pkg::*;
    import axi_scoreboard_pkg::*;
    import mem_scoreboard_pkg::*;
    import axi_coverage_pkg::*;
    import common_cfg_pkg::*;
    import mem_coverage_pkg::*;
    `include "uvm_macros.svh"

    class axi_env extends uvm_env;
        common_cfg m_cfg;
        axi_agent agt;
        mem_agent mem_agt;
        axi_scoreboard scb;
        mem_scoreboard mem_scb;
        axi_coverage cov;
        mem_coverage mem_cov;
        uvm_active_passive_enum is_active =  UVM_ACTIVE;
        
        `uvm_component_utils(axi_env)

        function new (string name = "axi_env" ,  uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            agt = axi_agent::type_id::create("agt",this);
            scb = axi_scoreboard::type_id::create("scb",this);
            cov = axi_coverage::type_id::create("cov",this);
            mem_cov = mem_coverage::type_id::create("mem_cov",this);
            mem_agt = mem_agent::type_id::create("mem_agt",this);
            mem_scb = mem_scoreboard::type_id::create("mem_scb",this);

            if(!(uvm_config_db #(uvm_active_passive_enum)::get(this,"","is_active",is_active)))
                `uvm_fatal(get_type_name(),"FAILED TO GET UVM ACTIVE PASSIVE AGENT")
            
            `uvm_info(get_type_name(),"AXI ENV BUILD PHASE",UVM_MEDIUM)
            uvm_config_db #(common_cfg)::get(this,"","m_cfg",m_cfg);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            if(is_active ==UVM_ACTIVE)
            begin
            agt.drv.m_cfg=m_cfg;    
            end
            agt.mon.m_cfg=m_cfg;
            agt.mon.ap.connect(scb.analysis_export);
            agt.mon.ap.connect(cov.analysis_export);
            mem_agt.mem_mon.mem_ap.connect(mem_scb.mem_analysis_export);
            mem_agt.mem_mon.mem_ap.connect(mem_cov.mem_analysis_export);
            `uvm_info(get_type_name(),"AXI ENV CONNECT PHASE",UVM_MEDIUM)
        endfunction

    endclass
endpackage