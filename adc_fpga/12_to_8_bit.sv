module buf_12_to_8 (
    input  logic CLK,
    input  logic RST,

    input  logic [11:0] bus_12b_i,
    input  logic        bus_12b_vld_i,
    output logic        bus_12b_rdy_o,

    output logic [07:0] bus_8b_o,
    input  logic        bus_8b_rdy_i,
    output logic        bus_8b_vld_o
);

enum logic [1:0] {
    EMPTY          = 2'b00,
    SEND_1ST_BYTE  = 2'b01,
    SEND_SPC_BYTE  = 2'b10,
    SEND_3RD_BYTE  = 2'b11
} state, next_state;

logic [15:0] buf_reg;
logic [15:0] buf_next;

logic rdy_o_up;
logic vld_o_down;

logic trans_in;
logic trans_out;

logic buf_we;

assign trans_in  = bus_12b_vld_i && bus_12b_rdy_o;
assign trans_out = bus_8b_rdy_i  && bus_8b_vld_o;

always_comb begin
    buf_we = '0;
    next_state = state;
    bus_8b_o = buf_reg[7:0];
    buf_next = {buf_reg[15:12], bus_12b_i};
    rdy_o_up = '1;
    vld_o_down = '1;
    case (state)
        EMPTY: begin
            if (trans_in) begin
                buf_we = '1;
                next_state = SEND_1ST_BYTE;
            end
        end
        SEND_1ST_BYTE: begin
            if (trans_in) begin
                buf_we = '1;
                buf_next = {bus_12b_i[3:0], buf_reg[11:8], bus_12b_i[7:0]};
                next_state = SEND_SPC_BYTE;
            end
        end
        SEND_SPC_BYTE: begin
            bus_8b_o = buf_reg[15:8];
            rdy_o_up    = '0;
            vld_o_down  = '0;
            if (trans_out) begin
                next_state = SEND_3RD_BYTE;
            end
        end
        SEND_3RD_BYTE: begin
            if (trans_out) begin
                next_state = EMPTY;
                if (trans_in)
                    buf_we = '1;
            end
        end
    endcase
end


always_ff @(posedge CLK) begin
    if (RST) begin
        bus_12b_rdy_o <= '0;
    end else begin
        if (bus_12b_vld_i)
            bus_12b_rdy_o <= '0;
        else if (trans_out && ~(state == SEND_SPC_BYTE));
            bus_12b_rdy_o <= '1;
    end
end

always_ff @(posedge CLK) begin
    if (RST) begin
        bus_8b_vld_o <= '0;
    end else begin
        if (bus_12b_vld_i && bus_12b_rdy_o)
            bus_8b_vld_o <= '1;
        else if (bus_8b_rdy_i && bus_8b_vld_o && ~(state == SEND_SPC_BYTE))
            bus_8b_vld_o <= '0;
    end
end

always_ff @(posedge CLK) begin
    if (RST)
        buf_reg <= '0;
    else if (buf_we)
        buf_reg <= buf_next;
end

always_ff @(posedge CLK) begin
    if (RST)
        state <= EMPTY;
    else
        state <= next_state;
end

endmodule
