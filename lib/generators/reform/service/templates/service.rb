module Services
  class <%= class_prefix %>Crud
    attr_accessor :post_params

    class << self
      delegate :find, to: <%= class_prefix %>
      delegate :all, to: <%= class_prefix %>

      def destroy(<%= name %>)
        <%= name %>.destroy
      end
    end

    def initialize(<%= name %>_params)
      @<%= name %>_params = <%= name %>_params
    end

    def create
      <%= name %> = <%= class_prefix %>.new(<%= name %>_params)
      ActiveRecord::Base.transaction do
        <%= name %>.save!
      end
      <%= name %>
    end

    def update(<%= name %>_id)
      ActiveRecord::Base.transaction do
        <%= name %> = <%= class_prefix%>.find(<%= name %>_id)
        <%= name %>.update!(<%= name %>_params)
        <%= name %>
      end
    end
  end
end
