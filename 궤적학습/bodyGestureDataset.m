% bodyGestureDataset.m
% GUI ��� ���� ���� ���� ���α׷�
function bodyGestureDataset()

% ���� ���� ����
clear x;
global x;

% Ű��Ʈ �ʱ�ȭ
% ���̷��� �ν��� ���� depth ķ
depthVid = videoinput('kinect', 2);
triggerconfig(depthVid, 'manual');
depthVid.FramesPerTrigger = 1;
depthVid.TriggerRepeat = inf;
set(getselectedsource(depthVid), 'TrackingMode', 'Skeleton');

% color ķ �ʱ�ȭ
colorVid = videoinput('kinect', 1);
triggerconfig(colorVid, 'manual');
colorVid.FramesPerTrigger = 1;
colorVid.TriggerRepeat = inf;

% �Լ��� ���� Ÿ�̸� ����
t = timer('TimerFcn', @dispDepth, 'Period', 0.1, ...
    'executionMode', 'fixedRate');

% GUI �����ӿ�ũ ����
window=figure('Color',[0.9255 0.9137 0.8471],'Name','Depth Camera',...
    'DockControl','off','Units','Pixels',...
    'toolbar','none',...
    'Position',[50 50 800 600]);

% ���� ���� ������ �����ϱ� ���� ��ư ����
startb=uicontrol('Parent',window,'Style','pushbutton','String',...
    'START',...
    'FontSize',11 ,...
    'Units','normalized',...
    'Position',[0.22 0.02 0.16 0.08],...
    'Callback',@startCallback);

% ���� ���� ������ ���߱� ���� ��ư ����
stopb=uicontrol('Parent',window,'Style','pushbutton','String',...
    'STOP',...
    'FontSize',11 ,...
    'Units','normalized',...
    'Position',[0.5 0.02 0.16 0.08],...
    'Callback',@stopCallback);

% ���� �ʱ�ȭ
i = 0;
m=0;

% ���̸� �����ֱ� ���� �Լ� ����
    function dispDepth(obj, event)
        
        % ���� ���(0~4096 �� ������ ������)
        trigger(colorVid);
        trigger(depthVid);
        [depthMap, ~, depthMetaData] = getdata(depthVid);
        [colorMetaData] = getdata(colorVid);
        idx = find(depthMetaData.IsSkeletonTracked);
        subplot(2,2,1);
        imshow(colorMetaData, [0 4096]);
        
        % ���� ó��
        % ���̷��� ������ ���� ��
        if idx ~= 0
            
            % ��ü ��ġ ����
            body = depthMetaData.JointDepthIndices(3,:,idx);
            
            % ��ü �����Ͱ� ����
            radius = 300;
            bodyBox = [body(1)-0.75*radius body(2)-0.3*radius 1.5*radius radius];
            
            % �簢������ ��ü ũ�� �� ȭ�鿡 ǥ��
            rectangle('position', bodyBox, 'EdgeColor', [1 1 0]);
            bodyImage = imcrop(colorMetaData,bodyBox);
            
            % ������ ������ ���� ��
            if ~isempty(bodyImage)
                
                m=m+1;
                x(:,:,:,m)= imresize(bodyImage,[300,450]);
                
                % 30 �������� �Ǿ��� �� ���� ������ ������ ����
                if(m==30)
                    i = i+1;
                    %���ϴ� ������ �Է��Ͽ� ����
                    outputVideo = VideoWriter(fullfile(strcat('��ȭ��������/����/����','_',num2str(i))));
                    outputVideo.FrameRate = 10;
                    open(outputVideo)
                    
                    for ii = 1:30
                        writeVideo(outputVideo,mat2gray(x(:,:,:,ii)));
                    end
                    
                    close(outputVideo)
                    m=0;
                end
            else
                m=0;
            end
        end
    end

% �� ��ɿ� ���� callback �Լ� ����
    function startCallback(obj, event)
        start(colorVid);
        start(depthVid);
        start(t);
    end

    function stopCallback(obj, event)
        stop(t);
        stop(colorVid);
        stop(depthVid);
        m=0;
    end
end

