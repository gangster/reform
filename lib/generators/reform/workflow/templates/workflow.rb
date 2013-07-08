module Workflows
  class <%= class_prefix %>Workflow
    attr_reader :form, :params

    def initialize(form, params)
      @form = form
      @params = params
    end

    def process
      if form.validate(params)
        form.save do |data, map|
          if form.<%= name %>.new_record?
            <%= name %> = ::Services::<%= class_prefix %>Crud.new(map[:<%= name %>]).create
          else
            <%= name %> = ::Services::<%= class_prefix %>Crud.new(map[:<%= name %>]).update(form.<%= name %>.id)
          end

          yield <%= name %> if block_given?
        end
      end
    end

  end
end
