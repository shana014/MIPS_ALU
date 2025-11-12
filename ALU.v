
module ALU (
	input [31:0] a, b,
	input [3:0] ctrl,
	output reg[31:0] out,
	output reg zero, overflow
);

/* 0000	AND
   0001	OR
   0010	ADD
   0110	SUB
   0111	SLT
   1100	NOR */

genvar i;

wire [31:0] and_result; // a & b
generate 
  for (i = 0; i < 32; i = i + 1) begin
    assign and_result[i] = ((a[i] == 1'b1) && (b[i] == 1'b1)) ? 1'b1 : 1'b0;
  end
endgenerate

wire [31:0] or_result; // a | b
generate
  for (i = 0; i < 32; i = i + 1) begin
    assign or_result[i] = ((a[i] == 1'b1) || (b[i] == 1'b1)) ? 1'b1 : 1'b0;
  end
endgenerate

wire [32:0] add_carry;
wire [31:0] add_result; // a + b
wire overflow_add;
generate 
  assign add_carry[0] = 1'b0;
  for (i = 0; i < 32; i = i + 1) begin
    assign add_result[i] = a[i] ^ b[i] ^ add_carry[i];
    assign add_carry[i+1] = (a[i] & b[i]) | (a[i] & add_carry[i]) | (b[i] & add_carry[i]);
  end
endgenerate
assign overflow_add = (add_carry[31] ^ add_carry[32]);
wire [32:0] sub_carry;
wire [31:0] sub_result; // a - b
wire overflow_sub;
generate 
  assign sub_carry[0] = 1'b1; // initial +1
  for (i = 0; i < 32; i = i + 1) begin
    assign sub_result[i] = a[i] ^ ~(b[i]) ^ sub_carry[i];
    assign sub_carry[i+1] = (a[i] & ~(b[i])) | (a[i] & sub_carry[i]) | (~(b[i]) & sub_carry[i]);
  end
endgenerate
assign overflow_sub = (sub_carry[31] ^ sub_carry[32]);

wire [31:0] slt_result; // a < b ?
assign slt_result = {31'b0, (overflow_sub ^ sub_result[31])};

wire [31:0] nor_result; // ~a && ~b
generate 
  for (i = 0; i < 32; i = i + 1) begin
    assign nor_result[i] = ~(or_result[i]);
  end
endgenerate

always @* begin
  overflow = 0;
  case (ctrl)
    4'b0000: out = and_result;
    4'b0001: out = or_result;
    4'b0010: begin
	     	out = add_result;
		overflow = overflow_add;
	     end
    4'b0110: begin
	     	out = sub_result;
		overflow = overflow_sub;
	     end
    4'b0111: out = slt_result;
    4'b1100: out = nor_result;
    default: begin
		out = 32'b0;
	     end
  endcase 
  zero = (out == 0);
end


endmodule

