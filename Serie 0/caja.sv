`timescale 1ns / 1ps

module UnionFSM(
    input  logic clk,
    input  logic reset,
    input  logic [1:0] R,   // Revoluciones de entrada
    input  logic       A,   // Apagado/Encendido
    output logic [1:0] M,   // Tipo de cambio
    output logic       AC   // Carro encendido
);

    // Logica de como se conecta la moore y la mealy
    logic [1:0] C;  


    // Instancia de mi maquina de la moore

    FSM_Moore_Rev moore (
        .clk(clk),
        .reset(reset),
        .R(R),      // entrada de revoluciones
        .A(A),      // encendido/apagado
        .C(C)       // salida:mi cantidad de revoluciones
    );

 // Instancia la mealy
 
    FSM_Mealy_Cambio mealy (
        .clk(clk),
        .reset(reset),
        .C(C),      // entrada: cantidad de revoluciones
        .A(A),      // entrada: encendido/apagado
        .M(M),      // salida: tipo de cambio o modo
        .AC(AC)     // salida: carro encendido
    );

endmodule


