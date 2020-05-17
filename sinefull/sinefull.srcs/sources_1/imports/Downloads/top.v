`timescale 1ns / 1ps

// Section 5.2.2 of prac manual ONLY

module top(
    // These signal names are for the nexys A7. 
    // Check your constraint file to get the right names
    input  CLK100MHZ,
    output AUD_PWM, 
    output AUD_SD
    );
    
// Memory IO
reg ena = 1;        // ena = read enable 
reg wea = 0;        // wea = write enble    // not using so set low
reg [7:0] addra=0;
reg [10:0] dina=0;  //We're not putting data in, so we can leave this unassigned
wire [10:0] douta;  // contains the samples read in from the LUT_sinefull.coe implemented in BRAM

//PWM_in - this gets tied to the BRAM output
reg [10:0] PWM_in;
reg [10:0] counter =0;                // counter to count up to 1493 (see prac manual for explanation)


// Instantiate block memory here
// Copy from the instantiation template and change signal names to the ones under "MemoryIO"
blk_mem_gen_0 BRAM_fullsine (
    .clka(CLK100MHZ),     // input wire clka
    .ena(ena),            // input wire ena               // ena = read enable
    .wea(wea),            // input wire [0 : 0] wea       // wea = write enble
    .addra(addra),        // input wire [7 : 0] addra
    .dina(dina),          // input wire [10 : 0] dina
    .douta(douta)         // output wire [10 : 0] douta
    );

// Instantiate the PWM module
// PWM should take in the clock, the data from memory
// PWM should output to AUD_PWM (or whatever the constraints file uses for the audio out.
pwm_module pwm1(CLK100MHZ, PWM_in, AUD_PWM);

    
always @(posedge CLK100MHZ) begin
    
    PWM_in <= douta;                // tie memory output to the PWM input
    
    if (counter == 11'd1493) begin
        addra <= addra + 1;         // parse through the LUT vector by incrementing index
        counter = 11'd0;            // reset the counter (NOTE: using '<=' here doesnt work well)
    end
    
    counter <= counter + 11'd1;
   
end

assign AUD_SD = 1'b1;               // Enable audio out

endmodule
