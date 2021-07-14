`timescale 1ns / 1ps                                   
module market19(                          
input button_1,	//moves right & 1 = KEY0
input button_2,	//moves down & 2 = KEY1
input button_3,	//selects & 3	= KEY2
input button_4,	//moves left % 4 = KEY3
input clk50,
input sw1,
input sw2,
output reg clk25=0,
output reg vgaR,vgaR1,vgaR2,vgaG,vgaG1,vgaG2,vgaB,vgaB1, //8 bit RGB VGA outputs
output reg hsync, // synchronization for VGA
output reg vsync
);


reg e1,e2,e3,e4;
reg t1,t2,t3,t4,t5;    					////TOTAL word seven segment
reg da1,da2,da3,da4,da5,da6,da7;    /// MSB (d4) of total account 
reg db1,db2,db3,db4,db5,db6,db7; 
reg dc1,dc2,dc3,dc4,dc5,dc6,dc7; 
reg dd1,dd2,dd3,dd4,dd5,dd6,dd7; 
reg de1,de2,de3,de4,de5,de6,de7;    /// LSB (d0) of total account

// quantity seven segment lines at the shopping list 
reg sa1,sa2,sa3,sa4,sa5,sa6,sa7; 
reg sb1,sb2,sb3,sb4,sb5,sb6,sb7;
reg sc1,sc2,sc3,sc4,sc5,sc6,sc7;
reg sd1,sd2,sd3,sd4,sd5,sd6,sd7;
reg se1,se2,se3,se4,se5,se6,se7;
reg sf1,sf2,sf3,sf4,sf5,sf6,sf7;

reg line; // line above the total 
reg nokta;// point at total 

reg [3:0] d4,d3,d2,d1,d0;
reg [1:0] originx,originy,coord_x,coord_y;
reg [9:0] counterx = 0;
reg [9:0] countery = 0;

//images' color stored in these registers
reg [7:0] color=0;
reg [7:0] color_text0=0;
reg [7:0] color_text1=0;
reg [7:0] color_text2=0;
reg [7:0] color_text3=0;
reg [7:0] color_text4=0;
reg [7:0] color_text5=0;
reg [7:0] color_textf=0;

// clk division registers and parameters
reg [27:0] counter=28'd0;
reg clk5=0;
parameter divisor=28'd10000000; 

reg durum;
reg cursorcolour;

// items are stored as registers
reg [19:0] sepet1value;
reg [19:0] sepet2value;
reg [19:0] sepet3value;
reg [19:0] sepet4value;
reg [19:0] sepet5value;
reg [19:0] sepet6value;
reg [6:0] quantity;
reg [6:0] sepet1;
reg [6:0] sepet2;
reg [6:0] sepet3;
reg [6:0] sepet4;
reg [6:0] sepet5;
reg [31:0] total;
reg [6:0] sepet6;
reg deletecheck;
reg navigation_check=0;
reg [5:0] sepetcount;
reg sepetcheck;
wire [2:0] sepetcounter; // For deleting operation
assign sepetcounter = sepetcount[0] + sepetcount[1] + sepetcount[2] + sepetcount[3] + sepetcount[4] + sepetcount[5];

//registers that stores data in .list files of images
reg [7:0] avo[0:9999];
reg [7:0] straw[0:9999];
reg [7:0] tomato[0:9999];
reg [7:0] patato[0:9999];
reg [7:0] pineapple[0:9999];
reg [7:0] apple[0:9999];
reg [7:0] banana[0:9999];
reg [7:0] peach[0:9999];
reg [7:0] coco[0:9999];
reg [7:0] cucumber[0:9999];
reg [7:0] wmelon[0:9999];
reg [7:0] pome[0:9999];
reg [7:0] logo[0:22499]; 
reg [17:0] state;

reg [7:0] avo_text[0:5599];
reg [7:0] straw_text[0:5599];
reg [7:0] tomato_text[0:5599];
reg [7:0] patato_text[0:5599];
reg [7:0] pineapple_text[0:5599];
reg [7:0] apple_text[0:5599];
reg [7:0] banana_text[0:5599];
reg [7:0] peach_text[0:5599];
reg [7:0] coco_text[0:5599];
reg [7:0] cucumber_text[0:5599];
reg [7:0] wmelon_text[0:5599];
reg [7:0] pome_text[0:5599];
reg [7:0] full_text[0:4999];
reg [17:0]state_text;



//integer int_total;

////Initializations 
initial begin
// read .list files and stores in previous assigned registers
$readmemh("imagelist/avo.list",avo);
$readmemh("imagelist/straw.list",straw);
$readmemh("imagelist/tomato.list",tomato);
$readmemh("imagelist/patato.list",patato);
$readmemh("imagelist/pineapple.list",pineapple);
$readmemh("imagelist/apple.list",apple);
$readmemh("imagelist/banana.list",banana);
$readmemh("imagelist/peach.list",peach);
$readmemh("imagelist/coco.list",coco);
$readmemh("imagelist/cucumber.list",cucumber);
$readmemh("imagelist/wmelon.list",wmelon);
$readmemh("imagelist/pome.list",pome);
$readmemh("imagelist/logo.list",logo);

$readmemh("imagelist/avo_text.list",avo_text);
$readmemh("imagelist/straw_text.list",straw_text);
$readmemh("imagelist/tomato_text.list",tomato_text);
$readmemh("imagelist/patato_text.list",patato_text);
$readmemh("imagelist/pineapple_text.list",pineapple_text);
$readmemh("imagelist/apple_text.list",apple_text);
$readmemh("imagelist/banana_text.list",banana_text);
$readmemh("imagelist/peach_text.list",peach_text);
$readmemh("imagelist/coco_text.list",coco_text);
$readmemh("imagelist/cucumber_text.list",cucumber_text);
$readmemh("imagelist/wmelon_text.list",wmelon_text);
$readmemh("imagelist/pome_text.list",pome_text);
$readmemh("imagelist/full_texts.list",full_text);
deletecheck = 0;
sepet1 = 7'b0000000;
sepet2 = 7'b0000000;
sepet3 = 7'b0000000;
sepet4 = 7'b0000000;
sepet5 = 7'b0000000;
sepet6 = 7'b0000000;
sepetcount = 6'b000000;
sepetcheck = 0;
quantity =  7'b0000000;
sepet1value = 20'b00000000000000;
sepet2value = 20'b00000000000000;
sepet3value = 20'b00000000000000;
sepet4value = 20'b00000000000000;
sepet5value = 20'b00000000000000;
sepet6value = 20'b00000000000000;

//
sepet_button_check = 1'b0;
sepet_cursor = 3'b001;
cursorcolour = 1'b0;
//
hl_avokado= 0;  hl_cilek = 0; hl_domates= 0; hl_patates= 0; hl_ananas = 0; hl_elma= 0;  
hl_coconut= 0; hl_hiyar = 0; hl_karpuz= 0;hl_nar= 0; hl_seftali = 0;  hl_muz= 0; 
barcode = 32'd0000; 
checkfordecimal = 4'b0000;
checkbutton = 0;
//
durum=0;
total=0;
originx=0;
originy=0;
d4=0; d3=0; d2=0; d1=0; d0=0;
end

//clock dividers for 25MHZ and 5 Hz

always @ (posedge clk50)
begin
  clk25 <= ~clk25;
end

always @(posedge clk50)
begin
 counter <= counter + 28'd1;
 if(counter>=(divisor-1))
  counter <= 28'd0;
  clk5 <= (counter<divisor/2)?1'b1:1'b0;
end

// VGA Synchronization
always @(posedge clk25)
  begin
    if(counterx == 799)
    begin
      counterx <= 0;
      if(countery == 524)
        countery <= 0;
      else 
        countery <= countery+1'b1;
    end
    else
      counterx <= counterx+1'b1;
 
 
  if (countery >= 490 && countery < 492) 
    vsync <= 1'b0;
  else
    vsync <= 1'b1;

  if (counterx >= 656 && counterx < 752) 
    hsync <= 1'b0;
  else
    hsync <= 1'b1;
  end
  
   // Images of the items are placed in this block
 always @ (posedge clk25) begin 
	if (counterx > 199 && counterx < 300 && countery > 139 && countery < 240) begin
		state <= (counterx-200)*100+countery-140;
		color <= avo[{state}];
	end 
   else if (counterx > 309 && counterx < 410 && countery > 139 && countery < 240) begin
		state <= (counterx-310)*100+countery-140;
		color <= straw[(state)];
	end 
  else if (counterx > 419 && counterx < 520 && countery > 139 && countery < 240) begin
		state <= (counterx-420)*100+countery-140;
		color <= tomato[(state)];
	end 
	else if (counterx > 529 && counterx < 630 && countery > 139 && countery < 240) begin
		state <= (counterx-530)*100+countery-140;
		color <= patato[(state)];
	end 
	else if (counterx > 199 && counterx < 300 && countery > 249 && countery < 350) begin
		state <= (counterx-200)*100+countery-250;
		color <= pineapple[(state)];
	end 
	else if (counterx > 309 && counterx < 410 && countery > 249 && countery < 350) begin
		state <= (counterx-310)*100+countery-250;
		color <= apple[(state)];
	end 
	else if (counterx > 419 && counterx < 520 && countery > 249 && countery < 350) begin
		state <= (counterx-420)*100+countery-250;
		color <= banana[(state)];
	end 
	else if (counterx > 529 && counterx < 630 && countery > 249 && countery < 350) begin
		state <= (counterx-530)*100+countery-250;
		color <= peach[(state)];
	end 
	else if (counterx > 199 && counterx < 300 && countery > 359 && countery < 460) begin
		state <= (counterx-200)*100+countery-360;
		color <= coco[{state}];
	end 
 else if (counterx > 309 && counterx < 410 && countery > 359 && countery < 460) begin
		state <= (counterx-310)*100+countery-360;
		color <= cucumber[(state)];
	end 
  else if (counterx > 419 && counterx < 520 && countery > 359 && countery < 460) begin
		state <= (counterx-420)*100+countery-360;
		color <= wmelon[(state)];
	end 
	else if (counterx > 529 && counterx < 630 && countery > 359 && countery < 460) begin
		state <= (counterx-530)*100+countery-360;
		color <= pome[(state)];
	end
	else if (counterx > 14 && counterx < 240 && countery > 14 && countery < 115) begin
		state <= (counterx-15)*100+countery-15;
		color <= logo[(state)];
	end
	else begin 
		color <=8'b00000000;
		end
  end 
  
  //shoppling list names are placed int this block according to the shopping list.
  always @(posedge clk25)begin
  if (sw2==1)begin
     case (sepet1[6:3])
	4'b0001: begin 
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= avo_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b0010: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= straw_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b0011: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= tomato_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b0100: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= patato_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b0101: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= pineapple_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b0110: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= apple_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b0111: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= banana_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b1000: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= peach_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b1001: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= coco_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b1010: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= cucumber_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b1011: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= wmelon_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	4'b1100: begin
		if (counterx > 19 && counterx < 160 && countery > 129 && countery < 170) begin
		state_text <= (counterx-20)*40+countery-130;
		color_text0 <= pome_text[{state_text}]; end 
		else begin 
		color_text0 <=8'b00000000; end
	end
	endcase
	
	  case (sepet2[6:3])
	4'b0001: begin 
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= avo_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b0010: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= straw_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b0011: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= tomato_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b0100: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= patato_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000;  end
	end
	4'b0101: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= pineapple_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b0110: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= apple_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b0111: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= banana_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b1000: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= peach_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b1001: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= coco_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b1010: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= cucumber_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b1011: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= wmelon_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	4'b1100: begin
		if (counterx > 19 && counterx < 160 && countery > 179 && countery < 220) begin
		state_text <= (counterx-20)*40+countery-180;
		color_text1 <= pome_text[{state_text}]; end 
		else begin 
		color_text1 <=8'b00000000; end
	end
	endcase
	  case (sepet3[6:3])
	4'b0001: begin 
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= avo_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b0010: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= straw_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b0011: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= tomato_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b0100: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= patato_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000;  end
	end
	4'b0101: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= pineapple_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b0110: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= apple_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b0111: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= banana_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b1000: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= peach_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b1001: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= coco_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b1010: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= cucumber_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b1011: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= wmelon_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	4'b1100: begin
		if (counterx > 19 && counterx < 160 && countery > 229 && countery < 270) begin
		state_text <= (counterx-20)*40+countery-230;
		color_text2 <= pome_text[{state_text}]; end 
		else begin 
		color_text2 <=8'b00000000; end
	end
	endcase
	
	  case (sepet4[6:3])
	4'b0001: begin 
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= avo_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b0010: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= straw_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b0011: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= tomato_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b0100: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= patato_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000;  end
	end
	4'b0101: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= pineapple_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b0110: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= apple_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b0111: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= banana_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b1000: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= peach_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b1001: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= coco_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b1010: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= cucumber_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b1011: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= wmelon_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	4'b1100: begin
		if (counterx > 19 && counterx < 160 && countery > 279 && countery < 320) begin
		state_text <= (counterx-20)*40+countery-280;
		color_text3 <= pome_text[{state_text}]; end 
		else begin 
		color_text3 <=8'b00000000; end
	end
	endcase
	
	  case (sepet5[6:3])
	4'b0001: begin 
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= avo_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b0010: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= straw_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b0011: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= tomato_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b0100: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= patato_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000;  end
	end
	4'b0101: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= pineapple_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b0110: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= apple_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b0111: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= banana_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b1000: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= peach_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b1001: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= coco_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b1010: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= cucumber_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b1011: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= wmelon_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	4'b1100: begin
		if (counterx > 19 && counterx < 160 && countery > 329 && countery < 370) begin
		state_text <= (counterx-20)*40+countery-330;
		color_text4 <= pome_text[{state_text}]; end 
		else begin 
		color_text4 <=8'b00000000; end
	end
	endcase
	
	case (sepet6[6:3])
	4'b0001: begin 
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= avo_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b0010: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= straw_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b0011: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= tomato_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b0100: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= patato_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000;  end
	end
	4'b0101: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= pineapple_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b0110: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= apple_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b0111: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= banana_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b1000: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= peach_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b1001: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= coco_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b1010: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= cucumber_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b1011: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= wmelon_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	4'b1100: begin
		if (counterx > 19 && counterx < 160 && countery > 379 && countery < 420) begin
		state_text <= (counterx-20)*40+countery-380;
		color_text5 <= pome_text[{state_text}]; end 
		else begin 
		color_text5 <=8'b00000000; end
	end
	endcase
	// Basket is full is written
	if (sepetcounter==6 && counterx > 254 && counterx < 355 && countery > 64 && countery < 115) begin
		state_text <= (counterx-255)*50+countery-65;
		color_textf <= full_text[{state_text}]; end 
		else begin 
		color_textf <=8'b00000000; end
	end
  end
 
 
 ///////////// Module highligh_selectings

reg hlred;
reg hlred1;
reg hlred2;
reg hlgreen;
reg hlgreen1;
reg hlgreen2;
reg hlblue;
reg hlblue1;
reg hl_avokado; reg hl_cilek; reg hl_domates; reg hl_patates; reg hl_ananas; reg hl_elma; reg hl_muz; reg hl_seftali;
reg hl_coconut; reg hl_hiyar; reg hl_karpuz; reg hl_nar;

//// Borders Of Items///

wire avokado_e1 =((counterx>196 && counterx<200) && (countery>136 && countery<243)) ;
wire avokado_e2 =((counterx>299 && counterx<303) && (countery>136 && countery<243));
wire avokado_e3 =((countery>239 && countery<243) && (counterx>196 && counterx<303));
wire avokado_e4 =((countery>136 && countery<140) && (counterx>196 && counterx<303));

wire avokado_hl_corners;
assign avokado_hl_corners = avokado_e1 || avokado_e2 || avokado_e3 || avokado_e4 ;

wire cilek_e1 =((counterx>306&&counterx<310) && (countery>136&&countery<243));
wire cilek_e2 = ((counterx>409&&counterx<413) && (countery>136&&countery<243));
wire cilek_e3 = ((countery>239&&countery<243) && (counterx>306&&counterx<413));
wire cilek_e4 = ((countery>136&&countery<140) && (counterx>306&&counterx<413));

wire cilek_hl_corners;
assign cilek_hl_corners = cilek_e1 || cilek_e2 || cilek_e3 || cilek_e4 ;

wire domates_e1 =((counterx>416&&counterx<420) && (countery>136&&countery<243));
wire domates_e2 =((counterx>519&&counterx<523) && (countery>136&&countery<243));
wire domates_e3 = ((countery>239&&countery<243) && (counterx>416&&counterx<523));
wire domates_e4 = ((countery>136&&countery<140) && (counterx>416&&counterx<523));

wire domates_hl_corners;
assign domates_hl_corners = domates_e1 || domates_e2 || domates_e3 || domates_e4 ;

wire patates_e1 =((counterx>526&&counterx<530) && (countery>136&&countery<243));
wire patates_e2 = ((counterx>629&&counterx<633) && (countery>136&&countery<243));
wire patates_e3 = ((countery>239&&countery<243) && (counterx>526&&counterx<633));
wire patates_e4 = ((countery>136&&countery<140) && (counterx>526&&counterx<633));

wire patates_hl_corners;
assign patates_hl_corners = patates_e1 || patates_e2 || patates_e3 || patates_e4 ;

wire ananas_e1 =((counterx>196&&counterx<200) && (countery>246&&countery<353));
wire ananas_e2 = ((counterx>299&&counterx<303) && (countery>246&&countery<353));
wire ananas_e3 = ((countery>349&&countery<353) && (counterx>196&&counterx<303));
wire ananas_e4 = ((countery>246&&countery<250) && (counterx>196&&counterx<303));

wire ananas_hl_corners;
assign ananas_hl_corners = ananas_e1 || ananas_e2 || ananas_e3 || ananas_e4 ;

wire elma_e1 =((counterx>306&&counterx<310) && (countery>246&&countery<353));
wire elma_e2 = ((counterx>409&&counterx<413) && (countery>246&&countery<353));
wire elma_e3 =((countery>349&&countery<353) && (counterx>306&&counterx<413));
wire elma_e4 = ((countery>246&&countery<250) && (counterx>306&&counterx<413));

wire elma_hl_corners;
assign elma_hl_corners = elma_e1 || elma_e2 || elma_e3 || elma_e4 ;

wire muz_e1 =((counterx>416&&counterx<420) && (countery>246&&countery<353));
wire muz_e2 = ((counterx>519&&counterx<523) && (countery>246&&countery<353));
wire muz_e3 = ((countery>349&&countery<353) && (counterx>416&&counterx<523));
wire muz_e4 = ((countery>246&&countery<250) && (counterx>416&&counterx<523));

wire muz_hl_corners;
assign muz_hl_corners = muz_e1 || muz_e2 || muz_e3 || muz_e4 ;

wire seftali_e1 =((counterx>526&&counterx<530) && (countery>246&&countery<353));
wire seftali_e2 = ((counterx>629&&counterx<633) && (countery>246&&countery<353));
wire seftali_e3 = ((countery>349&&countery<353) && (counterx>526&&counterx<633));
wire seftali_e4 = ((countery>246&&countery<250) && (counterx>526&&counterx<633));

wire seftali_hl_corners;
assign seftali_hl_corners = seftali_e1 || seftali_e2 || seftali_e3 || seftali_e4 ;

wire coconut_e1 =((counterx>196&&counterx<200) && (countery>356&&countery<463));
wire coconut_e2 = ((counterx>299&&counterx<303) && (countery>356&&countery<463));
wire coconut_e3 = ((countery>459&&countery<463) && (counterx>196&&counterx<303));
wire coconut_e4 = ((countery>356&&countery<360) && (counterx>196&&counterx<303));

wire coconut_hl_corners;
assign coconut_hl_corners = coconut_e1 || coconut_e2 || coconut_e3 || coconut_e4 ;

wire hiyar_e1 =((counterx>306&&counterx<310) && (countery>356&&countery<463));
wire hiyar_e2 = ((counterx>409&&counterx<413) && (countery>356&&countery<463));
wire hiyar_e3 = ((countery>459&&countery<463) && (counterx>306&&counterx<413));
wire hiyar_e4 = ((countery>356&&countery<360) && (counterx>306&&counterx<413));

wire hiyar_hl_corners;
assign hiyar_hl_corners = hiyar_e1 || hiyar_e2 || hiyar_e3 || hiyar_e4 ;

wire karpuz_e1 =((counterx>416&&counterx<420) && (countery>356&&countery<463));
wire karpuz_e2 =  ((counterx>519&&counterx<523) && (countery>356&&countery<463));
wire karpuz_e3 = ((countery>459&&countery<463) && (counterx>416&&counterx<523));
wire karpuz_e4 = ((countery>356&&countery<360) && (counterx>416&&counterx<523));

wire karpuz_hl_corners;
assign karpuz_hl_corners = karpuz_e1 || karpuz_e2 || karpuz_e3 || karpuz_e4 ;

wire nar_e1 =((counterx>526&&counterx<530) && (countery>356&&countery<463));
wire nar_e2 =((counterx>629&&counterx<633) && (countery>356&&countery<463));
wire nar_e3 = ((countery>459&&countery<463) && (counterx>526&&counterx<633));
wire nar_e4 = ((countery>356&&countery<360) && (counterx>526&&counterx<633));

wire nar_hl_corners;
assign nar_hl_corners = nar_e1 || nar_e2 || nar_e3 || nar_e4 ;


///Highlighting selections to vga when sw1 is high.
 
wire theonewire;

assign theonewire = (hl_avokado && avokado_hl_corners)||(hl_cilek && cilek_hl_corners)||(hl_domates && domates_hl_corners)||
(hl_patates && patates_hl_corners)||(hl_ananas && ananas_hl_corners)||(hl_elma && elma_hl_corners)||(hl_coconut && coconut_hl_corners)||     
(hl_hiyar && hiyar_hl_corners)||(hl_karpuz && karpuz_hl_corners)||(hl_nar && nar_hl_corners)||(hl_seftali && seftali_hl_corners)||
(hl_muz && muz_hl_corners);

always@(posedge clk25) begin
if(theonewire && (sw1==0)&&(sw2==0)) begin

hlred <= 1;
hlred1 <= 1;
hlred2 <= 1;

hlgreen <= 0;
hlgreen1 <= 0;
hlgreen2 <= 0;

hlblue <= 0;
hlblue1 <= 0;



end	
else if((theonewire == 0) && (sw1==0)&&(sw2==0)) begin
hlred <= 0;
hlred1 <= 0;
hlred2 <= 0;

hlgreen <= 0;
hlgreen1 <= 0;
hlgreen2 <= 0;

hlblue <= 0;
hlblue1 <= 0;

end
end



always@(posedge clk5) begin 
if(!((barcode==32'd4000)||(barcode==32'd4100)||(barcode==32'd4130)||(barcode==32'd4133)||(barcode==32'd4132)||(barcode==32'd4400)||(barcode==32'd4430)||(barcode==32'd4431)||
(barcode==32'd4432)||(barcode==32'd3000)||(barcode==32'd3200)||(barcode==32'd3210)||(barcode==32'd3214)||(barcode==32'd3213)||(barcode==32'd3100)||
(barcode==32'd3120)||(barcode==32'd3121)||(barcode==32'd3124)||(barcode==32'd2000)||(barcode==32'd2100)||(barcode==32'd2110)||(barcode==32'd2111)||(barcode==32'd2200)||(barcode==32'd2220)||
(barcode==32'd2222)||(barcode==32'd2300)||(barcode==32'd2330)||(barcode==32'd2333)||(barcode==32'd2400)||(barcode==32'd2440)||(barcode==32'd2444)))
begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0; hl_coconut= 0; hl_hiyar= 0;
 hl_karpuz= 0;hl_nar= 0; hl_seftali= 0;  hl_muz= 0; 
 end		
 
case (barcode)

32'd4000:begin
hl_avokado= 1;  hl_cilek= 1; hl_domates= 1; hl_patates= 1;  
hl_ananas= 0; hl_elma= 0;  hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 0; hl_karpuz= 0;hl_nar= 0; end
32'd4100:  begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 1; hl_patates= 1;  
hl_ananas= 0; hl_elma= 0; hl_coconut= 0; hl_hiyar= 0;
 hl_karpuz= 0;hl_nar= 0; hl_seftali= 0;  hl_muz= 0; end	
32'd4130:  begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 1; hl_patates= 1;  
hl_ananas= 0; hl_elma= 0; hl_coconut= 0; hl_hiyar= 0;
 hl_karpuz= 0;hl_nar= 0; hl_seftali= 0;  hl_muz= 0; end	
32'd4133: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 1; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0; hl_coconut= 0; hl_hiyar= 0;
 hl_karpuz= 0;hl_nar= 0; hl_seftali= 0;  hl_muz= 0; end		
32'd4132: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 1;  
hl_ananas= 0; hl_elma= 0; hl_coconut= 0; hl_hiyar= 0;
 hl_karpuz= 0;hl_nar= 0; hl_seftali= 0;  hl_muz= 0; end		
32'd4400: begin
hl_avokado= 1;  hl_cilek= 1; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0; hl_coconut= 0; hl_hiyar= 0;
 hl_karpuz= 0;hl_nar= 0; hl_seftali= 0;  hl_muz= 0; end
32'd4430: begin
hl_avokado= 1;  hl_cilek= 1; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0; hl_coconut= 0; hl_hiyar= 0;
 hl_karpuz= 0;hl_nar= 0; hl_seftali= 0;  hl_muz= 0; end	
32'd4431: begin
hl_avokado= 0;  hl_cilek= 1; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0; hl_coconut= 0; hl_hiyar= 0;
 hl_karpuz= 0;hl_nar= 0; hl_seftali= 0;  hl_muz= 0; end	
32'd4432: begin
hl_avokado= 1;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0; hl_coconut= 0; hl_hiyar= 0;
 hl_karpuz= 0;hl_nar= 0; hl_seftali= 0;  hl_muz= 0; end	
32'd3000: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 1; hl_elma= 1;hl_seftali= 1;  hl_muz= 1;
 hl_karpuz= 0;hl_nar= 0;  hl_coconut=0 ; hl_hiyar= 0; end
32'd3200: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 1; hl_elma= 1;hl_seftali= 0;  hl_muz= 0;
hl_karpuz= 0; hl_nar= 0;  hl_coconut= 0; hl_hiyar= 0; end
32'd3210: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 1; hl_elma= 1;hl_seftali= 0;  hl_muz= 0;
 hl_karpuz= 0;hl_nar= 0;  hl_coconut=0 ; hl_hiyar= 0; end	
32'd3214: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 1; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
 hl_karpuz= 0;hl_nar= 0;  hl_coconut= 0; hl_hiyar= 0; end	
32'd3213: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 1;hl_seftali= 0;  hl_muz= 0;
 hl_karpuz= 0;hl_nar= 0;  hl_coconut= 0; hl_hiyar= 0; end									
32'd3100: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 1;  hl_muz= 1;
hl_karpuz= 0;hl_nar= 0;  hl_coconut= 0; hl_hiyar= 0; end		
32'd3120: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 1;  hl_muz= 1;
hl_karpuz= 0;hl_nar= 0;  hl_coconut= 0; hl_hiyar= 0; end		
32'd3121: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 1;  hl_muz= 0;
hl_karpuz= 0;hl_nar= 0;  hl_coconut= 0; hl_hiyar= 0; end		
32'd3124: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 1;
hl_karpuz= 0;hl_nar= 0;  hl_coconut= 0; hl_hiyar= 0; end		
32'd2000: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 1; hl_hiyar= 1;  hl_karpuz= 1;hl_nar= 1; end		
32'd2100: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 0;  hl_karpuz= 0;hl_nar= 1; end	
32'd2110: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 0;  hl_karpuz= 0;hl_nar= 1; end	
32'd2111: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 0;  hl_karpuz= 0;hl_nar= 1; end	
32'd2200: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 0;  hl_karpuz= 1;hl_nar= 0; end	
32'd2220: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 0;  hl_karpuz= 1;hl_nar= 0; end	
32'd2222: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 0;  hl_karpuz= 1;hl_nar= 0; end	
32'd2300: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 1;  hl_karpuz= 0;hl_nar= 0; end
32'd2330: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 1;  hl_karpuz= 0;hl_nar= 0; end
32'd2333: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 0; hl_hiyar= 1;  hl_karpuz= 0;hl_nar= 0; end	
32'd2400: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 1; hl_hiyar= 0;  hl_karpuz= 0;hl_nar= 0; end
32'd2440: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 1; hl_hiyar= 0;  hl_karpuz= 0;hl_nar= 0; end
32'd2444: begin
hl_avokado= 0;  hl_cilek= 0; hl_domates= 0; hl_patates= 0;  
hl_ananas= 0; hl_elma= 0;hl_seftali= 0;  hl_muz= 0;
hl_coconut= 1; hl_hiyar= 0;  hl_karpuz= 0;hl_nar= 0; end	

endcase
end

///////Adding or deleting operations in shopping list///////////

//Adding//

always@(posedge clk5) begin
if((sw2==0)&&(sepetcheck == 0)&&(quantity != 7'b0000000)&&(sepetcount==6'b000000)) begin

sepet1 <= quantity;
sepetcount[0] <= 1;
sepetcheck <= 1;
end

else if((sw2==0)&&(sepetcheck == 0)&&(quantity!=7'b0000000)&&(sepetcount==6'b000001)) begin

sepet2 <= quantity;
sepetcount[1] <= 1;
sepetcheck <= 1;
end

else if((sw2==0)&&(sepetcheck == 0)&&(quantity!=7'b0000000)&&(sepetcount==6'b000011)) begin

sepet3 <= quantity;
sepetcount[2] <= 1;
sepetcheck <= 1;
end

else if((sw2==0)&&(sepetcheck == 0)&&(quantity!=7'b0000000)&&(sepetcount==6'b000111)) begin

sepet4 <= quantity;
sepetcount[3] <= 1;
sepetcheck <= 1;
end

else if((sw2==0)&&(sepetcheck == 0)&&(quantity!=7'b0000000)&&(sepetcount==6'b001111)) begin

sepet5 <= quantity;
sepetcount[4] <= 1;
sepetcheck <= 1;
end

else if((sw2==0)&&(sepetcheck == 0)&&(quantity!=7'b0000000)&&(sepetcount==6'b011111)) begin

sepet6 <= quantity;
sepetcount[5] <= 1;
sepetcheck <= 1;
end

else if ((quantity == 7'b0000000)&&(sw2==0)) begin
sepetcheck <= 0;
end


//Deleting//
	
else if ((sw2==1)&&(sepet_cursor==3'b001)&&(button_1==0)&&(deletecheck==0)) begin

case(sepetcounter) 

3'b001: begin

sepet1 <= 7'b0000000;
sepetcount <= 6'b000000;
deletecheck <=1;
end

3'b010: begin

sepet1 <= sepet2;
sepet2 <= 7'b0000000;
sepetcount <= 6'b000001;
deletecheck <=1;

////
end

3'b011: begin

sepet1 <= sepet2;
sepet2 <= sepet3;
sepet3 <= 7'b0000000;
sepetcount <= 6'b000011;
deletecheck <=1;
///
end

3'b100: begin

sepet1 <= sepet2;
sepet2 <= sepet3;
sepet3 <= sepet4;
sepet4 <= 7'b0000000;
sepetcount <= 6'b000111;
deletecheck <=1;
end
////

3'b101: begin

sepet1 <= sepet2;
sepet2 <= sepet3;
sepet3 <= sepet4;
sepet4 <= sepet5;
sepet5 <= 7'b0000000;
sepetcount <= 6'b001111;
deletecheck <=1;
end

3'b110: begin

sepet1 <= sepet2;
sepet2 <= sepet3;
sepet3 <= sepet4;
sepet4 <= sepet5;
sepet5 <= sepet6;
sepet6 <= 7'b0000000;
sepetcount <= 6'b011111;
deletecheck <=1;
end

endcase
end

else if ((sw2==1)&&(sepet_cursor==3'b010)&&(button_1==0)&&(deletecheck==0)) begin

case(sepetcounter) 


3'b010: begin

sepet2 <= 7'b0000000;
sepetcount <= 6'b000001;
deletecheck <=1;

end

3'b011: begin

sepet2 <= sepet3;
sepet3 <= 7'b0000000;
sepetcount <= 6'b000011;
deletecheck <=1;
///
end

3'b100: begin

sepet2 <= sepet3;
sepet3 <= sepet4;
sepet4 <= 7'b0000000;
sepetcount <= 6'b000111;
deletecheck <=1;
end
////

3'b101: begin

sepet2 <= sepet3;
sepet3 <= sepet4;
sepet4 <= sepet5;
sepet5 <= 7'b0000000;
sepetcount <= 6'b001111;
deletecheck <=1;
end

3'b110: begin


sepet2 <= sepet3;
sepet3 <= sepet4;
sepet4 <= sepet5;
sepet5 <= sepet6;
sepet6 <= 7'b0000000;
sepetcount <= 6'b011111;
deletecheck <=1;
end

endcase
end

else if ((sw2==1)&&(sepet_cursor==3'b011)&&(button_1==0)&&(deletecheck==0)) begin

case(sepetcounter) 

3'b011: begin

sepet3 <= 7'b0000000;
sepetcount <= 6'b000011;
deletecheck <=1;

end

3'b100: begin

sepet3 <= sepet4;
sepet4 <= 7'b0000000;
sepetcount <= 6'b000111;
deletecheck <=1;
end
////

3'b101: begin


sepet3 <= sepet4;
sepet4 <= sepet5;
sepet5 <= 7'b0000000;
sepetcount <= 6'b001111;
deletecheck <=1;
end

3'b110: begin


sepet3 <= sepet4;
sepet4 <= sepet5;
sepet5 <= sepet6;
sepet6 <= 7'b0000000;
sepetcount <= 6'b011111;
deletecheck <=1;
end

endcase
end


else if ((sw2==1)&&(sepet_cursor==3'b100)&&(button_1==0)&&(deletecheck==0)) begin

case(sepetcounter) 


3'b100: begin

sepet4 <= 7'b0000000;
sepetcount <= 6'b000111;
deletecheck <=1;
end


3'b101: begin


sepet4 <= sepet5;
sepet5 <= 7'b0000000;
sepetcount <= 6'b001111;
deletecheck <=1;
end

3'b110: begin



sepet4 <= sepet5;
sepet5 <= sepet6;
sepet6 <= 7'b0000000;
sepetcount <= 6'b011111;
deletecheck <=1;
end

endcase
end

else if ((sw2==1)&&(sepet_cursor==3'b101)&&(button_1==0)&&(deletecheck==0)) begin

case(sepetcounter) 

3'b101: begin

sepet5 <= 7'b0000000;
sepetcount <= 6'b001111;
deletecheck <=1;
end

3'b110: begin

sepet5 <= sepet6;
sepet6 <= 7'b0000000;
sepetcount <= 6'b011111;
deletecheck <=1;
end

endcase
end

else if ((sw2==1)&&(sepet_cursor==3'b110)&&(button_1==0)&&(deletecheck==0)) begin

case(sepetcounter) 


3'b110: begin

sepet6 <= 7'b0000000;
sepetcount <= 6'b011111;
deletecheck <=1;
end

endcase
end
else if((sw2==1)&&((button_1&&button_2&&button_3&&button_4)==1))begin
deletecheck <=0;
end

end








///// Assigning Barcode ///
reg [31:0] barcode;  


reg [3:0] checkfordecimal;
reg checkbutton;            
reg [2:0] buttonvalue;

 always@(posedge clk5) begin

if(button_1 == 0)begin
buttonvalue = 3'b001;
end

else if(button_2 == 0)begin
buttonvalue = 3'b010;
end

else if(button_3 == 0)begin
buttonvalue = 3'b011;
end

else if(button_4 == 0)begin
buttonvalue = 3'b100;
end 

else if ((button_1&&button_2&&button_3&&button_4)) begin
buttonvalue = 3'b000;
end

end


always@(posedge clk5) begin

if(((sw1==0) && (sw2==0)) && (checkfordecimal[3]== 0) && (checkbutton==0) && ( buttonvalue!=3'b000 )) begin

barcode <= barcode + 1000*buttonvalue;
checkfordecimal[3] <= 1;
checkbutton <= 1;
end


else if(((sw1==0) && (sw2==0)) && (checkfordecimal[2]==0) && (checkbutton==0) && ( buttonvalue!=3'b000 )) begin

barcode <= barcode+(100*buttonvalue);
checkfordecimal[2] <= 1;
checkbutton <= 1;
end



else if(((sw1==0) && (sw2 ==0)) && (checkfordecimal[1]==0) && (checkbutton == 0) && ( buttonvalue!=3'b000 )) begin

barcode <= barcode+(10*buttonvalue);
checkfordecimal[1] <= 1;
checkbutton <= 1;
end

else if(((sw1==0) && (sw2==0)) && (checkfordecimal[0]==0) && (checkbutton == 0) && ( buttonvalue!=3'b000 )) begin

barcode <= barcode + buttonvalue;
checkfordecimal[0] <= 1;
checkbutton <= 1;
end


else if( ((sw1==0) && (sw2==0)) && (checkfordecimal==4'b1111) && (checkbutton == 0) && ( buttonvalue!=3'b000 )) begin


case(barcode) 

32'd4432: begin
quantity <= 7'b0001000 + buttonvalue;
end

32'd4431: begin
quantity <= 7'b0010000 + buttonvalue;
end
32'd4133: begin
quantity <= 7'b0011000 + buttonvalue;
end
32'd4132: begin
quantity <= 7'b0100000 + buttonvalue;
end
32'd3214: begin
quantity <= 7'b0101000 + buttonvalue;
end
32'd3213: begin
quantity <= 7'b0110000 + buttonvalue;
end
32'd3124: begin
quantity <= 7'b0111000 + buttonvalue;
end
32'd3121: begin
quantity <= 7'b1000000 + buttonvalue;
end
32'd2444: begin
quantity <= 7'b1001000 + buttonvalue;
end
32'd2333: begin
quantity <= 7'b1010000 + buttonvalue;
end
32'd2222: begin
quantity <= 7'b1011000 + buttonvalue;
end
32'd2111: begin
quantity <= 7'b1100000 + buttonvalue;
end

endcase
barcode <= 32'd0000;
checkfordecimal <= 4'b0000;
checkbutton <= 1;
end

else if(sw2&&(barcode!=32'd0000)) begin    
barcode = 32'd0000;
checkfordecimal = 4'b0000;
checkbutton= 0;
end


else if ((buttonvalue == 3'b000) && (sw1==0) && (sw2 ==0)) begin
checkbutton <= 0;
quantity <= 7'b0000000;
end




////Selecting products with navigation system//////
else if (sw1==1&&sw2==0&&durum==0)	begin
		if (button_1==0 && originx!=3) begin
      originx<=originx+1'b1;
		end
		else if (button_1==0 && originx==3) begin
		originx<=2'b11;
		end
		else if (button_4==0 && originx!=0) begin
		originx<=originx-1'b1;
		end
		else if (button_4==0 && originx==0) begin
		originx<=2'b0;
		end
		else if (button_2==0 && originy!=2) begin
		originy<=originy+1'b1;
		end
		else if (button_2==0 && originy==2) begin
		originy<=2'b00;
		end
		/*else if (button_3==0 && originy!=0) begin
		originy<=originy-1'b1;
		end
		else if (button_3==0 && originy==0) begin
		originy<=2'b00;
		end*/
		else if (button_3==0) begin 
			durum<=1'b1;
			coord_x<=originx;
			coord_y<=originy;
			navigation_check<=1;
			quantity<=7'b0000000;
		end
	
end
	else if (sw1==1&&sw2==0&&durum==1&&navigation_check==0&&(buttonvalue!=3'b000))	begin
		quantity[6:3]<=coord_x + coord_y*4+1;
		quantity[2:0]<=buttonvalue;
		durum<=1'b0;
		navigation_check<=1;
	end
	else if ((buttonvalue==3'b000)&&(sw1==1)&&(sw2==0))begin
	navigation_check<=0;
	end
end

////Prices of every segment of shopping list and the total value of all of them///
always@(posedge clk5) begin
case(sepet1[6:3]) 

4'b0001:begin
sepet1value = 800*sepet1[2:0];
end

4'b0010:begin
sepet1value = 100*sepet1[2:0];
end

4'b0011:begin
sepet1value = 75*sepet1[2:0];
end

4'b0100:begin
sepet1value = 50*sepet1[2:0];
end

4'b0101:begin
sepet1value = 995*sepet1[2:0];
end

4'b0110:begin
sepet1value = 100*sepet1[2:0];
end

4'b0111:begin
sepet1value = 250*sepet1[2:0];
end

4'b1000:begin
sepet1value = 200*sepet1[2:0];
end

4'b1001:begin
sepet1value = 1490*sepet1[2:0];
end

4'b1010:begin
sepet1value = 150*sepet1[2:0];
end

4'b1011:begin
sepet1value = 1600*sepet1[2:0];
end

4'b1100:begin
sepet1value = 890*sepet1[2:0];
end
 default begin
 sepet1value = 13'b00000000000000;
end
endcase
end

always@(posedge clk5) begin
case(sepet2[6:3]) 

4'b0001:begin
sepet2value = 800*sepet2[2:0];
end

4'b0010:begin
sepet2value = 100*sepet2[2:0];
end

4'b0011:begin
sepet2value = 75*sepet2[2:0];
end

4'b0100:begin
sepet2value = 50*sepet2[2:0];
end

4'b0101:begin
sepet2value = 995*sepet2[2:0];
end

4'b0110:begin
sepet2value = 100*sepet2[2:0];
end

4'b0111:begin
sepet2value = 250*sepet2[2:0];
end

4'b1000:begin
sepet2value = 200*sepet2[2:0];
end

4'b1001:begin
sepet2value = 1490*sepet2[2:0];
end

4'b1010:begin
sepet2value = 150*sepet2[2:0];
end

4'b1011:begin
sepet2value = 1600*sepet2[2:0];
end

4'b1100:begin
sepet2value = 890*sepet2[2:0];
end
 default begin
 sepet2value = 13'b00000000000000;
end
endcase
end

always@(posedge clk5) begin
case(sepet3[6:3]) 

4'b0001:begin
sepet3value = 800*sepet3[2:0];
end

4'b0010:begin
sepet3value = 100*sepet3[2:0];
end

4'b0011:begin
sepet3value = 75*sepet3[2:0];
end

4'b0100:begin
sepet3value = 50*sepet3[2:0];
end

4'b0101:begin
sepet3value = 995*sepet3[2:0];
end

4'b0110:begin
sepet3value = 100*sepet3[2:0];
end

4'b0111:begin
sepet3value = 250*sepet3[2:0];
end

4'b1000:begin
sepet3value = 200*sepet3[2:0];
end

4'b1001:begin
sepet3value = 1490*sepet3[2:0];
end

4'b1010:begin
sepet3value = 150*sepet3[2:0];
end

4'b1011:begin
sepet3value = 1600*sepet3[2:0];
end

4'b1100:begin
sepet3value = 890*sepet3[2:0];
end
 default begin
 sepet3value = 13'b00000000000000;
end
endcase
end

always@(posedge clk5) begin
case(sepet4[6:3]) 

4'b0001:begin
sepet4value = 800*sepet4[2:0];
end

4'b0010:begin
sepet4value = 100*sepet4[2:0];
end

4'b0011:begin
sepet4value = 75*sepet4[2:0];
end

4'b0100:begin
sepet4value = 50*sepet4[2:0];
end

4'b0101:begin
sepet4value = 995*sepet4[2:0];
end

4'b0110:begin
sepet4value = 100*sepet4[2:0];
end

4'b0111:begin
sepet4value = 250*sepet4[2:0];
end

4'b1000:begin
sepet4value = 200*sepet4[2:0];
end

4'b1001:begin
sepet4value = 1490*sepet4[2:0];
end

4'b1010:begin
sepet4value = 150*sepet4[2:0];
end

4'b1011:begin
sepet4value = 1600*sepet4[2:0];
end

4'b1100:begin
sepet4value = 890*sepet4[2:0];
end
 default begin
 sepet4value = 13'b00000000000000;
end
endcase
end

always@(posedge clk5) begin
case(sepet5[6:3]) 

4'b0001:begin
sepet5value = 800*sepet5[2:0];
end

4'b0010:begin
sepet5value = 100*sepet5[2:0];
end

4'b0011:begin
sepet5value = 75*sepet5[2:0];
end

4'b0100:begin
sepet5value = 50*sepet5[2:0];
end

4'b0101:begin
sepet5value = 995*sepet5[2:0];
end

4'b0110:begin
sepet5value = 100*sepet5[2:0];
end

4'b0111:begin
sepet5value = 250*sepet5[2:0];
end

4'b1000:begin
sepet5value = 200*sepet5[2:0];
end

4'b1001:begin
sepet5value = 1490*sepet5[2:0];
end

4'b1010:begin
sepet5value = 150*sepet5[2:0];
end

4'b1011:begin
sepet5value = 1600*sepet5[2:0];
end

4'b1100:begin
sepet5value = 890*sepet5[2:0];
end
 default begin
 sepet5value = 13'b00000000000000;
end
endcase
end

always@(posedge clk5) begin
case(sepet6[6:3]) 

4'b0001:begin
sepet6value = 800*sepet6[2:0];
end

4'b0010:begin
sepet6value = 100*sepet6[2:0];
end

4'b0011:begin
sepet6value = 75*sepet6[2:0];
end

4'b0100:begin
sepet6value = 50*sepet6[2:0];
end

4'b0101:begin
sepet6value = 995*sepet6[2:0];
end

4'b0110:begin
sepet6value = 100*sepet6[2:0];
end

4'b0111:begin
sepet6value = 250*sepet6[2:0];
end

4'b1000:begin
sepet6value = 200*sepet6[2:0];
end

4'b1001:begin
sepet6value = 1490*sepet6[2:0];
end

4'b1010:begin
sepet6value = 150*sepet6[2:0];
end

4'b1011:begin
sepet6value = 1600*sepet6[2:0];
end

4'b1100:begin
sepet6value = 890*sepet6[2:0];
end
 default begin
 sepet6value = 13'b00000000000000;
end
endcase
end

always@(posedge clk5) begin
total <= sepet1value + sepet2value + sepet3value + sepet4value + sepet5value + sepet6value ; //// total alwaysden çıkarılıp wire şeklinde yazılmalı;
end


	
  //// navigation through menu indicator 
always @(posedge clk25) begin	
	if (sw1==1&&sw2==0)	begin
		case ({originx,originy})	
		4'b0000 : begin 
		e1 = ((counterx>196&&counterx<200) && (countery>136&&countery<243));
		e2 = ((counterx>299&&counterx<303) && (countery>136&&countery<243));
		e3 = ((countery>239&&countery<243) && (counterx>196&&counterx<303));
		e4 = ((countery>136&&countery<140) && (counterx>196&&counterx<303));  end
		
		4'b0100 : begin 
		e1 = ((counterx>306&&counterx<310) && (countery>136&&countery<243));
		e2 = ((counterx>409&&counterx<413) && (countery>136&&countery<243));
		e3 = ((countery>239&&countery<243) && (counterx>306&&counterx<413));
		e4 = ((countery>136&&countery<140) && (counterx>306&&counterx<413));  end
		
		4'b1000 : begin 
		e1 = ((counterx>416&&counterx<420) && (countery>136&&countery<243));
		e2 = ((counterx>519&&counterx<523) && (countery>136&&countery<243));
		e3 = ((countery>239&&countery<243) && (counterx>416&&counterx<523));
		e4 = ((countery>136&&countery<140) && (counterx>416&&counterx<523));  end
		
		4'b1100 : begin 
		e1 = ((counterx>526&&counterx<530) && (countery>136&&countery<243));
		e2 = ((counterx>629&&counterx<633) && (countery>136&&countery<243));
		e3 = ((countery>239&&countery<243) && (counterx>526&&counterx<633));
		e4 = ((countery>136&&countery<140) && (counterx>526&&counterx<633)); end
	
		4'b0001 : begin 
		e1 = ((counterx>196&&counterx<200) && (countery>246&&countery<353));
		e2 = ((counterx>299&&counterx<303) && (countery>246&&countery<353));
		e3 = ((countery>349&&countery<353) && (counterx>196&&counterx<303));
		e4 = ((countery>246&&countery<250) && (counterx>196&&counterx<303));  end
		
		4'b0101 : begin 
		e1 = ((counterx>306&&counterx<310) && (countery>246&&countery<353));
		e2 = ((counterx>409&&counterx<413) && (countery>246&&countery<353));
		e3 = ((countery>349&&countery<353) && (counterx>306&&counterx<413));
		e4 = ((countery>246&&countery<250) && (counterx>306&&counterx<413)); end
		
		4'b1001 : begin 
		e1 = ((counterx>416&&counterx<420) && (countery>246&&countery<353));
		e2 = ((counterx>519&&counterx<523) && (countery>246&&countery<353));
		e3 = ((countery>349&&countery<353) && (counterx>416&&counterx<523));
		e4 = ((countery>246&&countery<250) && (counterx>416&&counterx<523));  end
		
		4'b1101 : begin 
		e1 = ((counterx>526&&counterx<530) && (countery>246&&countery<353));
		e2 = ((counterx>629&&counterx<633) && (countery>246&&countery<353));
		e3 = ((countery>349&&countery<353) && (counterx>526&&counterx<633));
		e4 = ((countery>246&&countery<250) && (counterx>526&&counterx<633));  end
	
		4'b0010 : begin 
		e1 = ((counterx>196&&counterx<200) && (countery>356&&countery<463));
		e2 = ((counterx>299&&counterx<303) && (countery>356&&countery<463));
		e3 = ((countery>459&&countery<463) && (counterx>196&&counterx<303));
		e4 = ((countery>356&&countery<360) && (counterx>196&&counterx<303));  end
		
		4'b0110 : begin 
		e1 = ((counterx>306&&counterx<310) && (countery>356&&countery<463));
		e2 = ((counterx>409&&counterx<413) && (countery>356&&countery<463));
		e3 = ((countery>459&&countery<463) && (counterx>306&&counterx<413));
		e4 = ((countery>356&&countery<360) && (counterx>306&&counterx<413)); end
		
		4'b1010 : begin 
		e1 = ((counterx>416&&counterx<420) && (countery>356&&countery<463));
		e2 = ((counterx>519&&counterx<523) && (countery>356&&countery<463));
		e3 = ((countery>459&&countery<463) && (counterx>416&&counterx<523));
		e4 = ((countery>356&&countery<360) && (counterx>416&&counterx<523));	end
		
		4'b1110 : begin 
		e1 = ((counterx>526&&counterx<530) && (countery>356&&countery<463));
		e2 = ((counterx>629&&counterx<633) && (countery>356&&countery<463));
		e3 = ((countery>459&&countery<463) && (counterx>526&&counterx<633));
		e4 = ((countery>356&&countery<360) && (counterx>526&&counterx<633));  end
	endcase
end


end
	 
always @(posedge clk25) begin
	if(sw2==1) begin 
		d4<= total/10000;
		d3<=(total-d4*10000)/1000;
		d2<=(total-d4*10000-d3*1000)/100;
		d1<=(total-d4*10000-d3*1000-d2*100)/10;
		d0<=(total-d4*10000-d3*1000-d2*100-d1*10);
		
		
		t1=((countery==430&&(counterx>10&&counterx<20))||(counterx==15&&(countery>430&&countery<450)));
		t2=(((countery==430||countery==450)&&(counterx>25&&counterx<35))||((counterx==25||counterx==35)&&(countery>430&&countery<450)));    //TOTAL YAZISI
		t3=((countery==430&&(counterx>40&&counterx<50))||(counterx==45&&(countery>430&&countery<450)));
		t4=(((countery==430||countery==440)&&(counterx>55&&counterx<65))||((counterx==55||counterx==65)&&(countery>430&&countery<450)));
		t5=((countery==450&&(counterx>70&&counterx<80))||(counterx==70&&(countery>430&&countery<450)));
      line=countery==425 && counterx<185 && counterx>10;
///////////// SEVEN SEGMENT DISPLAY OF TOTAL ACCOUNT		
	 case(d4) 
	0: begin
		da1 = (countery==430 && (counterx>102&&counterx<112));
		da2 = (counterx==112 && (countery>430&&countery<440));
		da3 = (counterx==112 && (countery>440&&countery<450));
		da4 = (countery==450 && (counterx>102&&counterx<112));
		da5 = (counterx==102 && (countery<450&&countery>440));
		da6 = (counterx==102 && (countery<440&&countery>430));
		da7 = 0; end
	1: begin
		da1 = 0;
		da2 = (counterx==112 && (countery>430&&countery<440));
		da3 = (counterx==112 && (countery>440&&countery<450));
		da4 = 0;
		da5 = 0;
		da6 = 0;
		da7 = 0; end
	2: begin
		da1 = (countery==430 && (counterx>102&&counterx<112));
		da2 = (counterx==112 && (countery>430&&countery<440));
		da3 = 0;
		da4 = (countery==450 && (counterx>102&&counterx<112));
		da5 = (counterx==102 && (countery<450&&countery>440));
		da6 = 0;
		da7 = (countery==440 && (counterx>102&&counterx<112)); end
	3: begin
		da1 = (countery==430 && (counterx>102&&counterx<112));
		da2 = (counterx==112 && (countery>430&&countery<440));
		da3 = (counterx==112 && (countery>440&&countery<450));
		da4 = (countery==450 && (counterx>102&&counterx<112));
		da5 = 0;
		da6 = 0;
		da7 = (countery==440 && (counterx>102&&counterx<112)); end
	4: begin
		da1 = 0;
		da2 = (counterx==112 && (countery>430&&countery<440));
		da3 = (counterx==112 && (countery>440&&countery<450));
		da4 = 0;
		da5 = 0;
		da6 = (counterx==102 && (countery<440&&countery>430));
		da7 = (countery==440 && (counterx>102&&counterx<112)); end
	5: begin
		da1 = (countery==430 && (counterx>102&&counterx<112));
		da2 = 0;
		da3 = (counterx==112 && (countery>440&&countery<450));
		da4 = (countery==450 && (counterx>102&&counterx<112));
		da5 = 0;
		da6 = (counterx==102 && (countery<440&&countery>430));
		da7 = (countery==440 && (counterx>102&&counterx<112)); end
	6: begin
		da1 = (countery==430 && (counterx>102&&counterx<112));
		da2 = 0;
		da3 = (counterx==112 && (countery>440&&countery<450));
		da4 = (countery==450 && (counterx>102&&counterx<112));
		da5 = (counterx==102 && (countery<450&&countery>440));
		da6 = (counterx==102 && (countery<440&&countery>430));
		da7 = (countery==440 && (counterx>102&&counterx<112)); end
	7: begin
		da1 = (countery==430 && (counterx>102&&counterx<112));
		da2 = (counterx==112 && (countery>430&&countery<440));
		da3 = (counterx==112 && (countery>440&&countery<450));
		da4 = 0;
		da5 = 0;
		da6 = 0;
		da7 = 0; end
	8: begin
		da1 = (countery==430 && (counterx>102&&counterx<112));
		da2 = (counterx==112 && (countery>430&&countery<440));
		da3 = (counterx==112 && (countery>440&&countery<450));
		da4 = (countery==450 && (counterx>102&&counterx<112));
		da5 = (counterx==102 && (countery<450&&countery>440));
		da6 = (counterx==102 && (countery<440&&countery>430));
		da7 = (countery==440 && (counterx>102&&counterx<112)); end
	9: begin
		da1 = (countery==430 && (counterx>102&&counterx<112));
		da2 = (counterx==112 && (countery>430&&countery<440));
		da3 = (counterx==112 && (countery>440&&countery<450));
		da4 = (countery==450 && (counterx>102&&counterx<112));
		da5 = 0;
		da6 = (counterx==102 && (countery<440&&countery>430));
		da7 = (countery==440 && (counterx>102&&counterx<112)); end
	endcase
	
	 case(d3) 
	0: begin
		db1 = (countery==430 && (counterx>119&&counterx<129));
		db2 = (counterx==129 && (countery>430&&countery<440));
		db3 = (counterx==129 && (countery>440&&countery<450));
		db4 = (countery==450 && (counterx>119&&counterx<129));
		db5 = (counterx==119 && (countery<450&&countery>440));
		db6 = (counterx==119 && (countery<440&&countery>430));
		db7 = 0; end
	1: begin
		db1 = 0;
		db2 = (counterx==129 && (countery>430&&countery<440));
		db3 = (counterx==129 && (countery>440&&countery<450));
		db4 = 0;
		db5 = 0;
		db6 = 0;
		db7 = 0; end
	2: begin
		db1 = (countery==430 && (counterx>119&&counterx<129));
		db2 = (counterx==129 && (countery>430&&countery<440));
		db3 = 0;
		db4 = (countery==450 && (counterx>119&&counterx<129));
		db5 = (counterx==119 && (countery<450&&countery>440));
		db6 = 0;
		db7 = (countery==440 && (counterx>119&&counterx<129)); end
	3: begin
		db1 = (countery==430 && (counterx>119&&counterx<129));
		db2 = (counterx==129 && (countery>430&&countery<440));
		db3 = (counterx==129 && (countery>440&&countery<450));
		db4 = (countery==450 && (counterx>119&&counterx<129));
		db5 = 0;
		db6 = 0;
		db7 = (countery==440 && (counterx>119&&counterx<129)); end
	4: begin
		db1 = 0;
		db2 = (counterx==129 && (countery>430&&countery<440));
		db3 = (counterx==129 && (countery>440&&countery<450));
		db4 = 0;
		db5 = 0;
		db6 = (counterx==119 && (countery<440&&countery>430));
		db7 = (countery==440 && (counterx>119&&counterx<129)); end
	5: begin
		db1 = (countery==430 && (counterx>119&&counterx<129));
		db2 = 0;
		db3 = (counterx==129 && (countery>440&&countery<450));
		db4 = (countery==450 && (counterx>119&&counterx<129));
		db5 = 0;
		db6 = (counterx==119 && (countery<440&&countery>430));
		db7 = (countery==440 && (counterx>119&&counterx<129)); end
	6: begin
		db1 = (countery==430 && (counterx>119&&counterx<129));
		db2 = 0;
		db3 = (counterx==129 && (countery>440&&countery<450));
		db4 = (countery==450 && (counterx>119&&counterx<129));
		db5 = (counterx==119 && (countery<450&&countery>440));
		db6 = (counterx==119 && (countery<440&&countery>430));
		db7 = (countery==440 && (counterx>119&&counterx<129)); end
	7: begin
		db1 = (countery==430 && (counterx>119&&counterx<129));
		db2 = (counterx==129 && (countery>430&&countery<440));
		db3 = (counterx==129 && (countery>440&&countery<450));
		db4 = 0;
		db5 = 0;
		db6 = 0;
		db7 = 0; end
	8: begin
		db1 = (countery==430 && (counterx>119&&counterx<129));
		db2 = (counterx==129 && (countery>430&&countery<440));
		db3 = (counterx==129 && (countery>440&&countery<450));
		db4 = (countery==450 && (counterx>119&&counterx<129));
		db5 = (counterx==119 && (countery<450&&countery>440));
		db6 = (counterx==119 && (countery<440&&countery>430));
		db7 = (countery==440 && (counterx>119&&counterx<129)); end
	9: begin
		db1 = (countery==430 && (counterx>119&&counterx<129));
		db2 = (counterx==129 && (countery>430&&countery<440));
		db3 = (counterx==129 && (countery>440&&countery<450));
		db4 = (countery==450 && (counterx>119&&counterx<129));
		db5 = 0;
		db6 = (counterx==119 && (countery<440&&countery>430));
		db7 = (countery==440 && (counterx>119&&counterx<129)); end
	endcase
	
	 case(d2) 
	0: begin
		dc1 = (countery==430 && (counterx>136&&counterx<146));
		dc2 = (counterx==146 && (countery>430&&countery<440));
		dc3 = (counterx==146 && (countery>440&&countery<450));
		dc4 = (countery==450 && (counterx>136&&counterx<146));
		dc5 = (counterx==136 && (countery<450&&countery>440));
		dc6 = (counterx==136 && (countery<440&&countery>430));
		dc7 = 0; end
	1: begin
		dc1 = 0;
		dc2 = (counterx==146 && (countery>430&&countery<440));
		dc3 = (counterx==146 && (countery>440&&countery<450));
		dc4 = 0;
		dc5 = 0;
		dc6 = 0;
		dc7 = 0; end
	2: begin
		dc1 = (countery==430 && (counterx>136&&counterx<146));
		dc2 = (counterx==146 && (countery>430&&countery<440));
		dc3 = 0;
		dc4 = (countery==450 && (counterx>136&&counterx<146));
		dc5 = (counterx==136 && (countery<450&&countery>440));
		dc6 = 0;
		dc7 = (countery==440 && (counterx>136&&counterx<146)); end
	3: begin
		dc1 = (countery==430 && (counterx>136&&counterx<146));
		dc2 = (counterx==146 && (countery>430&&countery<440));
		dc3 = (counterx==146 && (countery>440&&countery<450));
		dc4 = (countery==450 && (counterx>136&&counterx<146));
		dc5 = 0;
		dc6 = 0;
		dc7 = (countery==440 && (counterx>136&&counterx<146)); end
	4: begin
		dc1 = 0;
		dc2 = (counterx==146 && (countery>430&&countery<440));
		dc3 = (counterx==146 && (countery>440&&countery<450));
		dc4 = 0;
		dc5 = 0;
		dc6 = (counterx==136 && (countery<440&&countery>430));
		dc7 = (countery==440 && (counterx>136&&counterx<146)); end
	5: begin
		dc1 = (countery==430 && (counterx>136&&counterx<146));
		dc2 = 0;
		dc3 = (counterx==146 && (countery>440&&countery<450));
		dc4 = (countery==450 && (counterx>136&&counterx<146));
		dc5 = 0;
		dc6 = (counterx==136 && (countery<440&&countery>430));
		dc7 = (countery==440 && (counterx>136&&counterx<146)); end
	6: begin
		dc1 = (countery==430 && (counterx>136&&counterx<146));
		dc2 = 0;
		dc3 = (counterx==146 && (countery>440&&countery<450));
		dc4 = (countery==450 && (counterx>136&&counterx<146));
		dc5 = (counterx==136 && (countery<450&&countery>440));
		dc6 = (counterx==136 && (countery>430&&countery<440));
		dc7 = (countery==440 && (counterx>136&&counterx<146)); end
	7: begin
		dc1 = (countery==430 && (counterx>136&&counterx<146));
		dc2 = (counterx==146 && (countery>430&&countery<440));
		dc3 = (counterx==146 && (countery>440&&countery<450));
		dc4 = 0;
		dc5 = 0;
		dc6 = 0;
		dc7 = 0; end
	8: begin
		dc1 = (countery==430 && (counterx>136&&counterx<146));
		dc2 = (counterx==146 && (countery>430&&countery<440));
		dc3 = (counterx==146 && (countery>440&&countery<450));
		dc4 = (countery==450 && (counterx>136&&counterx<146));
		dc5 = (counterx==136 && (countery<450&&countery>440));
		dc6 = (counterx==136 && (countery<440&&countery>430));
		dc7 = (countery==440 && (counterx>136&&counterx<146)); end
	9: begin
		dc1 = (countery==430 && (counterx>136&&counterx<146));
		dc2 = (counterx==146 && (countery>430&&countery<440));
		dc3 = (counterx==146 && (countery>440&&countery<450));
		dc4 = (countery==450 && (counterx>136&&counterx<146));
		dc5 = 0;
		dc6 = (counterx==136 && (countery<440&&countery>430));
		dc7 = (countery==440 && (counterx>136&&counterx<146)); end
	endcase
	 case(d1) 
	0: begin
		dd1 = (countery==430 && (counterx>153&&counterx<163));
		dd2 = (counterx==163 && (countery>430&&countery<440));
		dd3 = (counterx==163 && (countery>440&&countery<450));
		dd4 = (countery==450 && (counterx>153&&counterx<163));
		dd5 = (counterx==153 && (countery<450&&countery>440));
		dd6 = (counterx==153 && (countery<440&&countery>430));
		dd7 = 0; end
	1: begin
		dd1 = 0;
		dd2 = (counterx==163 && (countery>430&&countery<440));
		dd3 = (counterx==163 && (countery>440&&countery<450));
		dd4 = 0;
		dd5 = 0;
		dd6 = 0;
		dd7 = 0; end
	2: begin
		dd1 = (countery==430 && (counterx>153&&counterx<163));
		dd2 = (counterx==163 && (countery>430&&countery<440));
		dd3 = 0;
		dd4 = (countery==450 && (counterx>153&&counterx<163));
		dd5 = (counterx==153 && (countery<450&&countery>440));
		dd6 = 0;
		dd7 = (countery==440 && (counterx>153&&counterx<163)); end
	3: begin
		dd1 = (countery==430 && (counterx>153&&counterx<163));
		dd2 = (counterx==163 && (countery>430&&countery<440));
		dd3 = (counterx==163 && (countery>440&&countery<450));
		dd4 = (countery==450 && (counterx>153&&counterx<163));
		dd5 = 0;
		dd6 = 0;
		dd7 = (countery==440 && (counterx>153&&counterx<163)); end
	4: begin
		dd1 = 0;
		dd2 = (counterx==163 && (countery>430&&countery<440));
		dd3 = (counterx==163 && (countery>440&&countery<450));
		dd4 = 0;
		dd5 = 0;
		dd6 = (counterx==153 && (countery<440&&countery>430));
		dd7 = (countery==440 && (counterx>153&&counterx<163)); end
	5: begin
		dd1 = (countery==430 && (counterx>153&&counterx<163));
		dd2 = 0;
		dd3 = (counterx==163 && (countery>440&&countery<450));
		dd4 = (countery==450 && (counterx>153&&counterx<163));
		dd5 = 0;
		dd6 = (counterx==153 && (countery<440&&countery>430));
		dd7 = (countery==440 && (counterx>153&&counterx<163)); end
	6: begin
		dd1 = (countery==430 && (counterx>153&&counterx<163));
		dd2 = 0;
		dd3 = (counterx==163 && (countery>440&&countery<450));
		dd4 = (countery==450 && (counterx>153&&counterx<163));
		dd5 = (counterx==153 && (countery<450&&countery>440));
		dd6 = (counterx==153 && (countery<440&&countery>430));
		dd7 = (countery==440 && (counterx>153&&counterx<163)); end
	7: begin
		dd1 = (countery==430 && (counterx>153&&counterx<163));
		dd2 = (counterx==163 && (countery>430&&countery<440));
		dd3 = (counterx==163 && (countery>440&&countery<450));
		dd4 = 0;
		dd5 = 0;
		dd6 = 0;
		dd7 = 0; end
	8: begin
		dd1 = (countery==430 && (counterx>153&&counterx<163));
		dd2 = (counterx==163 && (countery>430&&countery<440));
		dd3 = (counterx==163 && (countery>440&&countery<450));
		dd4 = (countery==450 && (counterx>153&&counterx<163));
		dd5 = (counterx==153 && (countery<450&&countery>440));
		dd6 = (counterx==153 && (countery<440&&countery>430));
		dd7 = (countery==440 && (counterx>153&&counterx<163)); end
	9: begin
		dd1 = (countery==430 && (counterx>153&&counterx<163));
		dd2 = (counterx==163 && (countery>430&&countery<440));
		dd3 = (counterx==163 && (countery>440&&countery<450));
		dd4 = (countery==450 && (counterx>153&&counterx<163));
		dd5 = 0;
		dd6 = (counterx==153 && (countery<440&&countery>430));
		dd7 = (countery==440 && (counterx>153&&counterx<163)); end
	endcase
	 case(d0) 
	0: begin
		de1 = (countery==430 && (counterx>170&&counterx<180));
		de2 = (counterx==180 && (countery>430&&countery<440));
		de3 = (counterx==180 && (countery>440&&countery<450));
		de4 = (countery==450 && (counterx>170&&counterx<180));
		de5 = (counterx==170 && (countery<450&&countery>440));
		de6 = (counterx==170 && (countery<440&&countery>430));
		de7 = 0; end
	1: begin
		de1 = 0;
		de2 = (counterx==180 && (countery>430&&countery<440));
		de3 = (counterx==180 && (countery>440&&countery<450));
		de4 = 0;
		de5 = 0;
		de6 = 0;
		de7 = 0; end
	2: begin
		de1 = (countery==430 && (counterx>170&&counterx<180));
		de2 = (counterx==180 && (countery>430&&countery<440));
		de3 = 0;
		de4 = (countery==450 && (counterx>170&&counterx<180));
		de5 = (counterx==170 && (countery<450&&countery>440));
		de6 = 0;
		de7 = (countery==440 && (counterx>170&&counterx<180)); end
	3: begin
		de1 = (countery==430 && (counterx>170&&counterx<180));
		de2 = (counterx==180 && (countery>430&&countery<440));
		de3 = (counterx==180 && (countery>440&&countery<450));
		de4 = (countery==450 && (counterx>170&&counterx<180));
		de5 = 0;
		de6 = 0;
		de7 = (countery==440 && (counterx>170&&counterx<180)); end
	4: begin
		de1 = 0;
		de2 = (counterx==180 && (countery>430&&countery<440));
		de3 = (counterx==180 && (countery>440&&countery<450));
		de4 = 0;
		de5 = 0;
		de6 = (counterx==170 && (countery<440&&countery>430));
		de7 = (countery==440 && (counterx>170&&counterx<180)); end
	5: begin
		de1 = (countery==430 && (counterx>170&&counterx<180));
		de2 = 0;
		de3 = (counterx==180 && (countery>440&&countery<450));
		de4 = (countery==450 && (counterx>170&&counterx<180));
		de5 = 0;
		de6 = (counterx==170 && (countery<440&&countery>430));
		de7 = (countery==440 && (counterx>170&&counterx<180)); end
	6: begin
		de1 = (countery==430 && (counterx>170&&counterx<180));
		de2 = 0;
		de3 = (counterx==180 && (countery>440&&countery<450));
		de4 = (countery==450 && (counterx>170&&counterx<180));
		de5 = (counterx==170 && (countery<450&&countery>440));
		de6 = (counterx==170 && (countery<440&&countery>430));
		de7 = (countery==440 && (counterx>170&&counterx<180)); end
	7: begin
		de1 = (countery==430 && (counterx>170&&counterx<180));
		de2 = (counterx==180 && (countery>430&&countery<440));
		de3 = (counterx==180 && (countery>440&&countery<450));
		de4 = 0;
		de5 = 0;
		de6 = 0;
		de7 = 0; end
	8: begin
		de1 = (countery==430 && (counterx>170&&counterx<180));
		de2 = (counterx==180 && (countery>430&&countery<440));
		de3 = (counterx==180 && (countery>440&&countery<450));
		de4 = (countery==450 && (counterx>170&&counterx<180));
		de5 = (counterx==170 && (countery<450&&countery>440));
		de6 = (counterx==170 && (countery<440&&countery>430));
		de7 = (countery==440 && (counterx>170&&counterx<180)); end
	9: begin
		de1 = (countery==430 && (counterx>170&&counterx<180));
		de2 = (counterx==180 && (countery>430&&countery<440));
		de3 = (counterx==180 && (countery>440&&countery<450));
		de4 = (countery==450 && (counterx>170&&counterx<180));
		de5 = 0;
		de6 = (counterx==170 && (countery<440&&countery>430));
		de7 = (countery==440 && (counterx>170&&counterx<180)); end
	endcase
	nokta = ((counterx>147&&counterx<151)&&(countery>438&&countery<450)) ;
	
	//seven segment for quantities at shopping list 
case (sepet1[2:0])
	1: begin
		sa1 = 0;
		sa2 = (counterx==185 && (countery>140&&countery<150));
		sa3 = (counterx==185 && (countery>150&&countery<160));
		sa4 = 0;
		sa5 = 0;
		sa6 = 0;
		sa7 = 0; end
	2: begin
		sa1 = (countery==140 && (counterx>175&&counterx<185));
		sa2 = (counterx==185 && (countery>140&&countery<150));
		sa3 = 0;
		sa4 = (countery==160 && (counterx>175&&counterx<185));
		sa5 = (counterx==175 && (countery>150&&countery<160));
		sa6 = 0;
		sa7 = (countery==150 && (counterx>175&&counterx<185)); end
	3: begin
		sa1 = (countery==140 && (counterx>175&&counterx<185));
		sa2 = (counterx==185 && (countery>140&&countery<150));
		sa3 = (counterx==185 && (countery>150&&countery<160));
		sa4 = (countery==160 && (counterx>175&&counterx<185));
		sa5 = 0;
		sa6 = 0;
		sa7 = (countery==150 && (counterx>175&&counterx<185)); end
	4: begin
		sa1 = 0;
		sa2 = (counterx==185 && (countery>140&&countery<150));
		sa3 = (counterx==185 && (countery>150&&countery<160));
		sa4 = 0;
		sa5 = 0;
		sa6 = (counterx==175 && (countery>140&&countery<150));
		sa7 = (countery==150 && (counterx>175&&counterx<185)); end
	default begin
		sa1 = 0;
		sa2 = 0;
		sa3 = 0;
		sa4 = 0;
		sa5 = 0;
		sa6 = 0;
		sa7 = 0; end
	endcase
	
	case (sepet2[2:0])
	1: begin
		sb1 = 0;
		sb2 = (counterx==185 && (countery>190&&countery<200));
		sb3 = (counterx==185 && (countery>200&&countery<210));
		sb4 = 0;
		sb5 = 0;
		sb6 = 0;
		sb7 = 0; end
	2: begin
		sb1 = (countery==190 && (counterx>175&&counterx<185));
		sb2 = (counterx==185 && (countery>190&&countery<200));
		sb3 = 0;
		sb4 = (countery==210 && (counterx>175&&counterx<185));
		sb5 = (counterx==175 && (countery>200&&countery<210));
		sb6 = 0;
		sb7 = (countery==200 && (counterx>175&&counterx<185)); end
	3: begin
		sb1 = (countery==190 && (counterx>175&&counterx<185));
		sb2 = (counterx==185 && (countery>190&&countery<200));
		sb3 = (counterx==185 && (countery>200&&countery<210));
		sb4 = (countery==210 && (counterx>175&&counterx<185));
		sb5 = 0;
		sb6 = 0;
		sb7 = (countery==200 && (counterx>175&&counterx<185)); end
	4: begin
		sb1 = 0;
		sb2 = (counterx==185 && (countery>190&&countery<200));
		sb3 = (counterx==185 && (countery>200&&countery<210));
		sb4 = 0;
		sb5 = 0;
		sb6 = (counterx==175 && (countery>190&&countery<200));
		sb7 = (countery==200 && (counterx>175&&counterx<185)); end
	default begin
		sb1 = 0;
		sb2 = 0;
		sb3 = 0;
		sb4 = 0;
		sb5 = 0;
		sb6 = 0;
		sb7 = 0; end
	endcase
	
	case (sepet3[2:0])
	1: begin
		sc1 = 0;
		sc2 = (counterx==185 && (countery>240&&countery<250));
		sc3 = (counterx==185 && (countery>250&&countery<260));
		sc4 = 0;
		sc5 = 0;
		sc6 = 0;
		sc7 = 0; end
	2: begin
		sc1 = (countery==240 && (counterx>175&&counterx<185));
		sc2 = (counterx==185 && (countery>240&&countery<250));
		sc3 = 0;
		sc4 = (countery==260 && (counterx>175&&counterx<185));
		sc5 = (counterx==175 && (countery>250&&countery<260));
		sc6 = 0;
		sc7 = (countery==250 && (counterx>175&&counterx<185)); end
	3: begin
		sc1 = (countery==240 && (counterx>175&&counterx<185));
		sc2 = (counterx==185 && (countery>240&&countery<250));
		sc3 = (counterx==185 && (countery>250&&countery<260));
		sc4 = (countery==260 && (counterx>175&&counterx<185));
		sc5 = 0;
		sc6 = 0;
		sc7 = (countery==250 && (counterx>175&&counterx<185)); end
	4: begin
		sc1 = 0;
		sc2 = (counterx==185 && (countery>240&&countery<250));
		sc3 = (counterx==185 && (countery>250&&countery<260));
		sc4 = 0;
		sc5 = 0;
		sc6 = (counterx==175 && (countery>240&&countery<250));
		sc7 = (countery==250 && (counterx>175&&counterx<185)); end
	default begin
		sc1 = 0;
		sc2 = 0;
		sc3 = 0;
		sc4 = 0;
		sc5 = 0;
		sc6 = 0;
		sc7 = 0; end
	endcase

	case (sepet4[2:0])
	1: begin
		sd1 = 0;
		sd2 = (counterx==185 && (countery>290&&countery<300));
		sd3 = (counterx==185 && (countery>300&&countery<310));
		sd4 = 0;
		sd5 = 0;
		sd6 = 0;
		sd7 = 0; end
	2: begin
		sd1 = (countery==290 && (counterx>175&&counterx<185));
		sd2 = (counterx==185 && (countery>290&&countery<300));
		sd3 = 0;
		sd4 = (countery==310 && (counterx>175&&counterx<185));
		sd5 = (counterx==175 && (countery>300&&countery<310));
		sd6 = 0;
		sd7 = (countery==300 && (counterx>175&&counterx<185)); end
	3: begin
		sd1 = (countery==290 && (counterx>175&&counterx<185));
		sd2 = (counterx==185 && (countery>290&&countery<300));
		sd3 = (counterx==185 && (countery>300&&countery<310));
		sd4 = (countery==310 && (counterx>175&&counterx<185));
		sd5 = 0;
		sd6 = 0;
		sd7 = (countery==300 && (counterx>175&&counterx<185)); end
	4: begin
		sd1 = 0;
		sd2 = (counterx==185 && (countery>290&&countery<300));
		sd3 = (counterx==185 && (countery>300&&countery<310));
		sd4 = 0;
		sd5 = 0;
		sd6 = (counterx==175 && (countery>290&&countery<300));
		sd7 = (countery==300 && (counterx>175&&counterx<185)); end
	default begin
		sd1 = 0;
		sd2 = 0;
		sd3 = 0;
		sd4 = 0;
		sd5 = 0;
		sd6 = 0;
		sd7 = 0; end
	endcase
		
		case (sepet5[2:0])
	1: begin
		se1 = 0;
		se2 = (counterx==185 && (countery>240&&countery<250));
		se3 = (counterx==185 && (countery>250&&countery<260));
		se4 = 0;
		se5 = 0;
		se6 = 0;
		se7 = 0; end
	2: begin
		se1 = (countery==340 && (counterx>175&&counterx<185));
		se2 = (counterx==185 && (countery>340&&countery<350));
		se3 = 0;
		se4 = (countery==360 && (counterx>175&&counterx<185));
		se5 = (counterx==175 && (countery>350&&countery<360));
		se6 = 0;
		se7 = (countery==350 && (counterx>175&&counterx<185)); end
	3: begin
		se1 = (countery==340 && (counterx>175&&counterx<185));
		se2 = (counterx==185 && (countery>340&&countery<350));
		se3 = (counterx==185 && (countery>350&&countery<360));
		se4 = (countery==360 && (counterx>175&&counterx<185));
		se5 = 0;
		se6 = 0;
		se7 = (countery==350 && (counterx>175&&counterx<185)); end
	4: begin
		se1 = 0;
		se2 = (counterx==185 && (countery>340&&countery<350));
		se3 = (counterx==185 && (countery>350&&countery<360));
		se4 = 0;
		se5 = 0;
		se6 = (counterx==175 && (countery>340&&countery<350));
		se7 = (countery==350 && (counterx>175&&counterx<185)); end
	default begin
		se1 = 0;
		se2 = 0;
		se3 = 0;
		se4 = 0;
		se5 = 0;
		se6 = 0;
		se7 = 0; end
	endcase
	
		case (sepet6[2:0])
	1: begin
		sf1 = 0;
		sf2 = (counterx==185 && (countery>390&&countery<400));
		sf3 = (counterx==185 && (countery>400&&countery<410));
		sf4 = 0;
		sf5 = 0;
		sf6 = 0;
		sf7 = 0; end
	2: begin
		sf1 = (countery==390 && (counterx>175&&counterx<185));
		sf2 = (counterx==185 && (countery>390&&countery<400));
		sf3 = 0;
		sf4 = (countery==410 && (counterx>175&&counterx<185));
		sf5 = (counterx==175 && (countery>400&&countery<410));
		sf6 = 0;
		sf7 = (countery==400 && (counterx>175&&counterx<185)); end
	3: begin
		sf1 = (countery==390 && (counterx>175&&counterx<185));
		sf2 = (counterx==185 && (countery>390&&countery<400));
		sf3 = (counterx==185 && (countery>400&&countery<410));
		sf4 = (countery==410 && (counterx>175&&counterx<185));
		sf5 = 0;
		sf6 = 0;
		sf7 = (countery==400 && (counterx>175&&counterx<185)); end
	4: begin
		sf1 = 0;
		sf2 = (counterx==185 && (countery>390&&countery<400));
		sf3 = (counterx==185 && (countery>400&&countery<410));
		sf4 = 0;
		sf5 = 0;
		sf6 = (counterx==175 && (countery>390&&countery<400));
		sf7 = (countery==400 && (counterx>175&&counterx<185)); end
	default begin
		sf1 = 0;
		sf2 = 0;
		sf3 = 0;
		sf4 = 0;
		sf5 = 0;
		sf6 = 0;
		sf7 = 0; end
	endcase
	end
end

reg [2:0] sepet_cursor;
reg sepet_button_check;
//sepetcursor code
always @(posedge clk5) begin //button2 down, button3 up, button 1 delete
	if ((sw2==1)&&(button_2==0)&&(sepet_cursor<(sepetcounter))&&(sepet_button_check==0)&&(sepet_cursor!=3'b110))begin
	sepet_cursor<=(sepet_cursor+(3'b001));
	sepet_button_check<=1;
	end
	else if ((sw2==1)&&(button_3==0)&&(sepet_cursor!=3'b001)&&(sepet_button_check==0)) begin
	sepet_cursor<=(sepet_cursor-(3'b001));
	sepet_button_check<=1;
	end
	else if((sw2==1)&&(button_1==0)&&(sepet_cursor==sepetcounter)&&(sepet_cursor!=3'b001)&&(sepet_button_check==0)) begin
	sepet_cursor<=(sepet_cursor-3'b001);
	sepet_button_check<=1;
	end
	else if(((button_1&&button_2&&button_3&&button_4)==1)&&(sw2==1)) begin
	sepet_button_check<=0;
	end
end
/// sepetcursor to vga
always @(posedge clk25) begin 
if ((sw2==1) && (sepetcounter!=0) && (sepet_cursor==3'b001) && (countery>148 && countery<152) && (counterx>5 && counterx<13)) begin
	cursorcolour<=1'b1; end
	
else if ((sw2==1) && (sepetcounter!=0) && (sepet_cursor==3'b010) && (countery>198 && countery<202) && (counterx>5 && counterx<13)) begin
	cursorcolour<=1'b1; end

else if ((sw2==1) && (sepetcounter!=0) && (sepet_cursor==3'b011) && (countery>248 && countery<252) && (counterx>5 && counterx<13)) begin
	cursorcolour<=1'b1; end
	
else if ((sw2==1) && (sepetcounter!=0) && (sepet_cursor==3'b100) && (countery>298 && countery<302) && (counterx>5 && counterx<13)) begin
	cursorcolour<=1'b1; end

else if ((sw2==1) && (sepetcounter!=0) && (sepet_cursor==3'b101) && (countery>348 && countery<352) && (counterx>5 && counterx<13)) begin
	cursorcolour<=1'b1; end

else if ((sw2==1) && (sepetcounter!=0) && (sepet_cursor==3'b110) && (countery>398 && countery<402) && (counterx>5 && counterx<13)) begin
	cursorcolour<=1'b1; end

else begin
	cursorcolour<=1'b0; end
	
end

// color outputs assigned to RGB

wire R=color[0]||color_text0[0]||color_text1[0]||color_text2[0]||color_text3[0]||color_text4[0]||color_text5[0]||color_textf[0]||e1||e2||e3||e4||t1||t2||t3||t4||t5||da1||da2||da3||da4||da5||da6||da7||db1||db2||db3||db4||db5||db6||db7||dc1||dc2||dc3||dc4||dc5||dc6||dc7||dd1||dd2||dd3||dd4||dd5||dd6||dd7||de1||de2||de3||de4||de5||de6||de7||hlred||cursorcolour||nokta||sa1||sa2||sa3||sa4||sa5||sa6||sa7||sb1||sb2||sb3||sb4||sb5||sb6||sb7||sc1||sc2||sc3||sc4||sc5||sc6||sc7||sd1||sd2||sd3||sd4||sd5||sd6||sd7||se1||se2||se3||se4||se5||se6||se7||sf1||sf2||sf3||sf4||sf5||sf6||sf7||line;
wire R1=color[1]||color_text0[1]||color_text1[1]||color_text2[1]||color_text3[1]||color_text4[1]||color_text5[1]||color_textf[1]||e1||e2||e3||e4||t1||t2||t3||t4||t5||da1||da2||da3||da4||da5||da6||da7||db1||db2||db3||db4||db5||db6||db7||dc1||dc2||dc3||dc4||dc5||dc6||dc7||dd1||dd2||dd3||dd4||dd5||dd6||dd7||de1||de2||de3||de4||de5||de6||de7||hlred1||cursorcolour||nokta||sa1||sa2||sa3||sa4||sa5||sa6||sa7||sb1||sb2||sb3||sb4||sb5||sb6||sb7||sc1||sc2||sc3||sc4||sc5||sc6||sc7||sd1||sd2||sd3||sd4||sd5||sd6||sd7||se1||se2||se3||se4||se5||se6||se7||sf1||sf2||sf3||sf4||sf5||sf6||sf7||line;
wire R2=color[2]||color_text0[2]||color_text1[2]||color_text2[2]||color_text3[2]||color_text4[2]||color_text5[2]||color_textf[2]||e1||e2||e3||e4||t1||t2||t3||t4||t5||da1||da2||da3||da4||da5||da6||da7||db1||db2||db3||db4||db5||db6||db7||dc1||dc2||dc3||dc4||dc5||dc6||dc7||dd1||dd2||dd3||dd4||dd5||dd6||dd7||de1||de2||de3||de4||de5||de6||de7||hlred2||cursorcolour||nokta||sa1||sa2||sa3||sa4||sa5||sa6||sa7||sb1||sb2||sb3||sb4||sb5||sb6||sb7||sc1||sc2||sc3||sc4||sc5||sc6||sc7||sd1||sd2||sd3||sd4||sd5||sd6||sd7||se1||se2||se3||se4||se5||se6||se7||sf1||sf2||sf3||sf4||sf5||sf6||sf7||line;
wire G=color[3]||color_text0[3]||color_text1[3]||color_text2[3]||color_text3[3]||color_text4[3]||color_text5[3]||color_textf[3]||e1||e2||e3||e4||t1||t2||t3||t4||t5||da1||da2||da3||da4||da5||da6||da7||db1||db2||db3||db4||db5||db6||db7||dc1||dc2||dc3||dc4||dc5||dc6||dc7||dd1||dd2||dd3||dd4||dd5||dd6||dd7||de1||de2||de3||de4||de5||de6||de7||hlgreen||nokta||sa1||sa2||sa3||sa4||sa5||sa6||sa7||sb1||sb2||sb3||sb4||sb5||sb6||sb7||sc1||sc2||sc3||sc4||sc5||sc6||sc7||sd1||sd2||sd3||sd4||sd5||sd6||sd7||se1||se2||se3||se4||se5||se6||se7||sf1||sf2||sf3||sf4||sf5||sf6||sf7||line;
wire G1=color[4]||color_text0[4]||color_text1[4]||color_text2[4]||color_text3[4]||color_text4[4]||color_text5[4]||color_textf[4]||e1||e2||e3||e4||t1||t2||t3||t4||t5||da1||da2||da3||da4||da5||da6||da7||db1||db2||db3||db4||db5||db6||db7||dc1||dc2||dc3||dc4||dc5||dc6||dc7||dd1||dd2||dd3||dd4||dd5||dd6||dd7||de1||de2||de3||de4||de5||de6||de7||hlgreen1||nokta||sa1||sa2||sa3||sa4||sa5||sa6||sa7||sb1||sb2||sb3||sb4||sb5||sb6||sb7||sc1||sc2||sc3||sc4||sc5||sc6||sc7||sd1||sd2||sd3||sd4||sd5||sd6||sd7||se1||se2||se3||se4||se5||se6||se7||sf1||sf2||sf3||sf4||sf5||sf6||sf7||line;
wire G2=color[5]||color_text0[5]||color_text1[5]||color_text2[5]||color_text3[5]||color_text4[5]||color_text5[5]||color_textf[5]||e1||e2||e3||e4||t1||t2||t3||t4||t5||da1||da2||da3||da4||da5||da6||da7||db1||db2||db3||db4||db5||db6||db7||dc1||dc2||dc3||dc4||dc5||dc6||dc7||dd1||dd2||dd3||dd4||dd5||dd6||dd7||de1||de2||de3||de4||de5||de6||de7||hlgreen2||nokta||sa1||sa2||sa3||sa4||sa5||sa6||sa7||sb1||sb2||sb3||sb4||sb5||sb6||sb7||sc1||sc2||sc3||sc4||sc5||sc6||sc7||sd1||sd2||sd3||sd4||sd5||sd6||sd7||se1||se2||se3||se4||se5||se6||se7||sf1||sf2||sf3||sf4||sf5||sf6||sf7||line;
wire B=color[6]||color_text0[6]||color_text1[6]||color_text2[6]||color_text3[6]||color_text4[6]||color_text5[6]||color_textf[6]||t1||t2||t3||t4||t5||da1||da2||da3||da4||da5||da6||da7||db1||db2||db3||db4||db5||db6||db7||dc1||dc2||dc3||dc4||dc5||dc6||dc7||dd1||dd2||dd3||dd4||dd5||dd6||dd7||de1||de2||de3||de4||de5||de6||de7||hlblue||nokta||sa1||sa2||sa3||sa4||sa5||sa6||sa7||sb1||sb2||sb3||sb4||sb5||sb6||sb7||sc1||sc2||sc3||sc4||sc5||sc6||sc7||sd1||sd2||sd3||sd4||sd5||sd6||sd7||se1||se2||se3||se4||se5||se6||se7||sf1||sf2||sf3||sf4||sf5||sf6||sf7||line;
wire B1=color[7]||color_text0[7]||color_text1[7]||color_text2[7]||color_text3[7]||color_text4[7]||color_text5[7]||color_textf[7]||t1||t2||t3||t4||t5||da1||da2||da3||da4||da5||da6||da7||db1||db2||db3||db4||db5||db6||db7||dc1||dc2||dc3||dc4||dc5||dc6||dc7||dd1||dd2||dd3||dd4||dd5||dd6||dd7||de1||de2||de3||de4||de5||de6||de7||hlblue1||nokta||sa1||sa2||sa3||sa4||sa5||sa6||sa7||sb1||sb2||sb3||sb4||sb5||sb6||sb7||sc1||sc2||sc3||sc4||sc5||sc6||sc7||sd1||sd2||sd3||sd4||sd5||sd6||sd7||se1||se2||se3||se4||se5||se6||se7||sf1||sf2||sf3||sf4||sf5||sf6||sf7||line;

// vga input rgb pins are assigned in here
always@(posedge clk25) begin 
	vgaR <= R;
	vgaR1 <= R1;
	vgaR2 <= R2;
	vgaG <= G;
	vgaG1 <= G1;
	vgaG2 <= G2;
	vgaB <= B;
	vgaB1 <= B1;
end 
endmodule 