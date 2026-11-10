package axi_scoreboard_pkg;

    import axi_transaction_pkg::*;
    import axi_para_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class axi_scoreboard extends uvm_scoreboard;

        
        uvm_analysis_export   #(axi_transaction) analysis_export;
        uvm_tlm_analysis_fifo #(axi_transaction) fifo;
        int pass_total_count = 0;
        int fail_total_count = 0;

        `uvm_component_utils(axi_scoreboard)

        reg [DATA_WIDTH-1:0] gmemory [0:MEMORY_DEPTH-1];

        function new (string name = "axi_scoreboard" ,  uvm_component parent);
            super.new(name, parent);
            analysis_export = new("analysis_export",this);
            fifo = new("fifo",this);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            `uvm_info(get_type_name(),"AXI SCOREBOARD BUILD PHASE",UVM_MEDIUM)
            
            for (int z = 0; z < MEMORY_DEPTH; z = z + 1)
            gmemory[z] = 0;
           
        endfunction

        function void connect_phase(uvm_phase phase);
            analysis_export.connect(fifo.analysis_export);
        endfunction


        task run_phase(uvm_phase phase);
            axi_transaction tr;
            int i = 0;
            int j = 0;
            logic safeW;
            logic safeR;
            forever 
            begin
                
                `uvm_info(get_type_name(), "Waiting for transaction", UVM_LOW)
                fifo.get(tr);
                safeW = !(((tr.AWADDR & 12'hFFF) + ((tr.AWLEN +1 ) << tr.AWSIZE)) > 12'hFFF) && ((tr.AWADDR + i * (1 << tr.AWSIZE)) >> 2) < MEMORY_DEPTH;
                safeR = !(((tr.ARADDR & 12'hFFF) + ((tr.ARLEN +1 ) << tr.ARSIZE)) > 12'hFFF) && ((tr.ARADDR + i * (1 << tr.ARSIZE)) >> 2) < MEMORY_DEPTH;
                `uvm_info(get_type_name(), "Transaction received", UVM_LOW)
                tr.print();
                if (!tr.ARESETn)
                begin
                    i = 0;
                    j = 0;

                    // Check AWREADY
                    if (tr.AWREADY === 1'b1) begin
                        `uvm_info(get_type_name(), $sformatf("RESET CHECK | AWREADY Expected=1'b1 Actual=%0b | PASS", tr.AWREADY), UVM_LOW)
                        pass_total_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("RESET CHECK | AWREADY Expected=1'b1 Actual=%0b", tr.AWREADY))
                        fail_total_count++;
                    end

                    // Check WREADY
                    if (tr.WREADY === 1'b0) begin
                        `uvm_info(get_type_name(), $sformatf("RESET CHECK | WREADY Expected=1'b0 Actual=%0b | PASS", tr.WREADY), UVM_LOW)
                        pass_total_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("RESET CHECK | WREADY Expected=1'b0 Actual=%0b", tr.WREADY))
                        fail_total_count++;
                    end

                    // Check BVALID
                    if (tr.BVALID === 1'b0) begin
                        `uvm_info(get_type_name(), $sformatf("RESET CHECK | BVALID Expected=1'b0 Actual=%0b | PASS", tr.BVALID), UVM_LOW)
                        pass_total_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("RESET CHECK | BVALID Expected=1'b0 Actual=%0b", tr.BVALID))
                        fail_total_count++;
                    end

                    // Check BRESP
                    if (tr.BRESP === 2'b00) begin
                        `uvm_info(get_type_name(), $sformatf("RESET CHECK | BRESP Expected=2'b00 Actual=2'b%02b | PASS", tr.BRESP), UVM_LOW)
                        pass_total_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("RESET CHECK | BRESP Expected=2'b00 Actual=2'b%02b", tr.BRESP))
                        fail_total_count++;
                    end

                    // Check ARREADY
                    if (tr.ARREADY === 1'b1) begin
                        `uvm_info(get_type_name(), $sformatf("RESET CHECK | ARREADY Expected=1'b1 Actual=%0b | PASS", tr.ARREADY), UVM_LOW)
                        pass_total_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("RESET CHECK | ARREADY Expected=1'b1 Actual=%0b", tr.ARREADY))
                        fail_total_count++;
                    end

                    // Check RVALID
                    if (tr.RVALID === 1'b0) begin
                        `uvm_info(get_type_name(), $sformatf("RESET CHECK | RVALID Expected=1'b0 Actual=%0b | PASS", tr.RVALID), UVM_LOW)
                        pass_total_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("RESET CHECK | RVALID Expected=1'b0 Actual=%0b", tr.RVALID))
                        fail_total_count++;
                    end

                    // Check RRESP
                    if (tr.RRESP === 2'b00) begin
                        `uvm_info(get_type_name(), $sformatf("RESET CHECK | RRESP Expected=2'b00 Actual=2'b%02b | PASS", tr.RRESP), UVM_LOW)
                        pass_total_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("RESET CHECK | RRESP Expected=2'b00 Actual=2'b%02b", tr.RRESP))
                        fail_total_count++;
                    end

                    // Check RDATA
                    if (tr.RDATA[0] === {DATA_WIDTH{1'b0}}) begin
                        `uvm_info(get_type_name(), $sformatf("RESET CHECK | RDATA Expected=0 Actual=%0h | PASS", tr.RDATA[0]), UVM_LOW)
                        pass_total_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("RESET CHECK | RDATA Expected=0 Actual=%0h", tr.RDATA[0]))
                        fail_total_count++;
                    end

                    // Check RLAST
                    if (tr.RLAST === 1'b0) begin
                        `uvm_info(get_type_name(), $sformatf("RESET CHECK | RLAST Expected=1'b0 Actual=%0b | PASS", tr.RLAST), UVM_LOW)
                        pass_total_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("RESET CHECK | RLAST Expected=1'b0 Actual=%0b", tr.RLAST))
                        fail_total_count++;
                    end    
                end
                else if(tr.op ==WRITE)
                begin
                    if (safeW) //Safe
                    begin
                        if(tr.WVALID && tr.WREADY && !tr.BVALID)
                        begin
                            gmemory[(tr.AWADDR >> 2)+i] = tr.WDATA[i];
                            `uvm_info(get_type_name(),$sformatf("WRITE DATA CHECK | Beat[%0d] | Addr=0x%0h | WDATA=0x%0h | PASS",i,(tr.AWADDR + i * (1 << tr.AWSIZE)),tr.WDATA[i]),UVM_LOW)
                            i= i+1;
                            if(i == tr.AWLEN+1)
                                if(tr.WLAST)
                                begin
                                    `uvm_info(get_type_name(),$sformatf("WLAST CHECK | Expected=1 | Actual=%0b | Beat[%0d] | PASS",tr.WLAST,i),UVM_LOW)
                                    i = 0;
                                end
                                else
                                begin
                                    `uvm_error(get_type_name(),$sformatf("WLAST CHECK | Expected=1 | Actual=%0b | Beat[%0d] | FAILED",tr.WLAST,i))
                                    fail_total_count ++;
                                end
                        end
                        if(tr.BVALID)
                        begin
                            if(tr.BRESP == 0)
                            begin
                                `uvm_info(get_type_name(), $sformatf("BRESP CHECK | BRESP=2'b%02b (OKAY) | PASS", tr.BRESP), UVM_LOW)
                                pass_total_count ++;
                            end
                            else
                            begin
                                `uvm_error(get_type_name(), $sformatf("BRESP CHECK | BRESP=2'b%02b (OKAY) | ERROR", tr.BRESP))
                                fail_total_count++;
                            end                   
                        end
                    end
                    else
                    begin
                    if(tr.BVALID)
                        if(tr.BRESP == 2'b10)
                        begin
                            `uvm_info(get_type_name(),"BRESP ERROR IS RIGHT",UVM_LOW)
                            pass_total_count ++;
                        end
                        else
                        begin
                            `uvm_info(get_type_name(),"BRESP ERROR IS FAILED",UVM_LOW)
                            fail_total_count++;
                        end
                    end
                end
                else if(tr.op == READ)
                begin
                    if(safeR)
                    begin
                        if(tr.RVALID && tr.RREADY)
                        begin
                                `uvm_info(get_type_name(),$sformatf("READ DATA CHECK | Beat[%0d] | Addr=0x%0h | RDATA=0x%0h | ",j,(tr.ARADDR + j * (1 << tr.ARSIZE)),tr.RDATA[j]),UVM_LOW)
                                if(gmemory[(tr.ARADDR >> 2)+j] == tr.RDATA[j])
                                `uvm_info(get_type_name(),$sformatf("READ DATA CHECK | Expected=%0h | Actual=%0h | Beat[%0d] | PASS",gmemory[(tr.ARADDR >> 2)+j],tr.RDATA[j],j),UVM_LOW)
                                else
                                begin
                                `uvm_error(get_type_name(),$sformatf("READ DATA CHECK | Expected=%0h | Actual=%0h | Beat[%0d] | FAILED",gmemory[(tr.ARADDR >> 2)+j],tr.RDATA[j],j))
                                fail_total_count ++;
                                end
                            j= j+1;
                            if(j == tr.ARLEN+1)
                                if(tr.RLAST)
                                begin
                                    `uvm_info(get_type_name(),$sformatf("RLAST CHECK | Expected=1 | Actual=%0b | Beat[%0d] | PASS",tr.RLAST,j),UVM_LOW)
                                    j = 0;
                                end
                                else
                                begin
                                    `uvm_error(get_type_name(),$sformatf("RLAST CHECK | Expected=1 | Actual=%0b | Beat[%0d] | FAILED",tr.RLAST,j))
                                    fail_total_count ++;
                                end   
                        end
                        if(tr.RVALID)
                        begin
                                if(tr.RRESP == 0)
                                begin
                                    `uvm_info(get_type_name(), $sformatf("RRESP CHECK | RRESP=2'b%02b (OKAY) | PASS", tr.RRESP), UVM_LOW)
                                    pass_total_count ++;
                                end
                                else
                                begin
                                    `uvm_error(get_type_name(), $sformatf("RRESP CHECK | RRESP=2'b%02b (OKAY) | ERROR", tr.RRESP))
                                    fail_total_count++;
                                end                   
                        end     
                    end 
                    else
                    begin
                        if(tr.RVALID)
                        begin
                            if(tr.RRESP == 2'b10)
                            begin
                                `uvm_info(get_type_name(),"RRESP ERROR IS RIGHT",UVM_LOW)
                                if(tr.RDATA[j] == 0) 
                                begin
                                    `uvm_info(get_type_name(),$sformatf("READ DATA CHECK | Expected=%0h | Actual=%0h | Beat[%0d] | PASS",'h0,tr.RDATA[j],j),UVM_LOW)
                                    pass_total_count ++;
                                end
                                else
                                begin
                                    `uvm_error(get_type_name(),$sformatf("READ DATA CHECK | Expected=%0h | Actual=%0h | Beat[%0d] | FAILED",'h0,tr.RDATA[j],j))
                                    fail_total_count++;    
                                end

                            end
                            else
                            begin
                                `uvm_info(get_type_name(),"RRESP ERROR IS FAILED",UVM_LOW)
                                fail_total_count++;
                            end
                        end    
                    end   
                end
                else if(tr.op == IDLE)
                begin
                    // Check AWVALID remains deasserted
                    if (tr.AWVALID === 1'b0) 
                    begin
                        `uvm_info(get_type_name(), "IDLE CHECK | AWVALID Expected=0 Actual=0 | PASS", UVM_LOW)
                        pass_total_count++;
                    end 
                    else 
                    begin
                        `uvm_error(get_type_name(), $sformatf("IDLE CHECK | AWVALID Expected=0 Actual=%0b", tr.AWVALID))
                        fail_total_count++;
                    end

                    // Check ARVALID remains deasserted
                    if (tr.ARVALID === 1'b0) 
                    begin
                        `uvm_info(get_type_name(), "IDLE CHECK | ARVALID Expected=0 Actual=0 | PASS", UVM_LOW)
                        pass_total_count++;
                    end 
                    else 
                    begin
                        `uvm_error(get_type_name(), $sformatf("IDLE CHECK | ARVALID Expected=0 Actual=%0b", tr.ARVALID))
                        fail_total_count++;
                    end

                    // Check WVALID remains deasserted
                    if (tr.WVALID === 1'b0) 
                    begin
                        `uvm_info(get_type_name(), "IDLE CHECK | WVALID Expected=0 Actual=0 | PASS", UVM_LOW)
                        pass_total_count++;
                    end 
                    else 
                    begin
                        `uvm_error(get_type_name(), $sformatf("IDLE CHECK | WVALID Expected=0 Actual=%0b", tr.WVALID))
                        fail_total_count++;
                    end

                    // Check BVALID remains deasserted (no unexpected write response)
                    if (tr.BVALID === 1'b0) 
                    begin
                        `uvm_info(get_type_name(), "IDLE CHECK | BVALID Expected=0 Actual=0 | PASS", UVM_LOW)
                        pass_total_count++;
                    end 
                    else 
                    begin
                        `uvm_error(get_type_name(), $sformatf("IDLE CHECK | BVALID Expected=0 Actual=%0b", tr.BVALID))
                        fail_total_count++;
                    end

                    // Check RVALID remains deasserted (no unexpected read response)
                    if (tr.RVALID === 1'b0) 
                    begin
                        `uvm_info(get_type_name(), "IDLE CHECK | RVALID Expected=0 Actual=0 | PASS", UVM_LOW)
                        pass_total_count++;
                    end 
                    else 
                    begin
                        `uvm_error(get_type_name(), $sformatf("IDLE CHECK | RVALID Expected=0 Actual=%0b", tr.RVALID))
                        fail_total_count++;
                    end        
                end
            end
        endtask

        task print_pass_summary();
            `uvm_info(get_type_name(), "========================================", UVM_LOW)
            `uvm_info(get_type_name(), "           SCOREBOARD PASS SUMMARY      ", UVM_LOW)
            `uvm_info(get_type_name(), "========================================", UVM_LOW)
            `uvm_info(get_type_name(), $sformatf("Total Checks Passed : %0d", pass_total_count), UVM_LOW)
            `uvm_info(get_type_name(), $sformatf("Total Checks Failed : %0d", fail_total_count), UVM_LOW)
            `uvm_info(get_type_name(), "========================================", UVM_LOW)
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            print_pass_summary();
        endfunction

    endclass
endpackage