bias = 1000;
W = [0  0  0  1  0  0;
     1 -1  0  0  0  0;
     0  0  1  -1 0  0;];
 B = [bias; bias; bias;];
 
 % Read the first layer 
name = 'modified_controller_1.nt';

file = fopen(name,'r');
file_data = fscanf(file,'%f');
no_of_inputs = file_data(1);
no_of_outputs = file_data(2);
no_of_hidden_layers = file_data(3);
network_structure = zeros(no_of_hidden_layers+1,1);
pointer = 4;
for i = 1:no_of_hidden_layers
    network_structure(i) = file_data(pointer);
    pointer = pointer + 1;
end
network_structure(no_of_hidden_layers+1) = no_of_outputs;

subtract_from_bias = zeros(network_structure(1),1);

weight_matrix = zeros(network_structure(1), no_of_inputs);
bias_matrix = zeros(network_structure(1),1);

% READING THE INPUT WEIGHT MATRIX
for i = 1:network_structure(1)
    for j = 1:no_of_inputs
        weight_matrix(i,j) = file_data(pointer);
        subtract_from_bias(i) = subtract_from_bias(i) + bias * weight_matrix(i,j);
        pointer = pointer + 1;
    end
    bias_matrix(i) = file_data(pointer);
    pointer = pointer + 1;
end

fclose(file);

% Compute the change in bias due to offsetting 

new_bias = bias_matrix - subtract_from_bias;


file = fopen(name,'r');
file_data = fscanf(file,'%f');
fclose(file);



file = fopen('modified_controller_2.nt','w');

fprintf(file,'%d\n',6);

fprintf(file,'%d\n',1);

no_of_hidden_layers = file_data(3)+1;
fprintf(file,'%d\n',no_of_hidden_layers);

network_structure = zeros(no_of_hidden_layers+1,1);
network_structure(1) = 3;
fprintf(file, '%d\n', network_structure(1));

pointer = 4;
for i = 1:no_of_hidden_layers-1
    network_structure(i+1) = file_data(pointer);
    fprintf(file,'%d\n',file_data(pointer));
    pointer = pointer + 1;
end

network_structure(no_of_hidden_layers+1) = no_of_outputs;

x = ones(6, 1);


% READING THE INPUT WEIGHT MATRIX
for i = 1:network_structure(1)
    for j = 1:6
        fprintf(file,'%d\n',W(i,j));
    end
    fprintf(file,'%d\n',B(i));
end

size(W)
size(B)
% Doing the input transformation
g = x;
g = W * g;
g = g + B(:);
g = do_thresholding(g);





weight_matrix = zeros(network_structure(2), network_structure(1));
bias_matrix = zeros(network_structure(2),1);

% READING THE INPUT WEIGHT MATRIX
for i = 1:network_structure(2)
    for j = 1:network_structure(1)
        weight_matrix(i,j) = file_data(pointer);
        fprintf(file,'%d\n',file_data(pointer));
        pointer = pointer + 1;
    end
    bias_matrix(i) = file_data(pointer);
    fprintf(file,'%d\n',new_bias(i));
    
    pointer = pointer + 1;
end
size(weight_matrix)
size(new_bias)
% Doing the input transformation

g = weight_matrix * g;
g = g + bias_matrix(:);
g = do_thresholding(g);









for i = 2:(no_of_hidden_layers)
    
    weight_matrix = zeros(network_structure(i+1), network_structure(i));
    bias_matrix = zeros(network_structure(i+1),1);
    size(weight_matrix)
    size(bias_matrix)
    % READING THE WEIGHT MATRIX
    for j = 1:network_structure(i+1)
        for k = 1:network_structure(i)
            weight_matrix(j,k) = file_data(pointer);
            fprintf(file,'%d\n',file_data(pointer));
            
            pointer = pointer + 1;
        end
        bias_matrix(j) = file_data(pointer);
        fprintf(file,'%d\n',file_data(pointer));
        
        pointer = pointer + 1;
    end
   
    % Doing the transformation
    g = weight_matrix * g;
    g = g + bias_matrix(:);
    g = do_thresholding(g);

end
% Some bogus inputs
offset = 0;
scale_factor = 0;
y = g-offset;
y = y * scale_factor;
fclose(file);


