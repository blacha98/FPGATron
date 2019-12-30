module Tron(
	input clk,
	//do klawiatury
	input keyboardData, keyboardCLK, 
	//end
	output wire [9:0] xCount, yCount,
	output reg displayArea,
	output VGA_hSync, VGA_vSync,
	output wire [3:0] Red, Green, Blue
	);
	
	//rzeczy do monitora
	reg p_hSync, p_vSync;
	wire VGA_clk;
	
	integer porchHF = 640;
	integer syncH = 656;
	integer porchHB = 752;
	integer maxH = 800;
	
	integer porchVF = 480;
	integer syncV = 490;
	integer porchVB = 492;
	integer maxV = 525;
	
	//dzielenie clock na 2 do monitora
	always@(posedge clk)
	begin
		VGA_clk=~VGA_clk;
	end
	
	//wyświetlani powierzchni i synchro
	always@ (posedge VGA_clk)
	begin
		displayArea <= ((xCount < porchHF) && (yCount < porchVF));
	end
	
	always@ (posedge VGA_clk)
	begin
		p_hSync <= ((xCount >= syncH) && (xCount < porchHB));
		p_vSync <= ((yCount >= syncV) && (yCount < porchVB));
	end
	
	//przechodzenie do nowej lini	
	always@ (posedge VGA_clk)
	begin
		if(xCount == maxH)
			xCount <= 0;
		else
			xCount <= xCount + 1'b1;
	end
	
	always@ (posedge VGA_clk)
	begin
		if(xCount == maxH)
		begin
			if(yCount == maxV)
				yCount <= 0;
			else
				yCount <= yCount + 1'b1;
		end
	end	
	
	//kwadrat
	always@ (posedge VGA_clk)
	begin
		if(xCount>100 && xCount < 200)
			begin
				if(yCount > 100 && yCount < 200)
					Blue[3] = 1;
			end
		else
			Blue[3] = 0;
	end
		
		
	assign VGA_vSync = ~p_vSync;
	assign VGA_hSync = ~p_hSync;	
	
	
endmodule


	
	