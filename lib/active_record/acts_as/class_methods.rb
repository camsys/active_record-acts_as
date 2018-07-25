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
          if result.is_a?(ActiveRecord::Relation)
            all.joins(acting_as_name.to_sym).merge(result)
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
