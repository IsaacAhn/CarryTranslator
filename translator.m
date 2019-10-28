% translator.m
% GUI ��� ��ȭ�ν� ���α׷�
function translator(net, netLSTM)

% ���� ���� ����
clear k;
global k;
m = 0;

% googleNet input ����
netCNN = googlenet;
inputSize = netCNN.Layers(1).InputSize(1:2);
layerName = "pool5-7x7_s1";

% Ű��Ʈ �ʱ�ȭ
colorVid = videoinput('kinect', 1);
depthVid = videoinput('kinect', 2);

% ���̷��� �ν��� ���� depth ķ
triggerconfig(depthVid, 'manual');
depthVid.FramesPerTrigger = 1;
depthVid.TriggerRepeat = inf;
set(getselectedsource(depthVid), 'TrackingMode', 'Skeleton');

% color ķ �ʱ�ȭ
triggerconfig(colorVid, 'manual');
colorVid.FramesPerTrigger = 1;
colorVid.TriggerRepeat = inf;

% �Լ��� ���� Ÿ�̸� ����
t2 = timer('Period', 0.1,'ExecutionMode', 'fixedRate');
t2.TimerFcn = @dispDepth2;
t = timer('Period', 0.1,'ExecutionMode', 'fixedRate');
t.TimerFcn = @dispDepth;
t3 = timer('Period', 10,'ExecutionMode', 'fixedRate');
t3.TimerFcn = @speechfc;

% GUI �����ӿ�ũ ����
window=figure('Color',[0.9255 0.9137 0.8471],'Name','Depth Camera',...
    'DockControl','off','Units','Pixels',...
    'toolbar','none',...
    'Position',[50 50 800 600]);

% ��ȭ ���� ���â ����
b = uicontrol('Parent',window,'Style','text');
set(b,'String','��ȭ ���� ���','position',[150 150 250 80])
b.BackgroundColor = 'black';
b.ForegroundColor = 'white';
b.FontName = 'Dotum';
b.FontSize = 30;

% STT ���â ����
c = uicontrol('Parent',window,'Style','text');
set(c,'String','���� �ν� ���','position',[450 150 250 80])
c.BackgroundColor = 'black';
c.ForegroundColor = 'white';
c.FontName = 'Dotum';
c.FontSize = 30;

% ��ȭ�� �ν��ϱ� ���� ��ư ����
startb1=uicontrol('Parent',window,'Style','pushbutton','String',...
    '��ȭ',...
    'FontSize',11 ,...
    'Units','normalized',...
    'Position',[0.1 0.02 0.16 0.08],...
    'Callback',@startCallback);

% ������ �ν��ϱ� ���� ��ư ����
startb=uicontrol('Parent',window,'Style','pushbutton','String',...
    '����',...
    'FontSize',11 ,...
    'Units','normalized',...
    'Position',[0.3 0.02 0.16 0.08],...
    'Callback',@startCallback2);

% ���α׷��� ���߱� ���� ��ư ����
stopb=uicontrol('Parent',window,'Style','pushbutton','String',...
    'STOP',...
    'FontSize',11 ,...
    'Units','normalized',...
    'Position',[0.5 0.02 0.16 0.08],...
    'Callback',@stopCallback);

% ���� �ν��� �ϱ� ���� ��ư ����
speechb=uicontrol('Parent',window,'Style','pushbutton','String',...
    '���ϱ�',...
    'FontSize',11 ,...
    'Units','normalized',...
    'Position',[0.7 0.02 0.16 0.08],...
    'Callback',@speechCallback);

% ����ġ �Լ� ����
    function speechfc(obj, event)
        % ���� ����
        recObj = audiorecorder(44100, 16, 1);
        speechObject = speechClient('Google','languageCode','ko-KR');
        disp('Start speaking.')
        recordblocking(recObj, 5);
        disp('End of Recording.')
        
        % ������ ������ ���Ϸ� ������ load
        filename = 'sample.wav';
        y = getaudiodata(recObj);
        audiowrite(filename, y, 48000);
        [samples, fs] = audioread('sample.wav');
        
        % ���� ������ STT�� ������
        outInfo = speech2text(speechObject, samples, fs);
        result = outInfo.Transcript;
        set(c,'String', result,'position',[450 150 250 80])
    end

