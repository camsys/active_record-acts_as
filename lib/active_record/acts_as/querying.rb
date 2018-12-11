module ActiveRecord
  module ActsAs
    module QueryMethods
      def where!(opts, *rest)
        if acting_as? && opts.is_a?(Hash)

          if table_name_opts = opts.delete(table_name)
            opts = opts.merge(table_name_opts)
          end

          # Filter out the conditions that should be applied to the `acting_as_model`, which are
          # those that neither target specific tables explicitly (where the condition value
          # is a hash or the condition key contains a dot) nor are attributes of the submodel.
          opts, acts_as_opts = opts.stringify_keys.partition do |k, v|
            v.is_a?(Hash) ||
                k =~ /\./     ||
                column_names.include?(k.to_s) ||
                attribute_method?(k.to_s)
          end.map(&:to_h)

          acting_as_temp = try(:acting_as_model)
          while acting_as_temp.present?


            # Filter out the conditions that should be applied to the `acting_as_model`, which are
            # those that neither target specific tables explicitly (where the condition value
            # is a hash or the condition key contains a dot) nor are attributes of the submodel.
            acts_as_opts, acting_as_temp_opts = acts_as_opts.stringify_keys.partition do |k, v|
              v.is_a?(Hash) ||
                  k =~ /\./     ||
                  acting_as_temp.column_names.include?(k.to_s) ||
                  acting_as_temp.attribute_method?(k.to_s)
            end.map(&:to_h)

            if acts_as_opts.any?
              opts[acting_as_temp.table_name] = acts_as_opts
            end

            acting_as_temp = acting_as_temp.try(:acting_as_model)
            acts_as_opts = acting_as_temp_opts
          end
        end

        super opts, *rest
      end
    end

    module ScopeForCreate
      # for v = version and 5.2.0 <= v < 5.2.2 you could pass in an attributes but that has since been removed
      def scope_for_create(attributes = nil)
        activerecord_version = ActiveRecord.version.to_s

        if activerecord_version.include?('5.2.') && activerecord_version.split('.').last.to_i < 2
          scope = super(attributes)
        else
          scope = where_values_hash
        end
        if acting_as?
          scope.merge!(where_values_hash(acting_as_model.table_name))
        end
        scope.merge(create_with_value)
      end
    end
  end

  Relation.send(:prepend, ActsAs::QueryMethods)
  Relation.send(:prepend, ActsAs::ScopeForCreate)
end
