package axi_driver_delay_pkg;

    import uvm_pkg::*;
    import axi_para_pkg::*;
    import axi_transaction_pkg::*;
    import axi_driver_pkg::*;
    import common_cfg_pkg::*;
    `include "uvm_macros.svh"

    class axi_driver_delay extends axi_driver;

    `uvm_component_utils(axi_driver_delay)

    function new(
        string name = "axi_driver_delay",
        uvm_component parent
    );
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        `uvm_info(
            get_type_name(),
            "AXI DELAY DRIVER BUILD PHASE",
            UVM_MEDIUM
        )
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            axi_transaction req;

            seq_item_port.get_next_item(req);

            // Random idle cycles
            repeat ($urandom_range(0,3))
                @(posedge axi_vif.ACLK);

            // Use parent's drive()
            drive(req);

            seq_item_port.item_done();
        end
    endtask

endclass

endpackage