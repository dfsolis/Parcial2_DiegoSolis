`timescale 1ns / 1ps

module FSM_Moore_Rev(
    input  logic clk, reset,
    input  logic [1:0] R,   // Revoluciones de entrada
    input  logic       A,   // Apagado/Encendido
    output logic [1:0] C    // Cantidad de revoluciones
);

  
    typedef enum logic [1:0] {
        S0 = 2'b00,   // Apagado
        S1 = 2'b01,   // Primer rango
        S2 = 2'b10,   // Segundo rango
        S3 = 2'b11    // Tercer rango
    } state_t;

    state_t state, next_state;

    // Registro de estado
    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    // Transiciones corregidas
    always_comb begin
        if (!A) begin
            next_state = S0;         // Carro apagado
        end else begin
            case (R)
                2'b00: next_state = S0;
                2'b01: next_state = S1;
                2'b10: next_state = S2;
                2'b11: next_state = S3;
                default: next_state = S0;
            endcase
        end
    end

    // Salidas Moore
    always_comb begin
        case (state)
            S0: C = 2'b00;
            S1: C = 2'b01;
            S2: C = 2'b10;
            S3: C = 2'b11;
            default: C = 2'b00;
        endcase
    end

endmodule

