classdef TDOA < handle
    %TDOA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        nodes;
        ax;
        hFig;
        nodesRegistered;
        hit;
        XY;
        hitDist;
        minX;
        minY;
        maxX;
        maxY;
        inc = 0.001;
        err = 0.02; %Maximum modulus size
        R1; R2; R3;
        node1; node2; node3;
        dT2; dT3;
        t1_REF;
        max_dT = 0.015;
        loops;
        overHeadTime;
        time;
        plotIncs = 1.0;
        doPlots = true;
        movie = struct('cdata',[],'colormap',[]);
        m_count = 1;
    end
    
    properties (Constant = true)
        v = 3420./100; %cm./s
        NUM_SOLS = 6;
    end
    
    
    methods (Static)
        [x1_12, y1_12, x1_13, y1_13, x1_23, y1_23,   ...
            x2_12, y2_12, x2_13, y2_13, x2_23, y2_23] = ...
            symbolicallySolveThreeCircles();
        
        [xys1 xys2] = solveThreeCircles(x_1, x_2, x_3, y_1, y_2, y_3, R_1, R_2, R_3);
        
%         function matrix = checkIntercept(matrix,num)
%             %CHECKINTERCEPT - 
%             %Matrix is really a list of 6 numbers presenting the X or Y
%             %point of the circles intercepting. There will always be a
%             %real or complex intercept, however if the complex argument
%             %or modulus are significantly small, you can consider it real
%             %or 0.
%             %
%             %Each element of the matrix is compared to a number, which
%             %is a single intercept.
%             %
%             %The idea here is to hopefully find 3 elements in the marix
%             %which are very close to 0, if not exactly 0, both in
%             %real and imaginary domains.
%             %
%             %If the imaginary part is larger than a tollerance, just say
%             %the number is 999, which is obviously too large.
%             matrix  = matrix - num;
%             numsols = TDOA.NUM_SOLS;
%             imagerr = TDOA.imagErr;
%             %matrix(imag(matrix)~=0) = NaN; %this step is too matlab-like
%             
%             
%             %This method can be better ported to C hopefully.
%             for i = 1:numsols
%                 %if complex argument is insiginificant or
%                 %if the modulus is insigificatn
%                 %Then I concluded the number is effectively real or 0
%                 if abs(matrix(i)) > 5
%                     matrix(i) = 999;
%                 else
%                     matrix(i) = 0; %ensures no mess
%                 end
%             end
%         end
        function pt = findFirstIntercept(xInts,yInts)
            for i = 1:TDOA.NUM_SOLS
                if xInts(i) + yInts(i) == 2
                    pt = i;
                    return
                end
            end
            pt = 0;
        end
    end
    
    methods (Access = private)
        function plotTriProgress(obj,x_1,y_1,x_2,y_2,x_3,y_3,R_1,R_2,R_3,p)
            try %#ok<*TRYNC>
                rectangle('position', [x_1-R_1, y_1-R_1, 2.*R_1, 2.*R_1],...
                    'curvature',[1 1],...
                    'EdgeColor','b')
            end
            try
                rectangle('position', [x_2-R_2, y_2-R_2, 2.*R_2, 2.*R_2],...
                    'curvature',[1 1],...
                    'EdgeColor','c')
            end
            try
                rectangle('position', [x_3-R_3, y_3-R_3, 2.*R_3, 2.*R_3],...
                    'curvature',[1 1],...
                    'EdgeColor','g')
            end
            for i = 1:3
                %Plot Expanding Circles at specified changes of k-index
                switch i
                    case 1
                        color1 = 'y.';
                        color2 = 'm.';
                    case 2
                        color1 = 'c.';
                        color2 = 'b.';
                    case 3
                        color1 = 'g.';
                        color2 = 'r.';
                end
                %Plot real intercept paths.
                if isreal(p{1}(i,1)) && isreal(p{2}(i,1))
                    plot(p{1}(i,1),p{2}(i,1),color1)
                end
                if isreal(p{3}(i,1)) && isreal(p{4}(i,1))
                    plot(p{3}(i,1),p{4}(i,1),color2)
                end
            end
            obj.addframe();
        end
        
        function addframe(obj)
            %obj.movie(obj.m_count) = getframe(obj.hFig);
            %obj.m_count = obj.m_count + 1; 
        end
        
        function registerHit(obj, hitxy)
            obj.hit = round(hitxy./obj.inc).*obj.inc;
            if obj.doPlots
                plot(obj.ax,obj.hit(1),obj.hit(2),...
                    'ko','LineWidth',5)
                obj.addframe();
            end
        end
        function detDistances(obj)
            %this function will determine the hit locations distance to each node
            hitDistT = zeros(obj.nodesRegistered,1);
            hitT = obj.hit;
            nodesT = obj.nodes;
            for i = 1:obj.nodesRegistered
                hitDistT(i) = distance(hitT,nodesT(i,:));
            end
            obj.hitDist = hitDistT;
        end
        
        function withinLim = checkIfImpactWithinSensor(obj)
            withinLim = true; %obj.max_dT > obj.dT3;
        end
        function found = findInterceptPt(obj,X,Y,k)
            found = 0;
            errT = obj.err;
            nums = TDOA.NUM_SOLS;
            for z = 1:nums
                % This redundant looking code speeds up the algorithm greatly.
                modX = abs(X-X(z));
                %Make sure the modulus of the intercept is sufficently
                %small
                xInts = modX <= errT;
                
                if nnz(xInts) >= 3 %nnz is an easy function to port to C.
                    modY = abs(Y-Y(z));
                    yInts = modY <= errT;
                    if nnz(yInts) >= 3
                        if nargin == 4
                            disp('Found K')
                            disp(k)
                        end
                        %pt = find(xInts+yInts==2,1,'first');
                        %this function is too matlab-specific
                        found = TDOA.findFirstIntercept(xInts,yInts);
                        return
                    end
                end
            end
        end
    end
    
    methods
        function obj = TDOA()
            obj.overHeadTime = tic;
        end
        
        function checkIfAccurate(obj)
            
            
        end
        
        function makeMovie(obj)
           M = obj.movie;
           movie2avi(M, 'triangulation.avi');%, 'compression', 'Indeo5');
        end
        
        function makeGrid(obj)
            %             nodesT = [0, 0  ; 0.5, 0  ; 1, 0  ; 1.5, 0  ; 2, 0  ;
            %                       0, 1/3; 0.5, 1/3; 1, 1/3; 1.5, 1/3; 2, 1/3;
            %                       0, 2/3; 0.5, 2/3; 1, 2/3; 1.5, 2/3; 2, 2/3;
            %                       0, 1  ; 0.5, 1  ; 1, 1  ; 1.5, 1  ; 2, 1 ];
            
            %             nodesT = [0, 1  ; 1, 1    ; 2, 1;
            %                       1, 0.5;
            %                       0.5, 0  ; 1.5, 0];
            
            nodesT = [0, 1  ; 1, 1    ; 2, 1;
                0.5, 0.5; 1.5, 0.5;
                0, 0  ; 1, 0    ; 2, 0];

            obj.minX = min(nodesT(:,1));
            obj.minY = min(nodesT(:,2));
            obj.maxX = max(nodesT(:,1));
            obj.maxY = max(nodesT(:,2));
            if obj.doPlots
                clf;
                h = figure(1);
                axT = axes;
                for i = 1:length(nodesT)
                    plot(axT, nodesT(i,1), nodesT(i,2), 'k*');
                    hold on
                end
                %             axis([x_1-0.1, x_2+0.1, y_1-0.1, y_3+0.1])
                axis equal
                
                title(axT,'Sensor Figure');
                xlabel(axT,'Length of Sensor');
                ylabel(axT,'Width of Sensor');
                %legend(axT,'Capacitive Islands/Nodes',0);
                obj.ax = axT;
                obj.hFig = h;
                obj.addframe();
            end
            obj.nodes = nodesT;
            obj.nodesRegistered = length(nodesT);
        end
        
        function withinLimits = spreadSAW(obj, maxdt)
            if nargin == 2
                obj.max_dT = maxdt;
            end
            %this function will simulate the SAW wave. At each iteration of
            %the spread, it will check to see if it hit a node. If so, it
            %will notify a counter.
            obj.detDistances();
            hitDistsT = obj.hitDist;
            
            [obj.R1 obj.node1] = min(hitDistsT);
            hitDistsT(obj.node1) = inf;
            [obj.R2 obj.node2] = min(hitDistsT);
            hitDistsT(obj.node2) = inf;
            [obj.R3 obj.node3] = min(hitDistsT);
            
            %perform for the rest of the nodes for redundancy
            %To improve accuracy, triangulaization can be performed on many
            %different nodes, such as:
            %R1, R2, R3
            %R1, R2, R4
            %R2, R3, R4
            %etc and the answer which appears the most is the most
            %optimized
            %
            %This will remedy the anomali situations where the circles
            %converge on 2+ points at the same time.
            
            %             hitDistsT(obj.node3) = inf;
            %             [obj.R4 obj.node4] = min(hitDistsT);
            %             hitDistsT(obj.node4) = inf;
            %             [obj.R5 obj.node5] = min(hitDistsT);
            %             hitDistsT(obj.node5) = inf;
            %             [obj.R6 obj.node6] = min(hitDistsT);
            %             hitDistsT(obj.node6) = inf;
            %             [obj.R7 obj.node7] = min(hitDistsT);
            %             hitDistsT(obj.node7) = inf;
            %             [obj.R8 obj.node8] = min(hitDistsT);
            %             hitDistsT(obj.node7) = inf;
            
            
            t1 = obj.R1/obj.v;
            %in an actual prototype, dT2 and dT3 would be given
            %But here we have to derive them based on Time = Dist/Rate
            obj.dT2 = obj.R2/obj.v - t1;
            obj.dT3 = obj.R3/obj.v - t1;
            
            obj.t1_REF = t1;
            
            withinLimits = obj.checkIfImpactWithinSensor();
        end
        
        function highlightNodes(obj)
            plot(obj.nodes(obj.node1,1),obj.nodes(obj.node1,2),'g*',...
                obj.nodes(obj.node2,1),obj.nodes(obj.node2,2),'g*',...
                obj.nodes(obj.node3,1),obj.nodes(obj.node3,2),'g*')
            obj.addframe();
        end
        
        function pickImpact(obj)
            obj.registerHit(ginput(1));
        end
        
        function testImpact(obj,x,y)
            if nargin == 1
                obj.registerHit([.5 .5]);
            else
                obj.registerHit([x, y]);
            end
        end
        
        function randomImpact(obj)
            obj.registerHit([obj.maxX*rand, obj.maxY*rand]);
        end
    end
    
end

