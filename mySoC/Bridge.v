`timescale 1ns / 1ps
`include "defines.vh"

module Bridge (
    input  wire         rst_from_cpu,
    input  wire         clk_from_cpu,
    
    output wire [5:0]   enable_sel,

    output reg  [31:0]  rdata_to_cpu,
    input  wire [31:0]  wdata_from_cpu,
    input  wire         we_from_cpu,
    input  wire [31:0]  addr_from_cpu,

    output wire [31:0]  wdata_to_dram,
    input  wire [31:0]  rdata_from_dram,
    output wire [31:0]  addr_to_dram,

    output wire [31:0]  wdata_to_timer,
    input  wire [31:0]  rdata_from_timer,

    output  wire [15:0] wdata_to_led,

    input  wire [31:0]  rdata_from_sw,

    output wire [31:0]  wdata_to_dig
);

    wire access_mem = (addr_from_cpu[31:12] != 20'hFFFFF) ? 1'b1 : 1'b0;
    wire access_dig = (addr_from_cpu == `PERI_ADDR_DIG) ? 1'b1 : 1'b0;
    wire access_led = (addr_from_cpu == `PERI_ADDR_LED) ? 1'b1 : 1'b0;
    wire access_sw  = (addr_from_cpu == `PERI_ADDR_SW ) ? 1'b1 : 1'b0;
    wire access_timer_read =(addr_from_cpu ==`PERI_ADDR_TIMER_READ) ? 1'b1 : 1'b0;
    wire access_timer_write=(addr_from_cpu == `PERI_ADDR_TIMER_WRITE) ? 1'b1 : 1'b0;
    assign   enable_sel  = { access_mem,                            
                             access_sw,
                             access_dig,
                             access_led,                             
                             access_timer_read,
                             access_timer_write};
    always @(*) begin
        casex (enable_sel)
            6'b1?????: rdata_to_cpu = rdata_from_dram;
            6'b010000: rdata_to_cpu = rdata_from_sw;
            6'b000010: rdata_to_cpu = rdata_from_timer;   
            default:   rdata_to_cpu = 32'hdeadbfee;
        endcase
    end
    assign wdata_to_led   =   (access_led)         ? wdata_from_cpu[15:0] : 16'hDEAD  ;
    assign wdata_to_dig   =   (access_dig)         ? wdata_from_cpu       : 32'hDEAD_6666  ; //haha
    assign wdata_to_timer =   (access_timer_write) ? wdata_from_cpu       : 32'hDEAD_6666  ; 
    assign wdata_to_dram  =   (access_mem)         ? wdata_from_cpu       : 32'hDEAD_6666 ;
    assign addr_to_dram   =   (access_mem)         ? addr_from_cpu        : 32'hDEAD_6666  ;

endmodule


 /*  
   // Interface to DRAM
   // output wire         rst_to_dram,
   output wire         clk_to_dram,
   output wire [31:0]  addr_to_dram,
   input  wire [31:0]  rdata_from_dram,
   output wire         we_to_dram,
   output wire [31:0]  wdata_to_dram,
   
   // Interface to 7-seg digital LEDs
   output wire         we_to_dig,
   output wire [31:0]  wdata_to_dig,
   // Interface to LEDs
   output wire         rst_to_led,
   output wire         clk_to_led,
   output wire [31:0]  addr_to_led,
   output wire         we_to_led,
   output wire [15:0]  wdata_to_led,
   // Interface to switches
   input  wire [31:0]  rdata_from_sw,
   // Interface to buttons
   output wire         rst_to_btn,
   output wire         clk_to_btn,
   output wire [31:0]  addr_to_btn,
   input  wire [31:0]  rdata_from_btn,
   // with timer
   output wire         rst_to_timer,
   output wire         clk_to_timer,
   output wire         we_to_timer,
   output wire [31:0]  wdata_to_timer,
   input  wire [31:0]  rdata_from_timer
  */ 



/*
    // DRAM
    // assign rst_to_dram  = rst_from_cpu;
    assign clk_to_dram   = clk_from_cpu;
    assign addr_to_dram  = addr_from_cpu;
    assign we_to_dram    = we_from_cpu & access_mem;
    assign wdata_to_dram = wdata_from_cpu;

    // 7-seg LEDs
    assign rst_to_dig    = rst_from_cpu;
    assign clk_to_dig    = clk_from_cpu;
    assign we_to_dig     = we_from_cpu & access_dig;
    assign wdata_to_dig  = wdata_from_cpu;

    // LEDs
    assign rst_to_led    = rst_from_cpu;
    assign clk_to_led    = clk_from_cpu;
    assign addr_to_led   = addr_from_cpu;
    assign we_to_led     = we_from_cpu & access_led;
    assign wdata_to_led  = wdata_from_cpu;
    
    // Switches
    assign rst_to_sw     = rst_from_cpu;
    assign clk_to_sw     = clk_from_cpu;
    assign addr_to_sw    = addr_from_cpu;


    // Buttons
    assign rst_to_btn    = rst_from_cpu;
    assign clk_to_btn    = clk_from_cpu;
    assign addr_to_btn   = addr_from_cpu;

    //timer
    assign rst_to_timer  = rst_from_cpu;
    assign clk_to_timer  = clk_from_cpu;
    assign we_to_timer   = we_from_cpu & access_timer_write;
    assign wdata_to_timer= wdata_from_cpu;
*/