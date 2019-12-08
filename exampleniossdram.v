module exampleniossdram(
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [15:0]		DRAM_DQ,
	output		          		DRAM_LDQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_UDQM,
	output		          		DRAM_WE_N,

	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	input 		     [3:0]		KEY,

	input 		     [9:0]		SW,

	output		     [9:0]		LEDR,

       inout                                   HPS_CONV_USB_N,
        output              [14:0]              HPS_DDR3_ADDR,
        output               [2:0]              HPS_DDR3_BA,
        output                                  HPS_DDR3_CAS_N,
        output                                  HPS_DDR3_CKE,
        output                                  HPS_DDR3_CK_N,
        output                                  HPS_DDR3_CK_P,
        output                                  HPS_DDR3_CS_N,
        output               [3:0]              HPS_DDR3_DM,
        inout               [31:0]              HPS_DDR3_DQ,
        inout                [3:0]              HPS_DDR3_DQS_N,
        inout                [3:0]              HPS_DDR3_DQS_P,
        output                                  HPS_DDR3_ODT,
        output                                  HPS_DDR3_RAS_N,
        output                                  HPS_DDR3_RESET_N,
        input                                   HPS_DDR3_RZQ,
        output                                  HPS_DDR3_WE_N,
        output                                  HPS_ENET_GTX_CLK,
        inout                                   HPS_ENET_INT_N,
        output                                  HPS_ENET_MDC,
        inout                                   HPS_ENET_MDIO,
        input                                   HPS_ENET_RX_CLK,
        input                [3:0]              HPS_ENET_RX_DATA,
        input                                   HPS_ENET_RX_DV,
        output               [3:0]              HPS_ENET_TX_DATA,
        output                                  HPS_ENET_TX_EN,
        inout                [3:0]              HPS_FLASH_DATA,
        output                                  HPS_FLASH_DCLK,
        output                                  HPS_FLASH_NCSO,
        inout                [1:0]              HPS_GPIO,
        inout                                   HPS_GSENSOR_INT,
        inout                                   HPS_I2C1_SCLK,
        inout                                   HPS_I2C1_SDAT,
        inout                                   HPS_I2C2_SCLK,
        inout                                   HPS_I2C2_SDAT,
        inout                                   HPS_I2C_CONTROL,
        inout                                   HPS_KEY,
        inout                                   HPS_LED,
        output                                  HPS_SD_CLK,
        inout                                   HPS_SD_CMD,
        inout                [3:0]              HPS_SD_DATA,
        output                                  HPS_SPIM_CLK,
        input                                   HPS_SPIM_MISO,
        output                                  HPS_SPIM_MOSI,
        inout                                   HPS_SPIM_SS,
        input                                   HPS_UART_RX,
        output                                  HPS_UART_TX,
        input                                   HPS_USB_CLKOUT,
        inout                [7:0]              HPS_USB_DATA,
        input                                   HPS_USB_DIR,
        input                                   HPS_USB_NXT,
        output                                  HPS_USB_STP	
	);


	wire clk_clk;
	wire reset_reset_n;
	wire locked;
	wire [7:0] kex_export;
	wire [15:0] ledr_export;
	wire [31:0] hex_export;
	
	platformniossdram u0 (
		.clk_clk          (clk_clk),         
		.hex_wire_export  (hex_export),  
		.key_wire_export  (key_export), 
		.ledr_wire_export (ledr_export), 
		.reset_reset_n    (reset_reset_n),    
		.sdram_wire_addr  (DRAM_ADDR),  
		.sdram_wire_ba    (DRAM_BA),    
		.sdram_wire_cas_n (DRAM_CAS_N), 
		.sdram_wire_cke   (DRAM_CKE),   
		.sdram_wire_cs_n  (DRAM_CS_N),  
		.sdram_wire_dq    (DRAM_DQ),    
		.sdram_wire_dqm   ({DRAM_UDQM,DRAM_LDQM}),   
		.sdram_wire_ras_n (DRAM_RAS_N), 
		.sdram_wire_we_n  (DRAM_WE_N),  
		.sdram_clk_clk    (DRAM_CLK),
		.pll_0_locked_export (locked),
		
		        // DDR3
                .hps_0_ddr_mem_a                   ( HPS_DDR3_ADDR       ),                    
                .hps_0_ddr_mem_ba                  ( HPS_DDR3_BA         ),                      
                .hps_0_ddr_mem_ck                  ( HPS_DDR3_CK_P       ),                    
                .hps_0_ddr_mem_ck_n                ( HPS_DDR3_CK_N       ),                    
                .hps_0_ddr_mem_cke                 ( HPS_DDR3_CKE        ),                     
                .hps_0_ddr_mem_cs_n                ( HPS_DDR3_CS_N       ),                    
                .hps_0_ddr_mem_ras_n               ( HPS_DDR3_RAS_N      ),                   
                .hps_0_ddr_mem_cas_n               ( HPS_DDR3_CAS_N      ),                   
                .hps_0_ddr_mem_we_n                ( HPS_DDR3_WE_N       ),                    
                .hps_0_ddr_mem_reset_n             ( HPS_DDR3_RESET_N    ),             
                .hps_0_ddr_mem_dq                  ( HPS_DDR3_DQ         ),                      
                .hps_0_ddr_mem_dqs                 ( HPS_DDR3_DQS_P      ),                   
                .hps_0_ddr_mem_dqs_n               ( HPS_DDR3_DQS_N      ),                   
                .hps_0_ddr_mem_odt                 ( HPS_DDR3_ODT        ),                     
                .hps_0_ddr_mem_dm                  ( HPS_DDR3_DM         ),                      
                .hps_0_ddr_oct_rzqin               ( HPS_DDR3_RZQ        ),                     

        // ETHERNET
                .hps_0_io_hps_io_emac1_inst_TX_CLK ( HPS_ENET_GTX_CLK    ),    
                .hps_0_io_hps_io_emac1_inst_TXD0   ( HPS_ENET_TX_DATA[0] ), 
                .hps_0_io_hps_io_emac1_inst_TXD1   ( HPS_ENET_TX_DATA[1] ), 
                .hps_0_io_hps_io_emac1_inst_TXD2   ( HPS_ENET_TX_DATA[2] ), 
                .hps_0_io_hps_io_emac1_inst_TXD3   ( HPS_ENET_TX_DATA[3] ), 
                .hps_0_io_hps_io_emac1_inst_RXD0   ( HPS_ENET_RX_DATA[0] ), 
                .hps_0_io_hps_io_emac1_inst_MDIO   ( HPS_ENET_MDIO       ),       
                .hps_0_io_hps_io_emac1_inst_MDC    ( HPS_ENET_MDC        ),     
                .hps_0_io_hps_io_emac1_inst_RX_CTL ( HPS_ENET_RX_DV      ),       
                .hps_0_io_hps_io_emac1_inst_TX_CTL ( HPS_ENET_TX_EN      ),       
                .hps_0_io_hps_io_emac1_inst_RX_CLK ( HPS_ENET_RX_CLK     ),      
                .hps_0_io_hps_io_emac1_inst_RXD1   ( HPS_ENET_RX_DATA[1] ), 
                .hps_0_io_hps_io_emac1_inst_RXD2   ( HPS_ENET_RX_DATA[2] ), 
                .hps_0_io_hps_io_emac1_inst_RXD3   ( HPS_ENET_RX_DATA[3] ), 

        // NVRAM
                .hps_0_io_hps_io_qspi_inst_IO0     ( HPS_FLASH_DATA[0]   ),      
                .hps_0_io_hps_io_qspi_inst_IO1     ( HPS_FLASH_DATA[1]   ),      
                .hps_0_io_hps_io_qspi_inst_IO2     ( HPS_FLASH_DATA[2]   ),      
                .hps_0_io_hps_io_qspi_inst_IO3     ( HPS_FLASH_DATA[3]   ),      
                .hps_0_io_hps_io_qspi_inst_SS0     ( HPS_FLASH_NCSO      ),         
                .hps_0_io_hps_io_qspi_inst_CLK     ( HPS_FLASH_DCLK      ),         

        // SDMMC
                .hps_0_io_hps_io_sdio_inst_CMD     ( HPS_SD_CMD          ),         
                .hps_0_io_hps_io_sdio_inst_D0      ( HPS_SD_DATA[0]      ),    
                .hps_0_io_hps_io_sdio_inst_D1      ( HPS_SD_DATA[1]      ),    
                .hps_0_io_hps_io_sdio_inst_CLK     ( HPS_SD_CLK          ),          
                .hps_0_io_hps_io_sdio_inst_D2      ( HPS_SD_DATA[2]      ),    
                .hps_0_io_hps_io_sdio_inst_D3      ( HPS_SD_DATA[3]      ),    

        // USB
                .hps_0_io_hps_io_usb1_inst_D0      ( HPS_USB_DATA[0]     ),     
                .hps_0_io_hps_io_usb1_inst_D1      ( HPS_USB_DATA[1]     ),     
                .hps_0_io_hps_io_usb1_inst_D2      ( HPS_USB_DATA[2]     ),     
                .hps_0_io_hps_io_usb1_inst_D3      ( HPS_USB_DATA[3]     ),     
                .hps_0_io_hps_io_usb1_inst_D4      ( HPS_USB_DATA[4]     ),     
                .hps_0_io_hps_io_usb1_inst_D5      ( HPS_USB_DATA[5]     ),     
                .hps_0_io_hps_io_usb1_inst_D6      ( HPS_USB_DATA[6]     ),     
                .hps_0_io_hps_io_usb1_inst_D7      ( HPS_USB_DATA[7]     ),     
                .hps_0_io_hps_io_usb1_inst_CLK     ( HPS_USB_CLKOUT      ),      
                .hps_0_io_hps_io_usb1_inst_STP     ( HPS_USB_STP         ),         
                .hps_0_io_hps_io_usb1_inst_DIR     ( HPS_USB_DIR         ),         
                .hps_0_io_hps_io_usb1_inst_NXT     ( HPS_USB_NXT         ),         
 
        // SPI
                .hps_0_io_hps_io_spim1_inst_CLK    ( HPS_SPIM_CLK  ),   
                .hps_0_io_hps_io_spim1_inst_MOSI   ( HPS_SPIM_MOSI ),   
                .hps_0_io_hps_io_spim1_inst_MISO   ( HPS_SPIM_MISO ),   
                .hps_0_io_hps_io_spim1_inst_SS0    ( HPS_SPIM_SS ),   

        // UART          
                .hps_0_io_hps_io_uart0_inst_RX     ( HPS_UART_RX    ),     
                .hps_0_io_hps_io_uart0_inst_TX     ( HPS_UART_TX    ),     

        // I2C
                .hps_0_io_hps_io_i2c0_inst_SDA     ( HPS_I2C1_SDAT    ),     
                .hps_0_io_hps_io_i2c0_inst_SCL     ( HPS_I2C1_SCLK    ),     
                .hps_0_io_hps_io_i2c1_inst_SDA     ( HPS_I2C2_SDAT    ),     
                .hps_0_io_hps_io_i2c1_inst_SCL     ( HPS_I2C2_SCLK    )
		
	);

	assign clk_clk = CLOCK_50;
	assign reset_reset_n = KEY[0];
	
   hexdecoder HEXD0(hex_export[03:00], HEX0);
   hexdecoder HEXD1(hex_export[07:04], HEX1);
   hexdecoder HEXD2(hex_export[11:08], HEX2);
   hexdecoder HEXD3(hex_export[15:12], HEX3);
   hexdecoder HEXD4(hex_export[19:16], HEX4);
   hexdecoder HEXD5(hex_export[23:20], HEX5);
	
   assign key_export = SW;
   assign LEDR[7:0]  = ledr_export[7:0];

   reg [23:0]         heartbeat;

   // heartbeat indicator
   always @(posedge CLOCK_50, negedge KEY[0])
     if (KEY[0] == 1'b0)
       heartbeat <= 24'b0;
     else
       heartbeat <= heartbeat + 1'b1;
   assign LEDR[9] = heartbeat[23];
   assign LEDR[8] = ~heartbeat[23] ^ locked;
	
endmodule
