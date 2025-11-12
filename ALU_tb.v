module ALU_tb (); 

// internal signals 
reg signed[31:0] opa, opb; 
reg [3:0] op; wire signed[31:0] result; 
wire z, of; 

// Instantiate the DUT 
ALU DUT (.out(result), .a(opa), .b(opb), .ctrl(op), .zero(z), .overflow(of)); 

// inputs stimulate
integer i; 
reg signed[31:0] expected_result; 
reg calc_of, calc_z; 
initial begin $display("=== Starting ALU Testbench ==="); 

// Create 10 random sets of opa and opb an test them on all 6 operations
for (i = 0; i < 10; i = i + 1) begin 
  $display("********** Test %0d **********", i); 
  opa = $random; 
  opb = $random; 

  // AND 
  op = 4'b0000; 
  expected_result = (opa & opb); 
  calc_z = (expected_result == 0); 
  #10; $display("AND: ctrl=%b | opa=%b | opb=%b | result=%b | zero_flag=%b", op, opa, opb, result, z); 
  if (result !== expected_result) $error("The result should be %b", expected_result); 
  if (z !== calc_z) $error("Zero flag incorrect. Expected %b", calc_z); 

  // OR 
  op = 4'b0001; 
  expected_result = (opa | opb); 
  calc_z = (expected_result == 0); 
  #10; 
  $display("OR: ctrl=%b | opa=%b | opb=%b | result=%b | zero_flag=%b",op, opa, opb, result, z); 
  if (result !== expected_result) $error("The result should be %b", expected_result); 
  if (z !== calc_z) $error("Zero flag incorrect. Expected %b", calc_z); 

  // ADD 
  op = 4'b0010; 
  expected_result = (opa + opb); 
  calc_of = ((opa > 0 && opb > 0 && expected_result < 0) || (opa < 0 && opb < 0 && expected_result > 0)) ? 1 : 0; 
  calc_z = (expected_result == 0); 
  #10; 
  $display("ADD: ctrl=%b | opa=%0d | opb=%0d | result=%0d | overflow=%b | zero_flag=%b", op, opa, opb, result, of, z); 
  if (result !== expected_result) $error("The result should be %0d", expected_result); 
  if (of !== calc_of) $error("The overflow should be %b", calc_of); 
  if (z !== calc_z) $error("Zero flag incorrect. Expected %b", calc_z); 

  // SUB 
  op = 4'b0110; 
  expected_result = (opa - opb); 
  calc_of = ((opa[31] != opb[31]) && ((expected_result[31] != opa[31]))) ? 1 : 0; 
  calc_z = (expected_result == 0); 
  #10; 
  $display("SUB: ctrl=%b | opa=%0d | opb=%0d | result=%0d | overflow=%b | zero_flag=%b",op, opa, opb, result, of, z); 
  if (result !== expected_result) $error("The result should be %0d", expected_result); 
  if (of !== calc_of) $error("The overflow should be %b", calc_of); 
  if (z !== calc_z) $error("Zero flag incorrect. Expected %b", calc_z); 

  // SLT 
  op = 4'b0111; 
  expected_result = ($signed(opa) < $signed(opb)) ? 32'd1 : 32'd0; 
  calc_z = (expected_result == 0); 
  #10; 
  $display("SLT: ctrl=%b | opa=%0d | opb=%0d | result=%0d | zero_flag=%b",op, opa, opb, result, z); 
  if (result !== expected_result) $error("The result should be %0d", expected_result); 
  if (z !== calc_z) $error("Zero flag incorrect. Expected %b", calc_z); 

  // NOR 
  op = 4'b1100; 
  expected_result = (~(opa | opb)); calc_z = (expected_result == 0); 
  #10; 
  $display("NOR: ctrl=%b | opa=%b | opb=%b | result=%b | zero_flag=%b",op, opa, opb, result, z); 
  if (result !== expected_result) $error("The result should be %b", expected_result); 
  if (z !== calc_z) $error("Zero flag incorrect. Expected %b", calc_z); 
                  
end 
$display("\n=== Testing complete ==="); 
$finish; 

end 

endmodule
