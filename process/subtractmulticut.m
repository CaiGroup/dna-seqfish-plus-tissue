function I = subtractmulticut(multicutMask, simpleMask)
% function subractmulticut subtracts the multicut mask from a simple
% segmentation mask.
%
% simple mask will have 1 as the dapi or nissle label and 2 as the
% background label: need to alter mask

    revisedSimpleMask = (double(simpleMask) - 2) .* -1;
    I = multicutMask .* uint32(revisedSimpleMask);


end