% ��ȭ �Լ�
    function dispDepth(obj, event)
        
        % ���� ���(0~4096 �� ������ ������)
        trigger(depthVid);
        trigger(colorVid);
        [depthMap, ~, depthMetaData] = getdata(depthVid);
        [colorFrameData] = getdata(colorVid);
        idx = find(depthMetaData.IsSkeletonTracked);
        subplot(2,2,1);
        imshow(colorFrameData);
        
        % ���� ó��
        % ���̷��� ������ ���� ��
        if idx ~= 0
            % ������ ��ġ ����
            rightHand = depthMetaData.JointDepthIndices(12,:,idx);
            
            % ������ �����Ͱ� ����
            zCoord = 1e3*min(depthMetaData.JointWorldCoordinates(12,:,idx));
            radius = round(90 - zCoord / 50);
            rightHandBox = [rightHand-0.5*radius 1.2*radius 1.2*radius];
            
            % �簢������ ������ ũ��
            rectangle('position', rightHandBox, 'EdgeColor', [1 1 0]);
            handDepthImage = imcrop(colorFrameData,rightHandBox);
            
            % ������ ������ ���� ��
            if ~isempty(handDepthImage)
                temp = imresize(handDepthImage, [224 224]);
                
                % ���۳��� Ȱ���� ��� ����
                YPred = classify(net,temp);
                result = string(YPred);
                
                % tts ��� ���
                set(b,'String', result,'position',[150 150 250 80])
                tts(result)
            end
        end
    end

% ���� �Լ� ����
    function dispDepth2(obj, event)
        
        % ���� ���
        trigger(depthVid);
        trigger(colorVid);
        [depthMap, ~, depthMetaData] = getdata(depthVid);
        [colorFrameData] = getdata(colorVid);
        idx = find(depthMetaData.IsSkeletonTracked);
        subplot(2,2,1);
        imshow(colorFrameData);
        
        % ����ó��
        % ���̷��� ������ ���� ��
        if idx ~= 0
            
            % ô�� ��ġ ��� ��ݽ� ����
            body = depthMetaData.JointDepthIndices(3,:,idx);
            
            % �簢������ ��ݽ� ũ��
            radius = 300;
            bodyBox = [body(1)-0.75*radius body(2)-0.3*radius 1.5*radius radius];
            rectangle('position', bodyBox, 'EdgeColor', [1 1 0]);
            bodyImage = imcrop(colorFrameData,bodyBox);
            
            % ũ���� ���� ��
            if ~isempty(bodyImage)
                
                % timer �Լ��� �Ҹ� ������ m����
                m=m+1;
                
                % �̹��� ������¡ �� ����
                k(:,:,:,m)= uint8(imresize(bodyImage,[300,450]));
                
                % 10���������� 3�� ����
                if(m==30)
                    
                    % ������ �̹����� ������ ����
                    video = centerCrop(k,inputSize);
                    
                    % ������ ���۳ݿ� �˸��� �����ͷ� ��ȯ
                    sequences{1}= activations(netCNN,video,layerName,'OutputAs','columns');
                    
                    % ���۳��� Ȱ���� ��� ����
                    YPred = classify(netLSTM,sequences);
                    result = string(YPred);
                    
                    % tts�� ��� ���
                    set(b,'String', result,'position',[150 150 250 80])
                    tts(result)
                    
                    m=0;
                end
            else
                m=0;
            end
        end
    end

% �� ��ɿ� ���� callback �Լ� ����
    function startCallback2(obj, event)
        start(depthVid);
        start(colorVid);
        start(t2);
    end

    function startCallback(obj, event)
        start(depthVid);
        start(colorVid);
        start(t);
    end

    function stopCallback(obj, event)
        stop(depthVid);
        stop(colorVid);
        stop(t);
        stop(t2);
    end

    function speechCallback(obj, event)
        start(t3);
        stop(t3);
    end
end

% ���� ������¡ �Լ� ����
function videoResized = centerCrop(video,inputSize)

% ���� ������ ����
sz = size(video);

% ������ ǳ���� ��
if sz(1) < sz(2)
    idx = floor((sz(2) - sz(1))/2);
    video(:,1:(idx-1),:,:) = [];
    video(:,(sz(1)+1):end,:,:) = [];
    
    % ������ �ι��� ���� ��
elseif sz(2) < sz(1)
    
    idx = floor((sz(1) - sz(2))/2);
    video(1:(idx-1),:,:,:) = [];
    video((sz(2)+1):end,:,:,:) = [];
end

% ���� ������ ��ȯ
videoResized = imresize(video,inputSize(1:2));

end

