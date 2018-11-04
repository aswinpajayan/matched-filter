
close all;
clear all;
h1 = [1:4 4:-1:1];
[h2 w2] = freqz(h1);
figure
  subplot(2,1,1)
    stem(h1)
    title("first filter")
  subplot(2,1,2)
    plot(w2,abs(h2));
    h_new= fftshift(h1);
  title("frequncy response of first filter");
print -dpng "filter_1_chara.png"
figure
  subplot(2,1,1)

    stem(h_new) % plot for the shifted version of the input
    title("second filter")
  subplot(2,1,2)
    [h3 w3] = freqz(h_new);
    plot(w2,abs(h3));
  title("frequency response of second_filter");
print -dpng "filter_2_chara.png"
