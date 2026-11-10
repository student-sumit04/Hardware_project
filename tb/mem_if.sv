interface mem_if #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10,
    parameter DEPTH = 1024
)(
    input logic                  clk,
    input logic                  rst_n,
    input logic                  mem_en,
    input logic                  mem_we,
    input logic [ADDR_WIDTH-1:0] mem_addr,
    input logic [DATA_WIDTH-1:0] mem_wdata,
    input logic [DATA_WIDTH-1:0] mem_rdata
);
endinterface