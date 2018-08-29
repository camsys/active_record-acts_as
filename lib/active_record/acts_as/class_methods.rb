module ActiveRecord
  module ActsAs
    module ReflectionsWithActsAs
      def _reflections
        super.reverse_merge(acting_as_model._reflections)
      end
    end

    module ClassMethods
      def self.included(module_)
        module_.prepend ReflectionsWithActsAs
      end

      def validators_on(*args)
        super + acting_as_model.validators_on(*args)
      end

      def actables
        acting_as_model.where(actable_id: select(:id))
      end

      def respond_to_missing?(method, include_private = false)
        methods_callable_by_submodel = acting_as_model.methods_callable_by_submodel
        klass = acting_as_model.try(:acting_as_model)
        while klass
          methods_callable_by_submodel << klass.methods_callable_by_submodel
          klass = klass.try(:acting_as_model)
        end

        methods_callable_by_submodel.flatten.include?(method) || super
      end

      def method_missing(method, *args, &block)
        methods_callable_by_submodel = acting_as_model.methods_callable_by_submodel
        klass = acting_as_model.try(:acting_as_model)
        while klass
          methods_callable_by_submodel << klass.methods_callable_by_submodel
          klass = klass.try(:acting_as_model)
        end

        if methods_callable_by_submodel.flatten.include?(method)
          result = acting_as_model.public_send(method, *args, &block)
          if result.is_a?(ActiveRecord::Relation) # if its an activerecord result need to join through acts_as tree
            erd_hierarchy = []
            current_klass = acting_as_name.to_sym
            while current_klass.present?
              erd_hierarchy << current_klass
              current_klass =
                  begin
                    current_klass.to_s.classify.constantize.acting_as_name.to_sym
                  rescue
                    nil
                  end
            end

            if erd_hierarchy.count > 1
              idx = erd_hierarchy.length-2
              join_relations = Hash.new
              join_relations[erd_hierarchy[idx]] = erd_hierarchy[idx+1]
              idx -= 1
              while idx >= 0
                tmp = Hash.new
                tmp[erd_hierarchy[idx]] = join_relations
                join_relations = tmp
                idx -= 1
              end

              # unscoping the result being merged ensures the joins don't mess with the includes in the default_scope
              # manually eager_load these associations
              all.joins(join_relations).eager_load(join_relations).merge(result.unscoped)
            else
              all.joins(acting_as_name.to_sym).eager_load(join_relations).merge(result.unscoped)
            end
          else
            result
          end
        else
          super
        end
      end
    end
  end
end
