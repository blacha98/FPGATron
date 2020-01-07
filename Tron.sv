module Tron(
	input start,
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
	
	wire [4:0] direction1, direction2;
	reg [6:0] size = 90;
	reg [9:0] snakeX1[0:127];
	reg [8:0] snakeY1[0:127];
	reg [9:0] snakeHeadX1;
	reg [9:0] snakeHeadY1;
	reg [9:0] snakeX2[0:127];
	reg [8:0] snakeY2[0:127];
	reg [9:0] snakeHeadX2;
	reg [9:0] snakeHeadY2;	
	reg snakeHead1;
	reg snakeBody1;
	reg snakeHead2;
	reg snakeBody2;
	reg endGame;
	reg border;
	reg found;
	wire update, reset;
	integer count1, count2, count3;
	
	clk_reduce reduce1(clk, VGA_clk);
	VGA_gen gen1(VGA_clk, xCount, yCount, displayArea, VGA_hSync, VGA_vSync);
	kbInput kbIn(keyboardCLK, keyboardData, direction1, direction2);
	updateClk UPDATE(clk, update);
	
	

	
	always @(posedge VGA_clk)
	begin
		border <= (((xCount >= 0) && (xCount < 20) || (xCount >= 630) && (xCount < 641)) || ((yCount >= 0) && (yCount < 11) || (yCount >= 470) && (yCount < 481))) || (((xCount >= 160 && xCount < 170) || (xCount >= 480 && xCount < 490)) && ((yCount >= 160 && yCount < 230) || (yCount >= 250 && yCount < 320))) || ((xCount >= 160 && xCount < 480) && ((yCount >= 160 && yCount < 170) || (yCount >= 310 && yCount < 320)));
	end
	
	always@(posedge update)
	begin
		if(start)
		begin
			for(count1 = 127; count1 > 0; count1 = count1 - 1)
				begin
					if(count1 <= size - 1)
					begin
						snakeX1[count1] = snakeX1[count1 - 1];
						snakeY1[count1] = snakeY1[count1 - 1];
					end
				end
			case(direction1)
				5'b00010: snakeY1[0] <= (snakeY1[0] - 10);
				5'b00100: snakeX1[0] <= (snakeX1[0] - 10);
				5'b01000: snakeY1[0] <= (snakeY1[0] + 10);
				5'b10000: snakeX1[0] <= (snakeX1[0] + 10);
			endcase	
		end
		else if(~start)
		begin
			for(count3 = 1; count3 < size; count3 = count3+1)
				begin
					snakeX1[count3] = 100;
					snakeY1[count3] = 100;
				end
			snakeX1[0] = 110;
			snakeY1[0] = 100;
		end
	
	end
	
	
	always@(posedge VGA_clk)
	begin
		found = 0;
		
		for(count2 = 1; count2 < size; count2 = count2 + 1)
		begin
			if(~found)
			begin				
				snakeBody1 = ((xCount > snakeX1[count2] && xCount < snakeX1[count2]+10) && (yCount > snakeY1[count2] && yCount < snakeY1[count2]+10));
				found = snakeBody1;
			end
		end
	end
	
	always@(posedge VGA_clk)
	begin	
		snakeHead1 = (xCount > snakeX1[0] && xCount < (snakeX1[0]+10)) && (yCount > snakeY1[0] && yCount < (snakeY1[0]+10));
	end
	
	//snake2
	always@(posedge update)
	begin
		if(start)
		begin
			for(count1 = 127; count1 > 0; count1 = count1 - 1)
				begin
					if(count1 <= size - 1)
					begin
						snakeX2[count1] = snakeX2[count1 - 1];
						snakeY2[count1] = snakeY2[count1 - 1];
					end
				end
			case(direction2)
				5'b00010: snakeY2[0] <= (snakeY2[0] - 10);
				5'b00100: snakeX2[0] <= (snakeX2[0] - 10);
				5'b01000: snakeY2[0] <= (snakeY2[0] + 10);
				5'b10000: snakeX2[0] <= (snakeX2[0] + 10);
			endcase	
		end
		else if(~start)
		begin
			for(count3 = 0; count3 < size; count3 = count3+1)
				begin
					snakeX2[count3] = 400;
					snakeY2[count3] = 400;
				end
			snakeX2[0] = 410;
			snakeY2[0] = 400;
		end
	
	end
	
	always@(posedge VGA_clk)
	begin
		found = 0;
		
		for(count2 = 1; count2 < size; count2 = count2 + 1)
		begin
			if(~found)
			begin				
				snakeBody2 = ((xCount > snakeX2[count2] && xCount < snakeX2[count2]+10) && (yCount > snakeY2[count2] && yCount < snakeY2[count2]+10));
				found = snakeBody2;
			end
		end
	end
	
	always@(posedge VGA_clk)
	begin	
		snakeHead2 = (xCount > snakeX2[0] && xCount < (snakeX2[0]+10)) && (yCount > snakeY2[0] && yCount < (snakeY2[0]+10));
	end
	//end snake2
	
	always@ (posedge VGA_clk)
	begin
		if(start)
		begin
			if(snakeHead1 && (border || snakeBody1 || snakeBody2))
			begin
				endGame = 1;
			end
			else if(snakeHead2 && (border || snakeBody1 || snakeBody2))
			begin
				endGame = 1;
			end
		end
		else if (~start)
		begin
			endGame = 0;
		end
	end

	
	assign R = (displayArea && (snakeHead2 || endGame));
	assign G = (displayArea && snakeHead1 && ~endGame);
	assign B = (displayArea && (border || snakeBody1 || snakeBody2) && ~endGame);
	always@(posedge VGA_clk)
	begin
		Red = {3{R}};
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

module kbInput(keyboardCLK, keyboardData, direction1, direction2);

	input keyboardCLK, keyboardData;
	output reg [4:0] direction1, direction2;
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
			direction1 <= 5'b00010;
			direction2 <= direction2;
		end
		else if(code == 8'h1C)
		begin
			direction1 <= 5'b00100;
			direction2 <= direction2;
		end
		else if(code == 8'h1B)
		begin
			direction1 <= 5'b01000;
			direction2 <= direction2;
		end
		else if(code == 8'h23)
		begin
			direction1 <= 5'b10000;
			direction2 <= direction2;
		end
		else if(code == 8'h43)
		begin
			direction2 <= 5'b00010;
			direction1 <= direction1;
		end
		else if(code == 8'h3B)
		begin
			direction2 <= 5'b00100;
			direction1 <= direction1;
		end
		else if(code == 8'h42)
		begin
			direction2 <= 5'b01000;
			direction1 <= direction1;
		end
		else if(code == 8'h4B)
		begin
			direction2 <= 5'b10000;
			direction1 <= direction1;
		end
		else 
		begin
			direction2 <= direction2;
			direction1 <= direction1;
		end
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
