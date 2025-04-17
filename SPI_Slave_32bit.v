module SPI_Slave_32bit(
    input wire clk,
    input wire reset,
    input wire SCLK,
    input wire CS,
    input wire MOSI,
    output reg MISO,
    output reg [31:0] data_out,
    input wire [31:0] data_in,
    output reg [31:0] shifter_recv,
    output reg [31:0] shifter_send
);
    

    // Previous Value os SCLK
    // detect SCLK edge
    reg SCLK_prev;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            SCLK_prev <= 0;
        end 
        else begin
            SCLK_prev <= SCLK;
        end
    end
    wire SCLK_rising = (SCLK == 1 && SCLK_prev == 0);
    wire SCLK_falling = (SCLK == 0 && SCLK_prev == 1);

    
    reg [5:0] bit_cnt;
    reg [1:0] state;
    parameter IDLE = 2'b00, TRANSFER = 2'b01, DONE = 2'b10;

    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_cnt <= 0;
            shifter_recv <= 0;
            shifter_send <= 0;
            data_out <= 0;
            MISO <= 0;
            state <= IDLE;
        end 
        else begin
            case (state)
                IDLE: begin
                    if (!CS) begin // CS is active low
                        bit_cnt <= 0;
                        shifter_recv <= 0;
                        shifter_send <= data_in;
                        state <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if (!CS) begin
                        if (SCLK_falling) begin
                            // Prepare MISO on falling edge
                            MISO <= shifter_send[31];
                        end

                        if (SCLK_rising) begin
                            // Capture MOSI on rising edge
                            shifter_recv <= {shifter_recv[30:0], MOSI};
                            shifter_send <= {shifter_send[30:0], 1'b0};
                            bit_cnt <= bit_cnt + 1;

                            if (bit_cnt == 31)
                                state <= DONE;
                        end
                    end
                end

                DONE: begin
                    data_out <= shifter_recv;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
