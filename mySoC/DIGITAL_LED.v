`timescale 1ns / 1ps


module DIGITAL_LED(
    output reg [7:0] led_seg,
    output reg [7:0] dig_sel,
    input   clk,
    input   rst,
    input   write_enable,
    input  [31:0] data_from_bridge
    );
    
    reg [31:0] data;
    wire [63:0] data_after_mapping;
    //移位流水线,跟随固有时钟，后序可能可以优化
    always @(posedge clk or posedge rst) begin
        if(rst) dig_sel <= 8'b0000_0001;
        else    dig_sel <= {dig_sel[6:0] , dig_sel[7]};
    end
    //read data
    always @(posedge clk or posedge rst) begin
        if(rst) data <= 32'hdeadbeef;
        else if(write_enable)
            data <= data_from_bridge;
    end
    //feedback washed data
    always @(*) begin
        case(dig_sel)
            8'b0000_0001: led_seg = data_after_mapping[7: 0];
            8'b0000_0010: led_seg = data_after_mapping[15:8];
            8'b0000_0100: led_seg = data_after_mapping[23:16];
            8'b0000_1000: led_seg = data_after_mapping[31:24];
            8'b0001_0000: led_seg = data_after_mapping[39:32];
            8'b0010_0000: led_seg = data_after_mapping[47:40];
            8'b0100_0000: led_seg = data_after_mapping[55:48];
            8'b1000_0000: led_seg = data_after_mapping[63:56];
            default:      led_seg = 8'd0;
        endcase
    end

    //wash data
    MAPPING u_mapping0(
    .data(data[3:0]),
    .data_after_mapping(data_after_mapping[7:0])
    );
    MAPPING u_mapping1(
    .data(data[7:4]),
    .data_after_mapping(data_after_mapping [15:8])
    );
    MAPPING u_mapping2(
    .data(data[11:8]),
    .data_after_mapping(data_after_mapping [23:16])
    );
    MAPPING u_mapping3(
    .data(data[15:12]),
    .data_after_mapping(data_after_mapping[31:24])
    );
    MAPPING u_mapping4(
    .data(data[19:16]),
    .data_after_mapping(data_after_mapping[39:32])
    );
    MAPPING u_mapping5(
    .data(data[23:20]),
    .data_after_mapping(data_after_mapping[47:40])
    );
    MAPPING u_mapping6(
    .data(data[27:24]),
    .data_after_mapping(data_after_mapping[55:48])
    );
    MAPPING u_mapping7(
    .data(data[31:28]),
    .data_after_mapping(data_after_mapping[63:56])
    );

endmodule
