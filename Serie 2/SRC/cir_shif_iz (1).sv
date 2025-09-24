`timescale 100ns / 1ps

module cir_shif_iz(
    input  logic [5:0] a,
    output logic [5:0] y,
    output logic       carr
);
   
    assign carr = a[5];


    assign y = {a[4:0], 1'b0};
endmodule
