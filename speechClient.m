% speechClient.m
% STT�� �����ϱ����� client ȣ�� �Լ�
function clientObj = speechClient(apiName,varargin)

% String�� valid üũ
narginchk(1,Inf);
validatestring(apiName,{'Google','IBM','Microsoft'},'speechClient','apiName');

% api�� type�� ���� �ҷ����� client�� �ٸ�
switch apiName
    case 'Google'
        clientObj = GoogleSpeechClient.getClient();
    case 'IBM'
        clientObj = IBMSpeechClient.getClient();
    case 'Microsoft'
        clientObj = MicrosoftSpeechClient.getClient();
end

% client object�� option ����
clientObj.clearOptions();
clientObj.setOptions(varargin{:});

end