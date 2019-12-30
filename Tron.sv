module Tron(
	input clk,
	//do klawiatury
	input keyboardData, keyboardCLK, 
	
	//do wyświetlacza
	output wire [9:0] xCount, yCount,
	output reg displayArea,
	output VGA_hSync, VGA_vSync,
	output wire [3:0] Red, Green, Blue
	);
	
	wire VGA_clk;
	wire R;
	wire G;
	wire B;
	
	wire [4:0] direction;
	reg [6:0] size = 40;
	reg [9:0] snakeX[0:127];
	reg [8:0] snakeY[0:127];
	reg [9:0] snakeHeadX;
	reg [9:0] snakeHeadY;
	integer start = 1;
	reg snakeHead;
	reg snakeBody;
	reg border;
	reg found;
	wire update, reset;
	integer count1, count2, count3;
	
	clk_reduce reduce1(clk, VGA_clk);
	VGA_gen gen1(VGA_clk, xCount, yCount, displayArea, VGA_hSync, VGA_vSync);
	kbInput kbIn(keyboardCLK, keyboardData, direction, reset);
	updateClk UPDATE(clk, update);
	
	
	always @(posedge VGA_clk)
	begin
		border <= (((xCount >= 0) && (xCount < 20) || (xCount >= 630) && (xCount < 641)) || ((yCount >= 0) && (yCount < 11) || (yCount >= 470) && (yCount < 481)));
	end
	
	always@(posedge update)
	begin
		if(start == 1)
		begin
			for(count1 = 127; count1 > 0; count1 = count1 - 1)
				begin
					if(count1 <= size - 1)
					begin
						snakeX[count1] = snakeX[count1 - 1];
						snakeY[count1] = snakeY[count1 - 1];
					end
				end
			case(direction)
				5'b00010: snakeY[0] <= (snakeY[0] - 10);
				5'b00100: snakeX[0] <= (snakeX[0] - 10);
				5'b01000: snakeY[0] <= (snakeY[0] + 10);
				5'b10000: snakeX[0] <= (snakeX[0] + 10);
			endcase	
		end
		else if(start == 0)
		begin
			for(count3 = 1; count3 < 128; count3 = count3+1)
				begin
					snakeX[count3] = 700;
					snakeY[count3] = 500;
				end
		end
	
	end
	
	always@(posedge VGA_clk)
	begin
		found = 0;
		
		for(count2 = 1; count2 < size; count2 = count2 + 1)
		begin
			if(~found)
			begin				
				snakeBody = ((xCount > snakeX[count2] && xCount < snakeX[count2]+10) && (yCount > snakeY[count2] && yCount < snakeY[count2]+10));
				found = snakeBody;
			end
		end
	end
	
	always@(posedge VGA_clk)
	begin	
		snakeHead = (xCount > snakeX[0] && xCount < (snakeX[0]+10)) && (yCount > snakeY[0] && yCount < (snakeY[0]+10));
	end
	
	assign G = (displayArea && snakeHead);
	assign B = (displayArea && (border || snakeBody));
	always@(posedge VGA_clk)
	begin
		Green = {3{G}};
		Blue = {3{B}};
	end
	
	
endmodule

module clk_reduce(clk, VGA_clk);

	input clk; //50MHz clock
	output reg VGA_clk; //25MHz clock
	always@(posedge clk)
	begin
		VGA_clk=~VGA_clk;
	end
	
endmodule

module VGA_gen(VGA_clk, xCount, yCount, displayArea, VGA_hSync, VGA_vSync);

	input VGA_clk;
	output reg [9:0]xCount, yCount; 
	output reg displayArea;  
	output VGA_hSync, VGA_vSync;

	reg p_hSync, p_vSync; 
	
	integer porchHF = 640; //start of horizntal front porch
	integer syncH = 655;//start of horizontal sync
	integer porchHB = 747; //start of horizontal back porch
	integer maxH = 793; //total length of line.

	integer porchVF = 480; //start of vertical front porch 
	integer syncV = 490; //start of vertical sync
	integer porchVB = 492; //start of vertical back porch
	integer maxV = 525; //total rows. 

	always@(posedge VGA_clk)
	begin
		if(xCount === maxH)
			xCount <= 0;
		else
			xCount <= xCount + 1;
	end
	// 93sync, 46 bp, 640 display, 15 fp
	// 2 sync, 33 bp, 480 display, 10 fp
	always@(posedge VGA_clk)
	begin
		if(xCount === maxH)
		begin
			if(yCount === maxV)
				yCount <= 0;
			else
			yCount <= yCount + 1;
		end
	end
	
	always@(posedge VGA_clk)
	begin
		displayArea <= ((xCount < porchHF) && (yCount < porchVF)); 
	end

	always@(posedge VGA_clk)
	begin
		p_hSync <= ((xCount >= syncH) && (xCount < porchHB)); 
		p_vSync <= ((yCount >= syncV) && (yCount < porchVB)); 
	end
 
	assign VGA_vSync = ~p_vSync; 
	assign VGA_hSync = ~p_hSync;
endmodule

module kbInput(keyboardCLK, keyboardData, direction, reset);

	input keyboardCLK, keyboardData;
	output reg [4:0] direction;
	output reg reset = 0; 
	reg [7:0] code;
	reg [10:0]keyCode;
	reg recordNext = 0;
	integer count = 0;

always@(negedge keyboardCLK)
	begin
		keyCode[count] = keyboardData;
		count = count + 1;			
		if(count == 11)
		begin
			code = keyCode[8:1];
			count = 0;
		end
	end
	
	always@(code)
	begin
		if(code == 8'h1D)
		begin
			direction <= 5'b00010;
			//direction2 <= direction2;
		end
		else if(code == 8'h1C)
		begin
			direction <= 5'b00100;
			//direction2 <= direction2;
		end
		else if(code == 8'h1B)
		begin
			direction <= 5'b01000;
			//direction2 <= direction2;
		end
		else if(code == 8'h23)
		begin
			direction <= 5'b10000;
			//direction2 <= direction2;
		end
		else direction <= direction;
	end	
endmodule

module updateClk(clk, update);
	input clk;
	output reg update;
	reg [21:0]count;	

	always@(posedge clk)
	begin
		count <= count + 1;
		if(count == 1777777)
		begin
			update <= ~update;
			count <= 0;
		end	
	end
endmodule




	
	