% speech2text.m
% STT(Speech To Text) ��� ���� �Լ�
function tableOut = speech2text(connection, y, fs, varargin)

% Connection�� �ǰ�, �ش� class-type�� �´��� Ȯ��
assert(~isempty(connection) && isa(connection, 'BaseSpeechClient') && isvalid(connection), ...
    'The first input to the speech2text function should be a speechClient object');

% timeout �⺻�� ����
timeOut = 10;

% HTTP�� timeout ���� ������
if ~isempty(varargin)
    validatestring(varargin{1},{'HTTPTimeOut'});
    timeOut = varargin{2};
end

% speechClient�� ���� STT �Լ��� �ҷ���
tableOut = connection.speechToText(y,fs,timeOut);

end
