package axi_test_pkg;

    import uvm_pkg::*;
    import axi_env_pkg::*;
    import axi_sequence_pkg::*;
    import axi_driver_pkg::*;
    import axi_driver_delay_pkg::*;
    import common_cfg_pkg::*;
    `include "uvm_macros.svh"

    class axi_test extends uvm_test;

        axi_env env;
        axi_sequence seq;
        common_cfg m_cfg;
        `uvm_component_utils(axi_test)

        function new (string name = "axi_test" ,  uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase (uvm_phase phase);

            uvm_factory::get().set_type_override_by_type(axi_driver::get_type(),axi_driver_delay::get_type());
            super.build_phase(phase);
            env   = axi_env::type_id::create("env",this);
            seq   = axi_sequence::type_id::create("seq");
            m_cfg = common_cfg::type_id::create("m_cfg");
            `uvm_info(get_type_name(),"AXI TEST BUILD PHASE",UVM_LOW)

            uvm_config_db #(common_cfg)::set(this,"*","m_cfg",m_cfg);
        endfunction

        task run_phase(uvm_phase phase);
            phase.raise_objection(this);
                fork
                    begin
                        seq.start(env.agt.sqr);
                        #1000ns;
                    end
                join
                begin
                    `uvm_info(get_type_name(),"Starting AXI SEQUENCE",UVM_LOW)    
                end
            phase.drop_objection(this);
        endtask

        function void end_of_elaboration_phase(uvm_phase phase);
            super.end_of_elaboration_phase(phase);
            uvm_top.print_topology();
        endfunction

    endclass
endpackage