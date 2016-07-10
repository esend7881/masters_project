function [x1_12, y1_12, x1_13, y1_13, x1_23, y1_23,...
    x2_12, y2_12, x2_13, y2_13, x2_23, y2_23] = symbolicallySolveThreeCircles()
%This function is a reference. It shows how the exact solution is
%determined.
tic
syms x y r_d R_1 R_2 R_3 x_1 y_1 x_2 y_2 x_3 y_3 x_4 y_4 R_4
eq  = ' = 0 ';
eq1 = (x-x_1)^2 + (y-y_1)^2 - (R_1)^2; %#ok<*NODEF>
eq2 = (x-x_2)^2 + (y-y_2)^2 - (R_2)^2;
eq3 = (x-x_3)^2 + (y-y_3)^2 - (R_3)^2;
xT = x;
yT = y;

%%intersection of circles 1 and 2
x = solve([char(eq1-eq2),   eq],x); %#ok<*NASGU>
y = solve([char(eval(eq1)), eq],y);
x12 = simple(eval(x));
y12 = simple(y);
x = xT; y = yT;

%%Intersection of circles 1 and 3

x = solve([char(eq1-eq3),   eq],x);
y = solve([char(eval(eq1)), eq],y);
x13 = simple(eval(x));
y13 = simple(y);
x = xT; y = yT;

%%Intersections of Circles 2 and 3

x = solve([char(eq2-eq3),   eq],x);
y = solve([char(eval(eq2)), eq],y);
x23 = simple(eval(x));
y23 = simple(y);
x = xT; y = yT;

%%3 circles
x1_12 = x12(1);
y1_12 = y12(1);
x1_13 = x13(1);
y1_13 = y13(1);
x1_23 = x23(1);
y1_23 = y23(1);

x2_12 = x12(2);
y2_12 = y12(2);
x2_13 = x13(2);
y2_13 = y13(2);
x2_23 = x23(2);
y2_23 = y23(2);

toc

% xys1 = [x12(1) y12(1);
%         x13(1) y13(1);
%         x23(1) y23(1)];
% 
% xys2 = [x12(2) y12(2);
%         x13(2) y13(2);
%         x23(2) y23(2)];

% use ccode() to turn the results into a c/c++ expression.