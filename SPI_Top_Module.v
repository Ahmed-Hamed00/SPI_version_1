module SPI_Top_Module (
    input wire clk,
    input wire reset,
    input wire start,
    input wire [31:0] data_in,
    output wire [31:0] data_out,
    input wire MISO,
    output wire MOSI,
    output wire SCLK,
    output wire CS
);

    // Signals for connecting the Master and Slave
    wire [31:0] data_from_master;
    wire [31:0] data_to_master;

    // Instantiate the SPI Master module
    SPI_Master_32bit master (
        .clk(clk),
        .reset(reset),
        .start(start),
        .data_in(data_in),
        .data_out(data_from_master),
        .MISO(MISO),
        .MOSI(MOSI),
        .SCLK(SCLK),
        .CS(CS),
        .shifter_send(),
        .shifter_recv()
    );

    // Instantiate the SPI Slave module
    SPI_Slave_32bit slave (
        .clk(clk),
        .reset(reset),
        .SCLK(SCLK),
        .CS(CS),
        .MOSI(MOSI),
        .MISO(MISO),
        .data_out(data_out),
        .data_in(data_to_master),
        .shifter_recv(),
        .shifter_send()
    );

    // Connecting the Master data_out to the Slave data_in
    assign data_to_master = data_from_master;

endmodule
