import axi_para_pkg::*;
import AXI_properties_pkg::*;

interface AXI_if #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 16,
    parameter MEMORY_DEPTH = 1024
);

    op_t                      operation;
    logic                     ARESETn;
    logic                     ACLK;
    // Write address channel
    logic [ADDR_WIDTH-1:0]    AWADDR;
    logic [7:0]               AWLEN;
    logic [2:0]               AWSIZE;
    logic                     AWVALID;
    logic                     AWREADY;

    // Write data channel
    logic [DATA_WIDTH-1:0]    WDATA;
    logic                     WVALID;
    logic                     WLAST;
    logic                     WREADY;

    // Write response channel
    logic [1:0]                BRESP;
    logic                      BVALID;
    logic                      BREADY;

    // Read address channel
    logic [ADDR_WIDTH-1:0]    ARADDR;
    logic [7:0]               ARLEN;
    logic [2:0]               ARSIZE;
    logic                     ARVALID;
    logic                     ARREADY;

    // Read data channel
    logic [DATA_WIDTH-1:0]     RDATA;
    logic [1:0]                RRESP;
    logic                      RVALID;
    logic                      RLAST;
    logic                      RREADY;

    
   


    // --- ASSERTIONS 
    
    Assertion_bvalid_after_last: assert property (
        p_bvalid_after_wlast(ACLK, ARESETn, BVALID, WVALID, WREADY, WLAST)
    ) else $error("[SVA ERROR] bvalid_after_last is failed");

    Assertion_rready_after_last: assert property (
        RREADY_after_wlast_is_zero(ACLK, ARESETn, RLAST, RREADY, RVALID)
    ) else $error("[SVA ERROR] RREADY_after_wlast_is_zero is failed");

    Assertion_awready_after_awvalid: assert property (
        awready_after_awvalid(ACLK, ARESETn, AWVALID, AWREADY)
    ) else $error("[SVA ERROR] awready_after_awvalid is failed");

    Assertion_WLAST_AND_RLAST: assert property (
        WLAST_AND_RLAST(ACLK, ARESETn, WLAST, RLAST)
    ) else $error("[SVA ERROR] WLAST_AND_RLAST is failed");

    Assertion_WLAST_AND_AWREADY: assert property (
        WLAST_AND_AWREADY(ACLK, ARESETn, WLAST, AWREADY)
    ) else $error("[SVA ERROR] WLAST_AND_AWREADY is failed");

    Assertion_RLAST_AND_ARREADY: assert property (
        RLAST_AND_ARREADY(ACLK, ARESETn, RLAST, ARREADY)
    ) else $error("[SVA ERROR] RLAST_AND_ARREADY is failed");

    Assertion_WLAST_AND_AWVALID: assert property (
        WLAST_AND_AWVALID(ACLK, ARESETn, WLAST, AWVALID)
    ) else $error("[SVA ERROR] WLAST_AND_AWVALID is failed");

    Assertion_RLAST_AND_ARVALID: assert property (
        RLAST_AND_ARVALID(ACLK, ARESETn, RLAST, ARVALID)
    ) else $error("[SVA ERROR] RLAST_AND_ARVALID is failed");

    
    

endinterface 