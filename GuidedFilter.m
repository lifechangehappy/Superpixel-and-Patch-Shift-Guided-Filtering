function [Q, mRTV_min, mRTV_EdgeAware] = GuidedFilter(I, G, mRTV, label, k, eps)
    %   - filtering input image: I (should be a gray-scale/single channel image)
    %   - guidance image: G (should be a gray-scale/single channel image)
    %   - local window size: k
    %   - regularization parameter: eps
    
    r = floor(k / 2);
    dimX = size(I, 1); 
    dimY = size(I, 2);
    
    mRTV_min = zeros(size(mRTV));
    count = zeros(size(I));
    a = zeros(size(I));
    b = zeros(size(I));
    
    GI = I .* G;
    GG = G .* G;
        
    parfor i = 1 : dimX
        for j = 1 : dimY
            % Extract the local patch
            minX = max(1, i-r);
            minY = max(1, j-r);
            maxX = min(i+r, dimX);
            maxY = min(j+r, dimY);
            mRTV_patch = mRTV(minX:maxX, minY:maxY);
            
            mRTV_min(i, j) = min(mRTV_patch(:));
            [row, col] = find(mRTV_patch == mRTV_min(i, j), 1);
            
            % patch shift after select
            minX_select = max(minX+row-1-r, 1);  maxX_select = min(minX+row-1+r, dimX);
            minY_select = max(minY+col-1-r, 1);  maxY_select = min(minY+col-1+r, dimY);  

            lengthX = maxX_select - minX_select + 1;
            lengthY = maxY_select - minY_select + 1;
            isInSP = zeros(lengthX, lengthY);
            
            m = 0; 
            for x = minX_select : maxX_select
                m = m+1;
                n = 0;
                for y = minY_select : maxY_select
                    n = n+1;
                    if label(x, y) == label(i, j)
                        isInSP(m, n) = 1;
                        count(i, j) =count(i, j) + 1;
                    end
                end
            end
            
            I_patch = I(minX_select:maxX_select, minY_select:maxY_select);
            G_patch = G(minX_select:maxX_select, minY_select:maxY_select);
            GI_patch = GI(minX_select:maxX_select, minY_select:maxY_select);
            GG_patch = GG(minX_select:maxX_select, minY_select:maxY_select);
            I_window = I_patch .* isInSP;
            G_window = G_patch .* isInSP;
            GI_window = GI_patch .* isInSP;
            GG_window = GG_patch .* isInSP;
            
            mean_I_window = sum(I_window(:)) / count(i, j);
            mean_G_window = sum(G_window(:)) / count(i, j);
            mean_GI_window = sum(GI_window(:)) / count(i, j);
            mean_GG_window = sum(GG_window(:)) / count(i, j);
            
            Cov_GI = mean_GI_window - mean_G_window * mean_I_window;
            Var_G = mean_GG_window - mean_G_window * mean_G_window;
            
            a(i,j) = Cov_GI / (Var_G + eps);
            b(i,j) = mean_I_window - a(i,j) * mean_G_window;     

        end
    end
    Q = a .* G + b;
end