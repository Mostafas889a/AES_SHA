`default_nettype none

module user_project (
`ifdef USE_POWER_PINS
    inout vccd1,
    inout vssd1,
`endif

    input wire wb_clk_i,
    input wire wb_rst_i,
    input wire wbs_stb_i,
    input wire wbs_cyc_i,
    input wire wbs_we_i,
    input wire [3:0] wbs_sel_i,
    input wire [31:0] wbs_dat_i,
    input wire [31:0] wbs_adr_i,
    output wire wbs_ack_o,
    output wire [31:0] wbs_dat_o,

    output wire [2:0] user_irq
);

    wire [2:0] s_wb_cyc;
    wire [2:0] s_wb_stb;
    wire [2:0] s_wb_we;
    wire [11:0] s_wb_sel;
    wire [95:0] s_wb_adr;
    wire [95:0] s_wb_dat_mosi;
    wire [95:0] s_wb_dat_miso;
    wire [2:0] s_wb_ack;
    wire [2:0] s_wb_err;

    wire [15:0] irq_lines;
    wire aes_irq;
    wire sha256_irq;

    assign irq_lines[0] = aes_irq;
    assign irq_lines[1] = sha256_irq;
    assign irq_lines[15:2] = 14'b0;

    wishbone_bus_splitter #(
        .NUM_PERIPHERALS(3),
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .SEL_WIDTH(4),
        .ADDR_SEL_LOW_BIT(16)
    ) bus_splitter (
        .m_wb_adr_i(wbs_adr_i),
        .m_wb_dat_i(wbs_dat_i),
        .m_wb_dat_o(wbs_dat_o),
        .m_wb_we_i(wbs_we_i),
        .m_wb_sel_i(wbs_sel_i),
        .m_wb_cyc_i(wbs_cyc_i),
        .m_wb_stb_i(wbs_stb_i),
        .m_wb_ack_o(wbs_ack_o),
        .m_wb_err_o(),

        .s_wb_cyc_o(s_wb_cyc),
        .s_wb_stb_o(s_wb_stb),
        .s_wb_we_o(s_wb_we),
        .s_wb_sel_o(s_wb_sel),
        .s_wb_adr_o(s_wb_adr),
        .s_wb_dat_o(s_wb_dat_mosi),
        .s_wb_dat_i(s_wb_dat_miso),
        .s_wb_ack_i(s_wb_ack),
        .s_wb_err_i(s_wb_err)
    );

    EF_AES_WB aes_peripheral (
`ifdef USE_POWER_PINS
        .VPWR(vccd1),
        .VGND(vssd1),
`endif
        .wb_clk_i(wb_clk_i),
        .wb_rst_i(wb_rst_i),
        .wbs_adr_i(s_wb_adr[31:0]),
        .wbs_dat_i(s_wb_dat_mosi[31:0]),
        .wbs_dat_o(s_wb_dat_miso[31:0]),
        .wbs_sel_i(s_wb_sel[3:0]),
        .wbs_cyc_i(s_wb_cyc[0]),
        .wbs_stb_i(s_wb_stb[0]),
        .wbs_ack_o(s_wb_ack[0]),
        .wbs_we_i(s_wb_we[0]),
        .IRQ(aes_irq)
    );

    assign s_wb_err[0] = 1'b0;

    EF_SHA256_WB sha256_peripheral (
`ifdef USE_POWER_PINS
        .VPWR(vccd1),
        .VGND(vssd1),
`endif
        .clk_i(wb_clk_i),
        .rst_i(wb_rst_i),
        .adr_i(s_wb_adr[63:32]),
        .dat_i(s_wb_dat_mosi[63:32]),
        .dat_o(s_wb_dat_miso[63:32]),
        .sel_i(s_wb_sel[7:4]),
        .cyc_i(s_wb_cyc[1]),
        .stb_i(s_wb_stb[1]),
        .ack_o(s_wb_ack[1]),
        .we_i(s_wb_we[1]),
        .irq_o(sha256_irq)
    );

    assign s_wb_err[1] = 1'b0;

    WB_PIC pic (
        .clk(wb_clk_i),
        .rst_n(~wb_rst_i),
        .irq_lines(irq_lines),
        .irq_out(user_irq[0]),
        .wb_adr_i(s_wb_adr[95:64]),
        .wb_dat_i(s_wb_dat_mosi[95:64]),
        .wb_dat_o(s_wb_dat_miso[95:64]),
        .wb_sel_i(s_wb_sel[11:8]),
        .wb_cyc_i(s_wb_cyc[2]),
        .wb_stb_i(s_wb_stb[2]),
        .wb_we_i(s_wb_we[2]),
        .wb_ack_o(s_wb_ack[2])
    );

    assign s_wb_err[2] = 1'b0;
    assign user_irq[2:1] = 2'b0;

endmodule

`default_nettype wire
