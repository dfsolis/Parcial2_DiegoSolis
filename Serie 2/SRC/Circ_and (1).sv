`timescale 100ns / 1ps

module Circ_and(
    input  logic [5:0] a, b,
    output logic [5:0] y
);
  
    assign y = a & b;
endmodule
