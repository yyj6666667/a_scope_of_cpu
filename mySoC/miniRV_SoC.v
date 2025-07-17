`timescale 1ns / 1ps

`include "defines.vh"

module miniRV_SoC (
    input  wire         fpga_rst,   //!注意在下板之前改回来！原来是fpga_rstn
    input  wire         fpga_clk,   //

    input  wire [15:0]  sw,         //
    input  wire [ 4:0]  button,     //
    //高4位段选信号
    output wire [ 7:0]  led_seg0,   //
    //低4位段选信号
    output wire [ 7:0]  led_seg1,   //
    //位选信号
    output wire [ 7:0]  dig_sel, //
    output wire [15:0]  led


`ifdef RUN_TRACE
    ,// Debug Interface
    output wire         debug_wb_have_inst, // 当前时钟周期是否有指令写回 (对单周期CPU，可在复位后恒置1)
    output wire [31:0]  debug_wb_pc,        // 当前写回的指令的PC (若wb_have_inst=0，此项可为任意值)
    output              debug_wb_ena,       // 指令写回时，寄存器堆的写使能 (若wb_have_inst=0，此项可为任意值)
    output wire [ 4:0]  debug_wb_reg,       // 指令写回时，写入的寄存器号 (若wb_ena或wb_have_inst=0，此项可为任意值)
    output wire [31:0]  debug_wb_value      // 指令写回时，写入寄存器的值 (若wb_ena或wb_have_inst=0，此项可为任意值)
`endif
   );

    wire        pll_lock;
    wire        pll_clk;
    wire        cpu_clk;


    // Interface between CPU and Bridge
    wire [31:0] data_to_cpu;
    wire        en_data_trans;
    wire [31:0] Bus_addr;
    wire [31:0] Bus_wdata;
    
    // Interface between bridge and DRAM
    // wire         rst_bridge2dram;
    wire         clk_bridge2dram;
    wire [31:0]  addr_bridge2dram;
    wire [31:0]  rdata_dram2bridge;
    wire         we_bridge2dram;
    wire [31:0]  wdata_bridge2dram;  
    assign      addr_bridge2dram_pro = addr_bridge2dram[15:2];

    assign      led_seg1 = led_seg0;
    // Interface between bridge and peripherals
    // TODO: 在此定义总线桥与外设I/O接口电路模块的连接信号
    // bridge and dig
    wire  rst_to_dig;
    wire  clk_to_dig;
    wire  write_enable_to_dig; //相关信号由bri_control产生
    wire  [31:0] wdata_to_dig;
    //between bridge and sw
    wire [31:0] sw_pro;
    
     
`ifdef RUN_TRACE
    // Trace调试时，直接使用外部输入时钟
    assign cpu_clk = fpga_clk;
`else
    // 下板时，使用PLL分频后的时钟
    assign cpu_clk = pll_clk & pll_lock;

    cpuclk u_clkgen (
        // .resetn     (fpga_rst),
        .clk_in1    (fpga_clk),
        .clk_out1   (pll_clk),
        .locked     (pll_lock)
    );
`endif
    
    myCPU u_cpu (
        .cpu_rst            (fpga_rst), //原来是fpga_rst
        .cpu_clk            (cpu_clk),

        // Interface to Bridge
        .Bus_addr           (Bus_addr),
        .data_to_cpu        (data_to_cpu),//cpu read from 
        .en_data_trans      (en_data_trans),
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
        .clk_to_led         (/* TODO */),
        .addr_to_led        (/* TODO */),
        .we_to_led          (/* TODO */),
        .wdata_to_led       (/* TODO */),

        // Interface to switches
        .rdata_from_sw     (sw_pro),




        // Interface to buttons
        .rst_to_btn         (/* TODO */),
        .clk_to_btn         (/* TODO */),
        .addr_to_btn        (/* TODO */),
        .rdata_from_btn     (/* TODO */)
    );

    DRAM u_DRAM (
        .clk        (clk_bridge2dram),
        .a          (Bus_addr[15:2]),
        .spo        (rdata_dram2bridge),
        .we         (we_bridge2dram),
        .d          (wdata_bridge2dram)
    );
    
    // TODO: 在此实例化你的外设I/O接口电路模块
    //
    DIGITAL_LED u_digital_led(
        .led_seg(led_seg0),    //seg1直接被seg0赋值
        .dig_sel(dig_sel),
        //input below
        .clk(cpu_clk),
        .rst(fpga_rst),
        .write_enable(write_enable_to_dig), // b_control产生
        .data_from_bridge(wdata_to_dig)     //极有可能这个data来不及写进去，危险，时间紧
        
    );
    SW u_switch(
        .sw(sw),
        .sw_pro(sw_pro)
    );

endmodule
