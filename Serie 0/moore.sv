`timescale 1ns / 1ps

module FSM_Moore_Rev(
    input  logic clk, reset,
    input  logic [1:0] R,   // Revoluciones de entrada
    input  logic       A,   // Apagado/Encendido
    output logic [1:0] C    // Cantidad de revoluciones
);

    // Estados
    typedef enum logic [1:0] {S0, S1, S2, S3} state_t;
    state_t state, next_state;

    // Registro de estados
    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    // Transiciones de estados
    always_comb begin
        next_state = state;
        case (state)
            S0: if (A && R == 2'b01) next_state = S1;
                else next_state = S0;

            S1: if (A && R == 2'b10) next_state = S2;
                else if (!A) next_state = S0;
                else next_state = S1;

            S2: if (A && R == 2'b11) next_state = S3;
                else if (!A) next_state = S0;
                else next_state = S2;

            S3: if (!A) next_state = S0;
                else next_state = S3;

            default: next_state = S0;
        endcase
    end

    // Salida Moore 
    always_comb begin
        case (state)
            S0: C = 2'b00;   // Apagado
            S1: C = 2'b01;   // Primer rango de revolución
            S2: C = 2'b10;   // Segundo rango de revolución
            S3: C = 2'b11;   // Tercer rango de revolución
            default: C = 2'b00;
        endcase
    end

endmodule 

