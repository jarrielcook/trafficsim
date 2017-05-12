function [inference, weights] = smie_coa(values, rules, output_mfs, universe)

weights = ones(1,length(rules));
numerator = 0;
denominator = 0;
for rule = 1:length(rules)
    % Compute the weight for rule k
    for input = 1:length(rules{rule})
        weights(rule) = min(weights(rule), rules{rule}{input}(values(input)));
    end
    
    % Include this rule in the num. and denom. summations
    numerator = numerator + sum(min(output_mfs{rule}, weights(rule)) .* universe);
    denominator = denominator + sum(min(output_mfs{rule}, weights(rule)));
end
% Compute the inference
inference = numerator / denominator;
