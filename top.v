`timescale 1ns / 1ps

module top(
    // These signal names are for the nexys A7. 
    // Check your constraint file to get the right names
    input  CLK100MHZ,
    input [7:0] SW,
    input BTNL,
    output AUD_PWM, 
    output AUD_SD,
    output [2:0] LED
    );
    
    // Toggle arpeggiator enabled/disabled
    wire arp_switch;
    Debounce change_state (CLK100MHZ, BTNL, arp_switch); // ensure your button choice is correct
    
    // Memory IO
    reg ena = 1;
    reg wea = 0;
    reg [7:0] addra=0;
    reg [10:0] dina=0; //We're not putting data in, so we can leave this unassigned
    wire [10:0] douta;
    integer phase;
    
    reg [10:0] result= 0;
    
    // Instantiate block memory here
    // Copy from the instantiation template and change signal names to the ones under "MemoryIO"
    // use quartsine wave implementation
    BRAM quartsine (
        .clka(CLK100MHZ),    // input wire clka
        .ena(ena),      // input wire ena
        .wea(wea),      // input wire [0 : 0] wea
        .addra(addra),  // input wire [5 : 0] addra
        .dina(dina),    // input wire [10 : 0] dina
        .douta(douta)  // output wire [10 : 0] douta
    );
    
    
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
                result = 1024 - (douta - 1024);// may be buggy here
            end
            
            if (phase == 3) begin
                addra = addra - 1;
                result = 1024 - (douta - 1024);// may be buggy here
            end
        end
    endtask
    
    
    
    //PWM Out - this gets tied to the BRAM
    reg [10:0] PWM;
    
    // Instantiate the PWM module
    // PWM should take in the clock, the data from memory
    // PWM should output to AUD_PWM (or whatever the constraints file uses for the audio out.
    pwm_module pwm1(CLK100MHZ, douta, AUD_PWM);
    
    // Devide our clock down
    reg [12:0] clkdiv = 0;
    
    // keep track of variables for implementation
    reg [26:0] note_switch = 0;
    reg [1:0] note = 0;
    reg [8:0] f_base = 0;
    
always @(posedge CLK100MHZ) begin   
    PWM <= result; // tie memory output to the PWM input
    
    f_base[8:0] = 261 + SW[7:0]; // get the "base" frequency to work from 
    
    // Loop to change the output note IF we're in the arp state
    note_switch = note_switch + 1;    
    if(note_switch == 50000000)begin 
        note = note +1;
        note_switch = 0;
    end
    // FSM to switch between notes, otherwise just output the base note.
    clkdiv <= clkdiv +1;
    if(clkdiv >= f_base*2)begin
        clkdiv[12:0] <= 0;
        setPhase;
        readData;
    end
end


assign AUD_SD = 1'b1;  // Enable audio out
assign LED[1:0] = note[1:0]; // Tie FRM state to LEDs so we can see and hear changes


endmodule