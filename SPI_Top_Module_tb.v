
module tb_SPI_Top_Module;
    reg clk;
    reg reset;
    reg start;
    reg [31:0] data_in;
    wire [31:0] data_out;
    wire MOSI;
    wire SCLK;
    wire CS;
    wire MISO;
    // Clock generation
    initial begin
        clk = 0;
        forever #1 clk = ~clk; // 100MHz clock
    end

    // Instantiate the Top Module
    SPI_Top_Module uut (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .data_out(data_out),
        .MOSI(MOSI),
        .MISO(MISO),
        .SCLK(SCLK),
        .CS(CS)
    );


    // Stimulus
    initial begin
        // Initial values
        reset = 1;
        #10 start=1;
        data_in = 32'hA5A5A5A5;
        reset = 0;
        start = 1;
        // Send data        
        $display("Time | clk | rst | start | CS | SCLK | MOSI | MISO | Master_In | Master_Out");
        $monitor("%4t | %b   | %b   | %b     | %b  | %b    | %b    | %b    | %h      | %h",
                 $time, clk, reset, start, uut.CS, uut.SCLK, uut.MOSI, uut.MISO, uut.data_in, uut.data_out);
        #100;
        start = 0;

    end

endmodule
