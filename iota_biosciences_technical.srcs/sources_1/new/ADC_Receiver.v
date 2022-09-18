/*ADC Receiver

Responsible for buffering the data while the ADC is enabled.

LTC2229 samples at 32 Megasamples-per-second. 
ADC is active for 1us. 
Total samples: 32.
ADC data is 12-bits, 2's complement.

ADC Receiver is a 12-bit wide, 32 register deep FIFO.
*/

module ADC_Receiver #(parameter width = 12, parameter depth = 32)(
    input                   CLK_100MHz,             // DSP Clock
    input                   SRESET_n,               // Active low synchronous reset
    input                   ADC_CLK,                // 32 MHz ADC clock
    input                   ADC_OE_n,               // Active low ADC enable
    input [width-1:0]       ADC_DATA,               // 12-bit ADC data bus   
    input                   RD_ENB,                 // Read enable
    input                   WR_ENB,                 // Write enable
    output wire             EMPTY,                  
    output wire             FULL,
    output reg [width-1:0]  DATA_OUT
);

reg [4:0]        i_count;
reg [4:0]        i_readCount;
reg [4:0]        i_writeCount;
reg [width-1:0]  i_FIFO [0:depth-1];

assign EMPTY = (i_count == 0) ? 1'b1 : 1'b0; 
assign FULL = (i_count == depth-1) ? 1'b1 : 1'b0; 

// Reading out at 100MHz clock rate
always @ (posedge CLK_100MHz) begin
    if (SRESET_n == 1'b0) begin             // Reset
        DATA_OUT        <= 'b0;
        i_readCount     <= 'b0;
        i_count         <= 'b0;
    end else if (ADC_OE_n == 1'b1) begin    
        if (RD_ENB == 1'b1 && i_count != 0) begin
            DATA_OUT <= i_FIFO[i_readCount];
            i_readCount <= i_readCount + 1'b1;
        end
    end
    
    // Resetting read val after reaching max value
    if (i_readCount == depth-1) i_readCount = 0;
    
    if (i_readCount > i_writeCount) begin
        i_count <= i_readCount - i_writeCount;
    end else if (i_writeCount > i_readCount) i_count <= i_writeCount - i_readCount;
end

// Writing in at ADC Clock rate
always @ (posedge ADC_CLK) begin
    if (SRESET_n == 1'b0) begin
        i_writeCount    <= 'b0;
    end else if (ADC_OE_n == 1'b0) begin
        if (WR_ENB == 1'b1 && i_count < 31) begin
            i_FIFO[i_writeCount] <= ADC_DATA;
            i_writeCount <= i_writeCount + 1'b1;
        end
    end
    
    // Resetting the write val after reaching max
    if (i_writeCount == depth-1) i_writeCount = 0;
end
endmodule