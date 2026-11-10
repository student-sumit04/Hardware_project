package axi_transaction_pkg;

    import axi_para_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class axi_transaction extends uvm_sequence_item;

        rand logic                  ARESETn;
        rand logic [ADDR_WIDTH-1:0] AWADDR;
        rand logic [7:0]            AWLEN;
        logic      [2:0]            AWSIZE;
        rand logic                  AWVALID;
        logic                       AWREADY;
        // Write data channel
        rand logic [DATA_WIDTH-1:0] WDATA[];
        logic                       WVALID;
        logic                       WLAST;
        logic                       WREADY;

        // Write response channel
        logic      [1:0]            BRESP;
        logic                       BVALID;
        logic                       BREADY;

        // Read address channel
        rand logic [ADDR_WIDTH-1:0] ARADDR;
        rand logic [7:0]            ARLEN;
        logic      [2:0]            ARSIZE;
        rand logic                  ARVALID;
        logic                       ARREADY;

        // Read data channel
        logic      [DATA_WIDTH-1:0] RDATA[];
        logic      [1:0]            RRESP;
        logic                       RVALID;
        logic                       RLAST;
        logic                       RREADY;
        rand logic [1:0] addr_mode;
        rand logic  len_mode;
        rand op_t                   op;

    constraint operation {
            op dist {
                WRITE := 35,
                READ  := 35,
                IDLE  := 30
            };
            }
            constraint rst
            {
            ARESETn dist {1:=95 , 0:=5};
            }

            constraint address_mode 
            {
            addr_mode dist {3:=10, 2:=20, 1:=40, 0:=30}; //3:=10, 2:=20, 1:=40, 0:=30
            }
            constraint length_mode 
            {
            len_mode dist { 1:=50, 0:=50};
            }

            constraint addr {
            if(addr_mode == 0)
            {
                AWADDR inside {[3211 : 4095]};
                ARADDR == AWADDR;
            }
            else if (addr_mode == 2'd1)
            {
                (AWADDR + ((AWLEN + 1) * 4)) <= 4096;
                ARADDR == AWADDR;  
            }
            else if (addr_mode == 2'd2) 
            {
                AWADDR inside {[4096 : 65536]};
                ARADDR == AWADDR;
            }
            else
            {
                AWADDR inside {2024};  //0 , 4092
                ARADDR == AWADDR; 
            }
            }
            
            constraint burst_c {
            if(!len_mode)
            {
                AWLEN inside {[0:$]};
            }
            else
            {
                AWLEN inside {0};
            }
            WDATA.size() == AWLEN + 1;
            ARLEN == AWLEN;
            }
            
            constraint valid {
            if (op == WRITE) {
                AWVALID == 1;
                ARVALID == 0; 
            } else
            if (op == READ) {
                AWVALID == 0;
                ARVALID != AWVALID;
            } else {
                AWVALID == 0;
                ARVALID == 0;
            }
            }


        `uvm_object_utils_begin (axi_transaction)
            // Reset
            `uvm_field_int(ARESETn,   UVM_DEFAULT)

            // Write address channel
            `uvm_field_int(AWADDR,    UVM_DEFAULT)
            `uvm_field_int(AWLEN,     UVM_DEFAULT)
            `uvm_field_int(AWSIZE,    UVM_DEFAULT)
            `uvm_field_int(AWVALID,   UVM_DEFAULT)
            `uvm_field_int(AWREADY,   UVM_DEFAULT)

            // Write data channel
            `uvm_field_array_int(WDATA, UVM_DEFAULT)
            `uvm_field_int(WVALID,     UVM_DEFAULT)
            `uvm_field_int(WLAST,      UVM_DEFAULT)
            `uvm_field_int(WREADY,     UVM_DEFAULT)

            // Write response channel
            `uvm_field_int(BRESP,     UVM_DEFAULT)
            `uvm_field_int(BVALID,    UVM_DEFAULT)
            `uvm_field_int(BREADY,    UVM_DEFAULT)

            // Read address channel
            `uvm_field_int(ARADDR,    UVM_DEFAULT)
            `uvm_field_int(ARLEN,     UVM_DEFAULT)
            `uvm_field_int(ARSIZE,    UVM_DEFAULT)
            `uvm_field_int(ARVALID,   UVM_DEFAULT)
            `uvm_field_int(ARREADY,   UVM_DEFAULT)

            // Read data channel
            `uvm_field_array_int(RDATA, UVM_DEFAULT)
            `uvm_field_int(RRESP,        UVM_DEFAULT)
            `uvm_field_int(RVALID,       UVM_DEFAULT)
            `uvm_field_int(RLAST,        UVM_DEFAULT)
            `uvm_field_int(RREADY,       UVM_DEFAULT)                

        `uvm_object_utils_end

        function new (string name = "axi_transaction");
            super.new(name);
        endfunction

    endclass

endpackage