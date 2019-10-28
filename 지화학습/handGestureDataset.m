% handGestureDataset.m
% GUI ��� ��ȭ �̹��� ���� ���α׷�
function handGestureDataset()

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
t = timer('TimerFcn', @dispDepth, 'Period', 0.05, ...
    'executionMode', 'fixedRate');

% GUI �����ӿ�ũ ����
window=figure('Color',[0.9255 0.9137 0.8471],'Name','Depth Camera',...
    'DockControl','off','Units','Pixels',...
    'toolbar','none',...
    'Position',[50 50 800 600]);

% ��ȭ �̹��� ������ �����ϱ� ���� ��ư ����
startb=uicontrol('Parent',window,'Style','pushbutton','String',...
    'START',...
    'FontSize',11 ,...
    'Units','normalized',...
    'Position',[0.22 0.02 0.16 0.08],...
    'Callback',@startCallback);

% ��ȭ �̹��� ������ ���߱� ���� ��ư ����
stopb=uicontrol('Parent',window,'Style','pushbutton','String',...
    'STOP',...
    'FontSize',11 ,...
    'Units','normalized',...
    'Position',[0.5 0.02 0.16 0.08],...
    'Callback',@stopCallback);

% ���� �ʱ�ȭ
i = 0;
m = 0;

% ���̸� �����ֱ� ���� �Լ� ����
    function dispDepth(obj, event)
        
        % ���� ���(0~4096 �� ������ ������)
        trigger(colorVid);
        trigger(depthVid);
        [depthMap, ~, depthMetaData] = getdata(depthVid);
        [colorMap, ~, colorMetaData] = getdata(colorVid);
        idx = find(depthMetaData.IsSkeletonTracked);
        subplot(2,2,1);
        imshow(depthMap, [0 4096]);
        
        % ���� ó��
        % ���̷��� ������ ���� ��
        if idx ~= 0
            
            % ������ ��ġ ����
            rightHand = depthMetaData.JointDepthIndices(12,:,idx);
            
            % ������ �����Ͱ� ����
            zCoord = 1e3*min(depthMetaData.JointWorldCoordinates(12,:,idx));
            radius = round(90 - zCoord / 50);
            rightHandBox = [rightHand-0.5*radius 1.2*radius 1.2*radius];
            
            % �簢������ ������ ũ�� �� ȭ�鿡 ǥ��
            rectangle('position', rightHandBox, 'EdgeColor', [1 1 0]);
            handColorImage = imcrop(colorMap,rightHandBox);
            result = rgb2gray(handColorImage);
            subplot(2,2,3);
            imshow(handColorImage, [0 4096]);
            
            % ������ ������ ���� ��
            if ~isempty(handColorImage)
                
                % ��� ��ó��
                imageSize = size(handColorImage);
                
                for k = 1:imageSize(1)
                    for j = 1:imageSize(2)
                        if handColorImage(k, j) > 2300
                            handColorImage(k, j) = 0;
                        end
                    end
                end
                
                % ��ȭ �̹����� ������ ����
                i = i+1;
                if (mod(i,5)==1)
                    %���ϴ� ���ڸ� �־ �н�
                    imwrite(imresize(handColorImage,[224,224]), strcat('hangeul/��/��_',num2str(m),'.png'),'png');
                    m=m+1;
                end
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

