%% Highway Assist System: Image Text-to-Speech Conversion
clc;
clear;
close all;

disp('--- Highway Assist System Started ---');

%% Step 1: Initialize External Camera
camlist = webcamlist;
disp('Available Cameras:');
disp(camlist);

cam = webcam(2);   
disp('External webcam initialized...');
cam.Resolution = '640x480';
pause(0.25);

%% Step 2: Capture Image from Webcam
img = snapshot(cam);
imshow(img);
title('Captured Highway Image');
disp('Image captured successfully.');

%% Step 3: Image Preprocessing (Clear, Natural)
grayImg = rgb2gray(img);                
grayImg = imgaussfilt(grayImg, 1);       
grayImg = imadjust(grayImg, [0.2 0.8]); 


sharpImg = imsharpen(grayImg, 'Radius', 2, 'Amount', 1);

figure;
imshow(sharpImg);
title('Preprocessed Image (Enhanced & Natural)');
disp('Image preprocessing complete.');

%% Step 4: OCR Text Extraction
ocrResult = ocr(sharpImg);
extractedText = strtrim(ocrResult.Text);
disp('--- Extracted Text ---');
disp(extractedText);

%% Step 5: Text-to-Speech using PowerShell (Offline)
if ~isempty(extractedText)
    textToSpeak = extractedText;
    tempTextFile = 'tempText.txt';
    fid = fopen(tempTextFile, 'wt');
    fprintf(fid, '%s', textToSpeak);
    fclose(fid);

    tempAudioFile = 'spokenText.wav';
    command = ['PowerShell -Command "Add-Type –AssemblyName System.Speech; ', ...
               '$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer; ', ...
               '$speak.SetOutputToWaveFile(''', tempAudioFile, '''); ', ...
               '$speak.Speak([System.IO.File]::ReadAllText(''', tempTextFile, '''));"'];
    system(command);

    [y, Fs] = audioread(tempAudioFile);
    player = audioplayer(y, Fs);
    disp('Speaking the extracted text...');
    playblocking(player);

    delete(tempTextFile);
    delete(tempAudioFile);
else
    disp('No text detected for speech synthesis.');
end

%% Step 6: Cleanup
clear cam;
disp('--- Process Completed Successfully ---');
