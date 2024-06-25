`timescale 10ns / 1ps

module simpleCNN (
	CLK,
	nRST,
	START,
	X,
	Y,
	IMGIN,
	
	DONE,
	OUT,
    cur_state,
    next_state
);

	input			CLK;
	input			nRST;
	input			START;
	input	[4:0]	X;
	input	[4:0]	Y;
	input	[199:0]	IMGIN;
	
	output			DONE;
	output	[3:0]	OUT;
	output [2:0] cur_state;
    output [2:0] next_state;

	reg DONE;
	reg [3:0] OUT;

	reg [3:0] max_idx;
	reg [9:0] index;
	integer conv_output;
	integer fc_out [9:0];
	reg [2:0] row;
	reg [2:0] col;
	reg [3:0] i;

    reg [2:0] cur_state;
    reg [2:0] next_state;

    `include "kernel.vh"

	always @ (posedge CLK) begin
		if (nRST) begin
            cur_state <= next_state;
		end
		else begin
            cur_state <= 3'b000;
		end
	end

    // DONE, OUT
    always @(cur_state or max_idx) begin
        case(cur_state)
        3'b000: begin
            DONE = 1'b0;
            OUT = 3'd0;
        end
        3'b100: begin
            OUT = max_idx;
            DONE = 1'b1;
        end
        3'b101: begin
            DONE = 1'b0;
            OUT = 0;
        end
        endcase
    end

    // inference - hidden layer
    always @(cur_state or index or IMGIN) begin
        case(cur_state)
        3'b000: begin
            conv_output = 0;
            for(i=0;i<10;i=i+1)
                fc_out[i] = 0;
        end
        3'b010: begin
            // convolution
            conv_output = 0;
            for(row=0;row<5;row=row+1)begin
            for(col=0;col<5;col=col+1)begin
                conv_output = conv_output + $signed(IMGIN[199-40*row-8*col-:8]) * $signed(conv_kernel(row,col));
            end
            end
            
            // relu
            if(conv_output < 0)
                conv_output = 0;

            // fc
           for(i=0;i<10;i=i+1)
               fc_out[i] = fc_out[i] + conv_output * fc_kernel(i[3:0],index);
        end
        endcase
    end

    always @(cur_state) begin
        case(cur_state)
        3'b011: begin
            max_idx = 0;
            for(i=1;i<10;i=i+1)begin
                if (fc_out[max_idx] < fc_out[i])
                    max_idx = i;
            end
        end
        endcase
    end

    // state transition
    always @(cur_state or START or X or Y) begin
        case(cur_state)
        3'b000: begin // reset
            if (START) next_state = 3'b001;
            else next_state = 3'b000;
        end
        3'b001: begin
            if (START)
                next_state = 3'b001;
            else
                next_state = 3'b010;
        end
        3'b010: begin // inference
            index = Y*24+X;
            if (index == 575) begin
                next_state = 3'b011;
            end
            else next_state = 3'b010;
        end
        3'b011: begin // maxidx
            next_state = 3'b100;
        end
        3'b100: begin // out
            next_state = 3'b101;
        end
        3'b101: begin
            next_state = 3'b101;
        end
//        default: next_state = 3'b000;
        endcase
    end
endmodule
