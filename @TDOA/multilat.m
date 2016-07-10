function multilat(obj,dt2,dt3)
if nargin == 1
    dt2 = obj.dT2;
    dt3 = obj.dT3;
end
v = obj.v;

n1 = obj.nodes(obj.node1,:); %radius is 0
n2 = obj.nodes(obj.node2,:); %radius is v*dt1
n3 = obj.nodes(obj.node3,:); %raidus is v*dt2

r1 = 0; %given
r2 = dt2*v;
r3 = dt3*v;

if obj.doPlots
    %show the inital circle conditions
    obj.plotInitalCircles();
end


incT = obj.inc;

x_1 = obj.nodes(obj.node1,1);
y_1 = obj.nodes(obj.node1,2);
x_2 = obj.nodes(obj.node2,1);
y_2 = obj.nodes(obj.node2,2);
x_3 = obj.nodes(obj.node3,1);
y_3 = obj.nodes(obj.node3,2);
tries = 1000;  %floor(increase_max./incT);
p = cell(1,4);
plot_incs = obj.plotIncs;
R_1 = r1; R_2 = r2; R_3 = r3;
if obj.doPlots
    hold on
end
obj.overHeadTime = toc(obj.overHeadTime);
time_cum = 0;
for k = 1:tries
    %Exact solutions to the 3-circle intercept equations. 6 possibilities
    %Assume no sensor overlap. Complex solutions imply no intercept.
    %Since the equations are second order polynomials, xys1 is solution
    %space for the (+) --- Analogous to the quadratic formula
    A = tic;
    
    [xys1 xys2] = TDOA.solveThreeCircles(x_1, x_2, x_3, y_1, y_2, y_3, ...
        R_1, R_2, R_3);
    
    if mod(k,plot_incs) == 0 && obj.doPlots
        p{1}(:,1) = xys1(:,1); %x1_12, x1_13, x1_23
        p{2}(:,1) = xys1(:,2); %y1_12, y1_13, y1_23
        p{3}(:,1) = xys2(:,1); %x2_12, x2_13, x2_23
        p{4}(:,1) = xys2(:,2); %y2_12, y2_13, y2_23
        obj.plotTriProgress(x_1,y_1,x_2,y_2,x_3,y_3,...
            R_1,R_2,R_3,p);
        pause(eps);
    end
    
    %p       - the increments index
    %p{n}(i) - For n = 1,2:
    %                 i = 1 is the x,y intercept of Circ 1,2 (first)
    %                 i = 2 is the x,y intercept of Circ 1,3 (first)
    %                 i = 3 is the x,y intercept of Circ 2,3 (first)
    %           - For n = 3,4:
    %                 i = 1 is the x,y intercept of Circ 1,2 (second)
    %                 i = 2 is the x,y intercept of Circ 1,3 (second)
    %                 i = 3 is the x,y intercept of Circ 2,3 (second)
    %
    % If p{n}{i} is imaginary, there is no solution.
    % i well be a be either 1,2,3 or 1,2,4 or 1,3,4, or 2,3,4
    % as one of the circles
    
    %p cells are used for plotting below:
    
    x1_12 = xys1(1,1); %p{1}(1)
    x1_13 = xys1(2,1); %p{1}(2}
    x1_23 = xys1(3,1); %p{1}(3}
    y1_12 = xys1(1,2); %p{2}(1}
    y1_13 = xys1(2,2); %p{2}(2}
    y1_23 = xys1(3,2); %p{2}(3}
    
    x2_12 = xys2(1,1); %p{3}(1)
    x2_13 = xys2(2,1); %p{3}(2)
    x2_23 = xys2(3,1); %p{3}(3)
    y2_12 = xys2(1,2); %p{4}(1)
    y2_13 = xys2(2,2); %p{4}(2)
    y2_23 = xys2(3,2); %p{4}(3)
    
    %Based on this solution, the first real intercept from the first
    %hit sensor will be the target location.
    
    X = [x1_12, x1_13, x1_23;
        x2_12, x2_13, x2_23];
    
    Y = [y1_12, y1_13, y1_23;
        y2_12, y2_13, y2_23];
    
    X = round(X./obj.inc).*obj.inc;
    Y = round(Y./obj.inc).*obj.inc;
    
    found = obj.findInterceptPt(X,Y);    
    %increase R's incrementally for each iteration.
    %this needs to be here to be within the tic/toc. Otherwise, at end.
    R_1 = R_1 + incT;
    R_2 = R_2 + incT;
    R_3 = R_3 + incT;
    
    B = toc(A);
    time_cum = time_cum + B;
    
    if found
        if obj.doPlots
            obj.registerHit(obj.hit); %register original hit again to make it more pronouced on graph.
            plot(X(found), Y(found), 'ro', 'LineWidth',5);
            obj.addframe();
            pause(eps)
        end
        obj.XY = [X(found), Y(found)];
        break
    end
end
obj.time = time_cum;
obj.loops = k;