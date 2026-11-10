package axi_driver_pkg;

    import uvm_pkg::*;
    import axi_para_pkg::*;
    import axi_transaction_pkg::*;
    import common_cfg_pkg::*;
    `include "uvm_macros.svh"

    class axi_driver extends uvm_driver #(axi_transaction);

        shortint    i = 0;
        shortint    j = 0;
        virtual AXI_if axi_vif;
        common_cfg m_cfg;
        `uvm_component_utils(axi_driver)

        function new (string name = "axi_driver" ,  uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            if(!(uvm_config_db #(virtual AXI_if)::get(this,"","vif",axi_vif)))
                `uvm_fatal(get_type_name(),"FAILED TO GET INTERFERACE")
            `uvm_info(get_type_name(),"AXI DRIVER BUILD PHASE",UVM_MEDIUM)
        endfunction

        task run_phase(uvm_phase phase);
        forever begin
                axi_transaction req;
                `uvm_info("DRV", "Waiting for transaction", UVM_MEDIUM)
                seq_item_port.get_next_item(req);
                `uvm_info("DRV", "Got transaction", UVM_MEDIUM)
                drive(req);
                `uvm_info("DRV", "Drive finished", UVM_MEDIUM)
                seq_item_port.item_done();
            end
        endtask

        extern task drive (axi_transaction req);

    endclass

    task axi_driver::drive (axi_transaction req);
        @(negedge axi_vif.ACLK);
        req.print();

        axi_vif.ARESETn <= req.ARESETn;
        if(!req.ARESETn)
        begin
            `uvm_info(get_type_name(), ">>> DRIVER ASSERTING RESET <<<", UVM_LOW)
            // Reset all outputs
            axi_vif.AWREADY <= 1'b1;  // Ready to accept address
            axi_vif.WREADY <= 1'b0;
            axi_vif.BVALID <= 1'b0;
            axi_vif.BRESP <= 2'b00;
            
            axi_vif.ARREADY <= 1'b1;  // Ready to accept address
            axi_vif.RVALID <= 1'b0;
            axi_vif.RRESP <= 2'b00;
            axi_vif.RDATA <= {DATA_WIDTH{1'b0}};
            axi_vif.RLAST <= 1'b0;
            @(negedge axi_vif.ACLK);
            -> m_cfg.stimulus_sent_e;
            
        end
        else 
        begin
            case(req.op)
            WRITE: 
                begin
                    @(negedge axi_vif.ACLK);
                            axi_vif.AWVALID <= req.AWVALID;
                            axi_vif.AWADDR  <= req.AWADDR;
                            axi_vif.AWLEN   <= req.AWLEN;
                            axi_vif.AWSIZE  <= 'd2;
                            
                            `uvm_info(get_type_name(),"DRV Triggered", UVM_MEDIUM)
                            while (!axi_vif.AWREADY)
                                @(posedge axi_vif.ACLK);

                            @(negedge axi_vif.ACLK);
                            axi_vif.AWVALID <= 0;
                            -> m_cfg.stimulus_sent_e;

                            $display("WDATA size = %0d", req.WDATA.size());

                            foreach (req.WDATA[i]) begin

                                @(negedge axi_vif.ACLK);                                          

                                axi_vif.WVALID <= 1;
                                axi_vif.BREADY <= 1;
                                axi_vif.WLAST  <= (i == req.WDATA.size()-1);
                                axi_vif.WDATA  <= req.WDATA[i];

                                while (!axi_vif.WREADY)
                                    @(posedge axi_vif.ACLK);

                                @(negedge axi_vif.ACLK);
                                axi_vif.WVALID <= 0;
                                axi_vif.WLAST  <= 0;

                            end

                            while (!axi_vif.BVALID)
                                @(posedge axi_vif.ACLK);
                            req.BRESP = axi_vif.BRESP;
                            
                            @(negedge axi_vif.ACLK);      
                            // #50ps;
                            axi_vif.BREADY <= 0;
                end
            READ:
                begin
                    @(negedge axi_vif.ACLK);
                    //repeat(2) @(posedge axi_vif.ACLK);
                    axi_vif.ARADDR  <= req.ARADDR;
                    axi_vif.ARLEN   <= req.ARLEN;
                    axi_vif.ARVALID <= req.ARVALID;
                    axi_vif.ARSIZE  <= 'd2;
                    axi_vif.AWVALID <= req.AWVALID;
                    axi_vif.AWADDR  <= req.AWADDR;
                    axi_vif.AWLEN   <= req.AWLEN;
                    axi_vif.AWSIZE  <= 'd2;
                    
                    while (!axi_vif.ARREADY)
                        @(posedge axi_vif.ACLK);

                    @(negedge axi_vif.ACLK);            
                    axi_vif.ARVALID <= 0;
                    -> m_cfg.stimulus_sent_e;

                    req.RDATA = new[req.ARLEN+1];

                    foreach (req.RDATA[i]) 
                    begin

                    @(negedge axi_vif.ACLK);
                    axi_vif.RREADY <= 1;

                    while (!axi_vif.RVALID)
                        @(negedge axi_vif.ACLK);

                    req.RDATA[i] = axi_vif.RDATA;
                    req.RRESP    = axi_vif.RRESP;              // capture response while you're here

                    
                    end

                    @(negedge axi_vif.ACLK);
                    axi_vif.RREADY <= 0;
                end
            IDLE:
            begin
                 @(negedge axi_vif.ACLK);

                    axi_vif.AWVALID <= req.AWVALID;
                    axi_vif.WVALID  <= 0;
                    axi_vif.BREADY  <= 0;
                    axi_vif.AWADDR  <= req.AWADDR;
                    axi_vif.AWLEN   <= req.AWLEN;
                    axi_vif.AWSIZE  <= 'd2;

                    axi_vif.ARVALID <= req.ARVALID;
                    axi_vif.RREADY  <= 0;
                    axi_vif.WLAST   <= 0;
                    axi_vif.ARADDR  <= req.ARADDR;
                    axi_vif.ARLEN   <= req.ARLEN;
                    axi_vif.ARSIZE  <= 'd2;
                    -> m_cfg.stimulus_sent_e;

                @(posedge axi_vif.ACLK);
            end
            endcase
        end
        

    endtask
endpackage