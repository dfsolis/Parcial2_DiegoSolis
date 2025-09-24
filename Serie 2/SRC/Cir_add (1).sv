`timescale 100ns / 1ps

module Circ_add(
    input logic [5:0] a, b,
    input logic cin,
    input  logic res,
    output logic [5:0] s,
    output logic cout,
    output logic overflow,
    output logic negativo,
    output logic cero
   
    );
    
    logic [5:0] c_internal;
    
    add add0(
        .a(a[0]),
        .b(b[0]),
        .cin(res),
        .s(s[0]),
        .cout(c_internal[0])
        );
    add add1(
        .a(a[1]),
        .b(b[1]),
        .cin(c_internal[0]),
        .s(s[1]),
        .cout(c_internal[1])
        );
        
    add add2(
        .a(a[2]),
        .b(b[2]),
        .cin(c_internal[1]),
        .s(s[2]),
        .cout(c_internal[2])
        );
        
    add add3(
        .a(a[3]),
        .b(b[3]),
        .cin(c_internal[2]),
        .s(s[3]),
        .cout(c_internal[3])
        );

    add add4(
        .a(a[4]),
        .b(b[4]),
        .cin(c_internal[3]),
        .s(s[4]),
        .cout(c_internal[4])
        );    

    add add5(
        .a(a[5]),
        .b(b[5]),
        .cin(c_internal[4]),
        .s(s[5]),
        .cout(cout)
        );  
        
    assign overflow = c_internal[4] ^ cout;
    assign negativo = s[5] & res;       // MSB AND res
    assign cero     = (s == 6'b000000); // bandera de cero
        
            
    
endmodule
