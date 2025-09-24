`timescale 100ns / 1ps

module shif_der(
    input  logic [5:0] a,
    output logic [5:0] y,
    output logic       carr
);
   
    assign carr = a[0];

    
    assign y[5] = a[0];  
    assign y[0] = a[1];
    assign y[1] = a[2];
    assign y[2] = a[3];
    assign y[3] = a[4];
    assign y[4] = a[5];
endmodule



