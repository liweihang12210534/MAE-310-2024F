%HW4（2）b
%%
% 
% $$e^{\pi i} + 1 = 0$$
% 
clear all;clc % clean the memory and screen
error=zeros(1,7);h1=zeros(1,7);error2=zeros(1,7);
for i=1:7
% Define the external source or force and boundary data
f = @(x) -20*x.^3; % f(x) = x
g = 1.0;           % u    = g  at x = 1
h = 0.0;           % -u,x = h  at x = 0

% Setup the mesh
pp   = 2;              % polynomial degree
n_en = pp + 1;         % number of element or local nodes
n_el = 2*i;              % number of elements
n_np = n_el * pp + 1;  % number of nodal points
n_eq = n_np - 1;       % number of equations
n_int = 10;

hh = 1.0 / (n_np - 1); % space between two adjacent nodes
h1(1,i)=h1(1,i)+hh;
x_coor = 0 : hh : 1;   % nodal coordinates for equally spaced nodes

IEN = zeros(n_el, n_en);

for ee = 1 : n_el
  for aa = 1 : n_en
    IEN(ee, aa) = (ee - 1) * pp + aa;
  end
end

% Setup the ID array for the problem
ID = 1 : n_np;
ID(end) = 0;

% Setup the quadrature rule
[xi, weight] = Gauss(n_int, -1, 1);

% allocate the stiffness matrix
K = zeros(n_eq, n_eq);
F = zeros(n_eq, 1);

for ee = 1 : n_el
  
  k_ele = zeros(n_en, n_en); % allocate a zero element stiffness matrix
  f_ele = zeros(n_en, 1);    % allocate a zero element load vector

  x_ele = x_coor(IEN(ee,:));

  for qua = 1 : n_int
    
    dx_dxi = 0.0;
    x_l = 0.0;
    for aa = 1 : n_en
      x_l = x_l + x_ele(aa) * PolyShape(pp, aa, xi(qua), 0);
      dx_dxi = dx_dxi + x_ele(aa) * PolyShape(pp, aa, xi(qua), 1);
    end
    dxi_dx = 1.0 / dx_dxi;

    for aa = 1 : n_en
      f_ele(aa) = f_ele(aa) + weight(qua) * PolyShape(pp, aa, xi(qua), 0) * f(x_l) * dx_dxi;
      for bb = 1 : n_en
        k_ele(aa, bb) = k_ele(aa, bb) + weight(qua) * PolyShape(pp, aa, xi(qua), 1) * PolyShape(pp, bb, xi(qua), 1) * dxi_dx;
      end
    end
  end
 
  % check the ID(IEN(ee, aa)) and ID(IEN(ee,bb)), if they are positive
  % put the element stiffness matrix into K
  for aa = 1 : n_en
    P = ID(IEN(ee,aa));
    if(P > 0)
      F(P) = F(P) + f_ele(aa);
      for bb = 1 : n_en
        Q = ID(IEN(ee,bb));
        if(Q > 0)
          K(P, Q) = K(P, Q) + k_ele(aa, bb);
        else
          F(P) = F(P) - k_ele(aa, bb) * g; % handles the Dirichlet boundary data
        end
      end
    end
  end

  if ee == 1
    F(ID(IEN(ee,1))) = F(ID(IEN(ee,1))) + h;
  end
end

% Solve Kd = F equation
d_temp = K \ F;

disp = [d_temp; g];


%HW4 b
solution=@(x)x.^5;
dsolution=@(x)5*x.^4;
eup=0;edo=0;%设置相对误差的上下两项
eup2=0;edo2=0;
for ee = 1 : n_el
  
  
 

  x_ele = x_coor(IEN(ee,:));
eupt=0;edot=0;eupt2=0;edot2=0;
  for qua = 1 : n_int
    uh=0;uxh=0;
    dx_dxi = 0.0;
    x_l = 0.0;
    for aa = 1 : n_en
      x_l = x_l + x_ele(aa) * PolyShape(pp, aa, xi(qua), 0);
      dx_dxi = dx_dxi + x_ele(aa) * PolyShape(pp, aa, xi(qua), 1);
      
      
    end
    u=solution( x_l);
    ux=dsolution( x_l);
    dxi_dx = 1.0 / dx_dxi;

    for aa = 1 : n_en
      uh=uh+disp(IEN(ee,aa))*PolyShape(pp, aa, xi(qua), 0);
      uxh=uxh+disp(IEN(ee,aa))*PolyShape(pp, aa, xi(qua), 1);
    end
eupt=eupt+weight(qua)*((uh-u).^2)*dx_dxi;
edot=edot+weight(qua)*(u.^2)*dx_dxi;
eupt2=eupt2+weight(qua)*((dxi_dx*uxh-ux)).^2*dx_dxi;
edot2=edot2+weight(qua)*(ux.^2)*dx_dxi;
  end
  eup=eup+eupt;
  edo=edo+edot;
  eup2=eup2+eupt2;
  edo2=edo2+edot2;
end
e1=(eup.^0.5)/(edo.^0.5);
e2=(eup2.^0.5)/(edo2.^0.5);
error(1,i)=error(1,i)+e1;
error2(1,i)=error2(1,i)+e2;
end
figure(1)
plot(log(h1),log(error))
s1=polyfit(log(h1),log(error),1);
s2=polyfit(log(h1),log(error2),1);
figure(2)
plot(log(h1),log(error2))




% EOF