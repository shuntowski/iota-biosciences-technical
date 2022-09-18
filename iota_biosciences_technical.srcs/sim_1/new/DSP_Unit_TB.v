`timescale 1ns / 1ps

module DSP_Unit_TB();

reg         clk;
reg         CLK_100MHz;
reg         SRESET_n;
reg         ADC_CLK;
reg         ADC_OE_n;
reg         ADC_OF;
reg [11:0]  ADC_DATA;
reg [11:0]  DETECTION_THRESHOLD;
reg         RD_ENB;
reg         WR_ENB;
wire        EMPTY;
wire        FULL;
reg [11:0]  DATA_OUT;

//Clocks
initial begin
    clk <= 'b0;
    forever begin
        #1;
        clk <= ~clk;
    end
end

// NOTE: The spartan-6 has a 100MHz clock built-in, so this should be 'fine'.
// 100 MHz chip clock
initial begin
    CLK_100MHz <= 'b0;
    forever begin
        #5;
        CLK_100MHz <= ~CLK_100MHz;
    end
end

// 32 Mhz ADC Clock
initial begin
    ADC_CLK <= 'b0;
    forever begin
        #15.625;
        ADC_CLK <= ~ADC_CLK;
    end
end

initial begin
    SRESET_n    <= 'b1;
    ADC_OE_n    <= 'b1;
    ADC_OF      <= 'b0;
    ADC_DATA    <= 'b0;
    DETECTION_THRESHOLD <= 'b0;
end

always @ (posedge clk) begin
    SRESET_n <= 1'b0;           // Make sure everything is reset
    #15.625
    SRESET_n <= 1'b1;
    #15.625
    ADC_OE_n <= 1'b0;
    ADC_DATA <= 12'h001;        // Feed in the data from the ADC at its 32 MHz clock rate
    #15.625;
    ADC_DATA <= 12'h002;
    #15.625;
    ADC_DATA <= 12'h003;
    #15.625;
    ADC_DATA <= 12'h004;
    #15.625;
    ADC_DATA <= 12'h005;
    #15.625;
    ADC_DATA <= 12'h006;
    #15.625;
    ADC_DATA <= 12'h007;
    #15.625;
    ADC_DATA <= 12'h008;
    #15.625;
    ADC_DATA <= 12'h009;
    #15.625;
    ADC_DATA <= 12'h00a;
    #15.625;
    ADC_DATA <= 12'h00b;
    #15.625;
    ADC_DATA <= 12'h00c;
    #15.625;
    ADC_DATA <= 12'h00d;
    #15.625;
    ADC_DATA <= 12'h00e;
    #15.625;
    ADC_DATA <= 12'h00f;
    #15.625;
    ADC_DATA <= 12'h010;
    #15.625;
    ADC_DATA <= 12'h011;
    #15.625;
    ADC_DATA <= 12'h012;
    #15.625;
    ADC_DATA <= 12'h013;
    #15.625;
    ADC_DATA <= 12'h014;
    #15.625;
    ADC_DATA <= 12'h015;
    #15.625;
    ADC_DATA <= 12'h016;
    #15.625;
    ADC_DATA <= 12'h017;
    #15.625;
    ADC_DATA <= 12'h018;
    #15.625;
    ADC_DATA <= 12'h019;
    #15.625;
    ADC_DATA <= 12'h01a;
    #15.625;
    ADC_DATA <= 12'h01b;
    #15.625;
    ADC_DATA <= 12'h01c;
    #15.625;
    ADC_DATA <= 12'h01d;
    #15.625;
    ADC_DATA <= 12'h01e;
    #15.625;
    ADC_DATA <= 12'h01f;
    #15.625;
    ADC_DATA <= 12'h020;
    #15.625;
    ADC_OE_n <= 1'b1;
end
endmodule
