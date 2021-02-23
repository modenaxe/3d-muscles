%_____________________________________________________________________
% Author: Luca Modenese, January 2015
% email: l.modenese@griffith.edu.au
%
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%
function StorageMatStruc = Storage2MatStruct(Storage_file)
% OpenSim suggested settings
import org.opensim.modeling.*
OpenSimObject.setDebugLevel(3);

OpenSimStorage = Storage(Storage_file);

% extract time
timeColumn = ArrayDouble();
OpenSimStorage.getTimeColumn(timeColumn);
for n_t = 0:timeColumn.getSize-1
    time_vec(n_t+1,1) = timeColumn.getitem(n_t);
end

% converting labels
OSLabelsArray = OpenSimStorage.getColumnLabels;
for n_lab = 0:OSLabelsArray.getSize-1
    StorageMatStruc.colheaders{n_lab+1} = char(OSLabelsArray.get(n_lab));
end

% converting data
dataColumn = ArrayDouble();
ind = 0;
while OpenSimStorage.getDataColumn(ind, dataColumn)
    for n_d = 0:dataColumn.getSize-1
        StorageData(n_d+1,ind+1) = dataColumn.getitem(n_d);
    end
    ind = ind+1;
end
StorageMatStruc.data = [time_vec, StorageData];

n_diff = size(StorageMatStruc.colheaders,2)-size(StorageMatStruc.data,2);

if n_diff>0 % issue that happened reading some state files
%     warning(['In the conversion ',num2str(n_diff),' more header(s) than data was found. Removing extra headers.'])
    answ = menu(['In the conversion ',num2str(n_diff),' more header(s) than data was found. Removing extra headers (y) or stop (n).'], 'Yes','No');
    if answ == 1
        StorageMatStruc.colheaders = StorageMatStruc.colheaders(1:size(StorageMatStruc.data,2));
    elseif answ == 2
        error('Please check your sto files manually.');
    end
end
end