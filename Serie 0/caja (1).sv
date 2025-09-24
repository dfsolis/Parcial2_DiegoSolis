`timescale 1ns / 1ps

module UnionFSM(
    input  logic clk,
    input  logic reset,
    input  logic [1:0] R,   // Revoluciones de entrada
    input  logic       A,   // Apagado/Encendido
    output logic [1:0] M,   // Tipo de cambio / modo
    output logic       AC,  // Carro encendido
    output string      modo_str 
);

    
    logic [1:0] C;

    //  Moore (revoluciones)
    FSM_Moore_Rev moore (
        .clk(clk),
        .reset(reset),
        .R(R),
        .A(A),
        .C(C)
    );

    //  Mealy Cambio de modo
    FSM_Mealy_Cambio mealy (
        .clk(clk),
        .reset(reset),
        .C(C),
        .A(A),
        .M(M),
        .AC(AC),
        .modo_str(modo_str)   
    );

endmodule




