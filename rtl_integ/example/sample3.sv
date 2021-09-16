module sample3 #(
  parameter bit [3:0] param1 = 4'd5,
  parameter           param2 = 32
)
(
  output logic        sigo1,
  output              sigo2,
  output logic [3:0]  sigo3,
  output       [4:0]  sigo4,
  output logic        sigo5 [0:param1],
  output              sigo6 [0:param1],
  output logic [3:0]  sigo7 [0:param1],
  output       [4:0]  sigo8 [0:param1],

  input  logic        sigi1,
  input               sigi2,
  input  logic [3:0]  sigi3,
  input        [4:0]  sigi4,
  input  logic        sigi5 [0:param1],
  input               sigi6 [0:param1],
  input  logic [3:0]  sigi7 [0:param1],
  input        [4:0]  sigi8 [0:param1],
 
  input               clk,
  input               rstn 
);

endmodule


