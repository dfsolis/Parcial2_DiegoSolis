`timescale 100ns / 1ps

module add(
    input  logic a, b, cin,
    output logic s, cout
);
    logic p, g; 
    
    assign p = a ^ b;
    assign g = a & b;
    
    assign s = cin ^ p;
    assign cout = g | (cin & p);
endmodule
