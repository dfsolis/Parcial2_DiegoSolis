`timescale 100ns / 1ps

module Circ_or(
    input  logic [5:0] a, b,
    output logic [5:0] y
);
   
    assign y = a | b;
endmodule
