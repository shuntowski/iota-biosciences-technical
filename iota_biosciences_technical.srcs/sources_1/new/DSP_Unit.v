/*DSP Unit Outline

DSP Unit consists of four distinct parts: Receiver, Rectifier, Averager, and Detector
Details of each sub-unit provided in specification.

*/


module DSP_Unit (
    input           CLK_100MHz,             // DSP Clock
    input           SRESET_n,               // Active low synchronous reset
    input           ADC_CLK,                // 32 MHz ADC clock
    input           ADC_OE_n,               // Active low ADC enable
    input           ADC_OF,                 // ADC Overflow
    input [11:0]    ADC_DATA,               // 12-bit ADC data bus
    input [11:0]    DETECTION_THRESHOLD,    // Unsigned detection
    output reg      DETECTED
);

reg         i_RD_ENB;
reg         i_WR_ENB;
wire        i_EMPTY;
wire        i_FULL;
reg [11:0]  i_DATA_OUT;
reg         i_DATA_AVAIL;
reg [11:0]  i_RECT_DATA;
reg [15:0]  i_SUM;      // Largest number that can be represented by 32 12-bit 2's compliment numbers is 65504, 16-bits
reg [11:0]  i_AVERAGE;

ADC_Receiver Receiver(
    .CLK_100MHz (CLK_100MHz),
    .SRESET_n   (SRESET_n),
    .ADC_CLK    (ADC_CLK),
    .ADC_OE_n   (ADC_OE_n),
    .ADC_DATA   (ADC_DATA),
    .RD_ENB     (i_RD_ENB),
    .WR_ENB     (i_WR_ENB),
    .EMPTY      (i_EMPTY),                  
    .FULL       (i_FULL),
    .DATA_OUT   (i_DATA_OUT)
);

//----------------------Unclocked Logic----------------------------------
always begin
    i_WR_ENB <= ~ADC_OE_n;
    i_RD_ENB <= (i_DATA_AVAIL) ? 1'b0 : 1'b1;
    i_RECT_DATA <= (i_DATA_OUT[0] == 1'b0) ? (~i_DATA_OUT + 1'b1) : i_DATA_OUT;     // Rectifier
end

//-------------------------------Clocked Logic--------------------------
always @ (posedge CLK_100MHz) begin
    if (SRESET_n == 1'b0) begin
        i_DATA_OUT      <= 'b0;
        i_DATA_AVAIL    <= 'b0;
    end else begin
        if (i_FULL) i_DATA_AVAIL <= 1'b1;
        else if (i_EMPTY) i_DATA_AVAIL <= 1'b0;
    end
end

// Averager
always @ (posedge CLK_100MHz) begin
    if (SRESET_n == 1'b0) begin
        i_SUM           <= 'b0;
        i_AVERAGE       <= 'b0;
    end else if (i_DATA_AVAIL) begin
        i_SUM <= i_SUM + i_RECT_DATA;
    end else if (i_DATA_AVAIL == 1'b0) begin
        i_AVERAGE <= i_SUM >> 5; // Right-shift 5-bits to divide by 32, don't worry about remainder for now
        i_SUM <= 'b0;
    end
end

// Detector
always @ (posedge CLK_100MHz) begin
    if (SRESET_n == 1'b0) begin
        DETECTED <= 1'b0;
    end else if (ADC_OF == 1'b0) begin
        if (i_AVERAGE >= DETECTION_THRESHOLD) DETECTED <= 1'b1;
        else DETECTED <= 1'b0;
    end else DETECTED <= 1'b0;
end
endmodule