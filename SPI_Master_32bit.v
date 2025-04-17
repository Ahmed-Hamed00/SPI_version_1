
module SPI_Master_32bit(
    input wire start,
    input wire reset,
    input wire clk,
    input wire [31:0] data_in,
    output reg [31:0] data_out,
    input wire MISO,
    output reg MOSI,
    output reg SCLK,
    output reg CS,
    output reg [31:0] shifter_send,
    output reg [31:0] shifter_recv
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

    // ====== New Signal ======
    reg SCLK_EN;  // to control SCLK
	// Clock Divider controlled by SCLK_EN
    always @(posedge clk or posedge reset) begin
        if (reset)
            SCLK <= 0;
        else if (SCLK_EN)
            SCLK <= ~SCLK;
        else
            SCLK <= 0;
    end


    reg [5:0] bit_cnt;            // Counts 0 to 63 (32 bits * 2 edges)
    reg [1:0] state;
    parameter IDLE = 2'b00, TRANSFER = 2'b01, DONE = 2'b10;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            CS <= 1;
            SCLK_EN <= 0;
            MOSI <= 0;
            bit_cnt <= 0;
            shifter_send <= 0;
            shifter_recv <= 0;
            data_out <= 0;
            state <= IDLE;
        end 
        else begin
            case (state)
                IDLE: begin
                	if (bit_cnt < 32)begin
	                    MOSI <= 0;
                        SCLK_EN <= 0;
	                    if (start) begin
	                        CS <= 0;
                            SCLK_EN <= 1;
	                        bit_cnt <= 0;
	                        shifter_send <= data_in;
	                        shifter_recv <= 0;
	                        state <= TRANSFER;
	                    end
                    end
                end

                TRANSFER: begin
                	if (bit_cnt < 32)begin
	                    if (SCLK_falling) begin
                            MOSI <= shifter_send[31];
                        end
                        if (SCLK_rising) begin
                            shifter_recv <= {shifter_recv[30:0], MISO};        
                            shifter_send <= {shifter_send[30:0], 1'b0};      
                            bit_cnt <= bit_cnt + 1;

                            if (bit_cnt == 31) begin
                            state <= DONE;
                            SCLK_EN <= 0; // close SCLK
                            end
	                    end
                    end
                end

                DONE: begin
                    CS <= 1;
                    SCLK_EN <= 0;
                    MOSI <= 0;
                    data_out <= shifter_recv;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
