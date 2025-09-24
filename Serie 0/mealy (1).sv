`timescale 1ns / 1ps

module FSM_Mealy_Cambio(
    input  logic       clk, reset,
    input  logic [1:0] C,     // Cantidad de revoluciones (desde la Moore)
    input  logic       A,     // Apagado/Encendido
    output logic [1:0] M,     // Tipo de cambio / modo
    output logic       AC,    // Carro encendido
    output string      modo_str // para simular bonito
);

    typedef enum logic [1:0] {
        S00 = 2'b00,   // neutro
        S01 = 2'b01,   // eco
        S10 = 2'b10,   // normal
        S11 = 2'b11    // sport
    } state_t;

    state_t state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= S00;
        else
            state <= next_state;
    end

    // Transiciones
    always_comb begin
        if (!A)
            next_state = S00;
        else begin
            unique case (C)
                2'b00: next_state = S00;
                2'b01: next_state = S01;
                2'b10: next_state = S10;
                2'b11: next_state = S11;
                default: next_state = S00;
            endcase
        end
    end

    // Salidas Mealy
    always_comb begin
        AC = A;
        unique case (next_state)
            S00: M = 2'b00;
            S01: M = 2'b01;
            S10: M = 2'b10;
            S11: M = 2'b11;
            default: M = 2'b00;
        endcase
    end

    // 🔎 Salida extra en texto para debug
    always_comb begin
        case (M)
            2'b00: modo_str = "NEUTRO";
            2'b01: modo_str = "ECO";
            2'b10: modo_str = "NORMAL";
            2'b11: modo_str = "SPORT";
            default: modo_str = "----";
        endcase
    end

endmodule


