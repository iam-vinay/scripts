module #( 
  parameter param2 = 32,
  parameter param1 = 4
) top (
 input  logic  clk,
 input  logic  rstn,
 
// Auto generated ports 
 output  logic  sigo1,
 input  logic  sigi1,
 input  logic  [4:0] sigi8 [0:param1],
 input  logic  sigi2,
 output  logic  [3:0] sigo7 [0:param1],
 output  logic  [4:0] sigo8 [0:param1],
 output  logic  [3:0] sigo3,
 input  logic  [4:0] sigi4,
 output  logic  sigo6 [0:param1],
 input  logic  [3:0] sigi7 [0:param1],
 input  logic  sigi5 [0:param1],
 output  logic  sigo5 [0:param1],
 output  logic  sigo2,
 output  logic  [4:0] sigo4,
 input  logic  [3:0] sigi3,
 input  logic  sigi6 [0:param1]

);

logic  [4:0] sam2_to_sam1_4 ;
logic  [3:0] sam2_to_sam1_3 ;
logic  [4:0] sam1_to_sam2_4 ;
logic  sam2_to_sam1_2 ;
logic  sam1_to_sam2_2 ;
logic  [3:0] sam1_to_sam2_7 [0:3];
logic  sam2_to_sam1_6 [0:3];
logic  sam1_to_sam2_6 [0:3];
logic  sam2_to_sam1_5 [0:3];
logic  sam1_to_sam2_1 ;
logic  [3:0] sam2_to_sam1_7 [0:3];
logic  [4:0] sam1_to_sam2_8 [0:3];
logic  sam2_to_sam1_1 ;
logic  sam1_to_sam2_5 [0:3];
logic  [3:0] sam1_to_sam2_3 ;
logic  [4:0] sam2_to_sam1_8 [0:3];

sample3 #( 
  .param1(param1),
  .param2(param2)
) u_sample3 (
  .sigo4(sigo4),
  .sigo3(sigo3),
  .rstn(rstn),
  .sigi3(sigi3),
  .sigi7(sigi7),
  .sigi4(sigi4),
  .sigo6(sigo6),
  .sigi6(sigi6),
  .clk(clk),
  .sigi5(sigi5),
  .sigi8(sigi8),
  .sigo5(sigo5),
  .sigi1(sigi1),
  .sigo1(sigo1),
  .sigo7(sigo7),
  .sigi2(sigi2),
  .sigo2(sigo2),
  .sigo8(sigo8)
);

sample1 u_sample1 (
  .sigo8(sam1_to_sam2_8),
  .sigo2(sam1_to_sam2_2),
  .sigo7(sam1_to_sam2_7),
  .sigi2(sam2_to_sam1_2),
  .sigo5(sam1_to_sam2_5),
  .sigi8(sam2_to_sam1_8),
  .sigi1(sam2_to_sam1_1),
  .sigo1(sam1_to_sam2_1),
  .clk(clk),
  .sigi5(sam2_to_sam1_5),
  .sigi7(sam2_to_sam1_7),
  .sigi4(sam2_to_sam1_4),
  .sigo6(sam1_to_sam2_6),
  .sigi6(sam2_to_sam1_6),
  .rstn(rstn),
  .sigi3(sam2_to_sam1_3),
  .sigo4(sam1_to_sam2_4),
  .sigo3(sam1_to_sam2_3)
);

sample2 #( 
  .param2(param2),
  .param1(param1)
) u_sample2 (
  .sigi4(sam1_to_sam2_4),
  .sigo6(sam2_to_sam1_6),
  .sigi6(sam1_to_sam2_6),
  .sigi7(sam1_to_sam2_7),
  .sigi5(sam1_to_sam2_5),
  .clk(clk),
  .sigo3(sam2_to_sam1_3),
  .sigo4(sam2_to_sam1_4),
  .sigi3(sam1_to_sam2_3),
  .rstn(rstn),
  .sigo2(sam2_to_sam1_2),
  .sigo8(sam2_to_sam1_8),
  .sigo1(sam2_to_sam1_1),
  .sigi1(sam1_to_sam2_1),
  .sigi8(sam1_to_sam2_8),
  .sigo5(sam2_to_sam1_5),
  .sigi2(sam1_to_sam2_2),
  .sigo7(sam2_to_sam1_7)
);

endmodule
