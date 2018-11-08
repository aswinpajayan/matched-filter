close all;
clear all;

%setting the parameters 
%let fs be the sampling frequency 
	fs = 10;
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
%modelling the low pass filter , taking the sampling freq(fs = 10) and tolerance = 0.001
	tolerance = 0.001
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
	k = 10000; %be the number of arbitrary symbols
	sk	= -1 + 2*(rand(1,k)>0.5);
	%sk_1 = zeros(1,2000);
	%sk_1(1:2:end) = sk;


%generating pulses to be transmitted . 
	mod_sig = [];
       for i = sk
      	 	mod_sig =[mod_sig i.*[p_trunc  zeros(1,N-length(p_trunc))]];
	endfor  
%%plotting the modulated signal for first five symbol durations 
       	figure;
		subplot(2,1,1)	
			plot(mod_sig(1:5*N));
			title("	first five symbols ");

%low pass filtering by h_n
	mod_sig_filtered = conv(h_trunc,mod_sig);
		subplot(2,1,2)
			plot(mod_sig_filtered(1:5*N));
			title("modulated signal after low pass filtering")
			print -djpg "modulatedsignal.jpg"			
%addition of  gaussian noise 
	len_tx_sig = length(mod_sig_filtered);
	tx_sig = zeros(5,len_tx_sig);
	len_tx_sig = length(mod_sig_filtered);
	variance_param = [0.1 0.2 0.5 0.8 1.0]; 
	%multiplication by this parameter changes amplitude of the gaussian noise
	for i = 1:5
		tx_sig(i,:) = mod_sig_filtered+ variance_param(i).*randn(1,len_tx_sig);
	endfor
%matched filter reciever 
	basis = conv(p_trunc,h_trunc);
	matched_filter = basis(end:-1:1); 
%decoding of symbols 
%		len_basis = length(basis)
%	sk_hat = conv(tx_sig(1,:),matched_filter);
%	figure;
%		subplot(2,1,1)
%			stem(sk_hat(2*N:length(p_trunc):11*N));
%			title("Estimated symbol s_^ k");
%		subplot(2,1,2)
%			stem(sk(1:10));
%			title("original transmitted symbols (first 10)");
%		print -dpng "symbol_detection.png"
	
	sk_hat = zeros(5,k);
	for i = 1:5
		matched_filter_out = conv(tx_sig(i,:),matched_filter);
		sk_hat(i,:) = -1 + 2.*(matched_filter_out(2*N:length(p_trunc):end-length(matched_filter))>0);
	end
%plotting symbols
	
	figure;
	subplot(2,1,1)
		stem(sk_hat(5,1:10));
		title("Estimated symbol ");
	subplot(2,1,2)
		stem(sk(1:10));
		title("original transmitted symbols (first 10)");
	print -dpng "symbol_detection.png"
%calculation of bit error rate
	error_rate = zeros(1,5);
	for i = 1:5
		error_rate(i) = sum((sk - sk_hat(i,1:k)) != 0) / k;
	end
	figure;
	plot(error_rate);

