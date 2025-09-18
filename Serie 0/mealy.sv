`timescale 1ns / 1ps

module FSM_Mealy_Cambio(
    input  logic clk, reset,
    input  logic [1:0] C,   // Cantidad de revoluciones
    input  logic       A,   // Apagado/Encendido
    output logic [1:0] M,   // Tipo de cambio o modo
    output logic       AC   // Carro encendido
);

    // mis estados
    typedef enum logic {S0, S1} state_t;
    state_t state, next_state;

    // Registro de estados
    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    // Transiciones de los estados
    always_comb begin
        next_state = state;
        case (state)
            S0: if (A) next_state = S1;
                else next_state = S0;

            S1: if (!A) next_state = S0;
                else next_state = S1;

            default: next_state = S0;
        endcase
    end

    // Salidas Mealy
    always_comb begin
        M  = 2'b00;
        AC = 1'b0;
        case (state)
            S0: begin
                if (A && C == 2'b01) begin
                    M  = 2'b01;  // Primera marcha o modo eco
                    AC = 1'b1;
                end
                else if (A && C == 2'b10) begin
                    M  = 2'b10;  // Segunda marcha o normal
                    AC = 1'b1;
                end
                else if (A && C == 2'b11) begin
                    M  = 2'b11;  // Tercera marcha o sport
                    AC = 1'b1;
                end
            end
            S1: begin
                if (!A) begin
                    M  = 2'b00;  // neutro
                    AC = 1'b0;   // Carro apagado
                end
            end
        endcase
    end

endmodule
