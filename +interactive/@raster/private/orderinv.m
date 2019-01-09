function orderInv = orderinv(obj, Order)
orderInv = zeros(1,numel(obj.h_raster));
orderInv(Order) = 1:numel(obj.h_raster);