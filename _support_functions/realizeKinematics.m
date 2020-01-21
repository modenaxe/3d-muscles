%_____________________________________________________________________
% Author: Luca Modenese, January 2015
% email: l.modenese@griffith.edu.au
%
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%
function state = realizeKinematics(osimModel, state, kinStorage, n_frame)
% TO DO
% this function is slow. I should pass in only a row of
% coordinates. That would eliminate the need of a n_frame as well.

% OpenSim suggested settings
import org.opensim.modeling.*
OpenSimObject.setDebugLevel(3);

% getting model coordinates and their number
coordsModel = osimModel.updCoordinateSet();
N_coordsModel = coordsModel.getSize();

        for n_StateCoord = 0:N_coordsModel-1
            
            %%%%%% updating pose of the model %%%%%
            coordColumValues = ArrayDouble();
            %extracting the column for the state variable of interest
            coordName =  coordsModel.get(n_StateCoord).getName();
            % 
            CoordInd_in_kinStorage = kinStorage.getColumnIndicesForIdentifier(coordName);
            if CoordInd_in_kinStorage.getSize==0
                currentCoordValue =  coordsModel.get(coordName).getDefaultValue;
            else
                kinStorage.getDataColumn(coordName,coordColumValues);
                % Value of the state variable at that frame
                currentCoordValue = coordColumValues.getitem(n_frame);
            end
            coordsModel.get(n_StateCoord).setValue(state,currentCoordValue);
            switch char(coordsModel.get(n_StateCoord).get_motion_type())
                case 'rotational'
                    % transform to radiant for angles
                    coordsModel.get(n_StateCoord).setValue(state,currentCoordValue*pi/180);
                case 'translational'
                    % not changing linear distances
                    coordsModel.get(n_StateCoord).setValue(state,currentCoordValue);
                case 'coupled'
                    error('motiontype ''coupled'' is not managed by this function');
                otherwise
                    error('motion type not recognized. Error due to OpenSim update?')
            end
        end
end