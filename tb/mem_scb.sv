package mem_scoreboard_pkg;
    import uvm_pkg::*;
    import parameters_pkg::*;
    import mem_transaction_pkg::*;
    `include "uvm_macros.svh"
    
    class mem_scoreboard extends uvm_scoreboard;
        

        logic [DATA_WIDTH-1:0] memory_golden [0:DEPTH-1];
        logic [DATA_WIDTH-1:0] golden_rdata; // latch rdata form function 
        int pass_count = 0;
        int fail_count = 0;

        uvm_analysis_export   #(mem_transaction) mem_analysis_export;
        uvm_tlm_analysis_fifo #(mem_transaction) mem_fifo;
        `uvm_component_utils(mem_scoreboard)

        function new (string name = "mem_scoreboard" ,  uvm_component parent);
            super.new(name, parent);
            mem_analysis_export = new("mem_analysis_export",this);
            mem_fifo = new("mem_fifo",this);
        endfunction

        function void build_phase (uvm_phase phase);
            super.build_phase(phase);
            `uvm_info(get_type_name(),"MEM SCOREBOARD BUILD PHASE",UVM_MEDIUM)
            for (int i = 0; i < DEPTH; i++) 
            begin
                memory_golden[i] = '0;
            end
            golden_rdata = '0;   
        endfunction
        
        function void connect_phase(uvm_phase phase);
            mem_analysis_export.connect(mem_fifo.analysis_export);
        endfunction

        function void golden_mem(
            input  logic                     rst_n,      
            input  logic                     mem_en,
            input  logic                     mem_we,
            input  logic [ADDR_WIDTH-1:0]    mem_addr,
            input  logic [DATA_WIDTH-1:0]    mem_wdata,
            output logic [DATA_WIDTH-1:0]    mem_rdata
        );
            if (!rst_n) 
                begin
                    golden_rdata = '0;
                end else if (mem_en) 
                begin
                    if (mem_we)
                        memory_golden[mem_addr] = mem_wdata;
                    else
                        golden_rdata = memory_golden[mem_addr];
                end
            mem_rdata = golden_rdata;
        endfunction

        task run_phase(uvm_phase phase);
            mem_transaction mem_tr;
            logic [DATA_WIDTH-1:0] exp_mem_rdata;
            bit out_ok;

            forever 
            begin
                mem_fifo.get(mem_tr);
                
                golden_mem(mem_tr.rst_n, mem_tr.mem_en, mem_tr.mem_we, mem_tr.mem_addr, mem_tr.mem_wdata, exp_mem_rdata);

                // 1. Reset Check
                if (!mem_tr.rst_n) 
                begin
                    out_ok = (mem_tr.mem_rdata === exp_mem_rdata);
                    if (out_ok) begin
                        `uvm_info(get_type_name(), $sformatf("PASS | OP=RESET ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                mem_tr.mem_addr, mem_tr.mem_rdata, exp_mem_rdata), UVM_LOW)
                        pass_count++;
                    end else begin
                        `uvm_error(get_type_name(), $sformatf("FAIL | OP=RESET ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                mem_tr.mem_addr, mem_tr.mem_rdata, exp_mem_rdata))
                        fail_count++;
                    end
                end
                // 2. Memory Enabled Operations
                else if (mem_tr.mem_en) 
                begin
                    // Write Transaction
                    if (mem_tr.mem_we) 
                    begin
                        if (memory_golden[mem_tr.mem_addr] === mem_tr.mem_wdata)
                        begin
                            `uvm_info(get_type_name(), $sformatf("PASS | OP=WRITE ADDR=0x%03h | DATA=0x%08h", 
                                    mem_tr.mem_addr, mem_tr.mem_wdata), UVM_LOW)
                            pass_count++;
                        end
                        else
                        begin
                            `uvm_error(get_type_name(), $sformatf("Failed | OP=Write ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                    mem_tr.mem_addr, mem_tr.mem_wdata, memory_golden[mem_tr.mem_addr]))
                            fail_count++;
                        end
                    end 
                    // Read Transaction Check
                    else 
                    begin
                        out_ok = (mem_tr.mem_rdata === exp_mem_rdata);
                        if (out_ok) 
                        begin
                            `uvm_info(get_type_name(), $sformatf("PASS | OP=READ ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                    mem_tr.mem_addr, mem_tr.mem_rdata, exp_mem_rdata), UVM_LOW)
                            pass_count++;
                        end 
                        else 
                        begin
                            `uvm_error(get_type_name(), $sformatf("FAIL | OP=READ ADDR=0x%03h | DUT: 0x%08h | EXP: 0x%08h",
                                    mem_tr.mem_addr, mem_tr.mem_rdata, exp_mem_rdata))
                            fail_count++;
                        end
                    end
                end
                // 3. Memory Disabled / Idle Transaction
                else 
                begin
                    `uvm_info(get_type_name(), "PASS | OP=IDLE (mem_en=0)", UVM_LOW)
                    pass_count++;
                end
            end
        endtask

        task print_pass_summary();
            `uvm_info(get_type_name(), "========================================", UVM_LOW)
            `uvm_info(get_type_name(), "           MEM SCOREBOARD PASS SUMMARY      ", UVM_LOW)
            `uvm_info(get_type_name(), "========================================", UVM_LOW)
            `uvm_info(get_type_name(), $sformatf("Total Checks Passed : %0d", pass_count), UVM_LOW)
            `uvm_info(get_type_name(), $sformatf("Total Checks Failed : %0d", fail_count), UVM_LOW)
            `uvm_info(get_type_name(), "========================================", UVM_LOW)
        endtask

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        print_pass_summary();
    endfunction

    endclass

endpackage