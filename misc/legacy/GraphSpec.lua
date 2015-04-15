  -- Experimental Helper Functions for Arbitrary Graph Entity Generation --

  local function _gentempvertex( vlabel )
    local vlabel = vlabel or "1"

    local tempgraph = Graph()
    return tempgraph:addvertex( vlabel )
  end

  local function _gentempedge( svlabel, dvlabel, elabel )
    local svlabel = svlabel or "1"
    local dvlabel = dvlabel or "2"
    local elabel = elabel or svlabel .. ">" .. dvlabel

    local tempgraph = Graph()
    return tempgraph:addedge( tempgraph:addvertex(svlabel),
      tempgraph:addvertex(dvlabel) )
  end
