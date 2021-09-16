module tb_sample1;

logic  sigo1;
logic  sigo2;
logic  [3:0] sigo3;
logic  [4:0] sigo4;
logic  sigo5 [0:3] ;
logic  sigo6 [0:3] ;
logic  [3:0] sigo7 [0:3] ;
logic  [4:0] sigo8 [0:3] ;
logic  sigi1;
logic  sigi2;
logic  [3:0] sigi3;
logic  [4:0] sigi4;
logic  sigi5 [0:3] ;
logic  sigi6 [0:3] ;
logic  [3:0] sigi7 [0:3] ;
logic  [4:0] sigi8 [0:3] ;
logic  clk;
logic  rstn;


sample1 u_sample1 ( 
  .sigo1(sigo1), .sigo2(sigo2), .sigo3(sigo3), .sigo4(sigo4), .sigo5(sigo5), 
  .sigo6(sigo6), .sigo7(sigo7), .sigo8(sigo8), .sigi1(sigi1), .sigi2(sigi2), 
  .sigi3(sigi3), .sigi4(sigi4), .sigi5(sigi5), .sigi6(sigi6), .sigi7(sigi7), 
  .sigi8(sigi8), .clk(clk), .rstn(rstn));


initial
begin
  	clk1 = '0;
	clk2 = '0;
	clk3 = '0;

  	rst1 = 1'b0;
	rst1 = #100 1'b1;
	rst2 = 1'b0;
	rst2 = #100 1'b1;

  fork
    
		begin
			forever
				clk1 = #5 ~clk1;
			end

		begin
			forever
				clk2 = #5 ~clk2;
			end

		begin
			forever
				clk3 = #5 ~clk3;
			end

    begin : timeout
      $display ("Starting simulation");
      #10000000;
      $display ("Timeout period elapsed. Ending test");
      $finish;
    end
  join
end


initial
begin
  sigi1 = '0;
  sigi2 = '0;
  sigi3 = '0;
  sigi4 = '0;
  sigi5 = '0;
  sigi6 = '0;
  sigi7 = '0;
  sigi8 = '0;
  clk = '0;
  rstn = '0;
#100;
end
endmodule