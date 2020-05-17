`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2020 12:51:58
// Design Name: 
// Module Name: fullsine_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fullsine_tb();

reg CLK100MHZ = 0;
wire AUD_PWM;
wire AUD_SD;

top DUT(
    .CLK100MHZ(CLK100MHZ),
    .AUD_PWM(AUD_PWM),
    .AUD_SD(AUD_SD)
    );
    

initial begin
    // intialize inputs
    CLK100MHZ = 0;
    
end

always #5 CLK100MHZ = ~CLK100MHZ;

endmodule

