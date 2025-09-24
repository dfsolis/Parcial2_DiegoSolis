`timescale 1ns / 1ps

module cir_alu(
    input  logic [5:0] a, b,
    input  logic [3:0] menu,         // 0000=sum, 0001=sub, 0010=AND, 0011=OR, 1000=SHL, 0100=SHR
    output logic [5:0] Resultado,
    output logic       carry_out,    // carry de suma o resta
    output logic       overflow,     // el over que viene del add
    output logic       cero,
    output logic       negativo
);

   
    logic [5:0] add_out, and_out, or_out, shl_out, shr_out;
    logic       cout_add, ovf_add, neg_add, zero_add;
    logic [5:0] b_mux;

   
    always_comb begin
        if (menu == 4'b0001)  // resta
            b_mux = ~b;
        else
            b_mux = b;
    end

    // Suma y resta
    Circ_add u_add (
        .a(a),
        .b(b_mux),
        .res(menu[0]),       // 0 suma, 1 resta
        .s(add_out),
        .cout(cout_add),
        .overflow(ovf_add),  // overflow correcto que viene del Circ_add
        .cero(zero_add),
        .negativo(neg_add)
    );

    //  AND 
    Circ_and u_and (
        .a(a),
        .b(b),
        .y(and_out)
    );

    // OR
    Circ_or u_or (
        .a(a),
        .b(b),
        .y(or_out)
    );

    // SHL 
    cir_shif_iz u_shl (
        .a(a),
        .y(shl_out),
        .carr()             
    );

    //SHR
    shif_der u_shr (
        .a(a),
        .y(shr_out),
        .carr()             
    );

    // Menu de operaciones
    always_comb begin
        Resultado = 6'b0;
        carry_out = 1'b0;
        overflow  = 1'b0;
        cero      = 1'b0;
        negativo  = 1'b0;

        case (menu)
            4'b0000: begin // SUMA
                Resultado = add_out;
                carry_out = cout_add;
                overflow  = ovf_add;
                cero      = zero_add;
                negativo  = neg_add;
            end
            4'b0001: begin // RESTA
                Resultado = add_out;
                carry_out = cout_add;
                overflow  = ovf_add;
                cero      = zero_add;
                negativo  = neg_add;
            end
            4'b0010: begin // AND
                Resultado = and_out;
                cero      = (and_out == 6'b0);
                negativo  = and_out[5];
            end
            4'b0011: begin // OR
                Resultado = or_out;   
                cero      = (or_out == 6'b0);
                negativo  = or_out[5];
            end
            4'b1000: begin // SHIFT IZQ
                Resultado = shl_out;
                // carry_out=0; overflow=0;
                cero      = (shl_out == 6'b0);
                negativo  = shl_out[5];
            end
            4'b0100: begin // SHIFT DER
                Resultado = shr_out;
                
                cero      = (shr_out == 6'b0);
                negativo  = shr_out[5];
            end
            default: begin
                Resultado = 6'b0;
            end
        endcase
    end

endmodule


