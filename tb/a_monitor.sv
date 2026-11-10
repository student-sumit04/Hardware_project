package axi_monitor_pkg;

    import uvm_pkg::*;
    import axi_para_pkg::*;
    import common_cfg_pkg::*;
    import axi_transaction_pkg::*;
    `include "uvm_macros.svh"

    class axi_monitor extends uvm_monitor;

        uvm_analysis_port #(axi_transaction) ap;
        virtual AXI_if axi_vif;
        common_cfg m_cfg;
        `uvm_component_utils(axi_monitor)

        function new (string name = "axi_monitor" ,  uvm_component parent);
            super.new(name, parent);
            ap = new("ap",this);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            if(!(uvm_config_db #(virtual AXI_if)::get(this,"","vif",axi_vif)))
                `uvm_fatal(get_type_name(),"FAILED TO GET INTERFERACE")
            `uvm_info(get_type_name(),"AXI MONITOR BUILD PHASE",UVM_LOW)
        endfunction

       
        task run_phase(uvm_phase phase);
            int i = 0;
            `uvm_info(get_type_name(),"Entered Run phase in monitor",UVM_LOW)
            forever 
            begin
                
                wait(m_cfg.stimulus_sent_e.triggered)
                if (!axi_vif.ARESETn) 
                begin
                    axi_transaction tr = axi_transaction::type_id::create("tr_rst");
                    tr.ARESETn = axi_vif.ARESETn;
                    tr.AWREADY = axi_vif.AWREADY;
                    tr.WREADY  = axi_vif.WREADY;
                    tr.BVALID  = axi_vif.BVALID;
                    tr.BRESP   = axi_vif.BRESP;
                    tr.ARREADY = axi_vif.ARREADY;
                    tr.RVALID  = axi_vif.RVALID;
                    tr.RRESP   = axi_vif.RRESP;
                    tr.RLAST   = axi_vif.RLAST;
                    tr.RDATA   = new[1];
                    tr.RDATA[0]= axi_vif.RDATA;
                    tr.addr_mode =  0;

                    `uvm_info(get_type_name(), "Reset detected on bus: sending to scoreboard", UVM_LOW)
                    ap.write(tr);
                    @(posedge axi_vif.ACLK);

                end    
                else if (axi_vif.AWVALID)
                begin
                    axi_transaction tr = axi_transaction ::type_id::create("tr");
                    `uvm_info(get_type_name(),"MON Triggered - WRITE", UVM_LOW)
                    tr.op = WRITE;
                    tr.AWADDR  = axi_vif.AWADDR;
                    tr.AWLEN   = axi_vif.AWLEN;
                    tr.AWSIZE  = axi_vif.AWSIZE;
                    tr.AWVALID = axi_vif.AWVALID;
                    tr.AWREADY = axi_vif.AWREADY;
                    tr.WDATA = new[axi_vif.AWLEN+1];

                    // For Coverage
                    if (tr.AWADDR >= 3211 && tr.AWADDR <= 4095)
                        tr.addr_mode = 2'd0;
                    else if ((tr.AWADDR + ((tr.AWLEN + 1) * 4)) <= 4096)
                        tr.addr_mode = 2'd1;
                    else if (tr.AWADDR >= 4096)
                        tr.addr_mode = 2'd2;
                    else
                        tr.addr_mode = 2'd3;
                    

                    for (int x = 0 ; x<=tr.AWLEN;x++)
                    begin
                            @(posedge axi_vif.ACLK);
                            @(posedge axi_vif.ACLK);
                            tr.WDATA[x] = axi_vif.WDATA;
                            tr.WVALID   = axi_vif.WVALID;
                            tr.WLAST    = axi_vif.WLAST;
                            tr.WREADY   = axi_vif.WREADY;
                            tr.BRESP    = axi_vif.BRESP;
                            tr.BVALID   = axi_vif.BVALID;
                            tr.BREADY   = axi_vif.BREADY;
                            `uvm_info("MON", "About to send transaction Write OP", UVM_LOW)
                            ap.write(tr);
                            `uvm_info("MON", "Transaction sent Write OP", UVM_LOW)
                    end
                    @(posedge axi_vif.ACLK);
                    wait(axi_vif.BVALID);
                    tr.BRESP  = axi_vif.BRESP;
                    tr.BVALID = axi_vif.BVALID;
                    @(posedge axi_vif.ACLK);
                    tr.BREADY = axi_vif.BREADY;
                    `uvm_info("MON", "About to send transaction", UVM_LOW)
                    ap.write(tr);
                    `uvm_info("MON", "Transaction sent", UVM_LOW)
                end
                else if (axi_vif.ARVALID)
                begin
                    axi_transaction tr = axi_transaction ::type_id::create("tr");
                    `uvm_info(get_type_name(),"MON Triggered - READ", UVM_LOW)
                    tr.op = READ;
                    tr.ARADDR  = axi_vif.ARADDR;
                    tr.ARLEN   = axi_vif.ARLEN;
                    tr.ARSIZE  = axi_vif.ARSIZE;
                    tr.ARVALID = axi_vif.ARVALID;
                    tr.ARREADY = axi_vif.ARREADY;
                    tr.RDATA = new[axi_vif.ARLEN+1];

                    // For Coverage
                    if (tr.ARADDR >= 3211 && tr.ARADDR <= 4095)
                        tr.addr_mode = 2'd0;
                    else if ((tr.ARADDR + ((tr.ARLEN + 1) * 4)) <= 4096)
                        tr.addr_mode = 2'd1;
                    else if (tr.ARADDR >= 4096)
                        tr.addr_mode = 2'd2;
                    else
                        tr.addr_mode = 2'd3;

                    @(posedge axi_vif.ACLK);
                    @(posedge axi_vif.ACLK);        
                    for (int x = 0 ; x<=tr.ARLEN;x++)
                    begin
                            @(posedge axi_vif.ACLK);
                            @(posedge axi_vif.ACLK);
                            tr.RDATA[x] = axi_vif.RDATA;
                            tr.RVALID   = axi_vif.RVALID;
                            tr.RLAST    = axi_vif.RLAST;
                            tr.RREADY   = axi_vif.RREADY;
                            tr.RRESP    = axi_vif.RRESP;
                            `uvm_info("MON", "About to send transaction Read OP", UVM_LOW)
                            ap.write(tr);
                            `uvm_info("MON", "Transaction sent Read OP", UVM_LOW)
                    end
                end
                else
                begin
                    axi_transaction tr = axi_transaction ::type_id::create("tr");
                    `uvm_info(get_type_name(),"MON Triggered - IDLE", UVM_LOW)
                    @(posedge axi_vif.ACLK);
                    tr.op = IDLE;
                    tr.ARADDR  = axi_vif.ARADDR;
                    tr.ARLEN   = axi_vif.ARLEN;
                    tr.ARSIZE  = axi_vif.ARSIZE;
                    tr.ARVALID = axi_vif.ARVALID;
                    tr.ARREADY = axi_vif.ARREADY;
                    tr.RDATA = new[1];
                    tr.RVALID   = axi_vif.RVALID;
                    tr.RLAST    = axi_vif.RLAST;
                    tr.RREADY   = axi_vif.RREADY;
                    tr.RRESP    = axi_vif.RRESP;
                    tr.AWADDR  = axi_vif.AWADDR;
                    tr.AWLEN   = axi_vif.AWLEN;
                    tr.AWSIZE  = axi_vif.AWSIZE;
                    tr.AWVALID = axi_vif.AWVALID;
                    tr.AWREADY = axi_vif.AWREADY;
                    tr.WDATA = new[1];
                    tr.WVALID   = axi_vif.WVALID;
                    tr.WLAST    = axi_vif.WLAST;
                    tr.WREADY   = axi_vif.WREADY;
                    tr.BRESP    = axi_vif.BRESP;
                    tr.BVALID   = axi_vif.BVALID;
                    tr.BREADY   = axi_vif.BREADY;

                    // For Coverage ////////////////////////////////////
                    if (axi_vif.AWADDR >= 3211 && axi_vif.AWADDR <= 4095)
                        tr.addr_mode = 2'd0;
                    else if ((axi_vif.AWADDR + ((axi_vif.AWLEN + 1) * 4)) <= 4096)
                        tr.addr_mode = 2'd1;
                    else if (axi_vif.AWADDR >= 4096)
                        tr.addr_mode = 2'd2;
                    else
                        tr.addr_mode = 2'd3;
                    /////////////////////////////////////////////////////    
                    `uvm_info("MON", "About to send transaction IDLE OP", UVM_LOW)
                    ap.write(tr);
                    `uvm_info("MON", "Transaction sent IDLE OP", UVM_LOW)
                    @(posedge axi_vif.ACLK);
                end
            end
        endtask



    endclass
endpackage