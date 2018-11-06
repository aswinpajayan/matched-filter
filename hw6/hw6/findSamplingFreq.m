close all;
clear all;

%setting the parameters 
%let fs be the sampling frequency 
	fs = 1000;
	tolerance = 0.01;
%generating a pulse 
	t = -2:1/fs:2;
	p = exp(-pi*t.^2);
	figure;
		plot(t,p);
		title("pulse used for bpsk");
%finding the points at which amplitude goes beyond <tolerance specified>
	idx = lookup(p((fs*2)+1:end),tolerance);
	limit=t(idx+(fs*2));
	disp(["p at  "  num2str(limit) " is " num2str(exp(-pi*limit*limit))] )
	disp(["data rate = " num2str(1/limit) ])
	width = limit;
%need to truncate the pulse in the limits . 
	t_trunc = t((2*fs)-idx:(2*fs)+idx);
	p_trunc = p((2*fs)-idx:(2*fs)+idx);
	disp(["length of the sequence P_trunc = " num2str(length(p_trunc))])
%modelling the low pass filter , taking the same sampling freq(fs = 10) and tolerance = 0.01
	RC = 0.5;
	t = 0:1/fs:3;
	h = exp(-t/RC);
	idx = lookup(h,tolerance);
	h_trunc = h(1:idx);
	disp([" length of the sequence h at " num2str(fs) " and tolerance " num2str(tolerance) " is " num2str(length(h_trunc))])
	figure
		plot(t,h);
		title("low pass filter at sending end");
%calculating the value of 'N' , given Rb = 0.4 
	N = fs/0.4;
%generating random symbols for bpsk modulation
	sk = -1 + 2*(rand(1,1000)>0.5);
%generating pulses to be transmitted . 
	mod_sig = [];
       for i = sk
      	 	mod_sig =[mod_sig i.*[p_trunc  zeros(1,N-length(p_trunc))]];
	endfor  
%plotting the modulated signal for first five symbol durations 
       	figure;
		subplot(2,1,1)	
			plot(mod_sig(1:5*N));
			title("	first five symbols ");

%low pass filtering by h_n
	mod_sig_filtered = conv(h,mod_sig);
		subplot(2,1,2)
			plot(mod_sig_filtered(1:5*N));
			title("modulated signal after low pass filtering")
			print -djpg "modulated_signal.jpg"			
%addition of  gaussian noise 
	len_tx_sig = length(mod_sig_filtered);
	tx_sig = zeros(5,len_tx_sig);
	len_tx_sig = length(mod_sig_filtered);
	variance_param = [0.1 0.2 0.5 0.8 1.0];
	for i = 1:5
		tx_sig(i,:) = mod_sig_filtered + variance_param(i).*randn(1,len_tx_sig);
	endfor
%matched filter reciever 
	basis = conv(p_trunc,h_trunc);
	matched_filter = basis(end:-1:1);
%decoding of symbols 
	matched_fil_out = conv(mod_sig_filtered,matched_filter);
	plot(matched_fil_out(1:5*N));
	s_hat_k = [];
	len_basis = length(basis)
	for i  = 1:length(sk)
		matched_fil_out = tx_sig(1,i:i+len_basis) 
		s_hat_k(i) = matched_fil_out(len_basis);
	endfor

