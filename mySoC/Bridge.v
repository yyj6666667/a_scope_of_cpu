`timescale 1ns / 1ps
`include "defines.vh"

module Bridge (
    input  wire         rst_from_cpu,
    input  wire         clk_from_cpu,
    
    output wire [5:0]   enable_sel,

    output reg  [31:0]  rdata_to_cpu,
    input  wire [31:0]  wdata_from_cpu,
    input  wire [1 :0]  we_from_cpu,
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

    wire access_dig = (addr_from_cpu == `PERI_ADDR_DIG && we_from_cpu[1]) ? 1'b1 : 1'b0;
    wire access_led = (addr_from_cpu == `PERI_ADDR_LED) ? 1'b1 : 1'b0;
    wire access_sw  = (addr_from_cpu == `PERI_ADDR_SW ) ? 1'b1 : 1'b0;
    wire access_timer_read =(addr_from_cpu ==`PERI_ADDR_TIMER_READ) ? 1'b1 : 1'b0;
    wire access_timer_write=(addr_from_cpu == `PERI_ADDR_TIMER_WRITE) ? 1'b1 : 1'b0;
    assign   enable_sel  = { we_from_cpu[0],  //if it is one , then its lw or sw                            
                             access_sw,
                             access_dig,
                             access_led,                             
                             access_timer_read,
                             access_timer_write};
    always @(*) begin
        casex (enable_sel)
            6'b100010: rdata_to_cpu = rdata_from_timer;  
            6'b110000: rdata_to_cpu = rdata_from_sw;
            6'b1?????: rdata_to_cpu = rdata_from_dram; 
            default:   rdata_to_cpu = 32'hdeadbfee;
        endcase
    end
    assign wdata_to_led   =   (access_led)         ? wdata_from_cpu[15:0] : 16'hDEAD  ;
    assign wdata_to_dig   =   (access_dig)         ? wdata_from_cpu       : 32'hDEAD_6666  ; //haha
    assign wdata_to_timer =   (access_timer_write) ? wdata_from_cpu       : 32'hDEAD_6666  ; 
    assign wdata_to_dram  =   (we_from_cpu[1])         ? wdata_from_cpu       : 32'hDEAD_6666 ;
    assign addr_to_dram   =   (we_from_cpu[0])         ? addr_from_cpu        : 32'hDEAD_6666  ;

endmodule