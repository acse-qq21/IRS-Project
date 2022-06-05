experiments = zeros(54,8);
number_of_experiments=54;
number_of_variables=8;
%creating the input variables for each kinetic plots
C_init = 0.001;     %ppb or ug L-1 - this is the initial concentration of aqueous sorbate in the suspension
q_init = 0;     %ppb or ug L-1 - this is the initial concentration of adsorbed sorbate in the suspension
Cs = 1;       %g L-1 - this is the concentration of sorbent
Cinfluent = 0;  %ppb or ug L-1 - this is the concentration of sorbate in the influent (for continuous-flow modelling)
j = 0;          %this the turn-over frequency, i.e. bed volumes per minute
k = 0.022;     %this is the value of normalised k' (L g-1 min-1)
KF = 5.10;      %this is the Freundlich constant (mg g-1) used to determine 'qe' at each time step
n = 2.63;       %this is the second parameter for the Freundlich adsorption isotherm (g L-1) used to determine 'qe' at each time step

%setting the time intervals upon which data is recorded
t_end = 4320;   %1440 = 1 day
t_steps = 2000;
t_step = t_end/t_steps;
bv_end = t_end*j;

for i = 1:54
    experiments(i,1) = C_init;
    experiments(i,2) = q_init;
    experiments(i,3) = j;
    experiments(i,4) = Cinfluent;
    experiments(i,5) = k;
    experiments(i,6) = Cs; %exponentially increasing sorbent concentration
    experiments(i,7) = KF;
    experiments(i,8) = n;   
end

experiments(1,1) = 40000;
experiments(2,1) = 20;
experiments(3,1) = 40;
experiments(4,1) = 60;
experiments(5,1) = 80;
experiments(6,1) = 100;
experiments(7,1) = 125;
experiments(8,1) = 150;
experiments(9,1) = 175;
for i=10:46
    experiments(i,1) = ((i-9)*50)+150;
end
%---------------------------------------------
for i=47:number_of_experiments
    experiments(i,1) = ((i-46)*500)+2000;
end

global exp
%setting up the formatting for printing results
results_table=[];
formatSpec = '';
formatSpec2 = '';
formatHeader = '';


for i = 1:1
    exp = zeros(1,number_of_variables);   
    exp(1,:) = experiments(i,:);
    exp_C_init = exp(1,1);
    exp_q_init = exp(1,2);
    tt=[0:t_step:t_end];
    
    
    [t,C]=ode45(@DiffEq,tt,[exp_C_init exp_q_init]);   %call the ODE function  %call the ODE function
    
   
    results_t(i,:) = t;
    results_bv(i,:) = results_t(i,:)*exp(1,3);
    results_Ct(i,:) = C(:,1);
    results_qt(i,:) = C(:,2);
    results_theta(i,:) = C(:,2)/(1000*exp(1,7));

    results_table = [results_table,results_t(i,:).',results_bv(i,:).',results_Ct(i,:).',results_qt(i,:).',results_theta(i,:).'];

    %print the results
    %formatSpec = strcat(formatSpec,'\r\n')
    fileID = fopen('file1.txt','w');
  

    formatHeader = '*';
    for j = 1:1
    formatHeader = strcat(formatHeader,'%-50.4f ');
    end
    
    %fprintf(fileID,strcat(formatHeader,'\r\n'),experiments(1,:));
    formatSpec2 = strcat(formatSpec2,'%10s %10s %10s %10s %10s\r\n');
    
    fprintf(fileID,formatSpec2,'t','BV','Ct','qt','theta');
    %formatSpec = strcat(formatSpec,'%10.3f %10.5f %10.3f %10.3f %10.8f');
    formatSpec = strcat(formatSpec,'%.5E %.5E %.5E %.5E %.5E');
    fprintf(fileID,strcat(formatSpec,'\r\n'),results_table.');
    fclose(fileID);

end 







function dCdt = DiffEq(t,conditions)
global exp

time=t;
j = exp(1,3);
Cinfluent = exp(1,4);
k = exp(1,5);
Cs = exp(1,6);
KF = exp(1,7);
n = exp(1,8);

Ct = conditions(1);   %ppb
qt = conditions(2);   %ppb
Ct_mgL = Ct/1000;     %mg L-1
qt_mgg = qt/(Cs*1000);    %mg g-1

dCdt=zeros(2,1);
%calculate dq/dt in ppb L-1 min-1
rate_ads = 1000*k*Ct_mgL*Cs*((1-(qt_mgg/(KF*(Ct_mgL^(1/n)))))^2); 
%calculate the rate of sorbate influx (continuous-flow systems only)
rate_influx = j*Cinfluent; 
%calculate the rate of sorbate outflux (continuous-flow systems only)
rate_outflux = j*Ct; 

dCdt(1)=-rate_ads+rate_influx-rate_outflux;
dCdt(2) = rate_ads/1000*Cs; 

end


