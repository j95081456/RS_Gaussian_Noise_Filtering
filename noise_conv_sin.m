% ==========================================
% 高斯雜訊與正弦波卷積之驗證程式
% ==========================================

clear; clc; close all;

% 1. 參數設定
Fs = 1000;            % 取樣頻率 (Hz)
T = 200;              % 訊號總長度 (秒)
t = 0:1/Fs:T-1/Fs;    % 時間向量
f0 = 50;              % 正弦波頻率 (Hz)

% 2. 產生訊號
% 產生高斯白雜訊
noise = randn(size(t));

% 產生正弦訊號 (作為濾波器)
sine_wave = sin(2*pi*f0*t);

% 3. 執行卷積
% 使用 'same' 讓輸出長度與原訊號相同，方便對齊時間軸
% 除以 Fs 是為了做離散時間的積分正規化
conv_result = conv(noise, sine_wave, 'same') / Fs; 

% 4. 頻域分析 (快速傅立葉轉換 FFT)
N = length(t);
f = (0:N/2-1)*(Fs/N); % 建立頻率軸 (單邊)

% 計算單邊振幅頻譜
Noise_fft = abs(fft(noise))/N;      Noise_fft = Noise_fft(1:N/2);
Sine_fft = abs(fft(sine_wave))/N;   Sine_fft = Sine_fft(1:N/2);
Result_fft = abs(fft(conv_result))/N; Result_fft = Result_fft(1:N/2);

% 5. 繪圖驗證
figure('Name', '卷積驗證：高斯雜訊與正弦波', 'Position', [100, 100, 900, 700]);

% --- 圖 1：頻域視角 (驗證濾波效應) ---
subplot(2,1,1);
plot(f, Noise_fft, 'Color', [0.7 0.7 0.7]); hold on;
plot(f, Sine_fft, 'g', 'LineWidth', 1.5);
plot(f, Result_fft, 'b', 'LineWidth', 2);
title('頻域視角：驗證正弦波的帶通濾波效應');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
legend('原始高斯雜訊頻譜 (寬頻)', '正弦波頻譜 (脈衝)', '卷積後頻譜 (僅保留 f0 附近)', 'Location', 'best');
xlim([0 100]); % 只觀察 0 到 100 Hz 區間
grid on;

% --- 圖 2：時域視角 (驗證窄頻雜訊與包絡線) ---
subplot(2,1,2);
% 為了看清楚，我們只畫出其中一小段時間 (例如 0.5秒 到 1秒)
% idx = (t >= 0.5) & (t <= 1.0); 
  idx = (t >= 0) & (t <= T); 

plot(t(idx), noise(idx), 'Color', [0.8 0.8 0.8]); hold on;
plot(t(idx), conv_result(idx), 'b', 'LineWidth', 1.5);

% 使用 Hilbert 轉換提取卷積結果的「包絡線 (Envelope)」
envelope = abs(hilbert(conv_result));
plot(t(idx), envelope(idx), 'r--', 'LineWidth', 2);
plot(t(idx), -envelope(idx), 'r--', 'LineWidth', 2);

title('時域視角：驗證窄頻雜訊特徵 (隨機起伏的包絡線)');
xlabel('Time (s)'); ylabel('Amplitude');
legend('原始高斯雜訊', '卷積後訊號 (頻率為 f0)', '包絡線 (Rayleigh 分佈)', 'Location', 'best');
% xlim([0.5 1.0]);
  xlim([0 T]);
grid on;