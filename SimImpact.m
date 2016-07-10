%% Create TDOA object, initialize grid
clear tdoa; clf
warning off MATLAB:plot:IgnoreImaginaryXYPart
tdoa = TDOA;
if exist('doPlots','var')
    tdoa.doPlots = doPlots;
end
if exist('plotIncsM','var')
    tdoa.plotIncs = plotIncsM;
end
% tdoa.doPlots = 0;
tdoa.makeGrid();

% Impact
if exist('greenPress','var') && greenPress == true
    tdoa.pickImpact();
elseif exist('runrandom','var') && runrandom == true
    tdoa.randomImpact();
elseif exist('usex','var') && exist('usey','var')
    tdoa.testImpact(usex, usey);
else
    tdoa.pickImpact();
end
% tdoa.testImpact(1.351, 0.007);

%% Spread SAW
withinSensor = tdoa.spreadSAW();

if withinSensor
    %as the SAW spreads, the first three nodes to activate will come on.
    if tdoa.doPlots
        tdoa.highlightNodes();
    end
    %now use TDOA set on those 3 found nodes.
    %The two input arguments aren't "necesessary" from an object oriented
    %programming perspective, but they illustrate how this will work in the
    %real world.
    tdoa.multilat(tdoa.dT2,tdoa.dT3);
else
    disp('Impact Occured outside sensor');
end

tdoa.checkIfAccurate;
if tdoa.doPlots
%     tdoa.makeMovie();
end
% disp(tdoa)
warning on MATLAB:plot:IgnoreImaginaryXYPart