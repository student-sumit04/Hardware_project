package AXI_properties_pkg;

    property p_bvalid_after_wlast(ACLK,ARESETn,BVALID,WVALID,WREADY,WLAST);
    @(posedge ACLK) disable iff (!ARESETn)
    $rose(BVALID) |-> $past(WVALID && WREADY && WLAST);
    endproperty

    property RREADY_after_wlast_is_zero(ACLK,ARESETn,RLAST,RREADY,RVALID);
    @(posedge ACLK) disable iff (!ARESETn)
    (RLAST &&RREADY && RVALID) |-> ##1 (!RREADY);
    endproperty

    property awready_after_awvalid(ACLK,ARESETn,AWVALID,AWREADY);
    @(posedge ACLK) disable iff (!ARESETn)
    AWVALID |-> ##1 (!AWREADY);
    endproperty

    property WLAST_AND_RLAST(ACLK,ARESETn,WLAST,RLAST);
    @(posedge ACLK) disable iff (!ARESETn)
    not (WLAST && RLAST);
    endproperty

    property WLAST_AND_AWREADY(ACLK,ARESETn,WLAST,AWREADY);
    @(posedge ACLK) disable iff (!ARESETn)
    not (WLAST && AWREADY);
    endproperty

    property RLAST_AND_ARREADY(ACLK,ARESETn,RLAST,ARREADY);
    @(posedge ACLK) disable iff (!ARESETn)
    not (RLAST && ARREADY);
    endproperty

    property WLAST_AND_AWVALID(ACLK,ARESETn,WLAST,AWVALID);
    @(posedge ACLK) disable iff (!ARESETn)
    not (WLAST && AWVALID);
    endproperty

    property RLAST_AND_ARVALID(ACLK,ARESETn,RLAST,ARVALID);
    @(posedge ACLK) disable iff (!ARESETn)
    not (RLAST && ARVALID);
    endproperty

   

endpackage