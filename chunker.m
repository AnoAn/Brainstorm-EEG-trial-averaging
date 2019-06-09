%% script for creating and saving averages of epoch chunks in Brainstorm using the R201a Matlab version

cd '' %%% your Brainstorm directory

D = uigetdir('path containing your EEG data'); %%% select the subject and the folder with the epochs 
S = dir(fullfile(D));

% names of the conditions, as used in Brainstorm
conditions = {'NSp', 'NSw', 'PSp', 'PSw', 'NOp', 'NOw', 'POp' 'POw'}

% number of chunks in which to split the data
nChunks = 6

for x = conditions
target_condition = x{1}

tgt_files = {}
counter = 0
for k = 1:numel(S)
    N = S(k).name;
    if contains(N, target_condition)
        if contains(N, 'trial')
            counter = counter+1 
            tgt_files{counter} = N
        end
    end
end

% Input files - here the number 48, indicating whete to start with the
% name, was set manually, ergo, still needs automatization
sFiles = cellstr(strrep(S(1).folder(48:length(S(1).folder))+"/","\","/")+tgt_files');

length(sFiles)
int = fix(length(sFiles)/nChunks)
extra = mod(length(sFiles),nChunks)

for i = 1:nChunks
    target = (int*i+subplus(extra-subplus(extra-i)))
    if i == 1
        series = {1:target}
    else
        series(i) = {cont:target}
    end
    cont = target+1
end

assert(length(sFiles)==sum(cellfun('length',series)), 'error')

% set the string before and after the subject name
template = 'test_';
index1 = strfind(sFiles{1}, template) + length(template);
index2 = strfind(sFiles{1}, '_band');
ppnum = sFiles{1}(index1:index2-1)
SubjectNames = "pp"+ppnum+": "

for chk = 1:6
    % Process: Weighted Average: By trial group (subject average)
    sFiles2 = bst_process('CallProcess', 'process_average', sFiles(series{chk}), [], ...
        'avgtype',    6, ...  % By trial group (subject average)
        'avg_func',   1, ...  % Arithmetic average:  mean(x)
        'weighted',   1, ...
        'keepevents', 0);

    % Process: Set comment
    sFiles2 = bst_process('CallProcess', 'process_set_comment', sFiles2, [], ...
        'tag',           char(SubjectNames+target_condition+num2str(chk)), ...
        'isindex',       1);
    
    % Process: Move files: Chunks
    sFiles3 = bst_process('CallProcess', 'process_movefile', sFiles2, [], ...
        'subjectname', SubjectNames{1}(1:3), ...
        'folder',      'Chunks');
end

end
