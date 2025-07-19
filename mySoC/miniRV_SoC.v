`timescale 1ns / 1ps

`include "defines.vh"

module miniRV_SoC (
    input  wire         fpga_rst,  //!注意在下板之前改回来！原来是fpga_rstn
    input  wire         fpga_clk,   //
    input  wire [15:0]  sw,         //
    input  wire [ 4:0]  button,     //
    //高4位段选信号
    output wire [ 7:0]  led_seg0,   //
    //低4位段选信号
    output wire [ 7:0]  led_seg1,   //
    //位选信号
    output wire [ 7:0]  dig_sel,    //
    output wire [15:0]  led 

`ifdef RUN_TRACE
    ,
    output wire         debug_wb_have_inst, 
    output wire [31:0]  debug_wb_pc,        
    output              debug_wb_ena,       
    output wire [ 4:0]  debug_wb_reg,       
    output wire [31:0]  debug_wb_value      
`endif
   );
    assign       led_seg1 = led_seg0;
    wire         pll_lock;
    wire         pll_clk;
    wire         cpu_clk;

    wire [5:0]   enable_sel;

    wire [31:0]  data_to_cpu;
    wire         en_data_trans;
    wire [31:0]  Bus_addr;
    wire [31:0]  Bus_wdata;

    wire [31:0]  wdata_to_dram;  
    wire [31:0]  rdata_from_dram;
    wire [31:0]  addr_to_dram ;
    wire [13:0]  addr_to_dram_pro = addr_to_dram[15:2];

    wire [31:0]  wdata_to_timer;
    wire [31:0]  rdata_from_timer;

    wire [15:0]  wdata_to_led;

    wire [31:0]  rdata_from_sw; 

    wire [31:0]  wdata_to_dig;
    
     
`ifdef RUN_TRACE
        assign      cpu_clk = fpga_clk;
`else
        assign      cpu_clk = pll_clk & pll_lock;
    cpuclk u_clkgen (
    //  .resetn     (fpga_rst),
        .clk_in1    (fpga_clk),
        .clk_out1   (pll_clk),
        .locked     (pll_lock)
    );
`endif
    
    myCPU u_cpu (
        .cpu_rst            (fpga_rst), //原来是fpga_rst
        .cpu_clk            (cpu_clk),

        // Interface to Bridge
        .addr_out           (Bus_addr),
        .data_to_cpu        (data_to_cpu),//cpu read from 
        .en_data_trans      (en_data_trans), //感觉在我手上变成了一个标记信号
        .Bus_wdata          (Bus_wdata)
`ifdef RUN_TRACE
        ,
        .debug_wb_have_inst (debug_wb_have_inst),
        .debug_wb_pc        (debug_wb_pc),
        .debug_wb_ena       (debug_wb_ena),
        .debug_wb_reg       (debug_wb_reg),
        .debug_wb_value     (debug_wb_value)
`endif
    );
   
    
    
    Bridge u_bridge (       
        .rst_from_cpu(fpga_rstn),
        .clk_from_cpu(fpga_clk),   
        .enable_sel(enable_sel),     
        .rdata_to_cpu(data_to_cpu),
        .wdata_from_cpu(Bus_wdata),
        .we_from_cpu(en_data_trans), //doubt
        .addr_from_cpu(Bus_addr),
        .wdata_to_dram(wdata_to_dram),
        .rdata_from_dram(rdata_from_dram),
        .addr_to_dram(addr_to_dram),
        .wdata_to_timer(wdata_to_timer),
        .rdata_from_timer(rdata_from_timer),
        .wdata_to_led(wdata_to_led),
        .rdata_from_sw(rdata_from_sw),
        .wdata_to_dig(wdata_to_dig)
    );

    DRAM u_DRAM (
        .clk        (cpu_clk),
        .a          (addr_to_dram_pro),
        .spo        (rdata_from_dram),
        .we         (enable_sel[5] & en_data_trans),
        .d          (wdata_to_dram)
    );
    
    DIGITAL_LED u_digital_led(
        .led_seg(led_seg0),    
        .dig_sel(dig_sel),
        //input 
        .clk(cpu_clk),
        .rst(fpga_rst),
        .write_enable(enable_sel[3]), 
        .data_from_bridge(wdata_to_dig)    
    );
    SW u_switch(
        .sw(sw),
        .sw_pro(rdata_from_sw)
    );
    timer u_timer(
        .clk(cpu_clk),
        .rst(fpga_rst),
        .wen(enable_sel[0]),
        .windex_to_timer(wdata_to_timer),
        .rdata(rdata_from_timer)
    );

endmodule
/*
  // Interface to CPU
  .rst_from_cpu       (fpga_rst), //原来是fpga_rst
  .clk_from_cpu       (cpu_clk),
  .addr_from_cpu      (Bus_addr),
  .we_from_cpu        (en_data_trans),
  .wdata_from_cpu     (Bus_wdata),
  .rdata_to_cpu       (data_to_cpu),// to 表示数据的走向，我感觉这里read单指cpu获得data，write单指cpu往别的任何地方写
  
  // Interface to DRAM
  // .rst_to_dram    (rst_bridge2dram),
  .clk_to_dram        (clk_bridge2dram),
  .addr_to_dram       (addr_bridge2dram),
  .rdata_from_dram    (rdata_dram2bridge),
  .we_to_dram         (we_bridge2dram),
  .wdata_to_dram      (wdata_bridge2dram),
  
  // Interface to 7-seg digital LEDs
  .we_to_dig          (write_enable_to_dig),
  .wdata_to_dig                 (wdata_to_dig),
  // Interface to LEDs
  .rst_to_led         (),
  .clk_to_led         (/* TODO ),
  .addr_to_led        (/* TODO ),
  .we_to_led          (/* TODO ),
  .wdata_to_led       (/* TODO ),
  // Interface to switches
  .rdata_from_sw     (sw_pro),
  // Interface to buttons
  .rst_to_btn         (/* TODO ),
  .clk_to_btn         (/* TODO ),
  .addr_to_btn        (/* TODO ),
  .rdata_from_btn     (/* TODO )
  */