`include "uvm_macros.svh"
import uvm_pkg::*;    
import axi_test_pkg::*;

bind axi4_memory mem_if #(
    .ADDR_WIDTH(10),
    .DATA_WIDTH(32)
) mem_bd_if (
    .clk      (clk),
    .rst_n    (rst_n),
    .mem_en   (mem_en),
    .mem_we   (mem_we),
    .mem_addr (mem_addr),
    .mem_wdata(mem_wdata),
    .mem_rdata(mem_rdata)
);

module top;

    AXI_if axi_vif();
    axi4 dut (
        .ACLK    (axi_vif.ACLK),
        .ARESETn (axi_vif.ARESETn),

        // Write address channel
        .AWADDR  (axi_vif.AWADDR),
        .AWLEN   (axi_vif.AWLEN),
        .AWSIZE  (axi_vif.AWSIZE),
        .AWVALID (axi_vif.AWVALID),
        .AWREADY (axi_vif.AWREADY),

        // Write data channel
        .WDATA   (axi_vif.WDATA),
        .WVALID  (axi_vif.WVALID),
        .WLAST   (axi_vif.WLAST),
        .WREADY  (axi_vif.WREADY),

        // Write response channel
        .BRESP   (axi_vif.BRESP),
        .BVALID  (axi_vif.BVALID),
        .BREADY  (axi_vif.BREADY),

        // Read address channel
        .ARADDR  (axi_vif.ARADDR),
        .ARLEN   (axi_vif.ARLEN),
        .ARSIZE  (axi_vif.ARSIZE),
        .ARVALID (axi_vif.ARVALID),
        .ARREADY (axi_vif.ARREADY),

        // Read data channel
        .RDATA   (axi_vif.RDATA),
        .RRESP   (axi_vif.RRESP),
        .RVALID  (axi_vif.RVALID),
        .RLAST   (axi_vif.RLAST),
        .RREADY  (axi_vif.RREADY)
    );

    initial begin
        axi_vif.ACLK = 0;
        forever 
        begin
            #2ns axi_vif.ACLK = ~axi_vif.ACLK;
        end
    end

    initial begin
        uvm_config_db #(uvm_active_passive_enum)::set(null,"uvm_test_top.*","is_active",UVM_ACTIVE);
        uvm_config_db #(virtual AXI_if)::set(null,"uvm_test_top.env.agt.*","vif",axi_vif);
        uvm_config_db #(virtual mem_if)::set(null,"uvm_test_top.env.mem_agt.*","mem_vif",top.dut.mem_inst.mem_bd_if);
         uvm_top.set_report_verbosity_level(UVM_LOW);
        run_test ("axi_test");
    end

endmodule
