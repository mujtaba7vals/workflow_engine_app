# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.human_enum_name(enum_name, enum_value)
    I18n.t("activerecord.attributes.#{model_name.i18n_key}.#{enum_name.to_s.pluralize}.#{enum_value}")
  end

  def self.inherited(subclass)
    super
    return if subclass.abstract_class? || subclass.base_class == ActiveRecord::InternalMetadata

    subclass.instance_eval do
      def multitenant?
        @multitenant
      end

      def multitenant
        @multitenant = true
      end

      def not_multitenant
        @multitenant = false
      end

      multitenant
    end

    trace = TracePoint.new(:end) do |tp|
      if tp.self == subclass
        trace.disable
        if subclass.multitenant?
          tp.self.instance_eval do
            default_scope { where(company_id: Company.current_id) }
          end
        end
      end
    end
    trace.enable
  end
end
