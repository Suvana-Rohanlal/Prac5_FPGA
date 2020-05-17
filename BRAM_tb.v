`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/17/2020 02:34:21 PM
// Design Name: 
// Module Name: BRAM_tb
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


module BRAM_tb();
    reg CLK100MHZ;
    reg [0:0] wea; //write enable
    reg [7:0] addra; //address
    reg signed [31:0] dina; //data in
    reg ena; //input enable
    //outputs
    wire [10:0] douta; //output
    reg [10:0] result;
    BRAM test (
        .clka(CLK100MHZ),    // input wire clka
        .ena(ena),      // input wire ena
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra),  // input wire [7 : 0] addra
        .dina(dina),    // input wire [10 : 0] dina
        .douta(douta)  // output wire [10 : 0] douta
    );

    
    
    integer phase; // between 0 and 3
    integer counter; // when to read address at counter = 1493
    initial begin
        //initialize inputs
        CLK100MHZ = 0;
        addra = 0;
        dina = 0;
        phase = 0;
        counter = 0;
        #100
        wea <= 0;
        ena <= 1;
    end
    
    task setPhase;
        begin
            
            if (addra == 63 && phase == 0) begin //output = end of first quarter
                phase = 1;
            end
            
            if (addra == 0 && phase == 1) begin // end of second quarter
                phase = 2;
            end
            
            if (addra == 63 && phase == 2) begin // end of third quarter
                phase = 3;
            end
            
            if (addra == 0 && phase == 3) begin // end of fourth quarter,  loopback
                phase = 0;
            end           
            
        end
    endtask
    
    task readData;
        begin
            if (phase == 0) begin // first quarter normal output
                result = douta;
                addra = addra + 1;
            end
            
            if (phase == 1) begin
                addra = addra - 1;
                result = douta;
            end
            
            if (phase == 2) begin 
                addra = addra + 1;
                result = -douta;// may be buggy here
            end
            
            if (phase == 3) begin
                addra = addra - 1;
                result = -douta;// may be buggy here
            end
        end
    endtask
    
    always @ (posedge CLK100MHZ) begin
        
        if (counter == 1493) begin
            setPhase;
            readData;
            counter = 0;
        end
        
        counter = counter + 1;
        
    end
endmodule