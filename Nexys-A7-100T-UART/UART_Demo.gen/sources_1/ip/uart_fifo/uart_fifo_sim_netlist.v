// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2023 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2023.2.1 (win64) Build 4081461 Thu Dec 14 12:24:51 MST 2023
// Date        : Fri Feb  2 18:39:51 2024
// Host        : TWLAB-B running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/User1/Documents/Work/Nexys-A7-100T-UART/UART_Demo.gen/sources_1/ip/uart_fifo/uart_fifo_sim_netlist.v
// Design      : uart_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tcsg324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "uart_fifo,fifo_generator_v13_2_9,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_9,Vivado 2023.2.1" *) 
(* NotValidForBitStream *)
module uart_fifo
   (clk,
    srst,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    empty,
    valid,
    data_count);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 core_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME core_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input clk;
  input srst;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [7:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [7:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;
  output valid;
  output [9:0]data_count;

  wire clk;
  wire [9:0]data_count;
  wire [7:0]din;
  wire [7:0]dout;
  wire empty;
  wire full;
  wire rd_en;
  wire srst;
  wire valid;
  wire wr_en;
  wire NLW_U0_almost_empty_UNCONNECTED;
  wire NLW_U0_almost_full_UNCONNECTED;
  wire NLW_U0_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_overflow_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_full_UNCONNECTED;
  wire NLW_U0_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_underflow_UNCONNECTED;
  wire NLW_U0_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_overflow_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_full_UNCONNECTED;
  wire NLW_U0_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_underflow_UNCONNECTED;
  wire NLW_U0_axi_b_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_overflow_UNCONNECTED;
  wire NLW_U0_axi_b_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_b_prog_full_UNCONNECTED;
  wire NLW_U0_axi_b_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_underflow_UNCONNECTED;
  wire NLW_U0_axi_r_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_overflow_UNCONNECTED;
  wire NLW_U0_axi_r_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_r_prog_full_UNCONNECTED;
  wire NLW_U0_axi_r_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_underflow_UNCONNECTED;
  wire NLW_U0_axi_w_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_overflow_UNCONNECTED;
  wire NLW_U0_axi_w_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_w_prog_full_UNCONNECTED;
  wire NLW_U0_axi_w_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_underflow_UNCONNECTED;
  wire NLW_U0_axis_dbiterr_UNCONNECTED;
  wire NLW_U0_axis_overflow_UNCONNECTED;
  wire NLW_U0_axis_prog_empty_UNCONNECTED;
  wire NLW_U0_axis_prog_full_UNCONNECTED;
  wire NLW_U0_axis_sbiterr_UNCONNECTED;
  wire NLW_U0_axis_underflow_UNCONNECTED;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_m_axi_arvalid_UNCONNECTED;
  wire NLW_U0_m_axi_awvalid_UNCONNECTED;
  wire NLW_U0_m_axi_bready_UNCONNECTED;
  wire NLW_U0_m_axi_rready_UNCONNECTED;
  wire NLW_U0_m_axi_wlast_UNCONNECTED;
  wire NLW_U0_m_axi_wvalid_UNCONNECTED;
  wire NLW_U0_m_axis_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_tvalid_UNCONNECTED;
  wire NLW_U0_overflow_UNCONNECTED;
  wire NLW_U0_prog_empty_UNCONNECTED;
  wire NLW_U0_prog_full_UNCONNECTED;
  wire NLW_U0_rd_rst_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_s_axis_tready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire NLW_U0_underflow_UNCONNECTED;
  wire NLW_U0_wr_ack_UNCONNECTED;
  wire NLW_U0_wr_rst_busy_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_wr_data_count_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_U0_m_axi_wdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wuser_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tid_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tkeep_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tstrb_UNCONNECTED;
  wire [3:0]NLW_U0_m_axis_tuser_UNCONNECTED;
  wire [9:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [9:0]NLW_U0_wr_data_count_UNCONNECTED;

  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "0" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "0" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "0" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "8" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TKEEP_WIDTH = "1" *) 
  (* C_AXIS_TSTRB_WIDTH = "1" *) 
  (* C_AXIS_TUSER_WIDTH = "4" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "1" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "10" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "8" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "8" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "1" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_FULL_FLAGS_RST_VAL = "0" *) 
  (* C_HAS_ALMOST_EMPTY = "0" *) 
  (* C_HAS_ALMOST_FULL = "0" *) 
  (* C_HAS_AXIS_TDATA = "1" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "1" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "1" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "1" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "1" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "0" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "1" *) 
  (* C_HAS_UNDERFLOW = "0" *) 
  (* C_HAS_VALID = "1" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "0" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "1" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "1" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "1" *) 
  (* C_PRELOAD_REGS = "0" *) 
  (* C_PRIM_FIFO_TYPE = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "2" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "3" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "1022" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "1021" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "10" *) 
  (* C_RD_DEPTH = "1024" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "10" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "2" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "1" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "0" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "10" *) 
  (* C_WR_DEPTH = "1024" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "10" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  uart_fifo_fifo_generator_v13_2_9 U0
       (.almost_empty(NLW_U0_almost_empty_UNCONNECTED),
        .almost_full(NLW_U0_almost_full_UNCONNECTED),
        .axi_ar_data_count(NLW_U0_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_U0_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_U0_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_U0_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_U0_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_U0_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_U0_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_U0_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_U0_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_U0_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_U0_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_U0_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_U0_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_U0_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_U0_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_U0_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_U0_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_U0_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_U0_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_U0_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_U0_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_U0_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_U0_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_U0_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_U0_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_U0_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_U0_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_U0_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_U0_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_U0_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_U0_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_U0_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_U0_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_U0_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_U0_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_U0_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_U0_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_U0_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_U0_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_U0_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_U0_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_U0_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_U0_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_U0_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_U0_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_U0_axis_data_count_UNCONNECTED[10:0]),
        .axis_dbiterr(NLW_U0_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_U0_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_U0_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_U0_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_U0_axis_rd_data_count_UNCONNECTED[10:0]),
        .axis_sbiterr(NLW_U0_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_U0_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_U0_axis_wr_data_count_UNCONNECTED[10:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(clk),
        .data_count(data_count),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_U0_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_U0_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_U0_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_U0_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_U0_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_U0_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(NLW_U0_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_U0_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_U0_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_U0_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_U0_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_U0_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_U0_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_U0_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_U0_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_U0_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(NLW_U0_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_U0_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(NLW_U0_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_U0_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_U0_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_U0_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_U0_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_U0_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid(1'b0),
        .m_axi_bready(NLW_U0_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_U0_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_U0_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_U0_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(NLW_U0_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_U0_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_U0_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_U0_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(NLW_U0_m_axis_tdata_UNCONNECTED[7:0]),
        .m_axis_tdest(NLW_U0_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_U0_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_U0_m_axis_tkeep_UNCONNECTED[0]),
        .m_axis_tlast(NLW_U0_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(1'b0),
        .m_axis_tstrb(NLW_U0_m_axis_tstrb_UNCONNECTED[0]),
        .m_axis_tuser(NLW_U0_m_axis_tuser_UNCONNECTED[3:0]),
        .m_axis_tvalid(NLW_U0_m_axis_tvalid_UNCONNECTED),
        .overflow(NLW_U0_overflow_UNCONNECTED),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(1'b0),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[9:0]),
        .rd_en(rd_en),
        .rd_rst(1'b0),
        .rd_rst_busy(NLW_U0_rd_rst_busy_UNCONNECTED),
        .rst(1'b0),
        .s_aclk(1'b0),
        .s_aclk_en(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_U0_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_U0_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep(1'b0),
        .s_axis_tlast(1'b0),
        .s_axis_tready(NLW_U0_s_axis_tready_UNCONNECTED),
        .s_axis_tstrb(1'b0),
        .s_axis_tuser({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(srst),
        .underflow(NLW_U0_underflow_UNCONNECTED),
        .valid(valid),
        .wr_ack(NLW_U0_wr_ack_UNCONNECTED),
        .wr_clk(1'b0),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[9:0]),
        .wr_en(wr_en),
        .wr_rst(1'b0),
        .wr_rst_busy(NLW_U0_wr_rst_busy_UNCONNECTED));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2023.2.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
KlreIEsZzn0uSP/9D/ufxHC+XdeNB3Rp8BI1iopwDqZWY2LnU6LdwmOfKqbV5RHI2lmYxZ0DRkF5
dQDDyPtvkr5xpKd4mHw8pIRaCuoIi325TYyZ4mZtew/sj6ihSRoltQmaQarOPDD09PeuMbq8ecc4
WV85hZe43g7mcMbbTbo=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
j15cwxZDk4bw/lIMdYg2vWh4KM2Jwj1RvqcY+ixGr+6fKBD/f4kIxZR2uos4I2Vp8+I6EznWbJgn
Y6RbSMx6/VWYcgzA61qGw6Sc2i3+7vuWI4bzWdDsAGOm754iPsUXIzSiCWBShn3ueyU1KLf34OBT
aVPqizER8L+Vajby7qtqi7c9qV8YSAFUu7KLpy5WNSxnMWeASanJYDU91F2HEHZukcLPx5jLVbQw
OBkdbzP8W1Fw4r/HgO70HZAy3/FOoSjZh5h+xS3J/w7F67NZS7kKd10c1tiNJpj6TE98qMw7DFQn
9GjBtjNbFTiteg6uRQKaQQq1ONNMXpwB7utwYQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
H3xUZXdzhF1pUsPzoBc/UFs0dHjuWE6FlQNImwPPSNMppgVRimjThjFsTZHJGZT5Q6wPHLilexER
sJBrm7KaJA/EtDxlcPlNf6uSr7NwxLCWJHI4+UUZUmou/hONJTDyQ7NPVF7e6cfVv+cvp6Q4osDD
IvFefPUl5UCet4pC/Fw=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
GbfLotE8tiuAo0LPtdX4EdgfdhwUls/WuYf2kXJ25dku9LH+0LoHKO9xKnxQXMI6ZdNz+W9eeQv0
xctfj+/e7BBUir6MTIZn1JntWCoSOcA5nllYxwgOKPddNDj19HuQ69Hc67P2HtX1mkd5BZ0whU5T
hDRzNRZoU0ihPf+VNRdOAbFd+OMpu5Dt/GlzX0I4x3IjrmqqNe4fswlgFyE0Bngd5GzGJHbF/Hih
69H/CPfJQlACUMn4tLLsjhUm2zSHD89D3xTMZIRcgy0tRUrhN2hderFMvZex3czHPVXXHuoMG4DI
wL+MQJf8L3uYhHvW71REgpFAX8q2FPEBu+JdPQ==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
CLZkA80tepZrgoVGvQ8RsvTvbRbcJYWo4MzQydrlQ5vuZK2GZT1ZpYNX9S6ZfzDVxQ0DQG4Nq7w3
TwYMlZu0YYu0TucAa6A8IYxzWcB0AS15+O5xniGw4P5aOx4OCRNRdHIoN4UjiyASnG+QhFxeZtY8
HaZDJ3EeZXZ1xlPe9C4mAvfe8H4hbSvQ9d3/E8nkw7bknt7jf+zqxU888Lnd+Pb5tuO1jXniz1r2
0PVMglqKadXNh9mhFVVuC7Nckrw+xAZ7a69JBSMmlCOar5Q3e0KXNGrJUW+OS1hJCNYaIVyGowEU
Fz6zfzR/ir/OlaH+iI1ZVSMaKdHrv5G2oXMfpw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2022_10", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
BEgl1etvc3H+kX3GaaJ4m5Hx7TXsEMoNGUlLNweK7UABCVqh6geHLWdC3ZR4iTGKp7yTD1CFzLCQ
KbYafcTDi+Auh4GJYnMQ7KZWeo4HhlJEcP8WrZOUJ6/HxpGc61lUtyRV83wuHqlgcaZqkuiseyQF
AVe85UyV/HC7SNVkcVHIN5NrY9LXIOF8mzcj4KpVRA52VCYxISO9Ddk8bojLjd8tsHXofLMPC6l7
wgzk4VVgxAB8bQTOYobkdr2WhndqUgVBIeudzF9jf6OxF2KtStDn0wNvJdU/6ii5M4ZNCHqxWqeg
8AYTqpsmMs2noLyKIc7eQJ9P3H76BzOXpHl38g==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
onsTxmr9leZMdPEkXPYAoaahh6MejdZ+cABzdRPGCDSDlrxzmWDq5F3u3WAgYvyZJsrqmp53UbcC
QdZ/Z+S67/hSTBIV7+YeMLBlYAG7eOvkAVjHS9uKZwVuPUFFRn0dWN2m14DRBNrTakjgUBZotlCJ
zYG7z2eXFh/hHBcx9dKA7PBOPGkzLhqTEVXOheRubxuP1A6tXjRypAO25EfPd22ytlxCzg/y99H7
5CT7ry1htdqXNjvUpnIuq+Tyq1BGb2EauaxybVo/bgc+iQGjfGTdj1LZj0tLKJiGinVhSZe+9os4
WX2B9U2C8BFCpE1jvo76nUiR9lxeRZR97TE3Yg==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
h7dcg8VkOdwzgJApkUqZdCFHbnD9Ks/xXWCsxuKFs1/csamYnM58FaPqnbvDEYV4DkxFm8PDO/ls
W2K9ng/jhkqLQwywf4SN6IRDzF3MFf1mUSm3PiqA1rbQ6NLvHx7SBVVQOCXdeFx/d9ftLoHuxw6j
SUlF7d2ownLhSysrONY8QgrUTDcRwFvh0noZ9FoE//gEdaVDD7qq6rnncUH6NIXZD2QNJ8IgW2EE
ln7EE+92Md8gUTo6vfwF+q4Tl3k/m38ckIW/imfmOaxppQrAQswXHqN5cUv4u0e/dDuT5934ja1H
d3MCHRxmNscOVpNvgySnyTTXVws9twpygdvLMnXAsof5OSMfufvxql+aZOkGYBjtpVwatBDFndUR
iEcLkWxQxaqJ6ulTTO+ALxE6rPs1pOSH0GV48cEoLW2kyMb914+DVew9/AmRYu3rz0uQ7xDF/+Ql
AfxuRP02YBPcMevr0oCqNcpUOaJjkmyG7wKV/7ye59n1jP1D7WjoUMaJ

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
l/O5fpi+++bnBXEsyS4eB3ePsAEEy3fGqR43RuG2/GYX7hddhcZkc/S2i4kZV2ncl0rm3vHOiJ6d
Wql8ox+3bvRw4f3+/R2Jpvxb5nUf4aVLBxgZY9zkvxuqwxkj7o5a+3JZNYDZVQeBUZTsNblHo79n
SmBbtbfc9QTEx1V6ekqtwTIcTg8kDzRDjHcCrvFQp5dc7TeZYK7oJ8/R1o7qiZ/ekDfvpJHEB5QN
MHbg5mE7cE0wSmQMf7/SiZZ+0u6rHIXh56aq4H9xPsR8UPNT6vzPauPXwVy4drZJNkWw802kCzub
1z8ikZ3MYHVCjAp66EXhi0npLJ8owqLcSS7vgA==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
ZbiJS/yJ/2ChEUUUs/zhPZnydFHl5g230ox7ulrdOmeS05wNlv2XKjPyPjYvxWwxWWR13lYxbI1B
KsAIl1WqiBEmzIQyGnOoh19YB1tnNl3r/ilQ3bUH+E+YUUvXJhNP/RrE7gFQAUq1h5Kxsyov5v5d
b12AX4azJ81Yclmb6glYLU/A/Uc9xZsI8wTKceaR9rEHTzXXzEEKvfDLXZj7bb7oXl7rWJdXCuYp
xz/gyco669pKv9yI7eRsg8tbnXesftEv7fyMJr5UGeYoTwLMnoKGLOzcF28SSbLdtEWUbKHUrjHt
x+0UKWZVtujhxa+ybBDk74+0woxwgEBSJmcvng==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
YCuRj74sN8xcBGP8gF6yZ83qYxoB16s6B4faGO3UqeJ0n9Ge7P1Dyec46DdqfSXJ31NG0U84WuZ5
vEbKqZ+e1wG75oueGXZx1g/Bm/RcnkJH13yP3cy0TxuZQH3FfVeX3gP6sJxQpBGH5coAMYa/B679
xHTfAtAShfY0/riweEugdWcK3jTRQkW5vUICfrbbmhV3OCL3HqBHqq/x8wEPzrMfbjXDsxmH4N1V
aDZHTyg+cCthxtbLrQ5KYpVln2nfAXMJh0jbgpA/EPNCbsy2i2MsiRvTpSIKApWPNEQ4gHxCXlml
xpansgG6PYMz7OpRwfisdJ3HEcq4azqJn4zNPg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 100432)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
